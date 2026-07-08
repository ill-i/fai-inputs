#!/usr/bin/python3
"""Fix prefix mappings in vi.

Call this script to edit rr's internal mapping of prefixes to namespace URIs
This mapping is filled by harvestRegistries as it parses OAI records coming
from the data providers.  Sometimes, these put in totally insane URIs, and
then it's a good idea to fix the records by mapping the prefixes assigned
to the insane URLs.
"""

import pickle
import os
import subprocess
import tempfile

from gavo import base, utils

prefixCache = os.path.join(base.getConfig("cacheDir"), "rrOaiPrefixes.pickle")

with open(prefixCache, "rb") as f:
	stuff = pickle.load(f)

with tempfile.NamedTemporaryFile() as f:
	f.write(
		"\n".join("{}\t{}".format(*item) for item in stuff).encode("ascii"))
	f.flush()

	subprocess.call([os.environ["VISUAL"], f.name])

	f.seek(0)
	stuff = f.read().decode("ascii")

newPrefixes = [l.split("\t") for l in stuff.split("\n") if l]
assert set(len(p) for p in newPrefixes)=={2}

with utils.safeReplaced(prefixCache) as f:
	pickle.dump(newPrefixes, f)
