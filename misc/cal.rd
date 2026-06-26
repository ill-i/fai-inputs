<resource resdir="." schema="cal">
   <meta>
    creationDate: 2018-08-21T10:02:00Z
    title: Todo
    creator: XXX

    subject:virtual-observatories
    subject:ephemerides

    referenceURL: https://fai.kz/calendar/calendar_eng.php
    contentLevel: General
    content.type: Education
  </meta>

 	<meta name="description">Yadda</meta>

  <service id="comp" allowed="external">
    <meta name="shortName">fai calendar</meta>
    <publish sets="ivo_managed,local" render="external">
      <meta name="accessURL">https://fai.kz/calendar/calendar_eng.php</meta>
    </publish>
    <nullCore/>
  </service>
</resource>
