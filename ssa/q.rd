<?xml version="1.0" encoding="utf-8"?>

<resource schema="ssa" resdir=".">
    <meta name="title">Space Weather Data Service</meta>
    <meta name="creationDate">2024-11-14T12:02:00Z</meta>
    <meta name="description" format="plain">
        This service provides access to space weather data accumulated withing the SSA program run by FAI and Institute of Ionosphere (Almaty, Kazakhstan).
    </meta>
    <meta name="subject">space-weather</meta>
    <meta name="type">service</meta>

    <!-- Table Definition -->
    <table id="swdata">
        <column name="tstamp" type="timestamp" required="true" description="Timestamp of the data point" />
        <column name="val" type="double precision" required="true" description="Value of the data point" />
    </table>

    <!-- Service Definition -->
    <service id="sw" allowed="form,api">
        <meta name="shortName">swdata</meta>
        <customCore module="res/swcore"/>
        <!-- Publishing Information -->
        <publish sets="local,ivo_managed" render="form"/>
    </service>
</resource>

