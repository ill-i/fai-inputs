<resource schema="wr_wn_sequence" resdir=".">
	<meta name="creationDate">2025-08-15T13:04:00</meta>
	<meta name="title">Photometric and Spectral Data of Galactic Wolf-Rayet Stars (WN sequence)</meta>

	<meta name="description" format="rst">
			This catalogue contains results of **photometric and spectral observations**	
			of eleven Galactic **Wolf–Rayet stars** of the **WN sequence**,	
			obtained in 2021–2022 at the *Fesenkov Astrophysical Institute (FAI), Kazakhstan*.

			The observing programme included moderately bright stars (mostly fainter than *V = 10m*)	
			observed in **B**, **V**, and **Rc** photometric filters,	
			as well as **medium-resolution spectra** for measurement of absolute fluxes	
			in prominent emission lines.

			For each object, the table provides:	
				* identifiers (WR catalogue number, alternative name),	
				* spectral subtype,	
				* equatorial coordinates (J2000),	
				* literature photometry (B_cat, V_cat) and reference codes,	
				* date of observation and Julian Date (JD−2400000),	
				* measured **B**, **V**, **Rc** magnitudes with their errors,	
				* and absolute fluxes and equivalent widths for a set of emission lines, including	
					**He II λ4540**, **N III λ4619**, **He II λ4685**, **He II + H I λ4859**,	
					**N V λ4945**, **He II λ5411**, **He II λ6560**, **He II λ6583**, and **N IV λ7109**.

			These data were **first published** in the paper	
			*“Photometric and Spectral Studies of a Group of Galactic Wolf–Rayet Stars. I. WN Sequence”*,	
			*Astrophysics*, **Vol. 66, No. 4 (November 2023)**,	
			by *L.N. Kondratyeva, I.V. Reva, E.K. Denisyuk, S.A. Shomshekova, A.K. Aimanova*.	
			DOI: `10.54503/0002-3051-2023.76.4-521`
	</meta>
	
	<meta name="subject">massive-stars</meta>
	<meta name="subject">wolf-rayet-stars</meta>
	<meta name="subject">spectroscopy</meta>
	<meta name="subject">bv-photometry</meta>
	<meta name="subject">ccd-photometry</meta>
	<meta name="subject">johnson-photometry</meta>
	<meta name="subject">photometry</meta>
	<meta name="subject">stellar-photometry</meta>
	<meta name="subject">variable-stars</meta>
	
	<meta name="source">10.54503/0002-3051-2023.76.4-521</meta>
	<meta name="creator">L.N. Kondratyeva, I.V. Reva, E.K. Denissyuk, S.A. Shomshekova, A.K. Aimanova</meta>
	<meta name="facility">Fesenkov Astrophysical Institute</meta>
	<meta name="instrument">AZT-8</meta>
	
	<meta name="coverage.waveband">Optical</meta>
	<meta name="coverage.spectral">3.7e-7 7.3e-7</meta>
	<meta name="coverage.temporal">59214 59943</meta>
	<meta name="coverage.region">Milky Way</meta>
	<meta name="contentLevel">Research</meta>
	
	<table id="main" onDisk="True" adql="True">
		<column name="object"
			type="text"
			ucd="meta.id;src"
			tablehead="Object"
			description="WR catalogue number of the star."
			verbLevel="1"/>

		<column name="alt_name"
			type="text"
			ucd="meta.id;src"
			tablehead="Alt. name"
			description="Alternative identifier of the star (e.g., HD, BD number)."
			verbLevel="1"/>

		<column name="sp"
			type="text"
			ucd="src.spType"
			tablehead="Sp. type"
			description="Spectral type of the star."
			verbLevel="1"/>

		<column name="ra"
			type="double precision"
			ucd="pos.eq.ra;meta.main"
			unit="deg"
			tablehead="RA(J2000)"
			description="Right Ascension (J2000) of the star in decimal degrees."
			verbLevel="1"/>

		<column name="dec"
			type="double precision"
			ucd="pos.eq.dec;meta.main"
			unit="deg"
			tablehead="Dec(J2000)"
			description="Declination (J2000) of the star in decimal degrees."
			verbLevel="1"/>

		<column name="B_cat"
			type="real"
			ucd="phot.mag;em.opt.B"
			unit="mag"
			tablehead="B_cat"
			description="Catalogue B magnitude from literature."
			verbLevel="1"/>

		<column name="V_cat"
			type="real"
			ucd="phot.mag;em.opt.V"
			unit="mag"
			tablehead="V_cat"
			description="Catalogue V magnitude from literature."
			verbLevel="1"/>

		<column name="mag_ref"
			type="text"
			ucd="meta.bib"
			tablehead="Mag ref"
			description="Reference code for the catalogue magnitudes."
			verbLevel="1"/>

		<column name="date_obs"
			type="date"
			ucd="time.epoch"
			tablehead="Obs. date"
			description="UTC date of the observation."
			verbLevel="1"/>

		<column name="B_mag"
			type="real"
			ucd="phot.mag;em.opt.B"
			unit="mag"
			tablehead="B"
			description="Measured B magnitude from observations."
			verbLevel="1"/>

		<column name="B_mag_err"
			type="real"
			ucd="stat.error;phot.mag;em.opt.B"
			unit="mag"
			tablehead="e_B"
			description="Uncertainty in the measured B magnitude."
			verbLevel="1"/>

		<column name="V_mag"
			type="real"
			ucd="phot.mag;em.opt.V"
			unit="mag"
			tablehead="V"
			description="Measured V magnitude from observations."
			verbLevel="1"/>

		<column name="V_mag_err"
			type="real"
			ucd="stat.error;phot.mag;em.opt.V"
			unit="mag"
			tablehead="e_V"
			description="Uncertainty in the measured V magnitude."
			verbLevel="1"/>

		<column name="Rc_mag"
			type="real"
			ucd="phot.mag;em.opt.R"
			unit="mag"
			tablehead="Rc"
			description="Measured Cousins R magnitude from observations."
			verbLevel="1"/>

		<column name="Rc_mag_err"
			type="real"
			ucd="stat.error;phot.mag;em.opt.R"
			unit="mag"
			tablehead="e_Rc"
			description="Uncertainty in the measured Cousins R magnitude."
			verbLevel="1"/>
		<column name="NIII_4514_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(NIII 4514)"
			description="Absolute flux of N III λ4514 emission line."
			verbLevel="1"/>

		<column name="NIII_4514_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(NIII 4514)"
			description="Equivalent width of N III λ4514 emission line."
			verbLevel="1"/>

		<column name="HeII_4514_4540_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(HeII 4514–4540)"
			description="Absolute flux of He II λ4514–4540 blend."
			verbLevel="1"/>

		<column name="HeII_4514_4540_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(HeII 4514–4540)"
			description="Equivalent width of He II λ4514–4540 blend."
			verbLevel="1"/>

	<column name="HeII_4540_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(HeII 4540)"
			description="Absolute flux of He II λ4540 emission line."
			verbLevel="1"/>

	<column name="HeII_4540_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(HeII 4540)"
			description="Equivalent width of He II λ4540 emission line."
			verbLevel="1"/>

	<column name="NIII_4619_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(NIII 4619)"
			description="Absolute flux of N III λ4619 emission line."
			verbLevel="1"/>

	<column name="NIII_4619_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(NIII 4619)"
			description="Equivalent width of N III λ4619 emission line."
			verbLevel="1"/>

	<column name="NV_4620_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(NV 4620)"
			description="Absolute flux of N V λ4620 emission line."
			verbLevel="1"/>

	<column name="NV_4620_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(NV 4620)"
			description="Equivalent width of N V λ4620 emission line."
			verbLevel="1"/>

	<column name="NIII_4634_4640_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(NIII 4634–4640)"
			description="Absolute flux of N III λ4634–4640 blend."
			verbLevel="1"/>

	<column name="NIII_4634_4640_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(NIII 4634–4640)"
			description="Equivalent width of N III λ4634–4640 blend."
			verbLevel="1"/>

	<column name="NIII_4640_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(NIII 4640)"
			description="Absolute flux of N III λ4640 emission line."
			verbLevel="1"/>

	<column name="NIII_4640_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(NIII 4640)"
			description="Equivalent width of N III λ4640 emission line."
			verbLevel="1"/>

	<column name="HeII_4685_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(HeII 4685)"
			description="Absolute flux of He II λ4685 emission line."
			verbLevel="1"/>

	<column name="HeII_4685_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(HeII 4685)"
			description="Equivalent width of He II λ4685 emission line."
			verbLevel="1"/>

	<column name="HeII_4686_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(HeII 4686)"
			description="Absolute flux of He II λ4686 emission line."
			verbLevel="1"/>

	<column name="HeII_4686_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(HeII 4686)"
			description="Equivalent width of He II λ4686 emission line."
			verbLevel="1"/>

	<column name="HeII_HI_4859_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(HeII+HI 4859)"
			description="Absolute flux of He II + H I λ4859 blend."
			verbLevel="1"/>

	<column name="HeII_HI_4859_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(HeII+HI 4859)"
			description="Equivalent width of He II + H I λ4859 blend."
			verbLevel="1"/>

	<column name="HeII_4859_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(HeII 4859)"
			description="Absolute flux of He II λ4859 emission line."
			verbLevel="1"/>

	<column name="HeII_4859_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(HeII 4859)"
			description="Equivalent width of He II λ4859 emission line."
			verbLevel="1"/>

	<column name="NV_4933_4944_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(NV 4933–4944)"
			description="Absolute flux of N V λ4933–4944 blend."
			verbLevel="1"/>

	<column name="NV_4933_4944_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(NV 4933–4944)"
			description="Equivalent width of N V λ4933–4944 blend."
			verbLevel="1"/>

	<column name="NV_4940_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(NV 4940)"
			description="Absolute flux of N V λ4940 emission line."
			verbLevel="1"/>

	<column name="NV_4940_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(NV 4940)"
			description="Equivalent width of N V λ4940 emission line."
			verbLevel="1"/>

	<column name="NV_4945_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(NV 4945)"
			description="Absolute flux of N V λ4945 emission line."
			verbLevel="1"/>

	<column name="NV_4945_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(NV 4945)"
			description="Equivalent width of N V λ4945 emission line."
			verbLevel="1"/>
	
	<column name="HeII_5411_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(HeII 5411)"
			description="Absolute flux of He II λ5411 emission line."
			verbLevel="1"/>

	<column name="HeII_5411_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(HeII 5411)"
			description="Equivalent width of He II λ5411 emission line."
			verbLevel="1"/>

	<column name="CII_5801_5811_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(CII 5801–5811)"
			description="Absolute flux of C II λ5801–5811 blend."
			verbLevel="1"/>

	<column name="CII_5801_5811_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(CII 5801–5811)"
			description="Equivalent width of C II λ5801–5811 blend."
			verbLevel="1"/>

	<column name="HeII_HI_6560_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(HeII+HI 6560)"
			description="Absolute flux of He II + H I λ6560 blend."
			verbLevel="1"/>

	<column name="HeII_HI_6560_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(HeII+HI 6560)"
			description="Equivalent width of He II + H I λ6560 blend."
			verbLevel="1"/>

	<column name="HeII_6560_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(HeII 6560)"
			description="Absolute flux of He II λ6560 emission line."
			verbLevel="1"/>

	<column name="HeII_6560_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(HeII 6560)"
			description="Equivalent width of He II λ6560 emission line."
			verbLevel="1"/>

	<column name="HeII_6583_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(HeII 6583)"
			description="Absolute flux of He II λ6583 emission line."
			verbLevel="1"/>

	<column name="HeII_6583_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(HeII 6583)"
			description="Equivalent width of He II λ6583 emission line."
			verbLevel="1"/>

	<column name="HeII_6683_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(HeII 6683)"
			description="Absolute flux of He II λ6683 emission line."
			verbLevel="1"/>

	<column name="HeII_6683_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(HeII 6683)"
			description="Equivalent width of He II λ6683 emission line."
			verbLevel="1"/>

	<column name="HeI_7065_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(HeI 7065)"
			description="Absolute flux of He I λ7065 emission line."
			verbLevel="1"/>

	<column name="HeI_7065_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(HeI 7065)"
			description="Equivalent width of He I λ7065 emission line."
			verbLevel="1"/>

	<column name="NIV_7109_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(NIV 7109)"
			description="Absolute flux of N IV λ7109 emission line."
			verbLevel="1"/>

	<column name="NIV_7109_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(NIV 7109)"
			description="Equivalent width of N IV λ7109 emission line."
			verbLevel="1"/>

	<column name="NIV_7109_7122_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(NIV 7109–7122)"
			description="Absolute flux of N IV λ7109–7122 blend."
			verbLevel="1"/>

	<column name="NIV_7109_7122_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(NIV 7109–7122)"
			description="Equivalent width of N IV λ7109–7122 blend."
			verbLevel="1"/>

	<column name="NIV_7122_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(NIV 7122)"
			description="Absolute flux of N IV λ7122 emission line."
			verbLevel="1"/>

	<column name="NIV_7122_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(NIV 7122)"
			description="Equivalent width of N IV λ7122 emission line."
			verbLevel="1"/>

	<column name="NIV_HeII_7122_7177_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(NIV+HeII 7122–7177)"
			description="Absolute flux of N IV + He II λ7122–7177 blend."
			verbLevel="1"/>

	<column name="NIV_HeII_7122_7177_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(NIV+HeII 7122–7177)"
			description="Equivalent width of N IV + He II λ7122–7177 blend."
			verbLevel="1"/>

	<column name="NIV_7177_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(NIV 7177)"
			description="Absolute flux of N IV λ7177 emission line."
			verbLevel="1"/>

	<column name="NIV_7177_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(NIV 7177)"
			description="Equivalent width of N IV λ7177 emission line."
			verbLevel="1"/>

	<column name="HeII_7177_Fabs"
			type="real"
			ucd="phot.flux;em.line"
			unit="W.m**-2"
			tablehead="F(HeII 7177)"
			description="Absolute flux of He II λ7177 emission line."
			verbLevel="1"/>

	<column name="HeII_7177_EW"
			type="real"
			ucd="spect.line.eqWidth"
			unit="Angstrom"
			tablehead="EW(HeII 7177)"
			description="Equivalent width of He II λ7177 emission line."
			verbLevel="1"/>
	</table>

	<data id="import">
		<sources pattern="data/WR_spec_result_WN_power.csv"/>
		<make table="main">
			<rowmaker id="rm">
				<!-- имена: подрежем пробелы на входе -->
				<map key="object">@object</map>
				<map key="alt_name">@alt_name</map>
				<map key="sp">@sp</map>

				<!-- координаты из H:M:S / D:M:S в градусы -->
				<map key="ra">hmsToDeg(@ra, ":")</map>
				<map key="dec">dmsToDeg(@dec, ":")</map>

				<!-- фотометрия каталожная (если есть в CSV) -->
				<map key="B_cat">parseFloat(@B_cat)</map>
				<map key="V_cat">parseFloat(@V_cat)</map>
				<map key="mag_ref">@mag_ref</map>

				<!-- дата наблюдения: в ISO8601; если в CSV уже ISO, parseISODT просто вернёт datetime -->
				<map key="date_obs">parseDate(@date_obs)</map>
				<!-- при желании — MJD из той же даты (если есть колонка obs_mjd в таблице) -->
				<!-- <map key="obs_mjd">dateTimeToMJD(parseISODT(@date_obs))</map>-->

				<!-- фотометрия из наблюдений -->
				<map key="B_mag">parseFloat(killBlanks(@B_mag))</map>
				<map key="B_mag_err">parseFloat(killBlanks(@B_mag_err))</map>
				<map key="V_mag">parseFloat(killBlanks(@V_mag))</map>
				<map key="V_mag_err">parseFloat(killBlanks(@V_mag_err))</map>
				<map key="Rc_mag">parseFloat(@Rc_mag)</map>
				<map key="Rc_mag_err">parseFloat(@Rc_mag_err)</map>
				<map key="NIII_4514_Fabs">parseFloat(@NIII_4514_Fabs)</map>
				<map key="NIII_4514_EW">parseFloat(@NIII_4514_EW)</map>

				<map key="HeII_4514_4540_Fabs">parseFloat(@HeII_4514_4540_Fabs)</map>
				<map key="HeII_4514_4540_EW">parseFloat(@HeII_4514_4540_EW)</map>

				<map key="HeII_4540_Fabs">parseFloat(@HeII_4540_Fabs)</map>
				<map key="HeII_4540_EW">parseFloat(@HeII_4540_EW)</map>

				<map key="NIII_4619_Fabs">parseFloat(@NIII_4619_Fabs)</map>
				<map key="NIII_4619_EW">parseFloat(@NIII_4619_EW)</map>

				<map key="NV_4620_Fabs">parseFloat(@NV_4620_Fabs)</map>
				<map key="NV_4620_EW">parseFloat(@NV_4620_EW)</map>

				<map key="NIII_4634_4640_Fabs">parseFloat(@NIII_4634_4640_Fabs)</map>
				<map key="NIII_4634_4640_EW">parseFloat(@NIII_4634_4640_EW)</map>

				<map key="NIII_4640_Fabs">parseFloat(@NIII_4640_Fabs)</map>
				<map key="NIII_4640_EW">parseFloat(@NIII_4640_EW)</map>

				<map key="HeII_4685_Fabs">parseFloat(@HeII_4685_Fabs)</map>
				<map key="HeII_4685_EW">parseFloat(@HeII_4685_EW)</map>

				<map key="HeII_4686_Fabs">parseFloat(@HeII_4686_Fabs)</map>
				<map key="HeII_4686_EW">parseFloat(@HeII_4686_EW)</map>

				<map key="HeII_HI_4859_Fabs">parseFloat(@HeII_HI_4859_Fabs)</map>
				<map key="HeII_HI_4859_EW">parseFloat(@HeII_HI_4859_EW)</map>

				<map key="HeII_4859_Fabs">parseFloat(@HeII_4859_Fabs)</map>
				<map key="HeII_4859_EW">parseFloat(@HeII_4859_EW)</map>

				<map key="NV_4933_4944_Fabs">parseFloat(@NV_4933_4944_Fabs)</map>
				<map key="NV_4933_4944_EW">parseFloat(@NV_4933_4944_EW)</map>

				<map key="NV_4940_Fabs">parseFloat(@NV_4940_Fabs)</map>
				<map key="NV_4940_EW">parseFloat(@NV_4940_EW)</map>

				<map key="NV_4945_Fabs">parseFloat(@NV_4945_Fabs)</map>
				<map key="NV_4945_EW">parseFloat(@NV_4945_EW)</map>

				<map key="HeII_5411_Fabs">parseFloat(@HeII_5411_Fabs)</map>
				<map key="HeII_5411_EW">parseFloat(@HeII_5411_EW)</map>

				<map key="CII_5801_5811_Fabs">parseFloat(@CII_5801_5811_Fabs)</map>
				<map key="CII_5801_5811_EW">parseFloat(@CII_5801_5811_EW)</map>

				<map key="HeII_HI_6560_Fabs">parseFloat(@HeII_HI_6560_Fabs)</map>
				<map key="HeII_HI_6560_EW">parseFloat(@HeII_HI_6560_EW)</map>

				<map key="HeII_6560_Fabs">parseFloat(@HeII_6560_Fabs)</map>
				<map key="HeII_6560_EW">parseFloat(@HeII_6560_EW)</map>

				<map key="HeII_6583_Fabs">parseFloat(@HeII_6583_Fabs)</map>
				<map key="HeII_6583_EW">parseFloat(@HeII_6583_EW)</map>

				<map key="HeII_6683_Fabs">parseFloat(@HeII_6683_Fabs)</map>
				<map key="HeII_6683_EW">parseFloat(@HeII_6683_EW)</map>

				<map key="HeI_7065_Fabs">parseFloat(@HeI_7065_Fabs)</map>
				<map key="HeI_7065_EW">parseFloat(@HeI_7065_EW)</map>

				<map key="NIV_7109_Fabs">parseFloat(@NIV_7109_Fabs)</map>
				<map key="NIV_7109_EW">parseFloat(@NIV_7109_EW)</map>

				<map key="NIV_7109_7122_Fabs">parseFloat(@NIV_7109_7122_Fabs)</map>
				<map key="NIV_7109_7122_EW">parseFloat(@NIV_7109_7122_EW)</map>

				<map key="NIV_7122_Fabs">parseFloat(@NIV_7122_Fabs)</map>
				<map key="NIV_7122_EW">parseFloat(@NIV_7122_EW)</map>

				<map key="NIV_HeII_7122_7177_Fabs">parseFloat(@NIV_HeII_7122_7177_Fabs)</map>
				<map key="NIV_HeII_7122_7177_EW">parseFloat(@NIV_HeII_7122_7177_EW)</map>

				<map key="NIV_7177_Fabs">parseFloat(@NIV_7177_Fabs)</map>
				<map key="NIV_7177_EW">parseFloat(@NIV_7177_EW)</map>

				<map key="HeII_7177_Fabs">parseFloat(@HeII_7177_Fabs)</map>
				<map key="HeII_7177_EW">parseFloat(@HeII_7177_EW)</map>
			</rowmaker>
		</make>
		<csvGrammar/>
	</data>

	<service id="q" allowed="form">
		<meta name="shortName">WR WN Spec</meta>
		<publish render="form" sets="ivo_managed,local"/>
		<dbCore queriedTable="main">

			<condDesc>
				<inputKey name="name" type="text"
									ucd="meta.id;src"
									description="Search by object name or alternative name."/>
				<phraseMaker>
					<code>
val = inPars.get("name")
if not val:
	return
key1 = base.getSQLKey("object", "%" + val.replace(" ", "") + "%", outPars)
key2 = base.getSQLKey("alt_name", "%" + val.replace(" ", "") + "%", outPars)
yield "(UPPER(REPLACE(object, ' ', '')) LIKE UPPER(%%(%s)s) OR UPPER(REPLACE(alt_name, ' ', '')) LIKE UPPER(%%(%s)s))" % (key1, key2)
					</code>
				</phraseMaker>
			</condDesc>

			<condDesc>
				<inputKey name="sp" type="text"
									ucd="src.spType"
									description="Filter by spectral subtype (e.g., WN4, WN7)."/>
				<phraseMaker>
					<code>
val = inPars.get("sp")
if not val:
	return
key = base.getSQLKey("sp", "%" + val.strip().upper() + "%", outPars)
yield "UPPER(sp) LIKE %%(%s)s" % key
					</code>
				</phraseMaker>
			</condDesc>

			<condDesc buildFrom="date_obs"/>
			<condDesc buildFrom="B_mag"/>
			<condDesc buildFrom="V_mag"/>
			<condDesc buildFrom="Rc_mag"/>

		</dbCore>
	</service>

	<regSuite title="wr_spec_result (WN) regression">
		<regTest title="Base check of TAP aviabillity">
			<url parSet="TAP" QUERY="SELECT TOP 1 table_name FROM TAP_SCHEMA.tables">/tap/sync</url>
			<code>
				rows = list(self.getVOTableRows())
				self.assertTrue(len(rows) >= 0)
			</code>
		</regTest>
	</regSuite>

</resource>
