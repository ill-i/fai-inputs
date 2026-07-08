"""
A dispatching grammar to parse VOResource XML and to return records
for our registry schema.

Additionally, a second content handler creates concatenable individual
VOR records in XML for use in the OAI interface.
"""

import datetime
import re
import string
from xml import sax

from gavo import api
from gavo import base
from gavo import rsc
from gavo import stc
from gavo import utils
from gavo.grammars.customgrammar import CustomRowIterator
from gavo.protocols import oaiclient
from gavo.stc import bboxes
from gavo.utils import ElementTree
from gavo.utils import pgsphere
from gavo.utils import stanxml


# Set this to false to make the parsers skip all records that are
# not declared to belong to the ivo_managed set.
# That should be the right thing to
# do (except for validation records), but it turns out several
# registries don't set ivo_managed for records for which they are
# managing authority.  Until that's fixed, keep them; the quirk
# doesn't hurt much, few registries show anything on their PMH interfaces
# that the don't want to publish anyway.
QUIRK_INCLUDE_NON_MANAGED = True


# If VALIDATE_AUTHORITIES is  true, we only accept records when
# their authority is actually in their orginating registry's
# managedAuthorites set.  This is obviously important when
# harvesting without ivo_managed.  Right now, we are harvesting
# with ivo_managed, and so we rather turn this off, as managedAuthorites
# isn't as well curated as one may wish.
VALIDATE_AUTHORITIES = False

# Namespaces with fixed prefixes in RegTAP
FORCED_PREFIXES = {
	"http://www.openarchives.org/OAI/2.0/": "oai",
	"http://www.ivoa.net/xml/RegistryInterface/v1.0": "ri",
	"http://www.ivoa.net/xml/VORegistry/v1.0": "vg",
	"http://www.ivoa.net/xml/VOResource/v1.0": "vr",
	"http://purl.org/dc/elements/1.1/": "dc",
	"http://www.ivoa.net/xml/VODataService/v1.0": "vs",
	"http://www.ivoa.net/xml/VODataService/v1.1": "vs",
	"http://www.ivoa.net/xml/ConeSearch/v1.0": "cs",
	"http://www.ivoa.net/xml/SIA/v1.0": "sia",
	"http://www.ivoa.net/xml/SimpleImageAccess/v1.0": "sia",
	"http://www.ivoa.net/xml/SIA/v1.1": "sia",
	"http://www.ivoa.net/xml/SSA/v1.0": "ssap",
	"http://www.ivoa.net/xml/SSA/v0.4": "ssap",
	"http://www.ivoa.net/xml/SSA/v1.0": "ssap",
	"http://www.ivoa.net/xml/SSA/v1.02": "ssap",
	"http://www.ivoa.net/xml/SSA/v1.1": "ssap",
	"http://www.ivoa.net/xml/TAPRegExt/v1.0": "tr",
	"http://www.ivoa.net/xml/StandardsRegExt/v1.0": "vstd",
	"http://www.w3.org/2001/XMLSchema-instance": "xsi",
	"http://www.ivoa.net/xml/DocRegExt/v1": "doc",
}


# The "standard" STC the STC info from the publishers is conformed to
RR_STC = stc.parseSTCS("Time TT unit d\n"
	"Position ICRS BARYCENTER 0 0 unit deg\n"
	"Spectral BARYCENTER unit m\n"
	"Redshift OPTICAL")


def lowerNULL(aString):
	"""returns aString lower() or None if aString is None.
	"""
	if aString is None:
		return aString
	else:
		return aString.lower()


def _iterLoHi(intervals, point):
	"""helps STC generation.

	This will generate low/high pairs from STC intervals, falling back
	to making a null interval from point if that is given but no areas
	are there.
	"""
	if intervals:
		for i in intervals:
			# TODO: figure out how we want to do open limits.
			if i.lowerLimit and i.upperLimit:
				yield i.lowerLimit, i.upperLimit
	else:
		if point:
			yield point.value, point.value


# VOResource 1.1 deprecates some old 1.0 terms, and we map to the new ones.
RELATIONSHIP_TYPE_UPDATER = {
	'mirror-of': 'IsIdenticalTo',
	'service-for': 'IsServiceFor',
	'served-by': 'IsServedBy',
	'derived-from': 'IsDerivedFrom',
}

DATE_ROLE_UPDATER = {
	'representative': 'Collected',
	'creation': 'Created',
	'update': 'Updated',
	'collected': 'Collected',
}


################ OAI-PMH support

def _multiplexer(cls):
	"""a class decorator adding multiplexing ContentHandler methods.

	We don't care about signatures here, and we forbid keyword arguments.

	(all this is necessary since we have two content handlers, one of OAI-PMH
	and complete records, the other for generating rr records.)
	"""
	def getDistributor(methodName):
		def distribute(self, *args):
			try:
				for downstream in self.subordinates:
					getattr(downstream, methodName)(*args)
			except Exception as error:
				location = "(unknown)"
				if self.locator:
					location = "line %s, col %s"%(self.locator.getLineNumber(),
						self.locator.getColumnNumber())
				base.ui.notifyError("Error while parsing %s with arguments %s, at %s."
					"  The error is noted, but parsing will continue"
					" (see log for traceback)."%(
						self.sourceName, str(args), location))
				for downstream in self.subordinates:
					getattr(downstream, "notifyError", lambda x: True)(
						error)
		return distribute

	for methodName in ["startDocument",
			"endDocument", "startPrefixMapping", "endPrefixMapping",
			"startElement", "endElement", "startElementNS",
			"endElementNS", "characters", "ignorableWhitespace",
			"processingInstruction", "skippedEntity"]:
		setattr(cls, methodName,  getDistributor(methodName))
	return cls

# OAI Records is rather hacky -- we canonicalize the namespace prefixes and
# then store pre-made ivo_vor resource records in a database table.
# Particularly ugly is that the CanonicalPrefixes are kept outside
# the database, so that they could change while the canned records
# don't.  Ah well.  Let's see how much use the OAI-PMH interface
# of the full registry has, anyway
class OAIRecordsParser(oaiclient.OAIRecordsParser):
	"""a parser giving pre-formatted XML from incoming records.

	We derive from oaiclient's one because we want to filter out
	records not ivo_managed by the registry (sometimes), and we drop
	records not originating from the managing registry.
	"""
	def __init__(self, authorityChecker, canonicalPrefixes=None):
		self.authorityChecker = authorityChecker
		oaiclient.OAIRecordsParser.__init__(self, canonicalPrefixes)

	def shipout(self, role, record):
		# we do not want mirrored or otherwise unpublished records:
		if not QUIRK_INCLUDE_NON_MANAGED and 'ivo_managed' not in self.oaiSets:
			return
		# we manage no records at all, so suppress them.  We can hack on
		# the problem with an RE because we know the prefixes and that
		# oai:setSpec doesn't nest.
		if role=='oairecs':
			record["oaixml"] = re.sub(
				r"<oai:setSpec\s*>\s*ivo_managed\s*</oai:setSpec\s*>",
				"",
				record["oaixml"])

		# Use a few minutes back as rectimestamp to mitigate a race when
		# someone harvests us just while we're ingesting.
		record["recTimestamp"] = datetime.datetime.utcnow(
			)-datetime.timedelta(seconds=2000)
		oaiclient.OAIRecordsParser.shipout(self, role, record)

	def _end_oai_identifier(self, name):
		oaiclient.OAIRecordsParser._end_oai_identifier(self, name)
		if (VALIDATE_AUTHORITIES
				and not self.authorityChecker.isManagedByCurrent(self.ivoid)):
			# stop recording if the record doesn't come from the managing
			# registry
			self.writer = self.curXML = None

	endHandlers = oaiclient.OAIRecordsParser.endHandlers.copy()
	endHandlers["oai:identifier"] = _end_oai_identifier


# I'm "multiplexing" events coming from the parser so I have the
# relational registry *and* actual ivo_vor records for the
# OAI-PMH endpoint.
@_multiplexer
class ContentHandlerMultiplexer:
	"""A multiplexer for SAX content handlers.

	These objects are instanciated with one or more content handlers.
	Each event coming in will be propagated to all subordinate content
	handlers.

	The actual methods come from the decorator.
	"""
	locator = "unknown"

	def __init__(self, sourceName, *subordinates):
		self.sourceName = sourceName
		self.subordinates = subordinates
	
	def setDocumentLocator(self, locator):
		self.locator = locator
		for downstream in self.subordinates:
			downstream.setDocumentLocator(locator)


class AuthorityChecker:
	"""a facade to decide whether an RR comes from the responsible registry.

	A.C.s are constructed with a dictionary of authorities to their
	managigng registry's ivo-id, and the ivo-id of the "current" registry.
	They are then passed to the record parsers that use their
	managedByCurrent method to decide whether a resource comes from the
	originating registry.
	"""
	def __init__(self, managedAuths, currentRegistry):
		self.managedAuths = managedAuths
		self.currentRegistry = currentRegistry
	
	def isManagedByCurrent(self, ivoId):
		"""returns true if ivoId is managed by the current registry.

		Stray ivoIds (those that have no managing registry at all) are
		considered as being managed by the current registry.
		"""
		thisAuth = ivoId.split("/")[2]
		return (thisAuth not in self.managedAuths
				or self.managedAuths[thisAuth]==self.currentRegistry)



############ Making the RegTAP tables
# There's RelationalRecordParser for turning the VOResource XML into
# the various tables; an additional hack is required to handle the
# STC XML (this is what the BuildEtreeMixin does).
# Most of the actual mapping rules are given below (after "end hacks").

class BuildEtreeMixin:
	"""A mixin for sax content handlers that lets you temporarily
	switch off (almost) any parsing functionality and build an etree.

	This is used here for parsing embedded STC.

	This doesn't really work for mixed-content models since we only
	keep a single text content for each element.

	Basically, you call startRecording in your startElement method and pass
	some function taking the finished element Tree.
	
	After the element matching your start element has been processed, normal
	SAX processing commences.
	"""
	def startRecording(self, name, attrs, finishFunction):
		# A smallish hack: the root of the stack contains the handler
		# functions we need to restore (as good a place to keep them
		# as any other)
		self.__recordingStack = [
			(self.startElement, self.endElement),
			ElementTree.Element(name, dict(attrs.items()))]
		self.startElement = self.__recordElementStart
		self.endElement = self.__recordElementEnd
		self.__finishFunction = finishFunction

	def __restoreParseMethods(self, oldMethods):
		self.startElement, self.endElement = \
			oldMethods

	def __getAttributesDict(self, attrs):
		"""Returns the attributes in a dictionary, giving namespaced attribute
		names with their canonical prefixes.

		Oh, my.  All this is such a horrible nightmare.  I should decide
		to go all-namespaced or no-namespaced soon (which still wouldn't
		fix namespaced attribute values, though...)
		"""
		newAttrs = {}
		for key, value in attrs.items():
			if isinstance(key, tuple): # Namespaced, fix it
				ns, name = key
				if ns is None:
					key = name
				else:
					key = stanxml.NSRegistry.getPrefixForNS(ns)+":"+name
			newAttrs[key] = value
		return newAttrs

	def __recordElementStart(self, name, attrs):
		name = name.split(":")[-1]
		self.contentsStack.append([])
		self.__recordingStack.append(ElementTree.SubElement(
			self.__recordingStack[-1], name, self.__getAttributesDict(attrs)))
	
	def __recordElementEnd(self, name):
		res = self.__recordingStack.pop()
		res.text = "".join(self.contentsStack.pop())
		if len(self.__recordingStack)==1:
			self.__restoreParseMethods(self.__recordingStack.pop())
			self.__finishFunction(res)
			# the opening element still is on the stack, remove it
			self.elementStack.pop()


_XSI_TYPE_NAME = ElementTree.QName(stanxml.getPrefixInfo("xsi")[0], "type")


class RelationalRecordParser(oaiclient.RecordParser, BuildEtreeMixin):
	"""a SAX ContentHandler generating grammar input records from OAI/VOR
	instance documents.

	Basically, it is configured through the add<whatever> class
	method below.  See the docstring there on how to do this, and the,
	well, table definitions below.

	Some items requiring more logic are also defined manually
	as plain methods.

	RRPs are constructed with the ivorn of the registry the records came
	from, and a mapping of managed authorities to their registry ivorns.
	"""
	def __init__(self, authorityChecker, sourceName):
		self.authorityChecker = authorityChecker
		self.sourceName = sourceName
		self.prefixMap = {}
		self.originatingRegistry = self.authorityChecker.currentRegistry
		oaiclient.RecordParser.__init__(self)

	def _initialize(self):
		self.records = []
		self.rowdicts = []
		self.counters = {}
		self.pauseStack = []
		self.oaiSets = set()
		oaiclient.RecordParser._initialize(self)

	def notifyError(self, err):
		self._errorOccurred = True

	def shipout(self, role, record):
		# see _end_identifier for an explanation of the following condition
		if self.curIdentifier is None:
			return
		# ivo_managed records are actually "original" (for the others,
		# we might want to havest the validation at some point, but
		# we don't so far)
		if not QUIRK_INCLUDE_NON_MANAGED and 'ivo_managed' not in self.oaiSets:
			return
		# this allows things that want to temporarily suspend record generation
		# (to "ignore" an element and its children) to do that by pushing
		# something on the pauseStack
		if self.pauseStack:
			return

		# _start_header sets _isDeleted
		if self._isDeleted:
			# all rows for deleted records are shipped out in _end_record
			# (as it's quite possible we don't have a VOResource in a
			# deleted record at all.
			return

		self.accumulator.append((role, record))

	@property
	def embeddingName(self):
		"""gives the name attribute of the "parent" (one record up-stack).

		This is basically a service for referencing tables; I don't think
		we want more methods like this.
		"""
		return self.records[-2]["name"]

	def _addAttribute(self, name, value, normalize=False):
		"""sets the attribute name to value in the current record.

		value will be stripped (if string-valued) and turned to None if what's
		left is an empty string.

		If normalize is true, value will be lowercased if it is a string.
		"""
		if isinstance(value, str):
			value = value.strip()
		if not value:
			value = None

		if normalize:
			value = lowerNULL(value)

		self.records[-1][name] = value

	def _getAttribute(self, name, default=None):
		"""returns the value of name in the current record.

		If name doesn't exist, default is returned
		"""
		return self.records[-1].get(name, default)

	def _enterContentAsName(self, name, attrs, content):
		"""a generic implementation for _end_X methods that just do name=content
		"""
		self._addAttribute(name.lower(), content)

	def _enterNormalizedContentAsName(self, name, attrs, content):
		"""a generic implementation for _end_X methods that do name=content.lower()
		"""
		self._addAttribute(name.lower(), content.lower())

	def _addContentWithHash(self, name, attrs, content):
		name = name.lower()
		cur = self._getAttribute(name)
		if cur is None:
			self._addAttribute(name, content)
		else:
			self._addAttribute(name, "%s#%s"%(cur, content))

	def _addNormalizedContentWithHash(self, name, attrs, content):
		self._addContentWithHash(name, attrs, content.lower())

	# we need explicit control over the current namespace map due to
	# the stupid namespaced attributes.  Sigh.
	def startPrefixMapping(self, prefix, uri):
		self.prefixMap[prefix] = uri

	def endPrefixMapping(self, prefix):
		if prefix in self.prefixMap:
			del self.prefixMap[prefix]
	
	def normalizePrefix(self, colonedName):
		"""returns the prefix:name-form colonedName with prefix mapped to our
		standard ones.

		uncoloned names, unknown prefixes, and prefixes with unknown namespaces
		are left alone.
		"""
		if colonedName:
			parts = colonedName.split(":", 1)
			if len(parts)==2:
				newPrefix = FORCED_PREFIXES.get(
					self.prefixMap.get(parts[0]))
				if newPrefix is not None:
					return "%s:%s"%(newPrefix, parts[1])

		return colonedName


############################# individual element handlers
# (for when the generic stuff below doesn't do)

	def _start_record(self, name, attrs):
		# the OAI record is not really interesting to us (we go for ivo_vor
		# data).  However, we use it as a "transaction" separator.
		self._errorOccurred = False
		self._isDeleted = False
		self.accumulator = []
	
	def _end_record(self, name, attrs, content):
		# see _start_record; if an error has occurred while processing
		# the input, discard all rows that originated from the resource record.
		if self.curIdentifier:
			if self._errorOccurred:
				base.ui.notifyWarning("Resource record %s contained an error."
					"  Ignoring the whole record but continuing."%self.curIdentifier)

			elif self._isDeleted:
				# return an all-NULL record for resource to delete all traces
				# of the resource in the other tables; that record is then
				# removed in a postSource script of the data that uses this grammar.
				allNull = {"res_type": None}  # test instrumentation
				allNull["ivoid"] = self.curIdentifier
				self.rowdicts.append(('resource', allNull))

			else:
				self.rowdicts.extend(self.accumulator)

		del self.accumulator

	def _start_STCResourceProfile(self, name, attrs):
		def storeProfile(resETree):
			# here, our don't care-Attitude towards namespacees bites us:
			# we need to retrofit all tags with the stc namespace for
			# the STC-X machinery to recognize them.  This should probably
			# be fixed in the STC-X machinery.
			for node in utils.traverseETree(resETree):
				node.tag = ElementTree.QName(stc.STCNamespace, node.tag)

			if self.curIdentifier=="debugme":
				ElementTree.dump(resETree)

			try:
				ast = stc.parseFromETree(resETree)[0][1]
				ast = stc.conformTo(ast, RR_STC)

				for lo, hi in _iterLoHi(ast.timeAs, ast.time):
					self.shipout("stc_temporal", {
						"ivoid": self.curIdentifier,
						"time_start": stc.dateTimeToMJD(lo),
						"time_end": stc.dateTimeToMJD(hi),
					})

				for area in ast.areas:
					if hasattr(area, "asSMoc"):
						self.shipout("stc_spatial", {
							"ivoid": self.curIdentifier,
							"coverage": area.asSMoc(6)})

			except: # For now, don't worry about botched STC
				import traceback; traceback.print_exc()
				base.ui.notifyError("Bad STC spec in %s"%self.curIdentifier)

		# since this may be expensive, don't bother parsing or doing anything
		# if we throw everything away anyway.
		if self.curIdentifier is None:
			self.startRecording(name, attrs, lambda res: None)
		else:
			self.startRecording(name, attrs, storeProfile)

	def _end_identifier(self, name, attrs, content):
		# curIdentifier will be None unless the originating registry
		# actually manages the record.  curIdentifier being None
		# inhibits shipping out records.
		content = content.strip().lower()
		self.curIdentifier = content
		if (VALIDATE_AUTHORITIES
				and not self.authorityChecker.isManagedByCurrent(content)):
			self.curIdentifier = None

		# Here's an extra hack: I check the (unfortunate) status
		# attribute on resource, and I'm turning off record generation
		# if it's not active.  This should really be in _start_Resource,
		# but that's a container handler.  If we need more start method
		# trickery needed later, we should allow this kind of thing
		# in addContainerHandler.
		if self.elementStack[-1][0]=="Resource":
			# I'm Resource/identifier, not header/identifier
			if self.elementStack[-1][1]["status"]!="active":
				self._isDeleted = True

	def _end_accessURL(self, name, attrs, content):
		# We may want to handle multiple accessURLs by splitting up the
		# interface element later; for now, the last accessURL given wins.
		if self.elementStack[-1][0]=="Resource":
			# however, if the accessURL is the direct child of a Resource, it's
			# the URL of a DataCollection, and we just create a res_detail row.
			self.shipoutResDetail("/accessURL",
				content)
		else:
			self._addAttribute("url_use", lowerNULL(attrs.get("use")))
			self._addAttribute("access_url", content)

	def _end_name(self, name, attrs, content):
		if "ivo-id" in attrs:
			self._addAttribute("ivo-id", attrs["ivo-id"].lower())
		if "altIdentifier" in attrs:
			self._addAttribute("alt_identifier", attrs["altIdentifier"])
		self._addAttribute("name", content)
		
	def _end_source(self, name, attrs, content):
		if "format" in attrs:
			self._addAttribute("source_format", attrs["format"].lower())
		self._addAttribute("source_value", content)

	def _end_dataType(self, name, attrs, content):
		if "arraysize" in attrs:
			self._addAttribute("arraysize", attrs["arraysize"])
		self._addAttribute("type_system", attrs.get(_XSI_TYPE_NAME))
		self._addAttribute("datatype", content.strip().lower())

		if "extendedType" in attrs:
			self._addAttribute("extended_type", attrs["extendedType"])
		if "extendedSchema" in attrs:
			self._addAttribute("extended_schema", attrs["extendedSchema"])

	def _start_header(self, name, attrs):
		self._isDeleted = attrs.get("status", "").lower()=="deleted"
		self.oaiSets = set()
	
	def _end_setSpec(self, name, attrs, content):
		self.oaiSets.add(content)

	def _end_footprint(self, name, attrs, content):
		self._addAttribute("footprint_ivoid",
			lowerNULL(attrs.get("ivo-id", None)))
		self._addAttribute("footprint_url", content)

	def _start_creator(self, name, attrs):
		# see _end_creator on why we need to manually handle this
		self.records.append({})

	def _end_creator(self, name, attrs, content):
		"""creators are shipped out as any other container, but we
		collect the individual names in sequence for resource usage.
		"""
		toShip = self.records.pop()
		toShip.update({
			"role_ivoid": attrs.get("ivo-id"),
			"ivoid": self.curIdentifier,
			"role_name": toShip.pop("name", "<NOT GIVEN>"),
			"base_role": "creator"})
		self.shipout("res_role", toShip)

		if toShip.get("role_name"):
			cur = self._getAttribute("creator_seq")
			if cur is None:
				self._addAttribute("creator_seq", toShip["role_name"])
			else:
				self._addAttribute("creator_seq", "%s; %s"%(cur, toShip["role_name"]))

	# "manual" handling of relationship: We want to emit one row per
	# relatedResource rather than per relationship element; therefore,
	# memorize the type and, for safety, remove the attribute when
	# the relationship element is over.
	def _end_relationshipType(self, name, attrs, content):
		term = content.strip()
		self.curRelationshipType = RELATIONSHIP_TYPE_UPDATER.get(
			term, term)

	def _end_relationship(self, name, attrs, content):
		try:
			del self.curRelationshipType
		except AttributeError: # no relationshipType child, don't fail here
			pass
	
	# validationLevel can be a child of resource (cap_index=None)
	# or of capability (grab cap_index).
	def _end_validationLevel(self, name, attrs, content):
		try:
			rec = {"val_level": int(content),
				"validated_by": lowerNULL(attrs.get("validatedBy", None)),
				"ivoid": self.curIdentifier,
				"cap_index": getattr(self, "cap_index", None),
				}
		except ValueError: # weird stuff in content, ignore the element
			return
		self.shipout("validation", rec)

	# interface is an ugly fellow: There are "sample" interfaces in
	# StandardsRegExt records that don't belong to a capability.
	# We don't want these: they would destroy the important foreign
	# key relationship between interface and capability.
	# Hence, we check in interface whether we are in capability,
	# and if not, we stop element creation until we're out of
	# the bad interface; the actual handling is done in a container
	# handler for the "virtual" interface_in_capability element defined
	# below.
	def _start_interface(self, name, attrs):
		if self.getParentTag(depth=2)!="capability":
			self.pauseStack.append(None)
		return self._start_interface_in_capability(name, attrs)
	
	def _end_interface(self, name, attrs, content):
		self._end_interface_in_capability(name, attrs, content)
		if self.getParentTag()!="capability":
			self.pauseStack.pop()
			return

	def _end_version(self, name, attrs, content):
		# version can have an ivoid in TAPRegExt, which we immediately
		# emit to res_detail
		self._addAttribute("version", content)
		if "ivo-id" in attrs:
			self.shipoutResDetail(self.getPathToResource("version/@ivo-id"),
				attrs["ivo-id"], capIndex=getattr(self, "cap_index", None))

	def endDetailWithUnit(self, name, attrs, content):
		# TAPRegExt limits with optional units
		detailName = "/capability/%s/%s"%(self.getParentTag(), name)
		self.shipoutResDetail(detailName,
			content, capIndex=getattr(self, "cap_index", None))

		if "unit" in attrs:
			self.shipoutResDetail(detailName+"/@unit",
				attrs["unit"], capIndex=getattr(self, "cap_index", None))

	_end_hard = _end_default = endDetailWithUnit

	def _end_securityMethod(self, name, attrs, content):
		# We only collect securityMethods here; there's a hack turning
		# this list into authenticated_only and res_details rows.
		self.records[-1].setdefault("security_method_ids", []
			).append(attrs.get("standardID", None))

	def _end_kaputt(self, name, attrs, content):
		# test instrumentation
		raise ValueError(content)
	
	############### Diversions

	def divertSchema(self, name, attrs, content):
		# see if the schema element really is form StandardsRegExt rather
		# than VODataService; if it is, just make a res_details row
		if "namespace" in attrs:
			self.shipoutResDetail("/schema/@namespace",
				attrs["namespace"].lower())
			self.records.pop()
			return True

	############### Custom methods for particularly tricky res_details

	def _end_format(self, name, attrs, content):
		self.shipoutResDetail("/format", content.strip())
		self.shipoutResDetail("/format/@isMIMEType",
			attrs.get("isMIMEType", "false"))

	def _end_rights(self, name, attrs, content):
		self.shipoutResDetail("/rights", content.strip())
		if "rightsURI" in attrs:
			self.shipoutResDetail("/rights/@rightsURI", attrs["rightsURI"].strip())

		# if this is the first rights item, also add it to the
		# parent record (which better had be resource)
		if not "rights" in self.records[-1]:
			self.records[-1]["rights"] = content.strip()
			self.records[-1]["rights_uri"] = attrs.get("rightsURI")

	############### Generic methods for building the parser

	def shipoutResDetail(self, xpath, value, capIndex=None):
		self.shipout("res_detail", {
			"ivoid": self.curIdentifier,
			"cap_index": capIndex,
			"detail_xpath": xpath,
			"detail_value": value})
	
	def getPathToResource(self, name):
		"""returns the element names leading up to the enclosing ri:Resource.

		We need this to come up with xpaths for res_details.
		"""
		path = [name]
		for name, attrs in reversed(self.elementStack):
			if name=="Resource":
				return "/"+"/".join(reversed(path))
			path.append(name)
		raise ValueError("No xsi:typed elements above me")

	def _shipoutResDetailRowWithIvoid(self, baseXpath, capIndex, attrs, content):
		"""helps _makeCapDetailWithIvoId and _makeResDetailWithIvoId.
		"""
		content = content.strip()
		if content:
			self.shipoutResDetail(baseXpath, content, capIndex)
		if "ivo-id" in attrs:
			self.shipoutResDetail(baseXpath+'/@ivo-id',
				attrs["ivo-id"], capIndex)
		if "altIdentifier" in attrs:
			self.shipoutResDetail(baseXpath+"/@altIdentifier",
				attrs["altIdentifier"], capIndex)
	
	def _makeCapDetailWithIvoId(self, name, attrs, content):
		"""handles res_details for the TAPRegExt ivo-id'd quantities.

		This is generic enough to be probably applicable to similar
		constructs from other capabilities.
		"""
		self._shipoutResDetailRowWithIvoid(
			self.getPathToResource(name),
			self.cap_index, attrs, content)

	def _makeResDetailWithIvoId(self, name, attrs, content):
		"""generates res_details rows for ResourceNames in vr:Resource
		derviations.
		"""
		self._shipoutResDetailRowWithIvoid(
			self.getPathToResource(name),
			None, attrs, content)
		

	@classmethod
	def addContainerHandler(cls, name, attrMap={}, pythonMap={},
			translations=(), destRole=None,
			resetCounters=(), incrementCounter=None,
			hacks=(), addToParent=False,
			diversions=()):
		"""adds start/end methods for elements that generate
		records.

		name is the element and table name.

		attrMap is an optional dict mapping xml attribute names
		to column names (evaluated in the end handler); all values
		obtained in this way are lowercased.

		pythonMap is an optional dict mapping handler instance
		attribute names to column names (evaluated in the end handler); the
		values of the map are either attribute names or callables which
		will receive the element content.

		translations, a sequence of name pairs, gives from-to pairs of
		attributes to be renamed  in the current record before applying
		pythonMap.  Order obviously matters here.

		Using destRole, you can override the role the record will be
		added as (this defaults to name).

		All attributes in resetCounters will be set to 0 on startElement
		and deleted on endElement; an attribute named in incrementCounter
		is incremented on startElement.

		hacks can be a sequence of callables that will be passed the parser
		and the record to ship out; they can manipulate it in any devious way.

		Give addToParent=True to add the collected fields to the parent
		record rather than ship them out (this is for folding complex
		children into their parents).

		Diversions contains a list of method names.  Each method is called
		in sequence as if it were an end handler.  If it returns true, processing
		is aborted.  This is for cases like schema or interface, which are
		"re-used" for fairly different purposes in StandardsRegExt.
		"""
		attrItems = list(attrMap.items())
		pythonItems = list(pythonMap.items())
		if destRole is None:
			destRole = name

		def startMethod(self, name, attrs):
			newRec = {}
			for dest, src in attrItems:
				if src in attrs:
					newRec[dest] = attrs[src]
				else:
					newRec[dest] = None
			self.records.append(newRec)

			for counterName in resetCounters:
				setattr(self, counterName, None)

			if incrementCounter is not None:
				ct = getattr(self, incrementCounter)
				if ct is None:
					ct = 0
				setattr(self, incrementCounter, ct+1)
		
		def endMethod(self, name, attrs, content):
			for diversion in diversions:
				if getattr(self, diversion)(name, attrs, content):
					return
			toShip = self.records.pop()
			for fromName, toName in translations:
				if fromName in toShip:
					toShip[toName] = toShip.pop(fromName)

			for dest, src in pythonItems:
				try:
					if callable(src):
						toShip[dest] = src(content)
					else:
						toShip[dest] = getattr(self, src)
				except AttributeError:
					base.ui.notifyWarning("While parsing %s in %s: Missing parser"
						" attribute %s, ignoring %s element"%(
						self.curIdentifier, self.sourceName,
						src, name))
					return
			
			for hack in hacks:
				hack(self, toShip)
			
			if addToParent:
				self.records[-1].update(toShip)
			else:
				self.shipout(destRole, toShip)

			for counterName in resetCounters:
				delattr(self, counterName)
		
		setattr(cls, "_start_"+name, startMethod)
		setattr(cls, "_end_"+name, endMethod)

	@classmethod
	def addContentAdder(cls, elName, normalized=False):
		"""makes cls handle elName elements by setting their content as
		elName.lower() in the current record.

		if normalized is true, the value will be lowercased, too.
		"""
		if normalized:
			setattr(cls, "_end_"+elName, cls._enterNormalizedContentAsName)
		else:
			setattr(cls, "_end_"+elName, cls._enterContentAsName)

	@classmethod
	def addResDetailResMaker(cls, elName):
		"""installs a handler for handling elName by making a standard
		res_details row for a vr:Resource child.
		"""
		setattr(cls, "_end_"+elName, cls._makeResDetailWithIvoId)

	@classmethod
	def addResDetailCapMaker(cls, elName):
		"""installs a handler for handling elName by making a standard
		res_details row for a vr:Capability child.
		"""
		if "(" in elName:
			elName, xpath = re.match(r"([^(]*)\(([^)]*)\)", elName).groups()
			def handler(self, name, attrs, content):
				self._shipoutResDetailRowWithIvoid(xpath, self.cap_index,
					attrs, content)
		else:
			handler = cls._makeCapDetailWithIvoId
		setattr(cls, "_end_"+elName, handler)

	@classmethod
	def addHashAdder(cls, elName, normalize=True):
		"""makes cls handel elName elements by adding their content to
		a hash separated list of such values.
		"""
		if normalize:
			setattr(cls, "_end_"+elName, cls._addNormalizedContentWithHash)
		else:
			setattr(cls, "_end_"+elName, cls._addContentWithHash)


########### some hacks used below

def _parseStd(parser, record):
	# std is a boolean in VOR and an int relationally
	if "std" in record and record["std"]:
		record["std"] = base.parseBooleanLiteral(record["std"])
	else:
		record["std"] = None


def makeLowercaser(attrName):
	# returns a hack lowercasing the value of attrName
	def lowerAttr(parser, record):
		record[attrName] = lowerNULL(record.get(attrName))

	return lowerAttr


def mapDateRole(parser, record):
	# date/@role goes to value_role and is pushed through
	# DATE_ROLE_UPDATER to map 1.0 to 1.1 terms
	role = record.pop("role") or "Collected"
	record["value_role"] = DATE_ROLE_UPDATER.get(role, role).lower()


def makeRoleAdder(baseRole):
	# returns a function sticking baseRole into the record as base_role
	def addBaseRole(parser, record):
		record["base_role"] = baseRole

	return addBaseRole


def makeDetailXPathAdder(xpath):
	# returns a function sticking xpath into the record as detail_xpath
	def addXPath(parser, record):
		record["detail_xpath"] = xpath

	return addXPath


def makeDateParser(colName):
	# returns a function that tries (hard) to parse the content of
	# colName as a datetime.
	def parseADate(parser, record):
		try:
			record[colName] = utils.parseISODT(record[colName])
		except (ValueError, AttributeError):
			base.ui.notifyWarning("Bad datetime: %s in %s (%s)"%(record[colName],
				parser.curIdentifier, parser.sourceName))
			record[colName] = None

	return parseADate


def makeQNameNormalizer(colName):
	# returns a function that will change XML namespace prefixes in
	# colName to the "standard" ones from FORCED_PREFIXES as appropriate;
	# the entire name will also be lowercased.
	def normalizePrefix(parser, record):
		if record.get(colName):
			record[colName] = parser.normalizePrefix(record[colName]).lower()

	return normalizePrefix


def makeDefaulter(colName, default):
	# returns a function that adds a colName mapped to default if there's
	# no colName in the record yet.
	def addDefault(parser, record):
		if colName not in record:
			record[colName] = default
	
	return addDefault


def makeIntervalParser(prefix):
	# returns a function for filling the stc_(temporal|spectral)
	# tables: parse two floats out of a string and add prefix_start,
	# prefix_end keys to the record.
	def parsePair(parser, record):
		lower, upper = record["unparsed"].split()
		record[prefix+"start"] = float(lower)
		record[prefix+"end"] = float(upper)
	
	return parsePair


def createAuthenticatedOnly(parser, record):
	# This adds the authenticated_only column in records based
	# on the security method ids collected while parsing an interface.
	# Since this information is destroyed by emitSecurityMethodResDetail,
	# this hack has to run before it.
	smIds = record.get("security_method_ids", ())
	record["authenticated_only"] = bool(smIds and not None in smIds)


def emitSecurityMethodResDetail(parser, record):
	# This produces res_detail records from security methods sitting on
	# record.
	for smId in record.pop("security_method_ids", []):
		if smId is not None:
			parser.shipoutResDetail(
				"/capability/interface/securityMethod/@standardID",
				smId,
				capIndex=parser.cap_index)

def debug(*args):
	import pdb;pdb.set_trace()


############## Begin UAT hack
# remove this once there's sufficient UAT takeup.

from gavo.protocols import vocabularies
import os

def _load_to_uat_mapping():
	mapping = {}
	with open(os.path.join(
			base.getConfig("inputsDir"),
			"rr", "res", "uat-mapping.tsv")) as f:
		for l in f:
			l = l.rstrip("\n")
			if l:
				src, target = l.split("\t")
				if not target.startswith("ivoa:"):
					mapping[src] = target
	return mapping

UAT = vocabularies.get_vocabulary("uat")
TO_UAT = _load_to_uat_mapping()


# this is taken from uat2ivo from the vocabularies repo
def label_to_term(label:str):
    """returns an IVOA term for a label.

    "term" is the thing behind the hash.  It needs to consist of letters
    and a few other things exclusively.  We're replacing runs of one or
    more non-letters by a single dash.  For optics, we're also lowercasing
    the whole thing.

    ConceptMapping makes sure what's resulting is unique within the IVOA UAT.
    """
    return re.sub("[^a-z0-9]+", "-",
        label.lower())


def emitMappedSubject(parser, record):
	# this produces, until UAT is better taken up, UAT keywords in a separate
	# table.
	normalised = re.sub(r"\s+", " ", record.get("res_subject", None))
	if normalised is None:
		return
	as_identifier = label_to_term(normalised)

	if normalised in UAT["terms"]:
		uat_concept = normalised
	elif as_identifier in UAT["terms"]:
		uat_concept = as_identifier
	elif normalised in TO_UAT:
		uat_concept = TO_UAT[normalised]
	else:
		return

	parser.shipout("subject_uat", {
		"ivoid": parser.curIdentifier,
		"uat_concept": uat_concept})
			
################### End UAT hack
	
################### Begin extra stats hack

MIN_SINGLE = 1.17549435e-38
MAX_SINGLE = 3.4028235e38

def clamp_real(s):
	"""makes a float suitable for ingestion into real-valued postgres columns.

	We try to catch overflows (which become min/max-real) and underflows (which
	become zero) here.
	"""
	val = float(s)
	if val>0:
		if val<MIN_SINGLE:
			return 0
		elif val>MAX_SINGLE:
			return MAX_SINGLE
		else:
			return val
	
	else:
		if val>-MIN_SINGLE:
			return 0
		elif val<-MAX_SINGLE:
			return -MAX_SINGLE
		else:
			return val


_G_COLSTAT_NAME_MAP = {
	"fillFactor": "fill_factor",
	"max-value": "max_value",
	"min-value": "min_value",
	"median": "median",
	"percentile03": "percentile03",
	"percentile97": "percentile97",}

# remove this once g-colstat is history
def emitDaCHSStatistics(parser, record):
	# this produces records for rr.g_num_stat from DaCHS column metadata
	# We really want these attributes out of the column record; later
	# RegTAP will probably work differently from what we do here; hence,
	# just pull the attrs out of the column's endMethod.
	attrs = utils.stealVar("attrs")
	statsRec = {}

	for key, value in attrs.items():
		if value and key.startswith("{http://dc.g-vo.org/ColStats-1}"):
			statsRec[_G_COLSTAT_NAME_MAP[key[31:]]] = clamp_real(value)

	if statsRec:
		statsRec["ivoid"] = record["ivoid"]
		statsRec["table_index"] = record["table_index"]
		statsRec["name"] = record["name"]
		parser.shipout("g_num_stat", statsRec)


################### End extra stats hack

def debugOutput(parser, record):
	print("shipping out: %s"%repr(record))


########### end hacks

for elName in ["title", "shortName",
		"description", "referenceURL", "logo",
		"address", "email", "telephone", "unit",
		"wsdlURL", "regionOfRegard"]:
	RelationalRecordParser.addContentAdder(elName)

for elName in ["utype", "ucd",
		"arraysize", "delim", "resultType", "nrows"]:
	RelationalRecordParser.addContentAdder(elName, True)

for elName in ["type", "waveband", "contentLevel",
		"flag", "queryType"]:
	RelationalRecordParser.addHashAdder(elName)

for elName in ["mirrorURL"]:
	RelationalRecordParser.addHashAdder(elName, normalize=False)


for elName in [
# VOResource
		"testQueryString",
# SimpleDALRegExt
		"lat", "long", "extras", "verb", "ra", "dec", "sr", "maxRecords",
		"testQuery",
# SIAP
		"imageServiceType", "maxFileSize", "maxSR", "verbosity",
		"maxImageSize",
# SSAP
		"productType",
		"dataSource",
		"creationType",
		"supportedFrame",
		"complianceLevel", "maxSearchRadius",
		"defaultMaxRecords", "maxAperture", "queryDataCmd",
# TAPRegExt
		"outputFormat",
		"mime",
		"alias",
		"dataModel",
		"uploadMethod",
		"form",
# DocRegExt
		"locTitle",
		"languageCode",
		]:
	RelationalRecordParser.addResDetailCapMaker(elName)

	
for elName in [
# VOResource
# (custom code above for rights)
		"instrument", "facility",
# StandardRegExt
		"endorsedVersion", "deprecated",
# VORegistry
		"managedAuthority", "full", "managingOrg",
# VODataService
	# (custom code above for format and accessurl)
	"footprint",
	]:
	RelationalRecordParser.addResDetailResMaker(elName)


RelationalRecordParser.addContainerHandler("Resource",
	{"created": "created", "updated": "updated",
		"res_type": "{http://www.w3.org/2001/XMLSchema-instance}type"},
	{"ivoid": "curIdentifier", "harvested_from": "originatingRegistry"},
	translations=[
		("title", "res_title"),
		("type", "content_type"),
		("contentlevel", "content_level"),
		("regionofregard", "region_of_regard"),
		("description", "res_description"),
		("shortname", "short_name"),
		("version", "res_version"),
		("referenceurl", "reference_url")],
	destRole="resource",
	resetCounters=["table_index", "schema_index", "cap_index", "intf_index"],
	hacks=[makeDateParser("created"), makeDateParser("updated"),
		makeQNameNormalizer("res_type"), makeLowercaser("content_level"),
		makeLowercaser("content_type")])

RelationalRecordParser.addContainerHandler("capability",
	attrMap={"standard_id": "standardID",
		"cap_type": "{http://www.w3.org/2001/XMLSchema-instance}type"},
	pythonMap={"ivoid": "curIdentifier", "cap_index": "cap_index"},
	translations=[
		("description", "cap_description")],
	incrementCounter="cap_index",
	hacks=[makeLowercaser("standard_id"), makeQNameNormalizer("cap_type")],
	destRole="capability")

RelationalRecordParser.addContainerHandler("schema",
	pythonMap={"ivoid": "curIdentifier", "schema_index": "schema_index"},
	incrementCounter="schema_index",
	translations=[
		("utype", "schema_utype"),
		("description", "schema_description"),
		("name", "schema_name"),
		("title", "schema_title")],
	destRole="res_schema",
	hacks=[makeLowercaser("schema_name")],
	diversions=["divertSchema"])

RelationalRecordParser.addContainerHandler("table",
	attrMap={"table_type": "type"},
	pythonMap={"ivoid": "curIdentifier", "schema_index": "schema_index",
		"table_index": "table_index"},
	incrementCounter="table_index",
	translations=[
		("description", "table_description"),
		("name", "table_name"),
		("title", "table_title"),
		("utype", "table_utype")],
	destRole="res_table",
	hacks=[makeLowercaser("table_type")])

RelationalRecordParser.addContainerHandler("column",
	attrMap={"std": "std", "arraysize": "arraysize", "delim": "delim",
		"extended_schema": "extendedSchema", "extended_type": "extendedType"},
	pythonMap={"ivoid": "curIdentifier", "table_index": "table_index",},
	translations=[
		("description", "column_description")],
	destRole="table_column",
	hacks=[_parseStd, makeLowercaser("name"), makeLowercaser("extended_schema"),
		makeLowercaser("extended_type"), makeQNameNormalizer("type_system"),
		emitDaCHSStatistics])

RelationalRecordParser.addContainerHandler("interface_in_capability",
	attrMap={
		"intf_type": '{http://www.w3.org/2001/XMLSchema-instance}type',
		"intf_role": "role",
		"version": "version"},
	pythonMap={
		"ivoid": "curIdentifier",
		"intf_index": "intf_index",
		"cap_index": "cap_index"},
	translations=[
		("querytype", "query_type"),
		("resulttype", "result_type"),
		("wsdlurl", "wsdl_url"),
		("mirrorurl", "mirror_url"),
		("version", "std_version")],
	incrementCounter="intf_index",
	destRole="interface",
	hacks=[
		makeLowercaser("std_version"),
		makeLowercaser("security_method_id"),
		makeQNameNormalizer("intf_type"),
		makeLowercaser("intf_role"),
		createAuthenticatedOnly,
		emitSecurityMethodResDetail])

RelationalRecordParser.addContainerHandler("subject",
	pythonMap={
		"res_subject": str.strip,
		"ivoid": "curIdentifier"},
	destRole="res_subject",
	hacks=[emitMappedSubject])

RelationalRecordParser.addContainerHandler("contact",
	attrMap={"role_ivoid": "ivo-id"},
	translations=[
		("address", "street_address"),
		("name", "role_name")],
	pythonMap={"ivoid": "curIdentifier"},
	destRole="res_role",
	hacks=[makeRoleAdder("contact"), makeLowercaser("role_ivoid")])

RelationalRecordParser.addContainerHandler("publisher",
	attrMap={"role_ivoid": "ivo-id", "alt_identifier": "altIdentifier"},
	pythonMap={
		"ivoid": "curIdentifier",
		'role_name': utils.identity,},
	destRole="res_role",
	hacks=[makeRoleAdder("publisher"), makeLowercaser("role_ivoid")])

RelationalRecordParser.addContainerHandler("contributor",
	attrMap={"role_ivoid": "ivo-id", "alt_identifier": "altIdentifier"},
	pythonMap={
		"ivoid": "curIdentifier",
		'role_name': utils.identity,},
	destRole="res_role",
	hacks=[makeRoleAdder("contributor"), makeLowercaser("role_ivoid")])

RelationalRecordParser.addContainerHandler("relatedResource",
	attrMap={"related_id": "ivo-id", "related_alt_identifier": "altIdentifier"},
	pythonMap={"ivoid": "curIdentifier",
		"relationship_type": "curRelationshipType",
		"related_name": utils.identity},
	destRole="relationship",
	hacks=[makeLowercaser("related_id"), makeLowercaser("relationship_type")])

RelationalRecordParser.addContainerHandler("param",
	pythonMap={
		"ivoid": "curIdentifier",
		"intf_index": "intf_index"},
	attrMap={"param_use": "use", "std": "std"},
	destRole="intf_param",
	translations = [
		("description", "param_description",)],
	hacks=[_parseStd, makeLowercaser("name")])

RelationalRecordParser.addContainerHandler("date",
	pythonMap={
		"ivoid": "curIdentifier",
		"date_value": utils.parseISODT},
	attrMap={"role": "role"},
	destRole="res_date",
	hacks=[mapDateRole])

RelationalRecordParser.addContainerHandler("altIdentifier",
	pythonMap={
		"ivoid": "curIdentifier",
		"alt_identifier": utils.identity},
	destRole="alt_identifier")

# this is for standard keys, which we ignore (for now); we only
# do something about them so their children don't spill over
RelationalRecordParser.addContainerHandler("key", addToParent=True,
	translations=[("name", "ignored"), ("description", "ignored")])

# ...and this is similarly to defuse stuff from legacy CEA application
# definitions.
RelationalRecordParser.addContainerHandler("parameterDefinition",
	addToParent=True,
	translations=[("name", "ignored"), ("description", "ignored")])


def _parseMOC(content):
	try:
		return pgsphere.SMoc.fromASCII(content).asSMoc(6)
	except Exception as msg:
		base.ui.notifyError(f"Discarding a bad MOC: {msg}")

RelationalRecordParser.addContainerHandler("spatial",
	pythonMap={
		"ivoid": "curIdentifier",
		"coverage": _parseMOC,},
	destRole="stc_spatial")

RelationalRecordParser.addContainerHandler("spectral",
	pythonMap={
		"ivoid": "curIdentifier",
		"unparsed": utils.identity},
	hacks=[makeIntervalParser("spectral_")],
	destRole="stc_spectral")

RelationalRecordParser.addContainerHandler("temporal",
	pythonMap={
		"ivoid": "curIdentifier",
		"unparsed": utils.identity},
	hacks=[makeIntervalParser("time_")],
	destRole="stc_temporal")


################ res_detail feeders from TAPRegExt

RelationalRecordParser.addContainerHandler("language",
	pythonMap={
		"cap_index": "cap_index",
		"ivoid": "curIdentifier"},
	translations=[
		("name", "detail_value"),],
	destRole="res_detail",
	hacks=[
		makeDetailXPathAdder("/capability/language/name"),])


############### DaCHS interface


def makeDataPack(grammar):
	"""The data pack is a triple of mappings (regparts, auths, prefixes)
	
	regparts maps the path fragments (see bin/harvestRegistries.getDirnameFor)
	to the registry IVORNs.

	auths is a mapping from managed authorities to the registry
	authorities.

	prefixes is whatever getCanonicalPrefixes returns.

	auths is used to only include records coming from the registries that
	manage their authorities (or for unmanaged authorities), which in
	turn is necessary since there are publishing registries that also
	act as full registries.

	What we map to is the authority part of the ivo id;  this is what
	harvestRegistries.getDirnameFor builds currently.
	"""
	regparts, knownAuths = {}, {}
	with api.getTableConn() as conn:
		table = api.TableForDef(grammar.rd.getById("authorities"),
			connection=conn)
		for rec in table.iterQuery(table.tableDef, ""):
			knownAuths[rec["managed_authority"].lower()] = rec["ivoid"].lower()
			dirpart = rec["ivoid"].split("/")[2]
			regparts[dirpart] = rec["ivoid"].lower()
	
	return regparts, knownAuths, oaiclient.getCanonicalPrefixes()


class RowIterator(CustomRowIterator):
	def _iterRows(self):
		regparts, knownAuths, canonicalPrefixes = self.grammar.dataPack
		# the directory name gives the authority of the source registry id
		try:
			originatingRegistry = regparts[self.sourceToken.split("/")[-2]]
		except KeyError as msg:
			raise api.SourceParseError("Source file with unknown authority",
				source=self.sourceToken, offending=str(msg), location="file name")

		# one parser yields the rr rows, the other the rows for the
		# oairecs table
		authorityChecker = AuthorityChecker(knownAuths, originatingRegistry)
		rowsParser = RelationalRecordParser(authorityChecker,
			self.sourceToken)
		oairecordsParser = OAIRecordsParser(
			authorityChecker, canonicalPrefixes)

		xmlReader = sax.make_parser()
		# we need explicit namespace reporting in OAIRecordsParser
		xmlReader.setFeature(sax.handler.feature_namespaces, True)
		self.handler = ContentHandlerMultiplexer(
			self.sourceToken,
			rowsParser, oairecordsParser)
		xmlReader.setContentHandler(self.handler)

		with open(self.sourceToken, "rb") as f:
			xmlReader.parse(f)

		# We first need to iterate the resources; since the other
		# tables have foreign keys there, dropping them will drop
		# all other detritus from other tables, preventing primary
		# key clashes.
		for dest, rowdict in rowsParser.rowdicts:
			if dest=='resource':
				yield dest, rowdict
		yield rsc.FLUSH

		for dest, rowdict in rowsParser.rowdicts:
			if dest!='resource':
				yield dest, rowdict
		yield rsc.FLUSH

		for rowdict in oairecordsParser.rowdicts:
			yield rowdict
		yield rsc.FLUSH

	def getLocator(self):
		try:
			loc = self.handler.locator
			return "%s, col %s"%(loc.getLineNumber(), loc.getColumnNumber())
		except AttributeError:  # presumably self.handler not yet set
			return "beginning"
		except ReferenceError:
			return "after parser destruction"


if __name__=="__main__":
	from gavo.user import logui
	logui.LoggingUI(base.ui)
	class StandinGrammar:
		rd = api.getRD("rr/q")
	g = StandinGrammar()
	g.dataPack = makeDataPack(g)

	r = RowIterator(g, "../tests/samples/archive.stsci.edu/siapservice.xml", None)
	res = {}
	for item in r._iterRows():
		if item is rsc.FLUSH:
			continue
		key, rec = item
		res.setdefault(key, []).append(rec)
	open("zw.png", "wb").write(res["stc_spatial"][1]["coverage"].getPlot())
