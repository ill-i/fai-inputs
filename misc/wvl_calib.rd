<?xml version="1.0" encoding="UTF-8"?>

<resource resdir="." schema="cal">
  <meta>
    creationDate: 2026-08-16
    title: Wavelength Calibration Tool
    creator: A. Gluchshenko, I. Izmailova, A. Umirbayeva, D. Kuvatova, D. Yurin

    subject: virtual-observatories
    subject: astronomical-techniques
    subject: observational-astronomy
    subject: calibration

    referenceURL: https://vo.fai.kz/calibration
    contentLevel: General
    content.type: Education
  </meta>

  <meta name="description">The Wavelength Calibration Tool converts pixel coordinates of a one-dimensional calibration-lamp spectrum into a physical wavelength scale. Calibration requires a corresponding reference lamp spectrum with an already known wavelength axis, supplied by the user or selected from the built-in reference data. The service uses Dynamic Time Warping (DTW) to match emission peaks and RANSAC to reject incorrect matches and construct a robust polynomial dispersion solution. Users can inspect diagnostic plots and residual errors, then export the calibrated spectrum and calibration solution.</meta>

  <service id="comp" allowed="external">
    <meta name="shortName">wvl calib</meta>
    <publish sets="ivo_managed,local" render="external">
      <meta name="accessURL">https://vo.fai.kz/calibration</meta>
    </publish>
    <nullCore/>
  </service>
</resource>
