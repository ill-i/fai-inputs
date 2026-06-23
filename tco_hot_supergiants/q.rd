<resource schema="tco_hot_supergiants" resdir=".">
  <meta name="creationDate">2026-06-11T09:15:53Z</meta>

  <meta name="title">TCO Echelle Spectra of Hot Supergiants</meta>

  <meta name="description" format="rst">
Spectral Archive of Hot Galactic Supergiants (TCO Node)

This resource provides a digital archive of one-dimensional (1D) optical spectra of hot galactic supergiants, obtained at the Three College Observatory (TCO). The archive is integrated into the Kazakhstan National Virtual Observatory (KazVO) data services and optimized for the IVOA Simple Spectral Access Protocol (SSAP).

**Data Specification:**

* Data Type: Medium-resolution optical echelle spectra.
* File Format: FITS (Flexible Image Transport System).
* Data Representation: 1D merged (stitched) spectra.
* Flux Calibration: Relative intensity, normalized to the continuum.

**Observational Setup and Instrumentation:**

* Observatory: Three College Observatory (TCO), North Carolina, USA
* Telescope: 0.81-m Ritchey-Chretien telescope
* Instrument: Fiber-fed echelle spectrograph eShel
* Spectrograph Manufacturer: Shelyak Instruments

**Spectral Characteristics:**

* Spectral Range: Approximately 3900 - 7800 Angstroms (precise wavelength boundaries are frame-dependent and fixed within individual FITS headers).
* Spectral Resolution: R approx 12,000.
* Wavelength Calibration: Executed using a Thorium-Argon (ThAr) reference lamp spectrum.

**Data Reduction Pipeline:**

Primary and scientific data reduction was performed within the IRAF (Image Reduction and Analysis Facility) environment using standard echelle spectroscopy packages.

**Key Reduction Steps:**

1. Pre-processing: Bias frame subtraction.
2. Extraction: Localization and extraction of individual echelle orders.
3. Dispersion Relation: Wavelength calibration based on ThAr reference frames.
4. Order Merging: Stitching of discrete spectral orders into a continuous 1D array.
5. Kinematic Correction: Application of the heliocentric velocity correction (documented under the VHELIO FITS header keyword).
6. Continuum Normalization: Continuum flattening achieved via high-order polynomial fitting.
  </meta>

  <meta name="subject">stellar-spectroscopy</meta>
  <meta name="subject">supergiant-stars</meta>
  <meta name="subject">echelle-spectroscopy</meta>
  <meta name="subject">hot-stars</meta>

  <meta name="creator">Danford, S.; Miroshnichenko, A.</meta>
  <meta name="instrument">eShel spectrograph</meta>
  <meta name="facility">Three College Observatory</meta>

  <meta name="contentLevel">Research</meta>
  <meta name="type">Archive</meta>  

  <meta name="coverage.waveband">Optical</meta>

  <meta name="ssap.dataSource">pointed</meta>
  <meta name="ssap.creationType">spectralExtraction</meta>
  <meta name="productType">spectrum</meta>
  <meta name="ssap.testQuery">MAXREC=1</meta>

  <table id="raw_data" onDisk="True" adql="hidden" namePath="//ssap#instance">

    <LOOP listItems="
      ssa_dateObs
      ssa_dstitle
      ssa_targname
      ssa_length
      ssa_specstart
      ssa_specend
      ssa_specres
      ssa_timeExt
      ssa_pubDID
    ">
      <events>
        <column original="\item"/>
      </events>
    </LOOP>

    <mixin>//products#table</mixin>
    <mixin>//ssap#plainlocation</mixin>
    <mixin>//ssap#simpleCoverage</mixin>

    <FEED source="//scs#splitPosIndex"
      columns="ssa_location"
      long="degrees(long(ssa_location))"
      lat="degrees(lat(ssa_location))"/>

    <column name="datalink" type="text"
      ucd="meta.ref.url"
      tablehead="DataLink"
      description="A DataLink document for this spectrum, providing SODA access and the original file."
      verbLevel="15"
      displayHint="type=url">
      <property name="targetType">application/x-votable+xml;content=datalink</property>
      <property name="targetTitle">DataLink</property>
    </column>

    <column name="wave_min"
      type="double precision"
      unit="m"
      ucd="em.wl;stat.min"
      tablehead="λ min"
      description="Minimum wavelength covered by the spectrum."
      verbLevel="15"/>

    <column name="wave_max"
      type="double precision"
      unit="m"
      ucd="em.wl;stat.max"
      tablehead="λ max"
      description="Maximum wavelength covered by the spectrum."
      verbLevel="15"/>

    <column name="specrp"
      type="real"
      ucd="spect.resolution"
      tablehead="R"
      description="Spectral resolving power lambda/dlambda."
      verbLevel="15"/>

    <column name="calib_level"
      type="smallint"
      tablehead="Calib Level"
      ucd="meta.code.qual"
      required="True"
      description="ObsCore-style calibration level. Merged relative flux spectra are level 2."
      verbLevel="15"/>

    <column name="origfile"
      type="text"
      ucd="meta.id"
      tablehead="Original file"
      description="Original FITS file name before KazVO metadata enrichment."
      verbLevel="25"/>

    <column name="puborg"
      type="text"
      ucd="meta.curation"
      tablehead="Publisher"
      description="Publishing archive or organisation."
      verbLevel="25"/>

    <column name="dataorig"
      type="text"
      ucd="meta.note"
      tablehead="Data origin"
      description="Origin of the data with respect to KazVO/FAI."
      verbLevel="25"/>

    <column name="observer"
      type="text"
      ucd="meta.id;obs.observer"
      tablehead="Observer"
      description="Observer(s) listed in the FITS header."
      verbLevel="15"/>

    <column name="telescope"
      type="text"
      ucd="instr.tel"
      tablehead="Telescope"
      description="Telescope used for the observation."
      verbLevel="15"/>

    <column name="instrument"
      type="text"
      ucd="instr"
      tablehead="Instrument"
      description="Instrument or spectrograph used for the observation."
      verbLevel="15"/>

    <column name="camera"
      type="text"
      ucd="meta.id;instr.det"
      tablehead="Camera"
      description="Camera listed in the FITS header."
      verbLevel="25"/>

    <column name="detnam"
      type="text"
      ucd="meta.id;instr.det"
      tablehead="Detector"
      description="Detector name listed in the FITS header."
      verbLevel="25"/>

    <column name="bunit"
      type="text"
      ucd="meta.unit"
      tablehead="Flux unit"
      description="Flux unit from the enriched FITS header."
      verbLevel="15"/>

    <column name="norm"
      type="boolean"
      ucd="meta.code"
      tablehead="Normalized"
      required="True"
      description="True if the merged spectrum is continuum-normalized."
      verbLevel="15"/>

    <column name="wavecal"
      type="boolean"
      ucd="meta.code"
      tablehead="Wavecal"
      required="True"
      description="True if the spectrum is wavelength calibrated."
      verbLevel="25"/>

    <column name="fluxcal"
      type="text"
      ucd="meta.code"
      tablehead="Flux calibration"
      description="Flux calibration status from the enriched FITS header."
      verbLevel="15"/>

    <column name="biascor"
      type="boolean"
      ucd="meta.code"
      tablehead="Bias corrected"
      required="True"
      description="True if bias correction was applied."
      verbLevel="25"/>

    <column name="darkcor"
      type="boolean"
      ucd="meta.code"
      tablehead="Dark corrected"
      required="True"      
      description="True if dark correction was applied."
      verbLevel="25"/>

    <column name="bpixcor"
      type="boolean"
      ucd="meta.code"
      tablehead="Bad pixels"
      required="True"
      description="True if bad-pixel map correction was applied."
      verbLevel="25"/>

    <column name="flatcor"
      type="boolean"
      ucd="meta.code"
      tablehead="Flat corrected"
      required="True"
      description="True if flat-field correction was applied."
      verbLevel="25"/>

    <column name="cosmicr"
      type="text"
      ucd="meta.code"
      tablehead="Cosmic rays"
      description="Cosmic ray removal method."
      verbLevel="25"/>

    <column name="tellcor"
      type="boolean"
      ucd="meta.code"
      tablehead="Telluric corrected"
      required="True"
      description="True if telluric correction was applied."
      verbLevel="25"/>

    <column name="helcor"
      type="boolean"
      ucd="meta.code"
      tablehead="Heliocentric corrected"
      required="True"
      description="True if heliocentric correction was applied."
      verbLevel="25"/>
  </table>

  <procDef type="apply" id="read_sidecar">
    <setup>
      <code>
        import os
        import warnings
        from astropy.io import fits as pyfits
        from astropy.utils.exceptions import AstropyWarning
        from astropy.coordinates import Angle
        import astropy.units as u
      </code>
    </setup>
    <code>
      rel_path = vars.get("prodtar") or vars.get("accref")
      if not rel_path:
          return
          
      hdr_path = os.path.join(base.getConfig("inputsDir"), rel_path + ".hdr")
      
      vars["safe_ra"] = None
      vars["safe_dec"] = None
      
      if os.path.exists(hdr_path):
          with warnings.catch_warnings():
              warnings.simplefilter('ignore', AstropyWarning)
              try:
                  hdr = pyfits.Header.fromtextfile(hdr_path)
                  for k, v in hdr.items():
                      if k and k not in ["COMMENT", "HISTORY"]:
                          vars["hdr_" + k.replace("-", "_")] = v
              except Exception:
                  pass
                  
      raw_ra = vars.get("hdr_RA") or vars.get("RA")
      raw_dec = vars.get("hdr_DEC") or vars.get("DEC")
      

      # Robustly clean coordinate strings and bind them to BOTH namespaces
      if raw_ra:
          try:
              clean_ra = str(raw_ra).split('/')[0].strip()
              deg_ra = Angle(clean_ra, unit=u.hourangle).degree
              vars["safe_ra"] = deg_ra
              row["safe_ra"] = deg_ra  # Exposes the variable to the @safe_ra macro lookup
          except Exception: pass
          
      if raw_dec:
          try:
              clean_dec = str(raw_dec).split('/')[0].strip()
              deg_dec = Angle(clean_dec, unit=u.deg).degree
              vars["safe_dec"] = deg_dec
              row["safe_dec"] = deg_dec  # Exposes the variable to the @safe_dec macro lookup
          except Exception: pass
    </code>
  </procDef>

  <data id="import">
    <property name="previewDir">previews</property>
    <sources recurse="True" pattern="data/*.fits"/>

    <fitsProdGrammar qnd="True">
      <rowfilter procDef="//products#define">
        <bind key="table">"\schema.raw_data"</bind>
        <bind key="fsize">180000</bind>
        <bind key="mime">"application/fits"</bind>
        <bind key="preview">\splitPreviewPath{png}</bind>
      </rowfilter>
      
      <rowfilter>
        <code>
          import os
          import warnings
          from astropy.io import fits as pyfits
          from astropy.utils.exceptions import AstropyWarning
          from astropy.coordinates import Angle
          import astropy.units as u

          # Relies strictly on the 'accref' key established by the macro above
          rel_path = row.get("accref")
          
          # Initialize safe coordinate keys to prevent mapping crashes
          row["safe_ra"] = None
          row["safe_dec"] = None

          if rel_path:
              # Reconstruct absolute paths safely using DaCHS standard configuration
              base_dir = base.getConfig("inputsDir")
              file_path = os.path.join(base_dir, rel_path)
              hdr_path = file_path + ".hdr"

              if os.path.exists(hdr_path):
                  with warnings.catch_warnings():
                      warnings.simplefilter('ignore', AstropyWarning)
                      try:
                          hdr = pyfits.Header.fromtextfile(hdr_path)
                          for k, v in hdr.items():
                              if k and k not in ["COMMENT", "HISTORY"]:
                                  # Prefix keys to expose them seamlessly to the rowmaker
                                  row["hdr_" + k.replace("-", "_")] = v
                      except Exception:
                          pass

          # Coordinate parsing and sanitization from sidecar or native headers
          raw_ra = row.get("hdr_RA") or row.get("RA")
          raw_dec = row.get("hdr_DEC") or row.get("DEC")

          if raw_ra:
              try:
                  clean_ra = str(raw_ra).split('/')[0].strip()
                  row["safe_ra"] = Angle(clean_ra, unit=u.hourangle).degree
              except Exception: pass
              
          if raw_dec:
              try:
                  clean_dec = str(raw_dec).split('/')[0].strip()
                  row["safe_dec"] = Angle(clean_dec, unit=u.deg).degree
              except Exception: pass

          yield row
        </code>
      </rowfilter>
    </fitsProdGrammar>

    <make table="raw_data">
      <rowmaker idmaps="*">
        
        <var key="specAx">getWCSAxis(@header_, 1)</var>
        <var key="targetName">str(vars.get("hdr_OBJECT") or vars.get("OBJECT") or vars.get("OBJNAME") or "UNKNOWN").strip()</var>

        <var key="waveMinM">vars.get("hdr_WAVE_MIN") or @specAx.pixToPhys(1)*1e-10</var>
        <var key="waveMaxM">vars.get("hdr_WAVE_MAX") or @specAx.pixToPhys(@specAx.axisLength)*1e-10</var>

        <var key="specMidM">(float(vars["waveMinM"]) + float(vars["waveMaxM"])) / 2.0</var>
        <var key="specResM">float(vars["specMidM"]) / float(vars.get("hdr_SPECRP") or 12000.0)</var>

        <apply procDef="//ssap#fill-plainlocation">
          <bind key="ra">@safe_ra</bind>
          <bind key="dec">@safe_dec</bind>
          <bind key="aperture">float(vars.get("hdr_APERTURE") or 0.813)</bind>
        </apply>

        <map key="ssa_dateObs">dateTimeToMJD(parseTimestamp(vars.get("hdr_DATE_OBS") or vars.get("DATE_OBS")))</map>
        <map key="ssa_dstitle">"{} eShel spectrum {}".format(vars["targetName"], str(vars.get("hdr_DATE_OBS") or vars.get("DATE_OBS") or "1900-01-01")[:10])</map>
        <map key="ssa_targname">vars["targetName"]</map>

        <map key="ssa_specstart">vars["waveMinM"]</map>
        <map key="ssa_specend">vars["waveMaxM"]</map>
        <map key="ssa_length">vars.get("hdr_NAXIS1") or vars.get("NAXIS1")</map>
        <map key="ssa_timeExt">vars.get("hdr_EXPTIME") or vars.get("EXPTIME") or vars.get("EXPOSURE")</map>
        <map key="ssa_specres">vars["specResM"]</map>
        <map key="ssa_pubDID">vars.get("hdr_PUBDID")</map>
        <map key="datalink">\dlMetaURI{sdl}</map>

        <map key="wave_min">vars["waveMinM"]</map>
        <map key="wave_max">vars["waveMaxM"]</map>
        <map key="specrp">vars.get("hdr_SPECRP") or 12000.0</map>
        
        <map key="calib_level">vars.get("hdr_CALIB_LEVEL") or 2</map>
        
        <map key="origfile">vars.get("hdr_ORIGFILE")</map>
        <map key="puborg">vars.get("hdr_PUBORG") or "KazVO"</map>
        <map key="dataorig">vars.get("hdr_DATAORIG") or "external"</map>
        <map key="observer">vars.get("hdr_OBSERVER") or vars.get("OBSERVER")</map>
        <map key="telescope">vars.get("hdr_TELESCOP") or vars.get("TELESCOP") or "TCO"</map>
        <map key="instrument">vars.get("hdr_INSTRUME") or vars.get("INSTRUME") or "eShel"</map>
        <map key="camera">vars.get("hdr_CAMERA") or vars.get("CAMERA")</map>
        <map key="detnam">vars.get("hdr_DETNAM") or vars.get("DETNAM")</map>
        <map key="bunit">vars.get("hdr_BUNIT") or "relative"</map>
        
        <map key="norm">True if vars.get("hdr_NORM") in [True, "True", "T"] else False</map>
        <map key="wavecal">True if vars.get("hdr_WAVECAL") in [True, "True", "T"] else True</map>
        <map key="fluxcal">vars.get("fluxcal") or vars.get("hdr_FLUXCAL") or "RELATIVE"</map>
        <map key="biascor">True if vars.get("hdr_BIASCOR") in [True, "True", "T"] else False</map>
        <map key="darkcor">True if vars.get("hdr_DARKCOR") in [True, "True", "T"] else False</map>
        <map key="bpixcor">True if vars.get("hdr_BPIXCOR") in [True, "True", "T"] else False</map>
        <map key="flatcor">True if vars.get("hdr_FLATCOR") in [True, "True", "T"] else False</map>
        <map key="cosmicr">vars.get("hdr_COSMICR") or "manual"</map>
        <map key="tellcor">True if vars.get("hdr_TELLCOR") in [True, "True", "T"] else False</map>
        <map key="helcor">True if vars.get("hdr_HELCOR") in [True, "True", "T"] else False</map>
      </rowmaker>
    </make>
  </data>

  <table id="data" onDisk="True" adql="True">
    <mixin 
      sourcetable="raw_data" 
      copiedcolumns="*"
      ssa_aperture="1/3600."
      ssa_fluxunit="'relative'"
      ssa_spectralunit="'m'"
      ssa_bandpass="'Optical'"
      ssa_collection="'KazVO eShel'"
      ssa_fluxcalib="'RELATIVE'"
      ssa_fluxucd="'phot.flux.density;em.wl'"
      ssa_speccalib="'CALIBRATED'"
      ssa_spectralucd="'em.wl;obs.atmos'"
      ssa_targclass="'star'"
    >//ssap#view</mixin>

    <mixin 
      calibLevel="2" 
      sResolution="ssa_spaceres" 
      oUCD="ssa_fluxucd" 
      emUCD="ssa_spectralucd"
    >//obscore#publishSSAPMIXC</mixin> 

    <meta name="_associatedDatalinkService">
      <meta name="serviceId">sdl</meta>
      <meta name="idColumn">ssa_pubDID</meta>
    </meta>

  </table>

  <data id="make_view">
    <make table="data">
      <script type="preIndex" lang="SQL">
        INSERT INTO \schema.data (SELECT * FROM \schema.raw_data)
      </script>
    </make>
  </data>


  <coverage> 
    <updater sourceTable="data"/> 
  </coverage>


  <table id="instance" onDisk="False">
    <mixin ssaTable="data"
      spectralDescription="'Wavelength in meters'"
      fluxDescription="'Relative flux'"
    >//ssap#sdm-instance</mixin>
    <meta name="description">1D merged relative flux eShel spectrum</meta>
  </table>

  <data id="build_spectrum" auto="False">
    <embeddedGrammar>
      <iterator>
        <setup imports="gavo.protocols.products,gavo.utils.pyfits,gavo.utils"/>
        <code>
          fitsPath = base.getConfig("inputsDir") / self.sourceToken["accref"]

          with pyfits.open(fitsPath) as hdus:
              ax = utils.getWCSAxis(hdus[0].header, 1)
              data = hdus[0].data

              for spec, flux in enumerate(data):
                  wl_meters = ax.pix0ToPhys(spec) * 1e-10
                  yield {"spectral": wl_meters, "flux": float(flux)}
        </code>
      </iterator>
    </embeddedGrammar>
    <make table="instance">
      <parmaker>
        <apply procDef="//ssap#feedSSAToSDM"/>
      </parmaker>
    </make>
  </data>

  <service id="sdl" allowed="dlget,dlmeta">
    <meta name="title">\schema Datalink Service</meta>
    <meta name="description">
      The TCO datalink provides an IVOA spectral data model rendering of the
      merged echelle spectra and cutout and reformatting operations.
    </meta>
    
    <datalinkCore>
      <descriptorGenerator procDef="//soda#sdm_genDesc">
        <bind key="ssaTD">"\rdId#data"</bind>
      </descriptorGenerator>
      
      <dataFunction procDef="//soda#sdm_genData">
        <bind key="builder">"\rdId#build_spectrum"</bind>
      </dataFunction>
      
      <FEED source="//soda#sdm_cutout"/>
      <FEED source="//soda#sdm_format"/>
      
      <metaMaker semantics="#derivation">
        <code>
          if descriptor.pubDID is None:
              return
          yield descriptor.makeLink(
              makeAbsoluteURL("\rdId/sdl/dlget?ID="+urllib.parse.quote(descriptor.pubDID)),
              contentType="application/x-votable+xml",
              description="Spectrum as SDM VOTable",
              contentLength=100000
          )
        </code>
      </metaMaker>
    </datalinkCore>
  </service>


  <service id="web" defaultRenderer="form">
    <meta name="shortName">\schema Web Portal</meta>

    <dbCore queriedTable="data">
      <condDesc buildFrom="ssa_location"/>
      <condDesc buildFrom="ssa_dateObs"/>
      <condDesc>
        <inputKey original="data.ssa_targname" tablehead="Target Object">
          <values fromdb="ssa_targname from \schema.data order by ssa_targname"/>
        </inputKey>
      </condDesc>
    </dbCore>

    <outputTable>
      <autoCols>accref, ssa_targname, ssa_dateObs, datalink</autoCols>
      <FEED source="//ssap#atomicCoords"/>
      
      <outputField original="ssa_specstart" displayHint="displayUnit=Angstrom"/>
      <outputField original="ssa_specend" displayHint="displayUnit=Angstrom"/>
    </outputTable>
  </service>


  <service id="ssa" allowed="form,ssap.xml">
    <meta name="shortName">TCO Hot SG SSAP</meta>
    <meta name="ssap.complianceLevel">full</meta>

    <publish render="ssap.xml" sets="ivo_managed"/>
    <publish render="form" sets="ivo_managed,local" service="web"/>

    <ssapCore queriedTable="data">
      <FEED source="//ssap#hcd_condDescs"/>
    </ssapCore>
  </service>

</resource>
