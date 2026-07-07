from influxdb_client import InfluxDBClient
import datetime
from lxml import etree
import os

def query_influxdb(source, start_time=None, end_time=None, rate='10m'):
    # InfluxDB v2 connection details
    INFLUX_URL = 'http://10.0.1.6:8086'  # Replace with your InfluxDB URL
    ORG = 'aphi_ssa'  # Replace with your organization name

    # Map source to bucket, filter, token, unit, and ucd
    bucket = None
    flux_filter = ""
    unit = 'arbitrary'
    ucd = 'phys.parameter'

    # Load tokens from environment variables or configuration
    tokens = {
        'default': os.environ.get('INFLUXDB_TOKEN_DEFAULT'),
        'solar': os.environ.get('INFLUXDB_TOKEN_SOLAR'),
        'k_index': os.environ.get('INFLUXDB_TOKEN_KINDEX'),
    }

    token = tokens.get('default')

    if source == 'solar':
        bucket = "data-orbita"
        token = tokens.get('solar')
        unit = 'W/m^2'  # Adjust as appropriate
        ucd = 'phot.flux.density;em.radio'
    elif source == 'neutrons':
        bucket = "data-neitron"
        unit = 'counts/s'
        ucd = 'phys.particle;phys.neutron'
    elif source == 'k_index':
        bucket = "data-kindex"
        token = tokens.get('k_index')
        unit = ''  # K-index is dimensionless
        ucd = 'phys.magField;phys.atmol.ionosphere'
    elif source == 'geomag':
        bucket = "data-geomag"
        flux_filter = '|> filter(fn: (r) => r["_measurement"] == "geomag_XYZF" and r["Component"] == "F Component variation")'
        unit = 'nT'
        ucd = 'phys.magField'
    elif source == 'geomag_x':
        bucket = "data-geomag"
        flux_filter = '|> filter(fn: (r) => r["_measurement"] == "geomag_XYZF" and r["Component"] == "X Component variation")'
        unit = 'nT'
        ucd = 'phys.magField'
    elif source == 'geomag_y':
        bucket = "data-geomag"
        flux_filter = '|> filter(fn: (r) => r["_measurement"] == "geomag_XYZF" and r["Component"] == "Y Component variation")'
        unit = 'nT'
        ucd = 'phys.magField'
    elif source == 'geomag_z':
        bucket = "data-geomag"
        flux_filter = '|> filter(fn: (r) => r["_measurement"] == "geomag_XYZF" and r["Component"] == "Z Component variation")'
        unit = 'nT'
        ucd = 'phys.magField'
    else:
        raise ValueError(f'Unknown source: {str(source)}')

    # Initialize client with the appropriate token
    if not token:
        raise ValueError(f'Token for source "{source}" is not configured')
    client = InfluxDBClient(url=INFLUX_URL, token=token, org=ORG)

    # Handle time parameters
    if not start_time:
        raise ValueError('START_TIME parameter is required')
    if not end_time:
        end_time = 'now()'  # In Flux, 'now()' represents the current time

    # Construct the Flux query
    flux_query = f'''
    from(bucket: "{bucket}")
      |> range(start: {start_time}, stop: {end_time})
      {flux_filter}
      |> aggregateWindow(every: {rate}, fn: mean, createEmpty: false)
      |> yield(name: "mean")
    '''

    try:
        result = client.query_api().query(query=flux_query)
    except Exception as e:
        # Handle exceptions appropriately
        raise Exception(f'Error querying InfluxDB: {e}')

    # Prepare data for VOTable
    data_records = []
    for table in result:
        for record in table.records:
            time_str = record.get_time().isoformat()
            value = record.get_value()
            data_records.append({'time': time_str, 'value': value})

    # Create VOTable
    votable = etree.Element('{http://www.ivoa.net/xml/VOTable/v1.4}VOTABLE')
    resource = etree.SubElement(votable, 'RESOURCE')
    table_elem = etree.SubElement(resource, 'TABLE')

    # Define fields (columns)
    fields = [
        {'name': 'time', 'datatype': 'char', 'arraysize': '*', 'ucd': 'time.epoch', 'unit': 'ISO8601'},
        {'name': 'value', 'datatype': 'double', 'ucd': ucd, 'unit': unit},
    ]

    for field in fields:
        field_element = etree.SubElement(table_elem, 'FIELD', attrib={
            'name': field['name'],
            'datatype': field['datatype'],
            'ucd': field['ucd'],
            'unit': field['unit'],
        })
        if 'arraysize' in field:
            field_element.attrib['arraysize'] = field['arraysize']

    # Add data
    data_elem = etree.SubElement(table_elem, 'DATA')
    tabledata = etree.SubElement(data_elem, 'TABLEDATA')

    for record in data_records:
        tr = etree.SubElement(tabledata, 'TR')
        for field in fields:
            td = etree.SubElement(tr, 'TD')
            value = record.get(field['name'], '')
            td.text = str(value) if value is not None else ''

    return etree.tostring(votable, xml_declaration=True, encoding='UTF-8')
