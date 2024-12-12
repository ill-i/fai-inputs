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
	<meta name="instrument">LEMI-008</meta>
	<meta name="instrument">LEMI-203</meta>
	<meta name="instrument">POS-1</meta>
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
		<column name="obs_mjd" type="double precision"
			unit="d" ucd="time.epoch"
			tablehead="Observed at"
			description="Universal time of the observation at the detector as MJD."
			displayHint="type=humanDate"/>

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
			ucd="meta.id;meta.file"
			tablehead="Src."
			description="File this row was parsed from."
			verbLevel="30"/>

	</table>

	<coverage>
		<temporal>59555 70000</temporal>
	</coverage>

	<data id="import" updating="True">
		<sources pattern="/ssa-data/data/*.csv">
			<ignoreSources fromdb="select distinct source_path from \schema.main"/>
		</sources>

		<csvGrammar/>

		<make table="main">
			<rowmaker idmaps="*" id="build_main">
				<map key="b_total" nullExpr="999999.9">@B_total</map>
				<map key="b_x" nullExpr="999999.9">@Bx</map>
				<map key="b_y" nullExpr="999999.9">@By</map>
				<map key="b_z" nullExpr="999999.9">@Bz</map>
				<map key="obs_time">@timestamp</map> 
				<map key="source_path">\fullPath</map>
				<map key="obs_mjd">dateTimeToMJD(parseISODT(@timestamp))</map>
			</rowmaker>
		</make>
	</data>

	<service id="q" allowed="form">
		<meta name="shortName">Geomag. fields</meta>

		<publish render="form" sets="ivo_managed, local"/>

		<dbCore queriedTable="main">
			<condDesc>
				<inputKey original="obs_mjd" type="vexpr-mjd"/>
			</condDesc>
			<condDesc buildFrom="b_total"/>
		</dbCore>
		<outputTable autoCols="obs_mjd, b_x, b_y, b_z, b_total"/>
	</service>

	<regSuite id="reg_tests" title="geomag_field regression">
		
		<regTest id="b_tot_test" title="geomag_field b_total test">
			<url parSet="TAP"
						QUERY="SELECT * FROM geomagnetic_field.main WHERE obs_mjd between 60111.6903 and 60111.691"
				>/tap/sync</url>
				<code>
					row = self.getFirstVOTableRow()
					self.assertAlmostEqual(row["b_total"], 55630.6)
					self.assertEqual(row["obs_time"], datetime.datetime(2023, 6, 16, 16, 35))
			</code>
		</regTest>

		<regTest title="geomag_field mjd time range test">
			<url parSet="TAP"
					QUERY="SELECT * FROM geomagnetic_field.main
									WHERE obs_mjd BETWEEN 60248.00000 AND 60248.004"
				>/tap/sync</url>
			<code>
				rows = self.getVOTableRows()
				self.assertEqual(len(rows), 6)
				self.assertEqual({r["b_x"]&lt;-60 for r in rows}, {True})
			</code>
		</regTest>

    <regTest title="geomag web interface is there">
      <url parSet="form" obs_mjd="2023.231 ..  2023.2311">q/form</url>
      <code><![CDATA[
        self.assertHasStrings(
          "2023-03-26T14:57:00Z", # mjd serialisation, first row
          "55618.7", # B total, last row
          'title="Magnetic field component in the Y direction."')
      ]]></code>
    </regTest>
	</regSuite>
</resource>
