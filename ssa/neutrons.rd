<resource schema="neutrons" resdir=".">
	<meta name="creationDate">2024-12-11T15:27:49Z</meta>

	<meta name="title">Alma-Ata Station Neutron Monitor Data Service </meta>
	<meta name="description">
		The Alma-Ata Cosmic Ray Station operates the 18NM-64 neutron supermonitor
		at an altitude of 3340 meters above sea level with a geomagnetic cutoff
		rigidity of 6.7 GeV. The station provides real-time minute-level measurements of
		cosmic ray intensity and atmospheric pressure, contributing data to the
		international NMDB network (www.nmdb.eu).

		This service publishes daily tables containing two columns: timestamp and
		counts/sec. The timestamps reflect actual measurement times, ensuring accurate
		tracking even when delayed data from previous days is incorporated into current
		files due to communication delays with space stations.
	</meta>
	<meta name="subject">space-weather</meta>
	<meta name="subject">neutron-monitors</meta>
	<meta name="subject">cosmic-ray-detectors</meta>

	<meta name="creator">Fesenkov Astrophysical Institute</meta>
	<meta name="instrument">18NM-64 Neutron Monitor</meta>
	<meta name="facility">Alma-Ata Cosmic Ray Station (AATB)</meta>

	<meta name="source">https://ionos.kz/</meta>
	<meta name="contentLevel">Research</meta>
	<meta name="type">Archive</meta> 

	<execute every="3600" title="Ingest new files">
		<job>
			<code>
				execDef.spawn("dachs imp \rdId")
			</code>
		</job>
	</execute>

	<table id="main" onDisk="True" adql="True">
		<index columns="obs_mjd"/>
		<index columns="source_path"/>
		<index columns="counts"/>

		<column name="obs_mjd" type="double precision"
			unit="d" ucd="time.epoch"
			tablehead="Observed at"
			description="Universal time of the observation at the detector as MJD."
			displayHint="type=humanDate"/>
		<column name="counts" type="double precision"
			unit="count*sec**-1" ucd="arith.rate;phys.particle.neutron"
			tablehead="Count"
			description="Average neutron counts per second, derived from one-minute measurements."/>
		<column name="source_path" type="text"
			ucd="meta.id;meta.file"
			tablehead="Src."
			description="File this row was parsed from."
			verbLevel="30"/>
	</table>

	<coverage>
		<temporal>59555 70000</temporal>
	</coverage>

	<data id="import" updating="True">
		<sources pattern="/ssa-data/ndata/*.csv">
			<ignoreSources fromdb="select distinct source_path from \schema.main"/>
		</sources>

		<csvGrammar>
			<rowfilter>
				<code>
					# upstream writes their files live; skip files that
					# still seem to be written to.
					if os.path.getmtime(rowIter.sourceToken)>time.time()-3600:
						raise SkipThis(f"Skipping file still being written to: {rowIter.sourceToken}")
					yield row
				</code>
			</rowfilter>
		</csvGrammar>

		<make table="main">
			<rowmaker idmaps="*">
				<map key="source_path">\fullPath</map>
				<map key="obs_mjd">dateTimeToMJD(parseISODT(@timestamp))</map>
				<map key="counts">float(vars["counts/sec"])</map>
			</rowmaker>
		</make>
	</data>

	<service id="q" allowed="form">
		<meta name="shortName">\schema data</meta>

		<publish render="form" sets="ivo_managed, local"/>

		<dbCore queriedTable="main">
			<condDesc>
				<inputKey original="obs_mjd" type="vexpr-mjd"/>
			</condDesc>
			<condDesc buildFrom="counts"/>
		</dbCore>
		<outputTable autoCols="obs_mjd counts"/>
	</service>

	<regSuite title="neutrons regression">
		<regTest title="neutrons table serves some data">
			<url parSet="TAP"
				QUERY="SELECT * FROM neutrons.main WHERE counts > 1270"
				>/tap/sync</url>
			<code>
				# The actual assertions are pyUnit-like.	Obviously, you want to
				# remove the print statement once you've worked out what to test
				# against.
				row = self.getFirstVOTableRow()
				print(row)
				self.assertGreaterEqual(row["counts"], 1270)
			</code>
		</regTest>

		<regTest title="neutrons mjd time range test">
			<url REQUEST="doQuery"
					LANG="ADQL"
					QUERY="SELECT * FROM main
									WHERE obs_mjd BETWEEN 60248.00000 AND 60250.00347"
				>tap</url>
			<code>
				rows = self.getVOTableRows()
				self.assertEqual(len(rows), 6)
				for row in rows:
					self.assertGreaterEqual(row["obs_mjd"], 60248.00000)
					self.assertLessEqual(row["obs_mjd"], 60250.00347)
			</code>
		</regTest>

	</regSuite>
</resource>
