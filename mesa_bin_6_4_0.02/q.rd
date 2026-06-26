<resource schema="mesa_bin_6_4_002" resdir=".">
  <meta name="creationDate">2026-04-16T10:00:00Z</meta>
  <meta name="title">MESA Grid: Binary Evolution (M1=6.0, M2=4.0, Z=0.02)</meta>
  
  <meta name="description" format="rst">
Grid of Close-Binary Evolution Models

This dataset contains a grid of close-binary evolution models computed with the 
**MESA** (Modules for Experiments in Stellar Astrophysics) code, version `r24.08.1`. 
The primary objective is to investigate the dependence of binary interaction on 
the initial orbital period.

**Model Configuration:**

* **Donor Star (M1):** Fixed initial mass of 6.0 M_sun. The evolution is 
  followed self-consistently.
* **Companion (M2):** Represented as a point mass of 4.0 M_sun.
* **Orbit:** Initially circular; the grid is constructed by varying the initial 
  orbital period.

**Physics and Assumptions:**

* **Mass Transfer:** Implemented via the *Ritter prescription* for Roche-lobe 
  overflow (RLOF).
* **Efficiency:** Fully conservative mass transfer is assumed.
* **Angular Momentum:** Includes losses due to gravitational radiation, 
  magnetic braking, and systemic mass loss.
* **Tides:** Tidal synchronization of the donor star is accounted for.
* **Exclusions:** Wind mass transfer and irradiation effects are not included.

**Termination Criteria:**

Calculations are terminated if:

1. Roche-lobe overflow occurs at the very first timestep.
2. The system undergoes overflow through the outer Lagrangian point (L2).

The setup is designed to isolate the role of the initial orbital period in 
determining the onset of mass transfer and the subsequent evolutionary regime.
  </meta>
  <meta name="subject">accretion</meta>
  <meta name="subject">roche-lobe-overflow</meta>
  <meta name="subject">binary-stars</meta>
  <meta name="subject">stellar-evolution</meta>
  <meta name="subject">stellar-evolutionary-models</meta>
  <meta name="subject">hertzsprung-russell-diagram</meta>

  <meta name="creator">Vaidman, N. L.; Izmailova, I.</meta>
  <meta name="instrument">MESA</meta>
  <meta name="facility">Fesenkov Astrophysical Institute</meta>
  <meta name="contentLevel">Research</meta>
  <meta name="type">Simulation</meta>

<table id="main" onDisk="True" adql="True">
    <column name="component" type="text" ucd="meta.id.part" description="Evolutionary component (STAR1 or STAR2)"/>
    <column name="m1" type="integer" required="True" unit="solMass" ucd="phys.mass" description="Initial mass of primary"/>
    <column name="m2" type="integer" required="True" unit="solMass" ucd="phys.mass" description="Initial mass of secondary"/>
    <column name="period" type="double precision" unit="d" ucd="time.period" description="Initial orbital period"/>
    <column name="z" type="double precision" ucd="phys.abund.Z" description="Initial metallicity"/>
    <column name="model_number" type="integer" required="True" description="Evolutionary step number"/>
    <column name="star_age" type="double precision" unit="yr" ucd="time.age" description="Current age of the star"/>
    <column name="star_mass" type="double precision" unit="solMass" ucd="phys.mass" description="Current stellar mass"/>
    <column name="log_abs_mdot" type="double precision" unit="solMass/yr" description="log10(abs(star_mdot))"/>
    <column name="log_dt" type="double precision" unit="yr" description="log10 time_step in years"/>
    <column name="num_zones" type="integer" required="True" description="Number of zones in the model"/>
    <column name="mass_conv_core" type="double precision" unit="solMass" description="Mass coordinate of top of convective core"/>
    <column name="conv_mx1_top" type="double precision" description="Top of largest convective region (m/Mstar)"/>
    <column name="conv_mx1_bot" type="double precision" description="Bottom of largest convective region (m/Mstar)"/>
    <column name="conv_mx2_top" type="double precision" description="Top of 2nd largest convective region (m/Mstar)"/>
    <column name="conv_mx2_bot" type="double precision" description="Bottom of 2nd largest convective region (m/Mstar)"/>
    <column name="mx1_top" type="double precision" description="Top of largest mixed region (m/Mstar)"/>
    <column name="mx1_bot" type="double precision" description="Bottom of largest mixed region (m/Mstar)"/>
    <column name="mx2_top" type="double precision" description="Top of 2nd largest mixed region (m/Mstar)"/>
    <column name="mx2_bot" type="double precision" description="Bottom of 2nd largest mixed region (m/Mstar)"/>
    <column name="epsnuc_M_1" type="double precision" unit="solMass" description="Start of 1st burning zone"/>
    <column name="epsnuc_M_2" type="double precision" unit="solMass" description="Inner edge of 1st burning zone reaches limit"/>
    <column name="epsnuc_M_3" type="double precision" unit="solMass" description="Outer edge of 1st burning zone drops below limit"/>
    <column name="epsnuc_M_4" type="double precision" unit="solMass" description="End of 1st burning zone"/>
    <column name="epsnuc_M_5" type="double precision" unit="solMass" description="Start of 2nd burning zone"/>
    <column name="epsnuc_M_6" type="double precision" unit="solMass" description="Inner edge of 2nd burning zone reaches limit"/>
    <column name="epsnuc_M_7" type="double precision" unit="solMass" description="Outer edge of 2nd burning zone drops below limit"/>
    <column name="epsnuc_M_8" type="double precision" unit="solMass" description="End of 2nd burning zone"/>
    <column name="he_core_mass" type="double precision" unit="solMass" description="Helium core mass"/>
    <column name="co_core_mass" type="double precision" unit="solMass" description="CO core mass"/>
    <column name="fe_core_mass" type="double precision" unit="solMass" description="Iron core mass"/>
    <column name="log_LH" type="double precision" description="log10 power_h_burn"/>
    <column name="log_LHe" type="double precision" description="log10 power_he_burn"/>
    <column name="log_LZ" type="double precision" description="log10 total burning power excluding LH and LHe"/>
    <column name="log_Lnuc" type="double precision" description="log(LH + LHe + LZ)"/>
    <column name="log_Teff" type="double precision" ucd="phys.temperature.effective" description="Log10 effective temperature"/>
    <column name="luminosity" type="double precision" unit="solLum" ucd="phys.luminosity" description="Luminosity in Lsun units"/>
    <column name="log_L" type="double precision" ucd="phys.luminosity" description="Log10 luminosity in Lsun units"/>
    <column name="log_R" type="double precision" ucd="phys.size.radius" description="Log10 radius in Rsun units"/>
    <column name="log_g" type="double precision" ucd="phys.gravity" description="Log10 surface gravity"/>
    <column name="gravity" type="double precision" description="Surface gravity"/>
    <column name="surf_avg_omega" type="double precision" description="Surface average angular velocity"/>
    <column name="surf_avg_omega_div_omega_crit" type="double precision" description="Surface average omega divided by critical omega"/>
    <column name="log_center_T" type="double precision" description="Log10 central temperature"/>
    <column name="log_center_Rho" type="double precision" description="Log10 central density"/>
    <column name="log_center_P" type="double precision" description="Log10 central pressure"/>
    <column name="center_mu" type="double precision" description="Central mean molecular weight"/>
    <column name="center_ye" type="double precision" description="Central electron fraction"/>
    <column name="center_h1" type="double precision" description="Central H1 mass fraction"/>
    <column name="center_he4" type="double precision" description="Central He4 mass fraction"/>
    <column name="center_c12" type="double precision" description="Central C12 mass fraction"/>
    <column name="center_o16" type="double precision" description="Central O16 mass fraction"/>
    <column name="surface_c12" type="double precision" description="Surface C12 mass fraction"/>
    <column name="surface_o16" type="double precision" description="Surface O16 mass fraction"/>
    <column name="total_mass_h1" type="double precision" unit="solMass" description="Total H1 mass"/>
    <column name="total_mass_he4" type="double precision" unit="solMass" description="Total He4 mass"/>
    <column name="pp" type="double precision" description="Log10 total luminosity for pp reaction category"/>
    <column name="cno" type="double precision" description="Log10 total luminosity for cno reaction category"/>
    <column name="tri_alpha" type="double precision" description="Log10 total luminosity for tri-alpha reaction category"/>
    <column name="v_div_csound_surf" type="double precision" description="Velocity divided by sound speed at surface"/>
    <column name="num_retries" type="integer" required="True" description="Number of solver retries"/>
    <column name="model_number_1" type="double precision" description="Secondary model number tracker"/>
    <column name="age" type="double precision" unit="yr" description="Binary system age"/>
    <column name="period_days" type="double precision" unit="d" ucd="time.period" description="Current binary period"/>
    <column name="binary_separation" type="double precision" unit="solRad" ucd="phys.size;src.orbital" description="Orbital separation"/>
    <column name="v_orb_1" type="double precision" unit="km/s" description="Orbital velocity of star 1"/>
    <column name="v_orb_2" type="double precision" unit="km/s" description="Orbital velocity of star 2"/>
    <column name="rl_1" type="double precision" unit="solRad" description="Roche lobe radius of star 1"/>
    <column name="rl_2" type="double precision" unit="solRad" description="Roche lobe radius of star 2"/>
    <column name="rl_relative_overflow_1" type="double precision" description="Roche lobe relative overflow for star 1"/>
    <column name="rl_relative_overflow_2" type="double precision" description="Roche lobe relative overflow for star 2"/>
    <column name="star_1_mass" type="double precision" unit="solMass" description="Mass of star 1"/>
    <column name="star_2_mass" type="double precision" unit="solMass" description="Mass of star 2"/>
    <column name="lg_mtransfer_rate" type="double precision" unit="solMass/yr" description="Log10 mass transfer rate"/>
    <column name="lg_mstar_dot_1" type="double precision" unit="solMass/yr" description="Log10 mass change rate star 1"/>
    <column name="lg_mstar_dot_2" type="double precision" unit="solMass/yr" description="Log10 mass change rate star 2"/>
    <column name="lg_system_mdot_1" type="double precision" unit="solMass/yr" description="Log10 system mass change rate 1"/>
    <column name="lg_system_mdot_2" type="double precision" unit="solMass/yr" description="Log10 system mass change rate 2"/>
    <column name="lg_wind_mdot_1" type="double precision" unit="solMass/yr" description="Log10 wind mass loss rate star 1"/>
    <column name="lg_wind_mdot_2" type="double precision" unit="solMass/yr" description="Log10 wind mass loss rate star 2"/>
    <column name="fixed_xfer_fraction" type="double precision" description="Fixed transfer fraction"/>
    <column name="eff_xfer_fraction" type="double precision" description="Effective transfer fraction"/>
    <column name="J_orb" type="double precision" description="Orbital angular momentum"/>
    <column name="Jdot" type="double precision" description="Rate of change of orbital angular momentum"/>
    <column name="jdot_mb" type="double precision" description="Jdot due to magnetic braking"/>
    <column name="jdot_gr" type="double precision" description="Jdot due to gravitational radiation"/>
    <column name="jdot_ml" type="double precision" description="Jdot due to mass loss"/>
    <column name="jdot_ls" type="double precision" description="Jdot due to L-S coupling"/>
    <column name="jdot_missing_wind" type="double precision" description="Jdot due to missing wind"/>
    <column name="extra_jdot" type="double precision" description="Extra Jdot term"/>
    <column name="donor_index" type="double precision" description="Index of the donor star"/>
    <column name="point_mass_index" type="double precision" description="Index of the point mass companion"/>
  </table>

  <data id="import">
    <sources>data/mesa_grid_consolidated.fits</sources>
    
    <fitsTableGrammar hdu="1"/>

    <make table="main">
      <rowmaker idmaps="*"/>
    </make>
  </data>

  <service id="q" allowed="form">
    <meta name="shortName">MESA_Bin_Grid</meta>
    <publish render="form" sets="ivo_managed,local"/>
    <dbCore queriedTable="main">
      <condDesc buildFrom="component"/>
      <condDesc buildFrom="m1"/>
      <condDesc buildFrom="m2"/>
      <condDesc buildFrom="period"/>
      <condDesc buildFrom="z"/>
      
      <condDesc buildFrom="star_age"/>
      <condDesc buildFrom="star_mass"/>
      <condDesc buildFrom="log_Teff"/>
      <condDesc buildFrom="log_L"/>
      <condDesc buildFrom="log_g"/>
      
      <condDesc buildFrom="binary_separation"/>
      <condDesc buildFrom="rl_relative_overflow_1"/>
      <condDesc buildFrom="lg_mtransfer_rate"/>
    </dbCore>
  </service>
  
  <regSuite title="MESA Grid Verification">
    <regTest title="Test TAP access by physical period">
      <url parSet="TAP"
           QUERY="SELECT * FROM mesa_bin_6_4_002.main  
            WHERE model_number=10 AND period=3 AND m2=4"
           >/tap/sync</url>
      <code>
        row = self.getFirstVOTableRow()
        self.assertAlmostEqual(row["mass_conv_core"], 1.4827209107778008)
        
        # Проверяем массу (как целое или число)
        self.assertEqual(int(row["m1"]), 6)
        
        # Проверяем компонент, убирая возможные пробелы ( strip() )
        self.assertEqual(row["component"].strip(), "STAR1_HISTORY")
      </code>
    </regTest>
  </regSuite>


  </resource>

