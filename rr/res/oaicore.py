"""
A custom core to run OAI-PMH queries against our "full" registry.

This was forked and substantially reworked in purx/res/oaicore.py;
if you think of touching the code, consider reworking the entire OAI
part of rr to match essentially what's in purx.
"""

import functools
import re

from lxml import etree

from gavo import base
from gavo import registry
from gavo import rsc
from gavo import stc
from gavo import utils
from gavo.protocols.oaiclient import getCanonicalPrefixes
from gavo.registry import builders
from gavo.registry import oaiinter
from gavo.registry.model import OAI
from gavo.utils import stanxml

MAX_RECORDS = 1000
RD_ID = "rr/q"

try:
	# the UAT toplevel mapping is optionally used by makeOAIDataciteRecord
	# to add top-level concepts for B2FIND.  The mapping is generated
	# by manually running bin/make-uat-toplevel-mapping.py.
	with open(base.caches.getRD(RD_ID
			).getAbsPath("res/toplevel-mapping.tsv")) as _mapSource:
		UAT_TOPLEVELS = dict(
			(parts[0], set(parts[1].split())) for parts in
				(l.split("\t") for l in _mapSource))
	del _mapSource
except IOError:
	UAT_TOPLEVELS = {}

DATACITE_NS = "http://datacite.org/schema/kernel-4"
B2FIND_NS = "http://schema.eudat.eu/schema/kernel-1"


class RawXML(stanxml.Stub):
	"""A stanxml element spewing out raw stuff.

	No escaping is taking place, and no validation either; also, you're
	completely on your own concerning namespaces.

	So, use this only if you're very certain that what you insert
	makes sense.
	"""
	def __init__(self, rawText):
		self.rawText = rawText

	def __repr__(self):
		return "<RawXML %s>"%self.rawText[:30]

	def write(self, outFile):
		if isinstance(self.rawText, str):
			outFile.write(self.rawText.encode("utf-8"))
		else:
			outFile.write(self.rawText)

	def apply(self, func):
		# No children, no namespaces, nothing func could be applied to
		return
	
	def isEmpty(self):
		return False

	def __eq__(self, other):
		return id(self)==id(other)


def oaiName(name):
	return "{http://www.openarchives.org/OAI/2.0/}"+name


def makeOAIDCRecord(rawText):
	"""helps makeOAIDCRecord.
	"""
	# What's coming in here isn't actually well-formed XML since there's
	# unbound prefixes all over the place (they are bound in a toplevel
	# element).  However, I ignore most of this anyway and just want to
	# extract the identifier.  Based on this, I retrieve the necessary
	# metadata from the database and create my own records.
	# All this is marginally sound since I've fixed the prefixes on
	# ingesting the records.

# TODO: do a full PCDATA decode below
	identifier = re.search("<oai:identifier>(.*?)</oai:identifier>",
		rawText).group(1).strip().replace("&amp;", "&")
	
	with base.getTableConn() as conn:
		res = list(conn.queryToDicts(
			"""select * from rr.resource
			  	natural join rr.res_role
			  	natural left outer join (
			  		select
			  			ivoid, string_agg(detail_value, ', ') as rights
			  		from rr.res_detail
			  		where
			  			ivoid=%(ivoid)s
			  			and detail_xpath='/rights'
			  		group by ivoid) as r
					where ivoid=%(ivoid)s""",
			{"ivoid": identifier.lower()}))
	
	mc = base.MetaMixin()
	mc.setMeta("identifier", identifier)
	for metaName, colId, mapper in [
			("_metadataUpdated", "updated", utils.formatISODT),
			("title", "res_title", utils.identity),
			("description", "res_description", utils.identity),
			("rights", "rights", utils.identity)]:
		val = res[0][colId]
		if val:
			mc.setMeta(metaName, mapper(val))

	metaMap = {
		"contact": "contact.name",
		"creator": "creator.name",
		"contributor": "contributor.name",
		'publisher': "publisher",}
	for rec in res:
		key = metaMap[rec["base_role"]]
		mc.addMeta(key, rec["role_name"])

	return builders.getDCResourceElement(mc)


@utils.memoized
def getXmlnsDeclarations():
	"""returns a string declaring our canonical namespaces.
	"""
	return " ".join("xmlns:%s='%s'"%(prefix, ns)
		for prefix, ns in getCanonicalPrefixes().iterNS())


@utils.memoized
def getDataciteXSLT():
	"""returns an lxml XSLT object that turns ivo_vor to datacite metadata.
	"""
	xsltSource = base.caches.getRD(RD_ID).getAbsPath("res/vor-to-doi.xslt")
	with open(xsltSource, "rb") as f:
		return etree.XSLT(etree.XML(f.read()))


@utils.memoized
def getEudatXSLT():
	"""returns an lxml XSLT object that turns ivo_vor to eudat-core metadata.
	"""
	# for eudat's TemporalCoverage, we need to go from MJD to ISO, which
	# is a pain in XSLT.  I'll take a shortcut and register our implementation
	# as an XSLT extension.
	fnNS = etree.FunctionNamespace("urn:dachs")
	fnNS["mjd-to-iso"] = (lambda ctx, mjd:
		utils.formatISODT(stc.mjdToDateTime(float(mjd))))

	xsltSource = base.caches.getRD(RD_ID).getAbsPath("res/vor-to-eudc.xslt")
	with open(xsltSource, "rb") as f:
		return etree.XSLT(etree.XML(f.read()))


def getToplevelsFor(ivoid):
	"""returns UAT toplevel concepts for ivoid.

	This is by inspecting the subject_uat table in the local database.
	"""
	with base.getTableConn() as conn:
		subjects = set(r[0] for r in
			conn.query("SELECT uat_concept FROM rr.subject_uat"
				" WHERE ivoid=%(ivoid)s", locals()))
	
	newRoots = set()
	for term in subjects:
		root = UAT_TOPLEVELS[term.strip()]
		newRoots |= (root-subjects)
	return newRoots


def addUATToplevelsDatacite(dataciteTree):
	"""adds UAT toplevel subjects to dataciteTree.

	This assumes the local RR has the subject_uat extension for now (i.e.,
	as long as virtually no IVOA records actually use the UAT).  We
	get the UAT subjects from there.
	"""
	ivoid =  dataciteTree.xpath(
			"//d:alternateIdentifier[@alternateIdentifierType='ivoid']",
			namespaces={"d": DATACITE_NS}
		)[0].text.lower()

	newRoots = getToplevelsFor(ivoid)
	
	if newRoots:
		subjects = dataciteTree.xpath(
			"//d:subjects", namespaces={"d": DATACITE_NS})[0]
		for root in newRoots:
			newSubject = etree.SubElement(subjects, f"{{{DATACITE_NS}}}subject")
			newSubject.text = root


def addUATToplevelsEudat(eudatTree):
	"""adds UAT toplevel subjects to eudatTree.

	This assumes the ivoid is in eudc:PID.
	"""
	mainid =  eudatTree.xpath("//eudc:identifier", namespaces={"eudc": B2FIND_NS}
		)[0].text.lower()
	# mainid is the landing page URL; to get back the ivoid, replace anything
	# in front of the last segments of the landing page service URL with the
	# original ivo scheme.
	ivoid = re.sub(".*?q/lp/custom/", "ivo://", mainid)

	newRoots = getToplevelsFor(ivoid)
	
	if newRoots:
		subjects = eudatTree.xpath(
			"//eudc:keywords", namespaces={"eudc": B2FIND_NS})[0]
		for root in newRoots:
			newSubject = etree.SubElement(subjects, f"{{{B2FIND_NS}}}keyword")
			newSubject.text = root


def makeXSLTTransformedRecord(rawText, xslt, postprocessors=()):
	"""returns an the ivo-vor record in rawText transfomed with xslt.

	(xslt is lxml.etree.XSLT instance).

	Postprocessors can be a sequence of f(etree) post-processing
	the transformed tree.
	"""
	# The stuff in the database has normalised prefixes, which I need
	# to re-insert here so I can build a DOM from the XML
	rawText = rawText.replace("<oai:record>",
		"<oai:record %s>"%getXmlnsDeclarations())
	parsed = etree.XML(rawText.encode("utf-8"))

	# [1][0] is the first child of oai:metadata, i.e., ri:Resource;
	# this is what we want to XSL-transform.
	metadata = parsed[1][0]
	header = parsed[0]

	transformedTree = xslt(metadata)
	for proc in postprocessors:
		try:
			proc(transformedTree)
		except Exception as ex:
			base.ui.notifyError("Postprocessing transformed record {} failed: {}"
				.format(utils.makeEllipsis(rawText.split(">", 1)[-1], 300), ex))

	return OAI.record[RawXML(
		etree.tostring(header)
		+b"<oai:metadata>"
		+etree.tostring(transformedTree)
		+b"</oai:metadata>")]


def makeOAIDataciteRecord(rawText):
	# we're adding UAT toplevel terms here because that is what we
	# use for B2Find communication in 2021, and they need that.
	# Once they're using the b2find metadata prefix, we can probably
	# leave out the postprocessor (and drop the corresponding function).
	return makeXSLTTransformedRecord(rawText, getDataciteXSLT(),
		[addUATToplevelsDatacite])


def makeOAIEudatRecord(rawText):
	return makeXSLTTransformedRecord(rawText, getEudatXSLT(),
		[addUATToplevelsEudat])


def wrapRecordMaker(metadataPrefix, function):
	"""returns a function executing function, but with exception handling.
	"""
	def _(rawText):
		try:
			return function(rawText)
		except Exception as msg:
			base.ui.notifyError("OAI record from DB didn't work out for"
				" %s (%s): %s"%(metadataPrefix,
					utils.safe_str(msg),
					utils.makeEllipsis(rawText, 300)))
			return ""
	return _


def _getHeaderFromRec(oaiRec):
	"""returns the header from oaiRec.
	"""
	if isinstance(oaiRec, OAI.resumptionToken):
		return oaiRec

	rr = oaiRec["oaixml"]
	# Assuming the stuff in the DB was generated by vorgrammar, we know
	# prefixes and all.  Let's use this to save parsing time.
	try:
		hStart, hEnd = rr.index("<oai:header>"), rr.index("</oai:header>")
	except ValueError:
		# Record with no metadata?  Well, ignore.
		return None
	return RawXML(rr[hStart:hEnd+13])


def _addPrefixDefs(stanElement, restrictTo=None):
	"""adds the declarations for all prefixes we know to stanElement.
	"""
	canonicalPrefixes = getCanonicalPrefixes()
	# we try to add schema locations where we know them.
	schemaLocations = []

	for prefix, ns in canonicalPrefixes.iterNS():
		if restrictTo is not None and prefix not in restrictTo:
			continue
		if prefix is not None:
			stanElement.addAttribute("xmlns:"+prefix, ns)
			try:
				schemaURL = stanxml.NSRegistry.getPrefixInfo(
					stanxml.NSRegistry.getPrefixForNS(ns))[1]
				if schemaURL:
					schemaLocations.append("%s %s"%(ns, schemaURL))
			except base.NotFoundError:
				# we don't now the namespace and give no schema location.  Fine.
				pass
	stanElement.addAttribute("xsi:schemaLocation", " ".join(schemaLocations))
	return stanElement


def ensureMetadataPrefix(pars):
	"""raises errors if the metadata prefix is missing or unsupported.

	This must only be called on functions that actually require a metadata
	prefix.  We need this here because we shortcut execution on some
	functions so the registry.oaiinter validation doesn't kick in.
	"""
	if "metadataPrefix" in pars:
		getSerializerFor(pars["metadataPrefix"])
	else:
		raise oaiinter.BadArgument("metadataPrefix missing")


def getSerializerFor(prefix):
	if prefix=="oai_dc":
		baseFunc = wrapRecordMaker("oai_dc", makeOAIDCRecord)
	elif prefix=="oai_datacite":
		baseFunc = wrapRecordMaker("oai_datacite", makeOAIDataciteRecord)
	elif prefix=="oai_b2find":
		baseFunc = wrapRecordMaker("oai_b2find", makeOAIEudatRecord)

	elif prefix=="ivo_vor":
		baseFunc =  RawXML
	else:
		raise registry.CannotDisseminateFormat(
			"%s metadata are not supported"%prefix)
	
	def serializer(r):
		if isinstance(r, OAI.resumptionToken):
			return r
		else:
			return baseFunc(r["oaixml"])
	
	return serializer


def getListIdentifiersElement(records, prefix):
	return OAI.ListIdentifiers[[
		_getHeaderFromRec(r)
		for r in records]]


def getListRecordsElement(records, prefix):
	s = getSerializerFor(prefix)
	return _addPrefixDefs(OAI.ListRecords[
		[s(r) for r in records]])


def getGetRecordElement(record, prefix):
	formatted = getSerializerFor(prefix)(record)
	# XSLT might fail in various ways, but the exception is swallowed
	# for ListRecords' sake.  We cath that here again.
	if formatted=="":
		raise registry.CannotDisseminateFormat(f"Sorry, {record['ivoid']}"
			f" could not be transformed to {prefix}.  Please complain"
			" to the operator.")
	return _addPrefixDefs(OAI.GetRecord[formatted])


def getListSetsElement():
	return OAI.ListSets[
		OAI.set[
			OAI.setSpec["ivo_managed"],
			OAI.setName["ivo_managed"]]]


def _getSetCondition(pars, sqlPars):
# we don't support sets here, so if a set condition is given, we don't
# match anything.
	if "set" in pars:
		return ("1=2")


@functools.cache
def getRRTD(id):
	return base.caches.getRD(RD_ID).getById(id)


def getMatchingOAIRecs(pars):
	"""returns a list of identifiers matching pars, plus the metadata prefix.
	"""
	ensureMetadataPrefix(pars)
	td = getRRTD("oairecs")
	return (oaiinter.getMatchingRows(
		pars,
		getRRTD("oairecs"),
		_getSetCondition),
		pars["metadataPrefix"])


def getRecordForIdentifier(pars):
	"""returns a single record for what's in pars["identifier"].
	"""
	# the replace below is a hack to fix clients that fail to quote
	# plusses; blanks are not allowed in IVOIDs anyway, so it can't
	# actually break anything
	identifier = pars["identifier"].lower().replace(" ", "+")
	
	with base.getTableConn() as conn:
		table = rsc.TableForDef(getRRTD("oairecs"), connection=conn)
		res = list(table.iterQuery(table.tableDef, "ivoid=%(ivoid)s",
			{"ivoid": identifier}))
		if len(res)==1:
			# the .get for the metadata prefix is so you can use this
			# function to check for the presence of a record.
			return res[0], pars.get("metadataPrefix")
	raise oaiinter.IdDoesNotExist(pars["identifier"])


def getListMetadataFormatsElement():
	return OAI.ListMetadataFormats[[
		OAI.metadataFormat[
			OAI.metadataPrefix[prefix],
			OAI.schema[schema],
			OAI.metadataNamespace[ns],
		] for prefix, schema, ns in registry.METADATA_PREFIXES+[
			("oai_datacite",
				"http://schema.datacite.org/meta/kernel-4.1/metadata.xsd",
				DATACITE_NS),
			("oai_b2find",
				"http://docs.g-vo.org/schemata/eudat-core.xsd",
				B2FIND_NS),]]
	]


def _makeArgsForListMetadataFormats(pars):
	# returns arguments for builders.getListMetadataElements.
	# identifier is not ignored since crooks may be trying to verify the
	# existence of resource in this way and we want to let them do this.
	# Of course, we support both kinds of metadata on all records.
	if "identifier" in pars:
		getRecordForIdentifier(pars)
	return ()


class Core(oaiinter.RegistryCore):
	builders = {
		"GetRecord": ({
			"oai_dc": getGetRecordElement,
			"oai_datacite": getGetRecordElement,
			"oai_b2find": getGetRecordElement,
			"ivo_vor": getGetRecordElement},
			getRecordForIdentifier),
		"ListRecords": ({
			"oai_dc": getListRecordsElement,
			"oai_datacite": getListRecordsElement,
			"oai_b2find": getListRecordsElement,
			"ivo_vor": getListRecordsElement},
			getMatchingOAIRecs),
		"ListIdentifiers": ({
			"oai_dc": getListIdentifiersElement,
			"oai_datacite": getListIdentifiersElement,
			"oai_b2find": getListIdentifiersElement,
			"ivo_vor": getListIdentifiersElement},
			getMatchingOAIRecs),
		"ListSets": (getListSetsElement, lambda pars: ()),
		"Identify": (builders.getIdentifyElement,
			lambda pars: (getRRTD("pmh"),)),
		"ListMetadataFormats": (getListMetadataFormatsElement,
			_makeArgsForListMetadataFormats),
	}


if __name__=="__main__":
	# development code for the toplevel fudging for B2FIND
	with base.getTableConn() as conn:
		rawText = conn.query("SELECT oaixml FROM rr.oairecs"
			" WHERE ivoid='ivo://org.gavo.dc/hsoy/q/q'").__next__()[0]
	print("\n".join(re.findall("<d:subject>[^>]*",
		utils.debytify(makeOAIDataciteRecord(rawText).render()))))
	print("(Should have observational-astronomy and"
		" galactic-and-extragalactic-astronomy.")
