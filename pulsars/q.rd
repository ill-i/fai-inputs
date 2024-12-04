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
            ucd="meta.id"
            tablehead="Name"
            description="Name of the object"
            verbLevel="1" />
        <column name="ra" type="double precision"
            unit="deg" ucd="pos.eq.ra;meta.main"
            tablehead="RA"
            description="The pulsar's ICRS right ascension from SIMBAD"
            verbLevel="1" displayHint="type=hms,sf=2"/>
        <column name="dec" type="double precision"
            unit="deg" ucd="pos.eq.dec;meta.main"
            tablehead="Dec"
            description="The pulsar's ICRS declenation from SIMBAD"
            verbLevel="1" displayHint="type=dms,sf=2"/>
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
            verbLevel="15" displayHint="type=bibcode"/>
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
            verbLevel="15" displayHint="type=bibcode"/>
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
            tablehead="comp_class"
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
        <column name="persistent" type="smallint" required="True"
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

        <apply id="resolve-bibcodes" name="bibcodemap">
            <setup>
                <par key="key">"r_PLocSpDown"</par>
                <par key="mapping"><![CDATA[{
"1": "2021JApA...42...58S",
"2": "2018MNRAS.481.2779S",
"3": "1998A&A...340L..55S",
"4": "2009ApJ...691.1744T",
"5": "1979ApJ...229.1079H",
"6": "2006A&A...455.1165L",
"7": "Fermi Collaboration (Cen X-3) (2021)",
"8": "1989PASJ...41....1N",
"9": "CGRO-Collaboration (2000)",
"10": "2015A&A...577A.130F",
"11": "2012ApJ...759..124J",
"12": "2002ApJ...573..789C",
"13": "2009A&A...505..281M",
"13a": "2003yCat.2246....0C",
"14": "Fermi Collaboration (OAO 1657-415) (2021)",
"15": "2008A&A...486..293B",
"16": "2013MNRAS.433.2028E",
"16a": "2023A&A...671A.149F",
"17": "2017MNRAS.466..593L",
"18": "2010A&A...510A..61T",
"19": "2005A&A...439..255H",
"20": "2009MNRAS.394.1597K",
"20a": "2002MNRAS.337.1245L",
"21": "1998A&A...339L..41A",
"23": "2003A&A...401..313Q",
"25": "2014ApJ...780..133F",
"26": "1985ApJ...288..284S",
"27": "1978mcts.book.....H",
"28": "Fermi Collaboration (Vela X-1) (2021)",
"28a": "2002yCat.2237....0D",
"28b": "2021A&A...652A..95K",
"29": "1999ApJ...517..956C",
"29a": "2008ATel.1876....1N",
"30": "2002ApJ...577..923C",
"30a": "2007A&A...467..585B",
"31": "2006A&A...448..261Z",
"32": "2007ApJ...661..447T",
"33": "2010A&A...509A..79M",
"33a": "2019ApJ...873...62H",
"34": "2013ApJ...777...61H",
"35": "2014MNRAS.440.1626M",
"36": "1978MNRAS.184P..73P",
"37": "Fermi Collaboration (4U 1538-52) (2021)",
"38": "2019A&A...629A.101N",
"39": "1986ApJ...304..241S",
"40": "1995A&A...300..446K",
"41": "2004A&A...427..975K",
"42": "Fermi Collaboration (GX 301-2) (2021)",
"42a": "2000A&A...355L..27H",
"43": "2017MNRAS.470..713M",
"44": "2001ApJ...546..455D",
"44a": "2012ApJ...744..108B",
"45": "1997MNRAS.286..549L",
"46": "1998ApJ...509..897D",
"47": "2014ARep...58..376I",
"47a": "1991A&AS...89..415O",
"47b": "2017BlgAJ..27...10N",
"48": "1999MNRAS.306..100R",
"49": "2013MNRAS.436L..74C",
"50": "1997A&A...323..853M",
"51": "2009A&A...505..947L",
"51a": "2012yCat.1322....0Z",
"51b": "2011RAA....11..947S",
"51c": "2013MNRAS.436..945P",
"51d": "2008A&A...482..113M",
"51e": "2012A&A...548A..79A",
"52": "2006A&A...447.1027B",
"53": "2006ApJ...649..373T",
"54": "2016ApJ...823..146B",
"54a": "2015MNRAS.446.4148I",
"55": "2008ChJAS...8..197C",
"56": "2019ApJ...873...86P",
"57": "2019ApJ...879...34C",
"58": "2011A&A...532A..73D",
"60": "2006A&A...455..283L",
"61": "2009MNRAS.392.1242S",
"62": "1997A&A...322..183R",
"62a": "2015A&A...574A..33R",
"63": "2010ApJ...709.1249F",
"64": "2007ApJ...655..458C",
"65": "2004A&A...423..301T",
"67": "2011MNRAS.413.1083W",
"68": "2013ApJ...778...45C",
"69": "2005A&A...436L..31B",
"70": "1996rftu.proc..181R",
"71": "2000ApJ...528L..25C",
"72": "2000ApJ...542L..41K",
"73": "1999ApJ...523..197K",
"74": "2009A&A...504..181M",
"75": "2009ApJ...707..870B",
"76": "2019ATel12556....1H",
"77": "2005ApJ...635.1217G",
"78": "2020ApJ...896...90M",
"79": "2019ATel12554....1S",
"80": "2021MNRAS.503.6045D",
"81": "2013AstL...39..375B",
"82": "1991ApJ...375L..49N",
"83": "2001A&A...369..108N",
"84": "2012MNRAS.423.2854L",
"86": "2005ApJ...630L..65Z",
"87": "1990ApJ...365L..59M",
"88": "1999MNRAS.307..695N",
"90": "2022MNRAS.514L..46D",
"91": "1997ApJ...488..831S",
"91a": "2019MNRAS.485..770L",
"92": "2009MNRAS.393..419S",
"93": "2001PASJ...53.1179B",
"94": "2008A&A...486..911N",
"95": "2019MNRAS.482L..14S",
"95a": "2022ATel15614....1C",
"96": "2007ApJ...669..579H",
"96a": "2012yCat.2316....0U",
"97": "2022ApJ...929..137C",
"97a": "2022ApJ...927..194M",
"97b": "2016MNRAS.462.3823L",
"98": "2016MNRAS.457..258T",
"98a": "2022MNRAS.509.5955S",
"98b": "2009ApJ...695...30C",
"98c": "2017ATel10812....1J",
"98d": "2018A&A...613A..19D",
"98e": "2020MNRAS.491.1857D",
"98f": "2018ApJ...863....9W",
"98g": "GAIA-Collaboration (2022)",
"98h": "2020A&A...640A..35R",
"99": "2015A&A...576L...4R",
"100": "2009MNRAS.399L.113C",
"101": "2015MNRAS.447.2274B",
"102": "2008A&A...484..801R",
"102a": "2016A&A...596A..16B",
"102b": "2020ATel13625....1E",
"102c": "2012MNRAS.426L..16L",
"103": "2012ApJ...757..143N",
"104": "2012ATel.4235....1J",
"105": "1991IAUC.5294....2G",
"106": "2000MNRAS.314...87I",
"106a": "2012ATel.4235....1J",
"107": "2021MNRAS.508.5578R",
"108": "2009ATel.2008....1C",
"109": "2019A&A...621A.134T",
"109a": "2018MNRAS.476.2110R",
"109b": "Rermi Collaboration (IGR J19294+1816) (2021)",
"110": "2008A&A...485..797R",
"111": "2010ApJ...711.1306B",
"112": "2013ApJ...762...61D",
"113": "2011A&A...533A..23R",
"114": "2023arXiv230110678D",
"115": "2003ApJ...584..996W",
"116": "2012A&A...546A.125M",
"117": "2015ApJ...815...44M",
"118": "2010MNRAS.406.2663R",
"119": "1996A&AS..120C.209F",
"120": "2004MNRAS.349..173I",
"121": "1998A&A...338..505N",
"121a": "1984ApJ...276..621G",
"122": "2016A&A...591A..65B",
"123": "2004ApJ...613.1164G",
"124": "2014ApJ...784L..40F",
"125": "2003A&A...397..739N",
"126": "Fermi Collaboration (KS 1947+300) (2021)",
"127": "2007A&A...467..249S",
"128": "2008A&A...492..163R",
"129": "2001ApJ...553L.165I",
"130": "2000A&A...357..501P",
"130a": "2001A&A...371.1018I",
"131": "2019MNRAS.488.4427Z",
"132": "2000ApJ...530L..33C",
"133": "2013ApJ...764..158 ",
"134": "2008ApJ...678.1263W",
"135": "1999MNRAS.302..700R",
"136": "2014MNRAS.445.4235R",
"136a": "2022ApJ...927..139O",
"136b": "2013ApJ...775L..24L",
"137": "2010ATel.2564....1M",
"138": "2010ATel.2559....1C",
"139": "2007A&A...461..631N",
"139a": "2014ApJS..212...13A",
"140": "2021ApJ...920..139M",
"141": "1999ApJ...511..367W",
"142": "2007A&A...470.1065M",
"143": "2022A&A...667A..18R",
"145": "Fermi Collaboration (Cep X-4) (2021)",
"145a": "2005ApJ...632.1069G",
"145b": "2002ApJ...565.1150W",
"145c": "1998ApJ...502L.129M",
"146": "2020ApJ...899L..19G",
"147": "2013A&A...555A..95K",
"150": "2012A&A...539A.114R",
"151": "Fermi Collaboration (GRO J1008-57) (2021)",
"152": "2014RAA....14..565W",
"153": "2022A&A...657A..58N",
"154": "1999ApJ...517..449F",
"155": "2020RAA....20..155R",
"155a": "2016ATel.9823....1C",
"156": "1997ApJ...489L..83C",
"157": "2023AAS...24142807C",
"158": "2006MNRAS.368..447C",
"159": "1994A&A...291L..31K",
"161": "1980A&AS...40..289G",
"162": "Fermi Collaboration (1A 0535_262) (2021)",
"163": "1990MNRAS.243..475C",
"164": "2007MNRAS.381.1275H",
"164a": "2008MNRAS.386L..10K",
"164b": "2008A&A...489..657Z",
"164c": "2010MNRAS.409L..69K",
"164d": "2019A&A...622A.198N",
"164e": "2014MNRAS.445L.119L",
"164f": "2013ApJS..209...14K",
"165": "1998ApJ...495..435K",
"166": "2013A&A...558A..99S",
"167": "2006A&A...451..267M",
"168": "2012ApJ...753...73Y",
"170": "2012A&A...547A.103N",
"170a": "2004ATel..362....1I",
"171": "2007ESASP.622..503T",
"172": "2005ATel..377....1C",
"172a": "2009A&A...495..121M",
"173": "2020A&A...638A..71S",
"174": "2009ApJ...696.2068R",
"176": "2014A&A...562A..18L",
"177": "1977MNRAS.180P..21H",
"179": "2020ApJ...897...73M",
"180": "1998ApJ...499..820W",
"181": "1997ApJS..113..367B",
"182": "2019ApJ...883L..11M",
"183": "2013A&A...553A.103F",
"184": "2012MNRAS.421.2407T",
"185": "2005A&A...440.1079R",
"186": "2012A&A...539A..82L",
"186a": "Fermi Collaboration (RX J0440.9+4431) (2021)",
"187": "2020A&A...634A..89 ",
"187a": "2019ATel13211....1M",
"187b": "2021ApJ...909..154T",
"187c": "1998ApJ...508..854T",
"188": "2008ARep...52..138D",
"189": "2005A&A...444..821L",
"190": "2010MNRAS.405L..66L",
"190a": "2021MNRAS.502.5455A",
"190b": "2016A&A...591A..87C",
"191": "2018A&A...620L..13R",
"192": "2015PASJ...67...73S",
"193": "2019MNRAS.483L.144T",
"194": "2011PASJ...63S.751Y",
"195": "2015MNRAS.446.1013P",
"196": "1987MNRAS.225..369C",
"197": "1999PhDT.........6W",
"197a": "1997MNRAS.288..988S",
"197b": "2017A&A...607A..52A",
"198": "2022MNRAS.517.4132G",
"199": "2002ApJ...581.1293R",
"200": "1982MNRAS.201..171D",
"200a": "2021A&A...647A.165D",
"200b": "2022MNRAS.512.6093C",
"200c": "2022AstL...48..798G",
"201": "2014MNRAS.442..472R",
"201a": "2014MNRAS.441.1126E",
"202": "2007A&A...469.1063I",
"202a": "2021PASJ...73.1389U",
"202b": "2020A&A...634A..49H",
"203": "2005A&A...440..637R",
"204": "2014MNRAS.445.1314R",
"205": "2002ApJ...569..903B",
"207": "2004A&A...421..673R",
"208": "2014A&A...568A.115C",
"208a": "2018A&A...613A..52R",
"209": "2011A&A...526A...7N",
"210": "2011A&A...527A...7S",
"211": "2003AJ....125.2531R",
"212": "2010A&A...515L...1D",
"213": "1981A&A....99..274J",
"215": "2023MNRAS.518.4861T",
"216": "1980MNRAS.193P...7M",
"217": "2005A&A...436..661C",
"218": "2001MNRAS.327.1269B",
"219": "2008MNRAS.386.2253K",
"220": "2010A&A...516A..15W",
"221": "2010ATel.3069....1C",
"221a": "2020MNRAS.496.1768D",
"222": "2010ATel.3082....1K",
"223": "2012ApJ...748...86O",
"224": "Fermi Collaboration (MAXI J1409-619) (2021)",
"224a": "2020MNRAS.498.4830J",
"225": "2013ApJ...779...54J",
"226": "2000ApJ...532.1119W",
"227": "2005MNRAS.356..665M",
"228": "2012MNRAS.421.2079S",
"228a": "2015ApJ...809..140K",
"229": "2005MNRAS.364..455C",
"230": "2006IAUS..230...33C",
"231": "2013A&A...560A.108C",
"233": "2012ApJ...753....3B",
"234": "2013A&A...556A..27S",
"235": "2012MNRAS.420..554S",
"236": "2006ATel..779....1C",
"237": "2001A&A...380L..26I",
"238": "2000A&A...361...85I",
"239": "2005A&A...433L..41L",
"240": "2018A&A...618A..61G",
"241": "2017MNRAS.469.3056S",
"242": "2013A&A...555A.115R",
            }
            ]]></par>
            </setup>
            <code>
                vars[key] = mapping.get(vars[key])
            </code>
        </apply>
        
        <LOOP listItems="r_Ps r_PLocSpUp r_PGloSpDown r_PGloSpUp POrbRef 
            LXRef BRef DistRef CompNameRef CompBVRImagRef 
            CompJHKmagRef r_ExtBminusV">
            <events>
            <apply procDef="resolve-bibcodes">
                <bind key="key">"\item"</bind>
            </apply>
        </events>
        </LOOP>
        </rowmaker>
        </make>
    </data>

    <coverage>
        <updater spaceTable="main"/>
    </coverage>

    <!-- Service Definition -->
    <service id="scs" allowed="form,scs.xml">
        <meta name="shortName">FAI xray pulsars</meta>
        <scsCore queriedTable="main">
            <FEED source="//scs#coreDescs"/>
            <condDesc buildFrom="Ps"/>
        </scsCore>
        <!-- Publishing Information -->
        <publish sets="local,ivo_managed" render="form"/>
    </service>
</resource>
        
<!-- vi:ai:sta:ts=4:et:sw=4 
-->
