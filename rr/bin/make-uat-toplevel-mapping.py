# A script to turn the IVOA UAT into a mapping from terms to the
# seven top-level terms; this is then written to rr/res/toplevel-mapping.tsv
#
# I want this for the B2FIND-viewing datacite interface.  It should
# be run after UAT updates, failing that as part of the beginning-of-year
# chores.

from gavo import api
from gavo.protocols import vocabularies


RD = api.getRD("rr/q")
ROOT_TERMS = {
	'astrophysical-processes',
	'cosmology',
	'exoplanet-astronomy',
	'galactic-and-extragalactic-astronomy',
	'high-energy-astrophysics',
	'interdisciplinary-astronomy',
	'interstellar-medium',
	'observational-astronomy',
	'heliophysics',
	'solar-system-astronomy',
	'stellar-astronomy'}

DEBUG = False

def get_roots_for(term, uat_terms):
	"""returns the widest terms for term in uat_terms.

	uat_terms is the terms dictionary from a desise serialisation of
	the UAT.
	"""
	roots, seen = set(), set()

	def follow(t):
		wider = uat_terms[t]["wider"]
		if not wider:
			if not t in ROOT_TERMS:
				raise Exception(f"{t} found as a top-level term")
			roots.add(t)
		else:
			seen.add(t)
			for wider in uat_terms[t]["wider"]:
				follow(wider)
	
	follow(term)
	return roots


def main():
	uat = vocabularies.get_vocabulary("uat", force_update=not DEBUG)
	mapping = {}

	for term in uat["terms"]:
		if "deprecated" in uat["terms"][term]:
			continue
		mapping[term] = get_roots_for(term, uat["terms"])

	with open(RD.getAbsPath("res/toplevel-mapping.tsv"), "w") as f:
		for term, roots in sorted(mapping.items()):
			roots = " ".join(roots)
			f.write(f"{term}\t{roots}\n")


if __name__=="__main__":
	main()
