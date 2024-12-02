<?xml version="1.0" encoding="utf-8"?>

<resource schema="pulsars" resdir=".">
    <meta name="title">Galactic X-ray pulsars</meta>
    <meta name="creationDate">2024-11-25T12:00:00Z</meta>
    <meta name="description" format="plain">
        Catalog of Galactic population of persistent and transient X-ray pulsars in HMXB systems
    </meta>
    <meta name="subject">pulsars</meta>
    <meta name="type">service</meta>

    <!-- Table Definition -->
    <table id="combined_table">
        <column name="Number" type="integer" description="Catalog number of the object" />
        <column name="Name" type="text" description="Name of the object" />
        <column name="RAh" type="integer" description="Right Ascension hour (J2000)" />
        <column name="RAm" type="integer" description="Right Ascension minute (J2000)" />
        <column name="RAs" type="double precision" description="Right Ascension second (J2000)" />
        <column name="DE_sign" type="text" description="Declination sign (J2000)" />
        <column name="DEd" type="integer" description="Declination degree (J2000)" />
        <column name="DEm" type="integer" description="Declination arcminute (J2000)" />
        <column name="DEs" type="double precision" description="Declination arcsecond (J2000)" />
        <column name="Ps" type="double precision" description="Spin period (seconds)" />
        <column name="e_Ps" type="double precision" description="Error in spin period (seconds)" />
        <column name="PsYr" type="integer" description="Year of spin period measurement" />
        <column name="r_Ps" type="text" description="Reference for spin period" />
        <column name="PLocSpDown" type="double precision" description="Local spin-down period (seconds)" />
        <column name="e_PLocSpDown" type="double precision" description="Error in local spin-down period" />
        <column name="PLocSpDownStart" type="integer" description="Start date of local spin-down period measurement (YYYYMMDD)" />
        <column name="PLocSpDownStop" type="integer" description="End date of local spin-down period measurement (YYYYMMDD)" />
        <column name="r_PLocSpDown" type="text" description="Reference for local spin-down period" />
        <column name="PLocSpUpsign" type="text" description="Sign of local spin-up period" />
        <column name="PLocSpUp" type="double precision" description="Local spin-up period (seconds)" />
        <column name="e_PLocSpUp" type="double precision" description="Error in local spin-up period" />
        <column name="PLocSpUpStart" type="integer" description="Start date of local spin-up period measurement (YYYYMMDD)" />
        <column name="PLocSpUpStop" type="integer" description="End date of local spin-up period measurement (YYYYMMDD)" />
        <column name="r_PLocSpUp" type="text" description="Reference for local spin-up period" />
        <column name="PGloSpDown" type="double precision" description="Global spin-down period (seconds)" />
        <column name="e_PGloSpDown" type="double precision" description="Error in global spin-down period" />
        <column name="PGloSpDownStart" type="integer" description="Start date of global spin-down period measurement (YYYYMMDD)" />
        <column name="PGloSpDownStop" type="integer" description="End date of global spin-down period measurement (YYYYMMDD)" />
        <column name="r_PGloSpDown" type="text" description="Reference for global spin-down period" />
        <column name="PGloSpUpsign" type="text" description="Sign of global spin-up period" />
        <column name="PGloSpUp" type="double precision" description="Global spin-up period (seconds)" />
        <column name="e_PGloSpUp" type="double precision" description="Error in global spin-up period" />
        <column name="PGloSpUpStart" type="integer" description="Start date of global spin-up period measurement (YYYYMMDD)" />
        <column name="PGloSpUpStop" type="integer" description="End date of global spin-up period measurement (YYYYMMDD)" />
        <column name="r_PGloSpUp" type="text" description="Reference for global spin-up period" />
        <column name="POrbsign" type="text" description="Sign of orbital period" />
        <column name="POrbLower" type="double precision" description="Lower limit of orbital period (days)" />
        <column name="POrbUpper" type="double precision" description="Upper limit of orbital period (days)" />
        <column name="POrbErr" type="double precision" description="Error in orbital period (days)" />
        <column name="POrbRef" type="text" description="Reference for orbital period" />
        <column name="LXLower" type="double precision" description="Lower limit of X-ray luminosity (erg/s)" />
        <column name="LXUpper" type="double precision" description="Upper limit of X-ray luminosity (erg/s)" />
        <column name="LXRange" type="text" description="Range of X-ray luminosity" />
        <column name="LXRef" type="text" description="Reference for X-ray luminosity" />
        <column name="Bsign" type="text" description="Sign of magnetic field strength" />
        <column name="BLower" type="double precision" description="Lower limit of magnetic field strength (Gauss)" />
        <column name="BUpper" type="double precision" description="Upper limit of magnetic field strength (Gauss)" />
        <column name="BErr" type="double precision" description="Error in magnetic field strength (Gauss)" />
        <column name="BRef" type="text" description="Reference for magnetic field strength" />
        <column name="Distsign" type="text" description="Sign of distance measurement" />
        <column name="DistLower" type="double precision" description="Lower limit of distance (parsecs)" />
        <column name="DistUpper" type="double precision" description="Upper limit of distance (parsecs)" />
        <column name="DistError" type="double precision" description="Error in distance (parsecs)" />
        <column name="DistRef" type="text" description="Reference for distance measurement" />
        <column name="CompName" type="text" description="Name of the companion object" />
        <column name="CompNameClass" type="text" description="Classification of the companion object" />
        <column name="CompNameRef" type="text" description="Reference for companion object name" />
        <column name="CompBmag" type="double precision" description="Companion B-band magnitude" />
        <column name="e_CompBmag" type="double precision" description="Error in companion B-band magnitude" />
        <column name="CompVmag" type="double precision" description="Companion V-band magnitude" />
        <column name="e_CompVmag" type="double precision" description="Error in companion V-band magnitude" />
        <column name="CompRmag" type="double precision" description="Companion R-band magnitude" />
        <column name="e_CompRmag" type="double precision" description="Error in companion R-band magnitude" />
        <column name="CompImag" type="double precision" description="Companion I-band magnitude" />
        <column name="e_CompImag" type="double precision" description="Error in companion I-band magnitude" />
        <column name="CompBVRImagRef" type="text" description="Reference for companion B, V, R, I magnitudes" />
        <column name="CompJmag" type="double precision" description="Companion J-band magnitude" />
        <column name="e_CompJmag" type="double precision" description="Error in companion J-band magnitude" />
        <column name="CompHmag" type="double precision" description="Companion H-band magnitude" />
        <column name="e_CompHmag" type="double precision" description="Error in companion H-band magnitude" />
        <column name="CompKmag" type="double precision" description="Companion K-band magnitude" />
        <column name="e_CompKmag" type="double precision" description="Error in companion K-band magnitude" />
        <column name="CompJHKmagRef" type="text" description="Reference for companion J, H, K magnitudes" />
        <column name="ExtBminusV" type="double precision" description="Color excess E(B−V)" />
        <column name="e_ExtBminusV" type="double precision" description="Error in color excess E(B−V)" />
        <column name="r_ExtBminusV" type="text" description="Reference for color excess E(B−V)" />
        <column name="persistent" type="boolean" description="Persistent flag (1 for True, 0 for False)" />
    </table>

    <!-- Service Definition -->
    <service id="combined_data_service" allowed="form">
        <meta name="shortName">combined_data</meta>
        <customCore module="res/combined_core"/>
        <!-- Publishing Information -->
        <publish sets="local,ivo_managed" render="form"/>
    </service>
</resource>

