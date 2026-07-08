<resource resdir="." schema="cal">
   <meta>
    creationDate: 2018-08-21T10:02:00Z
    title: Astronomical Calendar: Sun and Moon Ephemerides and Twilight Calculator
    creator: V.Y. Kim

    subject:virtual-observatories
    subject:ephemerides

    referenceURL: https://fai.kz/calendar/calendar_eng.php
    contentLevel: General
    content.type: Education
  </meta>

 	<meta name="description">The Astronomical Calendar is a software package for automated calculations of the celestial coordinates (ephemerides) of the Sun and Moon. It computes the times of sunrise and sunset, the boundaries of civil, nautical, and astronomical twilight, and lunar phases, based on the geographic coordinates of the observing site and its time zone. A web-based implementation is hosted at the Fesenkov Astrophysical Institute and is available in Kazakh, Russian, and English. The service allows users to obtain ephemerides for any location on Earth and export results as tables (including PDF output).</meta>

  <service id="comp" allowed="external">
    <meta name="shortName">fai calendar</meta>
    <publish sets="ivo_managed,local" render="external">
      <meta name="accessURL">https://fai.kz/calendar/calendar_eng.php</meta>
    </publish>
    <nullCore/>
  </service>
</resource>
