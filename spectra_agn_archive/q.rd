<resource schema="spectra_agn_archive" resdir=".">
  <meta name="creationDate">2023-10-06T04:43:15Z</meta>

  <meta name="title">Archive of AGN spectral observations</meta>
  <meta name="description">The archive of AGN spectral observations is obtained on AZT-8 telescope at the Fesenkov Astrophysical Institute (FAI), Almaty, Kazakhstan.
It represents the result of observations for abot 25 years - from 1970 to 1995.  All observations were carried out at AZT-8 (D = 700 mm, F[main]  = 2800 mm, F[Cassegrain] = 11000 mm) with a high-power spectrograph. In 1967-68, on the basis of the image intensifier (https://doi.org/10.1080/1055679031000084795a) developed and assembled the spectrograph of the original design in the workshops of the FAI.
To use the spectra, please, download raw .fit file of required object, date and exposure. The open 'Calibration frames' in Related links and then use them to calibrate object spectra frames. For more information about calibration process please visit https://github.com/ill-i/Spectra-Reduction.
  </meta>
  <meta name="subject">active-galactic-nuclei</meta>
  <meta name="subject">history-of-astronomy</meta>
  <meta name="creator">Fesenkov Astrophysical Institute</meta>
  <meta name="instrument">AZT-8</meta>
  <meta name="facility">Fesenkov Astrophysical Institute</meta>
  <!--<meta name="source"></meta>-->
  <meta name="contentLevel">Research</meta>
  <meta name="type">Archive</meta>
  <meta name="coverage.waveband">Optical</meta>
  <meta name="ssap.dataSource">pointed</meta>
  <meta name="ssap.creationType">archival</meta>
  <meta name="productType">spectrum</meta>
  <meta name="ssap.testQuery">MAXREC=1</meta>

  <table id="raw_data" onDisk="True" adql="hidden"
      namePath="//ssap#instance">

    <LOOP listItems="ssa_dateObs ssa_dstitle ssa_targname ssa_timeExt ssa_specstart ssa_specend ssa_length">
      <events>
        <column original="\item"/>
      </events>
    </LOOP>

    <mixin>//products#table</mixin>
    <!-- remove this if your data doesn't have (usable) positions -->
    <mixin>//ssap#plainlocation</mixin>
    <!-- remove this if you don't have plainlocation or there is no
      aperture -->
    <mixin>//ssap#simpleCoverage</mixin>
    <!-- the following adds a q3c index so obscore queries over s_ra
      and s_dec are fast; again, remove this if you don't have useful
      positions -->

    <FEED source="//scs#splitPosIndex"
      long="degrees(long(ssa_location))"
      lat="degrees(lat(ssa_location))"/>

    <!-- the datalink column is mainly useful if you have a form-based
      service.  You can dump this (and the mapping rule filling it below)
      if you're not planning on web or don't care about giving them datalink
      access. -->

    <column name="datalink" type="text"
      ucd="meta.ref.url"
      tablehead="Datalink"
      description="A link to a datalink document for this spectrum."
      verbLevel="15" displayHint="type=url">
      <property name="targetType"
       >application/fit;content=datalink</property>
      <property name="targetTitle">Datalink</property>
    </column>

    <!--<column name="object" type="text"
      ucd="meta.id;src"
      tablehead="Objs."
      description="Name of object from the observation log."
    verbLevel="3"/>-->

    <column name="target_ra"
      unit="deg" ucd="pos.eq.ra;meta.main"
      tablehead="Target RA"
      description="Right ascension of object from observation log."
      verbLevel="1"/>
    <column name="target_dec"
      unit="deg" ucd="pos.eq.dec;meta.main"
      tablehead="Target Dec"
      description="Declination of object from observation log."
      verbLevel="1"/>

    <!--%add further custom columns if necessary here%-->
  </table>

  <!-- if you have data that is continually added to, consider using
    updating="True" and an ignorePattern here; see also howDoI.html,
    incremental updating.  -->
  <data id="import">
    <recreateAfter>make_view</recreateAfter>
    <!--<property key="previewDir">previews</property>-->
    <sources recurse="True"
      pattern="/var/gavo/inputs/astroplates/spectra_agn_archive/data/*.fit"/>

    <!-- The following (and the datalink stuff) assumes you have
      IRAF-style 1D arrays; if you have something even more flamboyant,
      you'll have to change things here as well as in build_sdm_data;
      you'll want to keep the products#define rowmaker, though. -->
    <fitsProdGrammar qnd="True">
      <rowfilter procDef="//products#define">
        <bind key="table">"\schema.raw_data"</bind>
      </rowfilter>
    </fitsProdGrammar>

    <make table="raw_data">
      <rowmaker idmaps="*">


        <!-- the following maps assume the column list in the LOOP
          above.  If you changed things there, you'll have to adapt
          things here, too -->
        <!--<map key="dateObs" source="DATE_OBS" nullExcs="KeyError"/>-->
        <map key="ssa_dateObs">dateTimeToMJD(parseTimestamp(@DATE_OBS))</map>
        <map key="ssa_dstitle">@FILENAME</map> <!--"{} {}".format(%make a string halfway human-readable and halfway unique for each data set%)</map>-->
        <map key="ssa_targname">@OBJECT</map>
        <map key="ssa_specstart">getWCSAxis(@header_, 1).pixToPhys(1)*1e-10</map>
        <map key="ssa_specend">getWCSAxis(@header_, 1).pixToPhys(getWCSAxis(@header_, 1).axisLength)*1e-10</map>
        <map key="ssa_length">getWCSAxis(@header_, 1).axisLength</map>

        <map key="target_ra"  nullExcs="KeyError">@RA_DEG</map>
        <map key="target_dec" nullExcs="KeyError">@DEC_DEG</map>

        <!--<var name="specAx">getWCSAxis(@header_, 1)</var>
        <map key="ssa_specstart">specAx.pixToPhys(1)*1e-10</map>
        <map key="ssa_specend">specAx.pixToPhys(@specAx.axisLength)*1e-10</map>
        <map key="ssa_length">specAx.axisLength</map>-->
        <map key="ssa_timeExt">@EXPTIME</map>
        <!--<map key="ssa_specres">%expression to compute the typical spectral FWHM *in meters*%</map>-->

        <map key="datalink">\dlMetaURI{sdl}</map>

        <!-- add mappings for your own custom columns here. -->
      </rowmaker>
    </make>
  </data>

  <table id="data" onDisk="True" adql="True">
    <!-- the SSA table (on which the service is based -->

    <meta name="_associatedDatalinkService">
      <meta name="serviceId">sdl</meta>
      <meta name="idColumn">ssa_pubDID</meta>
    </meta>

    <!-- again, the full list of things you can pass to the mixin
      is at http://docs.g-vo.org/DaCHS/ref.html#the-ssap-view-mixin.

      Things you already defined in raw_data are ignored here; you
      can also (almost always) leave them out altogether here.
      Defaulted attributes (the doc has "defaults to" for them) you
      can remove.

      The values for the ssa_ attributes below are SQL expressions – that
      is, you need to put strings in single quotes.
    -->
    <mixin
      sourcetable="raw_data"
      copiedcolumns="*"
      ssa_aperture="10/3600."
      ssa_fluxunit="''"
      ssa_spectralunit="'Pixel'"
      ssa_bandpass="'Optical'"
      ssa_collection="'FAI_AGN_archive'"
      ssa_fluxcalib="'UNCALIBRATED'"
      ssa_fluxucd="'phot.flux.density'"
      ssa_speccalib="'UNCALIBRATED'"
      ssa_spectralucd="'spect.line'"
      ssa_targclass="'active-galactic-nuclei'"
    >//ssap#view</mixin>

    <mixin
      calibLevel="1"
      coverage="ssa_region"
      sResolution="ssa_spaceres"
      oUCD="ssa_fluxucd"
      emUCD="ssa_spectralucd"
      >//obscore#publishSSAPMIXC</mixin>
  </table>

  <data id="make_view" auto="False">
    <make table="data"/>
  </data>

  <coverage>
    <updater sourceTable="data"/>
  </coverage>

  <!-- This is the table definition *for a single spectrum* as used
    by datalink.  If you have per-bin errors or whatever else, just
    add columns as above. -->
  <table id="instance" onDisk="False">
    <mixin ssaTable="data"
      spectralDescription="Wavelength"
      fluxDescription="Optical density"
      >//ssap#sdm-instance</mixin>
    <meta name="description">The raw archival spectrum of AGN, uncalibrated. </meta>
  </table>

<!--
  %this data item build spectrum *instances* (for datalink)
  <data id="build_spectrum">
    <embeddedGrammar>
      <iterator>
        <code>
          # we receive a pubDID in self.sourceToken["ssa_pubDID"];
          # the physical accref is behind its "?", potentially URL-encoded.

          sourcePath = os.path.join(
            base.getConfig("inputsDir"),
            urllib.decode(
              self.sourceToken["ssa_pubDID"].split('?', 1)[-1]))

          #% add code returning rowdicts from sourcePath %
          # this could be something like
          colNames = ["spectral", "flux"]
          with open(sourcePath) as f:
           for ln in f:
             yield dict(zip(colNames, [float(s) for s in ln.split()]))
          # make sure any further the names match what you gave
          # in the instance table def.
        </code>
      </iterator>
    </embeddedGrammar>
    <make table="instance">
      <parmaker>
        <apply procDef="//ssap#feedSSAToSDM"/>
      </parmaker>
    </make>
  </data>
-->


<data id="build_spectrum">
  <embeddedGrammar>
    <iterator>
      <code>
        # we receive a pubDID in self.sourceToken["ssa_pubDID"];
        # the physical accref is behind its "?", potentially URL-encoded.

        sourcePath = os.path.join(
            base.getConfig("inputsDir"),
            urllib.parse.unquote(
                self.sourceToken["ssa_pubDID"].split('?', 1)[-1]))

        # Using astropy to read the FITS file
        from astropy.io import fits
        with fits.open(sourcePath) as hdulist:
            # Assuming the data you want is in the primary HDU.
            # Adjust as needed.
            data = hdulist[0].data

        # If data is 2D (an image), you'll need to decide how you want
        # to handle it. This example simply returns the raw 2D data array.
        for row in data:
            yield {"image_data": row}
      </code>
    </iterator>
  </embeddedGrammar>
  <make table="instance">
    <parmaker>
      <apply procDef="//ssap#feedSSAToSDM"/>
    </parmaker>
  </make>
</data>

  <!-- the datalink service spitting out SDM spectra (and other formats
    on request) -->
  <service id="sdl" allowed="dlget,dlmeta">
    <meta name="title">\schema Datalink Service</meta>
    <datalinkCore>
      <descriptorGenerator procDef="//soda#sdm_genDesc">
        <bind key="ssaTD">"\rdId#data"</bind>
      </descriptorGenerator>
      <dataFunction procDef="//soda#sdm_genData">
        <bind key="builder">"\rdId#build_spectrum"</bind>
      </dataFunction>
      <FEED source="//soda#sdm_plainfluxcalib"/>
      <FEED source="//soda#sdm_cutout"/>
      <FEED source="//soda#sdm_format"/>
    </datalinkCore>
  </service>

  <!-- a form-based service – this is made totally separate from the
  SSA part because grinding down SSA to something human-consumable and
  still working as SSA is non-trivial -->
  <service id="web" defaultRenderer="form">
    <meta name="shortName">\schema Web</meta>

    <dbCore queriedTable="data">
      <condDesc buildFrom="ssa_location"/>
      <condDesc buildFrom="ssa_dateObs"/>
      <!-- add further condDescs in this pattern; if you have useful target
      names, you'll probably want to index them and say:

      <condDesc>
        <inputKey original="data.ssa_targname" tablehead="Standard Stars">
          <values fromdb="ssa_targname from theossa.data
            order by ssa_targname"/>
        </inputKey>
      </condDesc> -->
    </dbCore>

    <outputTable>
      <autoCols> ssa_targname,
                 target_ra, target_dec,
                accref, ssa_dateObs </autoCols>
      <!--<FEED source="//ssap#atomicCoords"/>-->
    </outputTable>
  </service>

  <service id="ssa" allowed="form,ssap.xml">
    <meta name="shortName">\schema SSAP</meta>
    <meta name="ssap.complianceLevel">full</meta>

    <publish render="ssap.xml" sets="ivo_managed"/>
    <publish render="form" sets="ivo_managed,local" service="web"/>

    <ssapCore queriedTable="data">
     <!-- <property key="previews">auto%delete this line if you have no previews; else delete just this.%</property>-->
      <FEED source="//ssap#hcd_condDescs"/>
    </ssapCore>
  </service>

  <regSuite title="spectra_agn_archive regression">
    <!-- see http://docs.g-vo.org/DaCHS/ref.html#regression-testing
      for more info on these. -->

    <regTest title="spectra_agn_archive SSAP serves some data">
      <url REQUEST="queryData" PUBLISHERDID="%a value you have in ssa_pubDID%"
        >ssa/ssap.xml</url>
      <code>
        <!-- to figure out some good strings to use here, run
          dachs test -k SSAP -D tmp.xml q
          and look at tmp.xml -->
        self.assertHasStrings(
          "%some characteristic string returned by the query%",
          "%another characteristic string returned by the query%")
      </code>
    </regTest>

    <regTest title="spectra_agn_archive Datalink metadata looks about right.">
      <url ID="%a value you have in ssa_pubDID%"
        >sdl/dlmeta</url>
      <code>
        <!-- to figure out some good strings to use here, run
          dachs test -k datalink -D tmp.xml q
          and look at tmp.xml -->
        self.assertHasStrings(
          "%some characteristic string in the datalink meta%")
      </code>
    </regTest>

    <regTest title="spectra_agn_archive delivers some data.">
      <url ID="%a value you have in ssa_pubDID%"
        >sdl/dlget</url>
      <code>
        <!-- to figure out some good strings to use here, run
          dachs test -k "delivers data" -D tmp.xml q
          and look at tmp.xml -->
        self.assertHasStrings(
          "%some characteristic string in the datalink meta%")
      </code>
    </regTest>

    <!-- add more tests: form-based service renders custom widgets, etc. -->
  </regSuite>
</resource>

