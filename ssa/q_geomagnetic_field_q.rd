<resource schema="geomagnetic_field" resdir=".">
	<meta name="creationDate">2024-12-09T11:51:56Z</meta>

	<meta name="title">Alma-Ata Geomagnetic Observatory Data Service</meta>
	<meta name="description" format="rst">
		The Alma-Ata Geomagnetic Observatory provides continuous monitoring of
		Earth’s geomagnetic field. Located at 1300 meters above sea level in the
		foothills of the Tien Shan Mountains, approximately 10 km from Almaty,
		Kazakhstan, the observatory operates state-of-the-art equipment certified by
		INTERMAGNET, including the fluxgate magnetometer LEMI-008 and the proton
		Overhauser magnetometer POS-1.

		The data service includes:

		* Observables: Three components of the geomagnetic field vector (X, Y, Z)
		  and the total field amplitude (F), measured in nanoteslas (nT).
		* Data Resolution:
			* XYZ components measured at a 1-second frequency.
			* F component measured at a 5-second frequency.
			* Derived minute averages for XYZF components available in real time.
			* Absolute measurements performed two to three times per week.

		The service provides open access to minute and hourly data (XYZF components
		and K-index of geomagnetic activity) through the Institute of Ionosphere’s
		website for data from 2003 onward. Additionally, INTERMAGNET hosts minute
		variations data since 2004. Data prior to 2003 are available upon request.
	</meta>

	<meta name="subject">geomagnetic-fields</meta>
	<meta name="subject">space-weather</meta>

	<meta name="creator">Fesenkov Astrophysical Institute</meta>
	<meta name="instrument">LEMI-008, LEMI-203, POS-1</meta>
	<meta name="facility">Alma-Ata Geomagnetic Observatory</meta>

	<meta name="source">https://ionos.kz/en/geomagnetic-observatory-2/</meta>
	<meta name="contentLevel">Research</meta>
	<meta name="type">Archive</meta>

	<execute at="1:00" title="Ingest new files">
		<job>
			<code>
				execDef.spawn("dachs imp \rdId")
			</code>
		</job>
	</execute>

	<table id="main" onDisk="True" adql="True">
		<index columns="obs_time"/>
		<index columns="source_path"/>
		<index columns="b_total"/>

		<column name="obs_time" type="timestamp"
			ucd="time.epoch"
			tablehead="Timestamp"
			description="Universal time of the observation at the detector."/>
		<column name="b_x" type="double precision"
			unit="nT" ucd="phys.magField;pos.cartesian.x"
			tablehead="B_x"
			description="Magnetic field component in the X direction."/>
		<column name="b_y" type="double precision"
			unit="nT" ucd="phys.magField;pos.cartesian.y"
			tablehead="B_y"
			description="Magnetic field component in the Y direction."/>
		<column name="b_z" type="double precision"
			unit="nT" ucd="phys.magField;pos.cartesian.z"
			tablehead="B_z"
			description="Magnetic field component in the Z direction."/>
		<column name="b_total" type="double precision"
			unit="nT" ucd="phys.magField"
			tablehead="B_total"
			description="Total magnetic field strength."/> 
		<column name="source_path" type="text"
			ucd="meta.file"
			tablehead="Src."
			description="File this row was parsed from."
			verbLevel="30"/>

	</table>

	<coverage>
		<updater sourceTable="main"/>
	</coverage>

	<data id="import" updating="True">
		<sources pattern="/ssa-data/data/*.txt">
			<ignoreSources fromdb="select distinct source_path from \schema.main"/>
		</sources>

		<reGrammar names="obs_time, b_x, b_y, b_z, b_total"/>

		<make table="main">
			<rowmaker idmaps="*" id="build_main">
				<LOOP listItems="b_x b_y b_z b_total">
					<events>
						<map key="\item" source="\item" nullExpr="999999.9"/>
					</events>
				</LOOP>
				<map key="source_path">\fullPath</map>
			</rowmaker>
		</make>
	</data>

	<service id="q" allowed="form">
		<meta name="shortName">Geomag. fields</meta>

		<publish render="form" sets="ivo_managed, local"/>

		<dbCore queriedTable="main">
			<condDesc buildFrom="obs_time"/>
			<condDesc buildFrom="b_total"/>
		</dbCore>
	</service>


	<regSuite title="geomagnetic_field regression">
		<regTest title="geomagnetic_field SCS serves some data">
			<url RA="76.57"
					DEC="43.1" SR="0.01"
				>cone/scs.xml</url>
			<code>
				row = self.getFirstVOTableRow()
				#print(row)
				self.assertAlmostEqual(row["ra"], 76.57)
				self.assertAlmostEqual(row["dec"], 43.1)
			</code>
		</regTest>

		<regTest title="geomagnetic_field TAP query works">
			<url REQUEST="doQuery"
						LANG="ADQL"
						QUERY="SELECT * FROM main WHERE B_total > 55710.0"
				>tap</url>
				<code>
					rows = self.getVOTableRows()
					self.assertGreater(len(rows), 0)
					for row in rows:
						self.assertGreater(row["B_total"], 55710.0)
			</code>
		</regTest>

		<regTest title="geomagnetic_field TAP time range">
			<url REQUEST="doQuery"
					LANG="ADQL"
					QUERY="SELECT * FROM main
									WHERE obs_time BETWEEN '2024-12-02T00:00:00.000Z'
									AND '2024-12-02T00:05:00.000Z'"
				>tap</url>
			<code>
				rows = self.getVOTableRows()
				self.assertEqual(len(rows), 6)
				for row in rows:
					self.assertGreaterEqual(row["timestamp"], "2024-12-02T00:00:00.000Z")
					self.assertLessEqual(row["timestamp"], "2024-12-02T00:05:00.000Z")
			</code>
		</regTest>

	</regSuite>
</resource>
