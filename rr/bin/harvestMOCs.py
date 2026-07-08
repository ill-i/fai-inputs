"""
Retrieves footprint documents for resources that have a footprint URL
but no stc_spatial entry.
"""

import sys

import requests

from gavo import api
from gavo.utils import pgsphere

api.setUserAgent(f"GAVO-RegTAP-harvester (IVOA-copy) DaCHS/{api.__version__}")


def ingestOne(dest_table, ivoid, footprintURL):
	"""retrieves footprintURL and tries to ingest it into stc_spatial as a MOC.
	"""
	res = requests.get(footprintURL)
	res.raise_for_status()
	moc = pgsphere.SMoc.fromFITS(res.content)
	moc.moc.normalize(max_order=6)
	dest_table.addRow({
		'ivoid': ivoid,
		'ref_system_name': None,
		'coverage': moc})


def main():
	with api.getWritableAdminConn() as conn:
		dest_table = api.TableForDef(
			api.resolveCrossId("rr/q#stc_spatial"),
			connection=conn)

		for row in conn.query("""
				SELECT ivoid, detail_value as footprint_url
				FROM rr.res_detail as d
				WHERE detail_xpath='/coverage/footprint'
				AND NOT EXISTS (
					SELECT 1
					FROM rr.stc_spatial as s
				WHERE d.ivoid=s.ivoid)"""):

			try:
				ingestOne(dest_table, *row)
				conn.commit()
			except Exception as ex:
				api.ui.notifyError("Error while retrieving footprint for %s: %s"%(
					row[0], ex))
				conn.rollback()
	
	return 0


if __name__=="__main__":
	api.LoggingUI(api.ui)
	api.StingyPlainUI(api.ui)
	sys.exit(main())
