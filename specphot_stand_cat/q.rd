<resource schema="specphot_stand_cat" resdir=".">
  <meta name="creationDate">2025-02-18T11:26:45Z</meta>

  <meta name="title">Spectrophotometric Standard Stars Catalog</meta>
<!-- ==SETUP== think about <meta name="longdoc" format="rst">-->
  <meta name="description" format="rst">
    The **Spectrophotometric Catalogue of Stars** (A.V. Kharitonov, V.M. Tereshenko, L.N. Knyazeva, 2011) provides calibrated monochromatic irradiances for bright northern-hemisphere stars and is intended for absolute/relative flux calibration of spectra and photometry.

    **Content (one row per star):**

    * Identifiers: sequential catalogue number, common name (if any), **BS** and **HD** numbers.

    * Astrometry: J2000.0 right ascension and declination (also given in decimal degrees as *raj2000*, *dej2000*).

    * Photometry and classification: visual magnitude **V**, colour index **B−V**, spectral type, trigonometric parallax (when available).

    * Notes/flags: *st_ds* (short classification/remarks), *n* (mantissa exponent; see below).

    * Spectrophotometry: monochromatic irradiances **F_λ** at fixed wavelengths from **3225 Å to 7575 Å** in **50 Å** steps (columns *f3225*, *f3275*, …, *f7575*). Values are given as **mantissae**; the full physical value is

      *F_λ = mantissa × 10^{-6}* in units of **W·m⁻²·m⁻¹**.

    **Intended use:**

    * Absolute/relative flux calibration of long-slit and fiber spectra.

    * Cross-checks of instrumental response and atmospheric extinction curves.

    * Educational and research tasks in stellar astrophysics.

    **Coverage:**

    * Wavelength grid: 3225–7575 Å, Δλ = 50 Å, continuous per star.

    * Typical targets: bright standards of spectral classes **O–M**, luminosity classes **I–V**.

  </meta>
  <meta name="subject">standard-stars</meta>
  <meta name="subject">spectrophotometry</meta>
  <meta name="subject">spectrophotometric-standards</meta>
  <meta name="creator">Kharitonov, A.V.; Tereschenko, V.M.; Knyazeva, L.N.</meta>
  <meta name="instrument">Goerz 50-cm reflector telescope</meta>
  <meta name="facility">Fesenkov Astrophysical Institute</meta>

  <meta name="source">1988scsb.book.....K</meta>
  <meta name="contentLevel">Research</meta>
  <meta name="type">Catalog</meta>  <!-- or Archive, Survey, Simulation -->
  <meta name="coverage.waveband">Optical</meta>

  <table id="main" onDisk="True" adql="True">
    <column name="number"
      type="integer"
      ucd="meta.id"
      tablehead="Number"
      description="Sequential number in the catalog">
      <values nullLiteral="-1"/>
      </column>
    <column name="name"
      type="text"
      ucd="meta.id;meta.main"
      tablehead="Object"
      description="Star name"
      required="False"/>
    <column name="bs"
      type="text"
      ucd="meta.id"
      tablehead="BS"
      description="Bright Star (BS) catalog number"
      required="False"/>
    <column name="hd"
      type="text"
      ucd="meta.id;meta.main"
      tablehead="HD"
      description="Henry Draper (HD) catalog number (primary)"
      required="False"/>
    <column name="raj2000"
      type="double precision"
      unit="deg"
      ucd="pos.eq.ra;meta.main"
      tablehead="RA (J2000)"
      displayHint="type=hms"
      description="Right Ascension J2000"/>
    <column name="dej2000"
      type="double precision"
      unit="deg"
      ucd="pos.eq.dec;meta.main"
      tablehead="DEC"
      displayHint="type=dms"
      description="Declination J2000"/>
    <column name="vmag"
      type="double precision"
      unit="mag"
      ucd="phot.mag"
      tablehead="V"
      description="V magnitude"/>
    <column name="b_v"
      type="double precision"
      unit="mag"
      tablehead="B-V"
      ucd="phot.color"
      description="B−V color index"/>
    <column name="parallax"
      type="integer"
      unit="mas"
      ucd="pos.parallax"
      tablehead="Parallax"
      description="Parallax">
      <values nullLiteral="9999"/>
      </column>
    <column name="sp_type"
      type="text"
      ucd="src.spType"
      tablehead="Sp type"
      description="Spectral type"/>
    <column name="st_ds"
      type="text"
      ucd="meta.code"
      description="Standard-star mark. β Ari - A, γ Ori - R, β Tau - T, α Leo - L, η UMa - U, α Lyr - Y, α Aql - Q, α Peg - P, HD221525 - H"/>
    <column name="n"
      type="text"
      ucd="arith.factor"
      tablehead="n"
      description="Order of magnitude factor for monochromatic illuminances; given in table header as 10^(-n), to be applied to flux mantissas"/>
    <column name="f3225" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl"
            description="Mantissa of monochromatic irradiance F_lambda at 3225 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f3275" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 3275 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f3325" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 3325 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f3375" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 3375 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f3425" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 3425 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f3475" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 3475 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f3525" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 3525 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f3575" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 3575 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f3625" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 3625 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f3675" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 3675 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f3725" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 3725 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f3775" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 3775 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f3825" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 3825 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f3875" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 3875 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f3925" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 3925 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f3975" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 3975 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f4025" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 4025 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f4075" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 4075 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f4125" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 4125 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f4175" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 4175 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f4225" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 4225 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f4275" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 4275 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f4325" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 4325 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f4375" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 4375 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f4425" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 4425 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f4475" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 4475 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f4525" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 4525 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f4575" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 4575 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f4625" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 4625 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f4675" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 4675 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f4725" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 4725 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f4775" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 4775 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f4825" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 4825 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f4875" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 4875 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f4925" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 4925 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f4975" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 4975 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f5025" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 5025 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f5075" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 5075 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f5125" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 5125 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f5175" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 5175 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f5225" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 5225 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f5275" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 5275 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f5325" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 5325 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f5375" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 5375 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f5425" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 5425 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f5475" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 5475 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f5525" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 5525 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f5575" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 5575 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f5625" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 5625 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f5675" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 5675 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f5725" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 5725 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f5775" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 5775 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f5825" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 5825 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f5875" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 5875 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f5925" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 5925 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f5975" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 5975 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f6025" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 6025 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f6075" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 6075 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f6125" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 6125 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f6175" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 6175 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f6225" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 6225 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f6275" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 6275 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f6325" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 6325 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f6375" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 6375 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f6425" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 6425 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f6475" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 6475 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f6525" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 6525 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f6575" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 6575 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f6625" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 6625 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f6675" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 6675 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f6725" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 6725 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f6775" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 6775 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f6825" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 6825 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f6875" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 6875 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f6925" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 6925 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f6975" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 6975 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f7025" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 7025 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f7075" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 7075 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f7125" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 7125 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f7175" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 7175 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f7225" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 7225 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f7275" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 7275 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f7325" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 7325 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f7375" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 7375 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f7425" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 7425 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f7475" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 7475 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f7525" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 7525 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
    <column name="f7575" type="double precision" unit="W.m**-2.m**-1" ucd="phot.flux.density;em.wl" description="Mantissa of monochromatic irradiance F_lambda at 7575 Å; multiply by 10^{-6}."><values nullLiteral="0"/></column>
  </table>

  <data id="import">
    <sources pattern="data/specphot_stand_cat_Tereshenko.csv"/>
    <csvGrammar/>

    <make table="main">
      <rowmaker id="rm">
        <!-- RA/Dec в градусах без regex и промежуточных var -->
        <map key="raj2000">(@RA  and hmsToDeg(str(@RA)))</map>
        <map key="dej2000">(@DEC and dmsToDeg(str(@DEC).replace("−","-")))</map>
        <map key="number">@Number</map>
        <map key="name">@Name</map>
        <map key="bs">(str(@BS).strip() or None)</map>
        <map key="hd">(str(@HD_1).strip() or None)</map>
        <map key="vmag">((@V is not None and @V.replace(" ","") not in ("", "-", "–")) and float(@V.replace(" ","")) or None)</map>
        <map key="b_v" source="B-V"/>
        <map key="parallax">((@Parallax is not None and @Parallax.strip() not in ("", "-", "–")) and float(@Parallax.strip()) or None)</map>
        <map key="sp_type">(str(@Sp).strip() or None)</map>
        <map key="st_ds" source="St-ds"/>
        <map key="n">@n</map>

        <map key="f3225" source="3225"/>
        <map key="f3275" source="3275"/>
        <map key="f3325" source="3325"/>
        <map key="f3375" source="3375"/>
        <map key="f3425" source="3425"/>
        <map key="f3475" source="3475"/>
        <map key="f3525" source="3525"/>
        <map key="f3575" source="3575"/>
        <map key="f3625" source="3625"/>
        <map key="f3675" source="3675"/>
        <map key="f3725" source="3725"/>
        <map key="f3775" source="3775"/>
        <map key="f3825" source="3825"/>
        <map key="f3875" source="3875"/>
        <map key="f3925" source="3925"/>
        <map key="f3975" source="3975"/>
        <map key="f4025" source="4025"/>
        <map key="f4075" source="4075"/>
        <map key="f4125" source="4125"/>
        <map key="f4175" source="4175"/>
        <map key="f4225" source="4225"/>
        <map key="f4275" source="4275"/>
        <map key="f4325" source="4325"/>
        <map key="f4375" source="4375"/>
        <map key="f4425" source="4425"/>
        <map key="f4475" source="4475"/>
        <map key="f4525" source="4525"/>
        <map key="f4575" source="4575"/>
        <map key="f4625" source="4625"/>
        <map key="f4675" source="4675"/>
        <map key="f4725" source="4725"/>
        <map key="f4775" source="4775"/>
        <map key="f4825" source="4825"/>
        <map key="f4875" source="4875"/>
        <map key="f4925" source="4925"/>
        <map key="f4975" source="4975"/>
        <map key="f5025" source="5025"/>
        <map key="f5075" source="5075"/>
        <map key="f5125" source="5125"/>
        <map key="f5175" source="5175"/>
        <map key="f5225" source="5225"/>
        <map key="f5275" source="5275"/>
        <map key="f5325" source="5325"/>
        <map key="f5375" source="5375"/>
        <map key="f5425" source="5425"/>
        <map key="f5475" source="5475"/>
        <map key="f5525" source="5525"/>
        <map key="f5575" source="5575"/>
        <map key="f5625" source="5625"/>
        <map key="f5675" source="5675"/>
        <map key="f5725" source="5725"/>
        <map key="f5775" source="5775"/>
        <map key="f5825" source="5825"/>
        <map key="f5875" source="5875"/>
        <map key="f5925" source="5925"/>
        <map key="f5975" source="5975"/>
        <map key="f6025" source="6025"/>
        <map key="f6075" source="6075"/>
        <map key="f6125" source="6125"/>
        <map key="f6175" source="6175"/>
        <map key="f6225" source="6225"/>
        <map key="f6275" source="6275"/>
        <map key="f6325" source="6325"/>
        <map key="f6375" source="6375"/>
        <map key="f6425" source="6425"/>
        <map key="f6475" source="6475"/>
        <map key="f6525" source="6525"/>
        <map key="f6575" source="6575"/>
        <map key="f6625" source="6625"/>
        <map key="f6675" source="6675"/>
        <map key="f6725" source="6725"/>
        <map key="f6775" source="6775"/>
        <map key="f6825" source="6825"/>
        <map key="f6875" source="6875"/>
        <map key="f6925" source="6925"/>
        <map key="f6975" source="6975"/>
        <map key="f7025" source="7025"/>
        <map key="f7075" source="7075"/>
        <map key="f7125" source="7125"/>
        <map key="f7175" source="7175"/>
        <map key="f7225" source="7225"/>
        <map key="f7275" source="7275"/>
        <map key="f7325" source="7325"/>
        <map key="f7375" source="7375"/>
        <map key="f7425" source="7425"/>
        <map key="f7475" source="7475"/>
        <map key="f7525" source="7525"/>
        <map key="f7575" source="7575"/>
      </rowmaker>
    </make>
  </data>

  <service id="q" allowed="form">
    <meta name="shortName">SpecPhotCat</meta>

    <publish render="form" sets="ivo_managed, local"/>

    <dbCore queriedTable="main">
      <condDesc buildFrom="raj2000"/>
      <condDesc buildFrom="dej2000"/>
      <condDesc buildFrom="name"/>
      <condDesc buildFrom="bs"/>
      <condDesc buildFrom="hd"/>
      <condDesc buildFrom="vmag"/>
      <condDesc buildFrom="parallax"/>
      <condDesc buildFrom="sp_type"/>
    </dbCore>
  </service>

  <regSuite title="specphot_stand_cat regression">
    
    <regTest title="TAP returns expected columns">
      <url parSet="TAP"
        QUERY="SELECT TOP 1 raj2000, dej2000, name, bs, hd, vmag, b_v, parallax, sp_type
                FROM specphot_stand_cat.main">/tap/sync</url>
      <code>
        row = self.getFirstVOTableRow()

        ra = float(row["raj2000"])
        dec = float(row["dej2000"])

        self.assertTrue(0.0 &lt;= ra and ra &lt; 360.0)
        self.assertTrue(-90.0 &lt;= dec and dec &lt;= 90.0)
        self.assertNotEqual(str(row["name"]).strip(), "")
      </code>
    </regTest>

    <regTest title="Photometry values are numeric">
      <url parSet="TAP"
           QUERY="SELECT vmag, b_v FROM specphot_stand_cat.main
                  WHERE Name='30 epsilon And'">
        /tap/sync
      </url>
      <code>
        row = self.getFirstVOTableRow()
        self.assertAlmostEqual(row["vmag"],4.37)
        self.assertAlmostEqual(row["b_v"],0.87)
      </code>
    </regTest>

  </regSuite>
</resource>
