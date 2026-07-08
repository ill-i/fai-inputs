<resource schema="asteroids_obs_tab" resdir=".">
  <meta name="creationDate">2025-04-18T06:18:07Z</meta>

  <meta name="title">FAI Asteroid Observation Log</meta>
	<meta name="description" format="rst">
    This table is a preview catalog of asteroid observations carried out by the
    Fesenkov Astrophysical Institute (FAI) as part of our ongoing contribution
    to planetary defense and space situational awareness. The observations are
    regularly reported to the Minor Planet Center (https://minorplanetcenter.net/).

    The dataset includes the following fields:

    - **obs_date**: Date of observation (format: yyyy-mm-dd).
    - **target**: Asteroid designation from MPC.
    - **bin**: CCD binning mode (N×N pixels).
    - **filter**: Photometric filter used (CL means clear).
    - **exptime**: Exposure time in seconds.
    - **nframes**: Number of CCD frames obtained.
    - **reference**: Link to MPC circular or MPS telegram.
    - **page**: Page number referencing N42 telescope observations.
    - **notes**: Additional remarks.

    This is an overview table. For more details about our space situational awareness
    activities, please visit our SSA portal: https://ssa.fai.kz/.

    For questions or data reuse requests, please contact us at vo[at]fai.kz.
  </meta> 
  <meta name="subject">asteroids</meta>
  <meta name="subject">small-solar-system-bodies</meta>
  <meta name="subject">observation-log</meta>

  <meta name="creator">Fesenkov Astrophysical Institute</meta>
  <meta name="instrument">Zeiss-1000 (east)</meta>
  <meta name="facility">Tien-Shan Astronomical Observatory</meta>
	<meta name="contact.name">Kazakhstan Virtual Observatory</meta>
	<meta name="contact.email">vo@fai.kz</meta>
  <meta name="contentLevel">Research</meta>

  <meta name="type">Catalog</meta>  <!-- or Archive, Survey, Simulation -->

  <meta name="coverage.waveband">Optical</meta>

  <execute at="1:00" title="Ingest new files">
    <job>
      <code>
        #execDef.spawn("dachs imp \rdId")
        execDef.spawn(["dachs", "imp", "asteroids_obs_tab/q"])
      </code>
    </job>
  </execute>

  <table id="main" onDisk="True" adql="True">
    <column name="obs_date"
      type="date" ucd="time.date;obs"
			required="True"
      tablehead="Obs Date"
      description="Observation date (ISO format DD-MM-YYYY)"
      verbLevel="1"/>
    <column name="target"
      type="text" ucd="meta.id;src"
			required="True"
      tablehead="Target"
      description="Asteroid designation or provisional ID"
      verbLevel="1"/>
    <column name="bin"
      type="integer" ucd="instr.detector.bin"
			required="True"
      tablehead="Bin"
      description="Detector binning"
      verbLevel="5"/>
    <column name="filter"
      type="text" ucd="instr.filter"
			required="True"
      tablehead="Filter"
      description="Filter used during observation"
      verbLevel="1"/>
    <column name="exptime"
      type="integer" unit="s" ucd="time.duration;obs.exposure"
      required="True"
			tablehead="Exp."
      description="Exposure time in seconds"
      verbLevel="1"/>
    <column name="nframes"
			type="integer" ucd="meta.number;obs"
  		required="True"
			tablehead="Frames"
  		description="Number of frames per object"
			verbLevel="5"/>
    <column name="reference"
      type="text" ucd="meta.ref.url"
      tablehead="MPC Ref."
      description="URL to Minor Planet Center report PDF"
      verbLevel="5">
      <values nullLiteral=""/>
    </column>
    <column name="page"
      type="text"
      tablehead="Page"
      description="Page number in MPC PDF"
      verbLevel="10">
      <values nullLiteral=""/>
    </column>
    <column name="notes"
      type="text"
      tablehead="Notes"
      description="Additional comments"
      verbLevel="10">
      <values nullLiteral=""/>
    </column>
  </table>

  <data id="import" updating="True">
		<sources pattern="data/asteroids_obs_tab.csv"/>
		<csvGrammar/>
		<make table="main">
			<rowmaker>
				<map key="obs_date" source="obs_date"/>
				<map key="target" source="target"/>
				<map key="bin" source="bin"/>
				<map key="filter" source="filter"/>
				<map key="exptime" source="exptime"/>
				<map key="nframes" source="nframes"/>
				<map key="reference" source="reference"/>
				<map key="page" source="page"/>
				<map key="notes" source="notes"/>
			</rowmaker>
		</make>
	</data>
	<service id="q" allowed="form">
    <meta name="shortName">Asteroids Obs</meta>
    <publish render="form" sets="ivo_managed, local"/>
    <dbCore queriedTable="main">
      <condDesc buildFrom="obs_date"/>
      <condDesc buildFrom="target"/>
		</dbCore>
	  <outputTable verbLevel="10" autoCols="target obs_date filter bin exptime nframes reference page notes"/>
  </service>

  <regSuite title="asteroids_obs_tab regression">
    <regTest title="basic data check">
      <url parSet="TAP" QUERY="SELECT * FROM asteroids_obs_tab.main LIMIT 1">/tap/sync</url>
      <code>
        row = self.getFirstVOTableRow()
        print(row)
        self.assertTrue("target" in row)
      </code>
    </regTest>
  </regSuite>

</resource>
