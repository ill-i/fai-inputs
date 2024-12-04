<?xml version="1.0" encoding="utf-8"?>

<resource schema="pulsars" resdir=".">
    <meta name="title">Galactic X-ray pulsars</meta>
    <meta name="creationDate">2024-11-25T12:00:00Z</meta>
    <meta name="description" format="plain">
        This catalog contains data on the Galactic population of 82 confirmed X-ray pulsars
        in high-mass X-ray binary (HMXB) systems, classified into 18 persistent and 64
        transient sources. Key parameters include spin periods, spin evolution (local and global
        trends), orbital periods, X-ray luminosities, magnetic fields, distances, and detailed
        companion star characteristics. The data have been compiled through cross-matching
        with recent HMXB catalogs and databases such as Fortin et al. (2023), Neumann et al.
        (2023), and Krivonos et al. (2022), supplemented with literature and SIMBAD database
        analysis. The catalog aims to support studies on stellar evolution, accretion processes,
        and binary dynamics.
    </meta>
    <meta name="subject">pulsars</meta>
    <meta name="type">service</meta>
    <meta name="bibcode" format="plain">2023ApJS..268...21K</meta>
    <!-- Table Definition -->
    <table id="main" onDisk="True" adql="True" mixin="//scs#pgs-pos-index">
        <column name="Number" type="integer" required="True"
            ucd="meta.id;meta.main"
            description="Catalog number of the object"
            verbLevel="1"/>
        <column name="Name" type="text"
            ucd="meta.id;meta.main"
            tablehead="Name"
            description="Name of the object"
            verbLevel="1" />
        <column name="ra" type="double precision"
            unit="deg" ucd="pos.eq.ra;meta.main"
            tablehead="RA"
            description="The pulsar's ICRS right ascension form XY?"
            verbLevel="1" displayHint="sf=7"/>
        <column name="dec" type="double precision"
            unit="deg" ucd="pos.eq.dec;meta.main"
            tablehead="Dec"
            description="The pulsar's ICRS right ascension form XY?"
            verbLevel="1" displayHint="type=dms,sf=1"/>
        <column name="Ps" type="double precision"
            unit="s" ucd="time.period.rotation"
            tablehead="P_s"
            description="Spin period of the pulsar"
            verbLevel="1" />
        <column name="e_Ps" type="double precision"
            unit="s" ucd="stat.error;time.period.rotation"
            tablehead="e_P_s"
            description="Error in spin period"
            verbLevel="15" />
        <column name="PsYr" type="integer"
       	    unit="yr"	
            ucd="time.epoch"
            tablehead="P_s_yr"
            description="Year of spin period measurement"
            verbLevel="3" >
            <values nullLiteral="-1"/>
        </column>
        <column name="r_Ps" type="text"
            ucd="meta.ref"
            tablehead="r_P_S"
            description="Reference for spin period"
            verbLevel="15" />
        <column name="PLocSpDown" type="double precision"
            unit="s" ucd="time.period"
            tablehead="loc_P_s_down"
            description="Local spin-down period"
            verbLevel="3" />
        <column name="e_PLocSpDown" type="double precision"
            unit="s" ucd="stat.error;time.period"
            tablehead="e_loc_P_s_down"
            description="Error in local spin-down period"
            verbLevel="15" />
        <column name="PLocSpDownStart" type="double precision"
            unit="d" ucd="time.start;obs"
            tablehead="loc_P_s_down_start"
            description="Start date of local spin-down period measurement in MJD"
            verbLevel="3" />
        <column name="PLocSpDownStop" type="double precision"
            unit="d" ucd="time.stop;obs"
            tablehead="loc_P_s_down_stop"
            description="End date of local spin-down period measurement in MJD"
            verbLevel="3" />
        <column name="r_PLocSpDown" type="text"
            ucd="meta.ref"
            tablehead="r_loc_P_s_down"
            description="Reference for local spin-down period"
            verbLevel="15" />
        <column name="PLocSpUpsign" type="text"
            ucd="meta.code"
            tablehead="sign_loc_P_s_up"
            description="Sign of local spin-up period"
            verbLevel="3" />
        <column name="PLocSpUp" type="double precision"
            unit="s" ucd="time.period"
            tablehead="loc_P_s_up"
            description="Local spin-up period"
            verbLevel="3" />
        <column name="e_PLocSpUp" type="double precision"
            unit="s" ucd="stat.error;time.period"
            tablehead="e_loc_P_s_up"
            description="Error in local spin-up period"
            verbLevel="15" />
        <column name="PLocSpUpStart" type="double precision"
            unit="d" ucd="time.start;obs"
            tablehead="loc_P_s_up_start"
            description="Start date of local spin-up period measurement in MJD"
            verbLevel="3" />
        <column name="PLocSpUpStop" type="double precision"
            unit="d" ucd="time.stop;obs"
            tablehead="loc_P_s_up_stop"
            description="End date of local spin-up period measurement in MJD"
            verbLevel="3" />
        <column name="r_PLocSpUp" type="text"
            ucd="meta.ref"
            tablehead="r_loc_P_s_up"
            description="Reference for local spin-up period"
            verbLevel="15" />
        <column name="PGloSpDown" type="double precision"
            unit="s" ucd="time.period"
            tablehead="glo_P_s_down"
            description="Global spin-down period"
            verbLevel="3" />
        <column name="e_PGloSpDown" type="double precision"
            unit="s" ucd="stat.error;time.period"
            tablehead="e_glo_P_s_down"
            description="Error in global spin-down period"
            verbLevel="15" />
        <column name="PGloSpDownStart" type="double precision"
            unit="d" ucd="time.start;obs"
            tablehead="glo_P_s_down_start"
            description="Start date of global spin-down period measurement in MJD"
            verbLevel="3" />
        <column name="PGloSpDownStop" type="double precision"
            unit="d" ucd="time.stop;obs"
            tablehead="glo_P_s_down_stop"
            description="End date of global spin-down period measurement in MJD"
            verbLevel="3" />
        <column name="r_PGloSpDown" type="text"
            ucd="meta.ref"
            tablehead="r_glo_P_s_down"
            description="Reference for global spin-down period"
            verbLevel="15" />
        <column name="PGloSpUpsign" type="text"
            ucd="meta.code"
            tablehead="sign_glo_P_s_up"
            description="Sign of global spin-up period"
            verbLevel="3" />
        <column name="PGloSpUp" type="double precision"
            unit="s" ucd="time.period"
            tablehead="glo_P_s_up"
            description="Global spin-up period in seconds"
            verbLevel="3" />
        <column name="e_PGloSpUp" type="double precision"
            unit="s" ucd="stat.error;time.period"
            tablehead="e_glo_P_s_up"
            description="Error in global spin-up period"
            verbLevel="15" />
        <column name="PGloSpUpStart" type="double precision"
            unit="d" ucd="time.start;obs"
            tablehead="glo_P_s_up_start"
            description="Start date of global spin-up period measurement in MJD"
            verbLevel="3" />
        <column name="PGloSpUpStop" type="double precision"
            unit="d" ucd="time.stop;obs"
            tablehead="glo_P_s_up_stop"
            description="End date of global spin-up period measurement in MJD"
            verbLevel="3" />
        <column name="r_PGloSpUp" type="text"
            ucd="meta.ref"
            tablehead="r_glo_P_s_up"
            description="Reference for global spin-up period"
            verbLevel="15" />
        <column name="POrbsign" type="text"
            ucd="meta.code"
            tablehead="sign_P_orb"
            description="Sign of orbital period"
            verbLevel="3" />
        <column name="POrbLower" type="double precision"
            unit="d" ucd="time.period"
            tablehead="P_orb_lower"
            description="Lower limit of orbital period"
            verbLevel="3" />
        <column name="POrbUpper" type="double precision"
            unit="d" ucd="time.period"
            tablehead="P_orb_upper"
            description="Upper limit of orbital period"
            verbLevel="3" />
        <column name="POrbErr" type="double precision"
            unit="d" ucd="stat.error;time.period"
            tablehead="e_P_orb"
            description="Error in orbital period"
            verbLevel="15" />
        <column name="POrbRef" type="text"
            ucd="meta.ref"
            tablehead="r_P_orb"
            description="Reference for orbital period"
            verbLevel="15" />
        <column name="LXLower" type="double precision"
            unit="erg/s" ucd="phys.luminosity;em.x-ray"
            tablehead="L_x_lower"
            description="Lower limit of X-ray luminosity"
            verbLevel="3" />
        <column name="LXUpper" type="double precision"
            unit="erg/s" ucd="phys.luminosity;em.x-ray"
            tablehead="L_x_upper"
            description="Upper limit of X-ray luminosity"
            verbLevel="3" />
        <column name="LXRange" type="text"
            ucd="meta.code"
            tablehead="L_x_range"
            description="Range of X-ray luminosity"
            verbLevel="3" />
        <column name="LXRef" type="text"
            ucd="meta.ref"
            tablehead="r_L_x"
            description="Reference for X-ray luminosity"
            verbLevel="15" />
        <column name="Bsign" type="text"
            ucd="meta.code"
            tablehead="sign_B"
            description="Sign of magnetic field strength"
            verbLevel="3" />
        <column name="BLower" type="double precision"
            unit="Gauss" ucd="phys.magfield"
            tablehead="B_lower"
            description="Lower limit of magnetic field strength in Gauss"
            verbLevel="3" />
        <column name="BUpper" type="double precision"
            unit="Gauss" ucd="phys.magfield"
            tablehead="B_upper"
            description="Upper limit of magnetic field strength in Gauss"
            verbLevel="3" />
        <column name="BErr" type="double precision"
            unit="Gauss" ucd="stat.error;phys.magfield"
            tablehead="e_B"
            description="Error in magnetic field strength in Gauss"
            verbLevel="15" />
        <column name="BRef" type="text"
            ucd="meta.ref"
            tablehead="r_B"
            description="Reference for magnetic field strength"
            verbLevel="15" />
        <column name="Distsign" type="text"
            ucd="meta.code"
            tablehead="sign_dist"
            description="Sign of distance measurement"
            verbLevel="3" />
        <column name="DistLower" type="double precision"
            unit="pc" ucd="pos.distance;stat.min"
            tablehead="dist_lower"
            description="Lower limit of distance in parsecs"
            verbLevel="3" />
        <column name="DistUpper" type="double precision"
            unit="pc" ucd="pos.distance;stat.max"
            tablehead="dist_upper"
            description="Upper limit of distance in parsecs"
            verbLevel="3" />
        <column name="DistError" type="double precision"
            unit="pc" ucd="stat.error;pos.distance"
            tablehead="e_dist"
            description="Error in distance measurement in parsecs"
            verbLevel="15" />
        <column name="DistRef" type="text"
            ucd="meta.ref"
            tablehead="r_dist"
            description="Reference for distance measurement"
            verbLevel="15" />
        <column name="CompName" type="text"
            ucd="meta.id;src"
            tablehead="comp_name"
            description="Name of the companion object"
            verbLevel="3" />
        <column name="CompNameClass" type="text"
            ucd="src.class"
            tablehead="comp_name_class"
            description="Classification of the companion object"
            verbLevel="3" />
        <column name="CompNameRef" type="text"
            ucd="meta.ref"
            tablehead="r_comp_name"
            description="Reference for companion object name"
            verbLevel="15" />
        <column name="CompBmag" type="double precision"
            unit="mag" ucd="phot.mag;em.opt.b"
            tablehead="comp_B_mag"
            description="Companion B-band magnitude"
            verbLevel="3" />
        <column name="e_CompBmag" type="double precision"
            unit="mag" ucd="stat.error;phot.mag"
            tablehead="e_comp_B_mag"
            description="Error in companion B-band magnitude"
            verbLevel="15" />
        <column name="CompVmag" type="double precision"
            unit="mag" ucd="phot.mag;em.opt.v"
            tablehead="comp_V_mag"
            description="Companion V-band magnitude"
            verbLevel="3" />
        <column name="e_CompVmag" type="double precision"
            unit="mag" ucd="stat.error;phot.mag"
            tablehead="e_comp_V_mag"
            description="Error in companion V-band magnitude"
            verbLevel="15" />
        <column name="CompRmag" type="double precision"
            unit="mag" ucd="phot.mag;em.opt.r"
            tablehead="comp_R_mag"
            description="Companion R-band magnitude"
            verbLevel="3" />
        <column name="e_CompRmag" type="double precision"
            unit="mag" ucd="stat.error;phot.mag"
            tablehead="e_comp_R_mag"
            description="Error in companion R-band magnitude"
            verbLevel="15" />
        <column name="CompImag" type="double precision"
            unit="mag" ucd="phot.mag;em.opt.i"
            tablehead="comp_I_mag"
            description="Companion I-band magnitude"
            verbLevel="3" />
        <column name="e_CompImag" type="double precision"
            unit="mag" ucd="stat.error;phot.mag"
            tablehead="e_comp_I_mag"
            description="Error in companion I-band magnitude"
            verbLevel="15" />
        <column name="CompBVRImagRef" type="text"
            ucd="meta.ref"
            tablehead="r_comp_BVRI_mag"
            description="Reference for companion B, V, R, I magnitudes"
            verbLevel="15" />
        <column name="CompJmag" type="double precision"
            unit="mag" ucd="phot.mag;em.ir.j"
            tablehead="comp_J_mag"
            description="Companion J-band magnitude"
            verbLevel="3" />
        <column name="e_CompJmag" type="double precision"
            unit="mag" ucd="stat.error;phot.mag"
            tablehead="e_comp_J_mag"
            description="Error in companion J-band magnitude"
            verbLevel="15" />
        <column name="CompHmag" type="double precision"
            unit="mag" ucd="phot.mag;em.ir.h"
            tablehead="comp_H_mag"
            description="Companion H-band magnitude"
            verbLevel="3" />
        <column name="e_CompHmag" type="double precision"
            unit="mag" ucd="stat.error;phot.mag"
            tablehead="e_comp_H_mag"
            description="Error in companion H-band magnitude"
            verbLevel="15" />
        <column name="CompKmag" type="double precision"
            unit="mag" ucd="phot.mag;em.ir.k"
            tablehead="comp_K_mag"
            description="Companion K-band magnitude"
            verbLevel="3" />
        <column name="e_CompKmag" type="double precision"
            unit="mag" ucd="stat.error;phot.mag"
            tablehead="e_comp_K_mag"
            description="Error in companion K-band magnitude"
            verbLevel="15" />
        <column name="CompJHKmagRef" type="text"
            ucd="meta.ref"
            tablehead="r_comp_JHK_mag"
            description="Reference for companion J, H, K magnitudes"
            verbLevel="15" />
        <column name="ExtBminusV" type="double precision"
            unit="mag" ucd="phys.colorIndex"
            tablehead="ext_B-V"
            description="Color excess E(B−V)"
            verbLevel="3" />
        <column name="e_ExtBminusV" type="double precision"
            unit="mag" ucd="stat.error;phys.colorIndex"
            tablehead="e_ext_B-V"
            description="Error in color excess E(B−V)"
            verbLevel="15" />
        <column name="r_ExtBminusV" type="text"
            ucd="meta.ref"
            tablehead="r_ext_B-V"
            description="Reference for color excess E(B−V)"
            verbLevel="15" />
        <column name="persistent" type="smallint"
            ucd="meta.code.qual"
            tablehead="Persistent/Transient"
            description="Flag indicating the type of pulsar: 1 for persistent pulsars, 0 for transient pulsars"
            verbLevel="5" />
    </table>

    <data id="import">
        <sources pattern="data/data.db"/>
        <embeddedGrammar> <!-- probably wrong: better use CSV or FITS binary
            or whatever.  But for demo: -->
            <iterator>
                <setup imports="sqlite3">
                    <code>
                        def dict_factory(cursor, row):
                            fields = [column[0] 
                                for column in cursor.description]
                            return {key: value 
                                for key, value in zip(fields, row)}
                    </code>
                </setup>
                <code>
                    conn = sqlite3.connect(self.sourceToken)
                    conn.row_factory = dict_factory
                    for row in conn.execute("SELECT * FROM combined_table"):
                        yield row
                </code>
            </iterator>
        </embeddedGrammar>
        <make table="main">
            <rowmaker id="build_main" idmaps="*">
                <map key="ra">hmsToDeg(
                    "{}:{}:{}".format(@RAh, @RAm, @RAs), sepChar=":")</map>
                <map key="dec">dmsToDeg(
                    "{}{}:{}:{}".format(@DE_sign, @DEd, @DEm, @DEs), sepChar=":")</map>
            </rowmaker>
        </make>
    </data>

    <coverage>
        <updater spaceTable="main"/>
    </coverage>

    <!-- Service Definition -->
    <service id="scs" allowed="form,scs.xml">
        <meta name="shortName">FAI x-ray pulsars</meta>
        <scsCore queriedTable="main">
            <FEED source="//scs#coreDescs"/>
            <condDesc buildFrom="Ps"/>
        </scsCore>
        <!-- Publishing Information -->
        <publish sets="local,ivo_managed" render="form"/>
    </service>
</resource>

<!-- vim:ai:sta:ts=4:et:sw=4 
-->
