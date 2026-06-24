"""
This is a DaCHS processor (http://docs.g-vo.org/DaCHS/processors.html)
to add standard headers to FITS files from the FAI 50cm Maksutov telescope.
"""
import csv
import os
import re
import sys
import warnings
# Suppress all warnings
warnings.filterwarnings("ignore")
from astropy.time import Time
import astropy.units as u
from astropy.coordinates import EarthLocation
from astroquery.simbad import Simbad
from astroplan.observer import Observer
from astropy.io import fits
import pandas as pd
from transliterate import translit #for observer


import pandas as pd
import numpy as np

from gavo.helpers import fitstricks
from gavo import api
from gavo.helpers import anet

from googletrans import Translator


##################################################
#_______________SOME INITIAL DATA________________#
##################################################

observatory= Observer(name='observatory',location=EarthLocation.from_geodetic('76d57m58.00s','43d10m36.00s'))

def translate_to_english(text):
    translator = Translator()
    translated = translator.translate(text, src='ru', dest='en')
    return translated.text

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~OBJECT NAME~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

def get_object_cards(raw_objects):
  """
  returns dictionary of keyword-value pairs for the FITS headers for our raw objects list

  >>> get_object_cards("Th4-4")
  {'OBJECT': 'Th4-4'}
  >>> get_object_cards("NGC6611;NGC6618")
  {'OBJECT': 'NGC6611', 'OBJECT1': 'NGC6611', 'OBJECT2': 'NGC6618'}
  """
  objects=raw_objects.split(";")
  if len(objects)==1:
    return {"OBJECT": objects[0]}
  else:
    retval = {"OBJECT": objects[0]}
    retval.update(dict(
      (f"OBJECT{n+1}",val) for n,val in enumerate(objects)))
    return retval

def get_objtype_cards(raw_objtype):
  """
  returns dictionary of keyword-value pairs for the FITS headers for our raw objects list

  """
  objtype=raw_objtype.split(";")
  if len(objtype)==1:
    return {"OBJTYPE": objtype[0]}
  else:
    retval = {"OBJTYPE": objtype[0]}
    retval.update(dict(
      (f"OBJTYPE{n+1}",val) for n,val in enumerate(objtype)))
    return retval

def get_filters_cards(filters):
  """
  returns dictionary of keyword-value pairs for the FITS headers for filters list

  >>> get_filters_cards(["name"])
  {'FILTER': 'name'}
  >>> get_filters_cards(["name1","name2"])
  {'FILTER': 'name1', 'FILTER1': 'name1', 'FILTER2': 'name2'}
  """
  if len(filters)==1:
    return {"FILTER": filters[0]}
  else:
    retval = {"FILTER": filters[0]}
    retval.update(dict(
      (f"FILTER{n+1}",val) for n,val in enumerate(filters)))
    return retval
  
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~COORDINATES~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEC_FORMATS = [re.compile(pat) for pat in [
    r"(?P<sign>-?)(?P<degrees>\d+\.?\d*)$",
    r"(?P<sign>-?)((?P<degrees>\d+) (?P<minutes>\d+\.?\d*))$",
    r"(?P<sign>-?)(?P<degrees>\d+) (?P<minutes>\d+)(?: (?P<seconds>\d+(?:.\d+)?))?$",
    r"(?P<sign>-?)((?P<degrees>\d+):(?P<minutes>\d+):(?P<seconds>\d+(?:.\d+)?))$",
]]

def dec_to_deg(raw_dec):
    """
    returns declanation as float in degrees.

    >>> dec_to_deg("29.06")
    29.06
    >>> dec_to_deg("-23.30")
    -23.3
    >>> "{:.5f}".format(dec_to_deg("50 41 45"))
    '50.69583'
    >>> "{:.5f}".format(dec_to_deg("-01 28 02"))
    '-1.46722'
    >>> "{:.5f}".format(dec_to_deg("-01 28"))
    '-1.46667'
    """
    #print("dec ", raw_dec)
    if not raw_dec:
      return None
    try:
      raw_dec = raw_dec.strip().replace("+","")
    except AttributeError:
      print("raw_dec ",raw_dec)
    if ":" in raw_dec:
      raw_dec = raw_dec.replace(":", " ")

    for pattern in DEC_FORMATS:
        mat = re.match(pattern, raw_dec)
        if mat:
            break
    else:
        raise ValueError(f"Not a valid Dec {raw_dec}")

    parts = mat.groupdict()
    deg = (float(parts["degrees"])
        + float(parts.get("minutes", 0))/60.
        + float(parts.get("seconds", 0) or 0)/3600.)

    if parts["sign"]=="-":
        return -deg
    else:
        return deg

def reformat_single_dec(raw_dec):
    """
    returns declination in the format "dd:mm:ss".

    >>> reformat_single_dec("29.06")
    '+29:03:36'
    >>> reformat_single_dec("-23.30")
    '-23:18:00'
    >>> reformat_single_dec("50 41 45")
    '+50:41:45'
    >>> reformat_single_dec("-01 28 02")
    '-01:28:02'
    >>> reformat_single_dec("-01 28")
    '-01:28:00'
    """
    return api.degToDms(
        dec_to_deg(raw_dec),
        sepChar=":", secondFracs=0,
        preserveLeading=True)

def reformat_dec(raw_dec):
    """
    returns declination in the format "dd:mm:ss".

    >>> reformat_dec("29.06;-23.30")
    ['+29:03:36', '-23:18:00']
    >>> reformat_dec("50 41 45")
    ['+50:41:45']
    >>> reformat_dec("-01 28")
    ['-01:28:00']
    """
    raw_dec = raw_dec.split(";")
    return [reformat_single_dec(dec) for dec in raw_dec]

RA_FORMATS = [re.compile(pat) for pat in [
    r"(?P<hours>\d+) (?P<minutes>\d+)(?: (?P<seconds>\d+(?:.\d+)?))?$",
    r"(?P<hours>\d+)h(?P<minutes>\d+(?:\.\d+)?)m(?:(?P<seconds>\d+)s)?$",
    r"(?P<hours>\d+)h(?P<minutes>\d+(?:m?\.\d+)?)(?:(?P<seconds>\d+)s)?$",
    r"(?P<hours>\d+):(?P<minutes>\d+):(?P<seconds>\d+(?:.\d+)?)$",
]]

def ra_to_deg(raw_ra):
    """
    returns declanation as float in degrees.

    >>> "{:.5f}".format(ra_to_deg("05 32 49"))
    '83.20417'
    >>> ra_to_deg("05h33m")
    83.25
    >>> "{:.4f}".format(ra_to_deg("02h41m45s"))
    '40.4375'
    >>> ra_to_deg("01 28")
    22.0
    """
    #print("ra ", raw_dec)
    if not raw_ra:
      return None

    try:
      raw_ra = raw_ra.strip()
    except AttributeError:
      print("raw_ra ",raw_ra)
    if ":" in raw_ra:
      raw_ra = raw_ra.replace(":", " ")

    for pattern in RA_FORMATS:
        mat = re.match(pattern, raw_ra)
        if mat:
            break
    else:
        raise ValueError(f"Not a valid RA {raw_ra}")

    parts = mat.groupdict()
    hours = (float(parts["hours"])
        + float(parts["minutes"].replace("m",""))/60.
        + float(parts["seconds"] or 0)/3600.)
    return hours/24*360

def reformat_single_ra(raw_ra):
    """
    returns right ascension in the format "hh:mm:ss"

    >>> reformat_single_ra("05 32 49")
    '05:32:49'
    >>> reformat_single_ra("05h33m")
    '05:33:00'
    >>> reformat_single_ra("02h41m45s")
    '02:41:45'
    >>> reformat_single_ra("01 28")
    '01:28:00'
    >>> reformat_single_ra("12h")
    Traceback (most recent call last):
    ValueError: Not a valid RA 12h
    """
    return api.degToHms(ra_to_deg(raw_ra), sepChar=":", secondFracs=0)

def reformat_ra(raw_ra):
    """
    returns right ascension in the format "hh:mm:ss"

    >>> reformat_ra("05 32 49;05h33m")
    ['05:32:49', '05:33:00']
    >>> reformat_ra("02h41m45s;01 28")
    ['02:41:45', '01:28:00']
    >>> reformat_ra("12h")
    Traceback (most recent call last):
    ValueError: Not a valid RA 12h
    """
    raw_ra = raw_ra.split(";")
    return [reformat_single_ra(ra) for ra in raw_ra]

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~EXPOSURE~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

def parse_single_exposure(raw_time):
    """returns seconds of time for an h-m-s time string.

    Here is the syntax supported by the function.

    >>> parse_single_exposure("1h")
    3600.0
    >>> parse_single_exposure("4h30m")
    16200.0
    >>> parse_single_exposure("1h30m20s")
    5420.0
    >>> parse_single_exposure("20m")
    1200.0
    >>> parse_single_exposure("10.5m")
    630.0
    >>> parse_single_exposure("1m10s")
    70.0
    >>> parse_single_exposure("15s")
    15.0
    >>> parse_single_exposure("s23m")
    Traceback (most recent call last):
    ValueError: Cannot understand time 's23m'
    """
    try:
      raw_time.replace(" ","")
    except AttributeError:
      print("raw_time ",raw_time)
    mat = re.match(
        r"^(?P<hours>\d+(?:\.\d+)?h)?"
        r"(?P<minutes>(\d+m)?(?:\d+\.\d+m)?(?:\d+m\.\d+)?)?"
        r"(?P<seconds>\d+(?:\.\d+)?s?)?$", raw_time.replace(" ",""))
    if mat is None:
        raise ValueError(f"Cannot understand time '{raw_time}'")
    parts = mat.groupdict()
    return (float((parts["hours"] or "0h").replace('h',''))*3600
        + float((parts["minutes"] or "0m").replace("m",""))*60
        + float((parts["seconds"] or "0s").replace('s','')))

def parse_exposure_times(raw_time):
    """
    returns a list of floats giving the exposure times encoded in raw_exp_times.

    This is a ;-separated list of individual items.    see parse_single_exposure for
    details on the format.
    >>> parse_exposure_times("1h;2h;3h")
    [3600.0, 7200.0, 10800.0]
    >>> parse_exposure_times("1h30m20s;2h20m10s")
    [5420.0, 8410.0]
    >>> parse_exposure_times("1h30m20s;h20m10s")
    Traceback (most recent call last):
    ValueError: Cannot understand time 'h20m10s'
    """
    try:
      raw_time.replace(" ","")
    except AttributeError:
      print("raw_time1 ",raw_time)
    if ';' in raw_time:
      return [parse_single_exposure(r_t.replace(" ",""))
        for r_t in raw_time.split(";")]
    else:
      return [parse_single_exposure(r_t.replace(" ",""))
        for r_t in raw_time.split(",")]

def get_exposure_cards(raw_exp_times):
  """
  returns dict of keyword-value pairs for the FITS headers for our raw
  exposure times.

  >>> get_exposure_cards("1h")
  {'EXPTIME': 3600.0}
  >>> get_exposure_cards("1h;5h")
  {'EXPTIME': 3600.0, 'EXPTIM1': 3600.0, 'EXPTIM2': 18000.0}
  """
  exptimes = parse_exposure_times(raw_exp_times)
  if len(exptimes)==1:
    return {"EXPTIME": exptimes[0]}
  else:
    retval = {"EXPTIME": exptimes[0]}
    retval.update(dict(
      (f"EXPTIM{n+1}", val) for n, val in enumerate(exptimes)))
    return retval

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~TIME OBS~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TIME_FORMATS = [re.compile(pat) for pat in [
    r"(?P<hours>\d+)h$",
    r"(?P<hours>\d+\.h\d+)$",
    r"(?P<hours>\d+)h(?P<minutes>\d+)m?$",
    r"(?P<hours>\d+)h(?P<minutes>\d+(?:\.\d+)?)m?$",
    r"(?P<hours>\d+)h(?P<minutes>\d+(?:m?\.\d+)?)$",
    r"(?P<hours>\d+h)(?P<minutes>\d+)m(?P<seconds>\d+)s?$",
]]

def reformat_single_time(raw_time):
    """
    returns time in format hh:mm:ss

    >>> reformat_single_time("12.h5")
    '12:30:00'
    >>> reformat_single_time("2h23m23s")
    '02:23:23'
    >>> reformat_single_time("5h31")
    '05:31:00'
    >>> reformat_single_time("5h31m")
    '05:31:00'
    >>> reformat_single_time("13h54m24s")
    '13:54:24'
    >>> reformat_single_time("13h54m24")
    '13:54:24'
    >>> reformat_single_time("h20m2")
    Traceback (most recent call last):
    ValueError: Not a valid time h20m2
    """

    try:
      raw_time.replace(" ","")
    except AttributeError:
      print("raw_time2 ",raw_time)
    raw_time = raw_time.replace(" ","")
    for pattern in TIME_FORMATS:
        mat = re.match(pattern, raw_time)
        if mat:
            break
    else:
        raise ValueError(f"Not a valid time {raw_time}")

    parts = mat.groupdict()
    hours = (float(parts.get("hours", '0h').replace('h', ''))
        + float(parts.get("minutes", '0m').replace('m', ''))/60.
        + float(parts.get("seconds", '0s').replace('s',''))/3600.)

    return api.hoursToHms(hours)

def reformat_time(raw_times):
    """
    returns time in format hh:mm:ss
    >>> reformat_time('2h23m23s;10h58m')
    ['02:23:23', '10:58:00']
    >>> reformat_time('5h31m;22h19m')
    ['05:31:00', '22:19:00']
    >>> reformat_time('1h54;13h49')
    ['01:54:00', '13:49:00']
    >>> reformat_time('2h23m23s;3h13m45s')
    ['02:23:23', '03:13:45']
    """
    if raw_times==raw_times and raw_times!=None:
        return [reformat_single_time(time) for time in raw_times.split(";")]
    else:
        return None

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~TIME ORIG~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


def get_time_start_cards(raw_times, time_format):
  """
  returns dict of keyword-value pairs for the FITS headers for our raw
  local sidereal time of end of observations.

  >>> get_time_start_cards("1h23m12s", "LT ")
  {'TMS-ORIG': 'LT 01:23:12'}
  >>> get_time_start_cards("13h23m;5h13;12h15m54s", "LST ")
  {'TMS-ORIG': 'LST 13:23:00', 'TMS-OR1': 'LST 13:23:00', 'TMS-OR2': 'LST 05:13:00', 'TMS-OR3': 'LST 12:15:54'}
  """
  times = reformat_time(raw_times)
  if len(times)==1:
    return {"TMS-ORIG": f"{time_format}{times[0]}"}
  else:
    retval = {"TMS-ORIG": f"{time_format}{times[0]}"}
    retval.update(dict(
      (f"TMS-OR{n+1}", f"{time_format}{val}") for n, val in enumerate(times)))
    return retval

def get_time_end_cards(raw_times, time_format):
  """
  returns dict of keyword-value pairs for the FITS headers for our raw
  local sidereal time of end of observations.

  >>> get_time_end_cards("1h23m12s", "LT ")
  {'TME-ORIG': 'LT 01:23:12'}
  >>> get_time_end_cards("13h23m;5h13;12h15m54s", "LST ")
  {'TME-ORIG': 'LST 13:23:00', 'TME-OR1': 'LST 13:23:00', 'TME-OR2': 'LST 05:13:00', 'TME-OR3': 'LST 12:15:54'}
  """
  times = reformat_time(raw_times)
  if len(times)==1:
    return {"TME-ORIG": f"{time_format}{times[0]}"}
  else:
    retval = {"TME-ORIG": f"{time_format}{times[0]}"}
    retval.update(dict(
      (f"TME-OR{n+1}", f"{time_format}{val}") for n, val in enumerate(times)))
    return retval

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~DATE OBS~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

def expand_date(raw_date):
    """
    Inserts a 19 in front of the year part of a d.m.y raw_date if we
    sense a two-digit year and inserts 0 in front of date/month part
    if there is one digit date

    >>> expand_date("30.x1.29")
    '30.x1.1929'
    >>> expand_date("30.x1.1929")
    '30.x1.1929'
    >>> expand_date("3.2.98")
    '03.02.1998'
    >>> expand_date("13.2.98")
    '13.02.1998'
    >>> expand_date("3.12.1998")
    '03.12.1998'
    """
    date_split = raw_date.split(".")
    if len(date_split[0])==1:
        date_split[0] = f'0{date_split[0]}'
    if len(date_split[1])==1:
        date_split[1] = f'0{date_split[1]}'
    if len(date_split[-1])==2:
        date_split[-1] = f'19{date_split[-1]}'
    return f'{date_split[0]}.{date_split[1]}.{date_split[2]}'

def parse_one_date(raw_date):
    """
    Returns the first part of a date or date interval.

    >>> parse_one_date('13.03.1956')
    '13.03.1956'
    >>> parse_one_date('13.04.76')
    '13.04.1976'
    >>> parse_one_date('01-02.01.1964')
    '01.01.1964'
    >>> parse_one_date('01-02.01.64')
    '01.01.1964'
    >>> parse_one_date('31.08-01.09.1967')
    '31.08.1967'
    >>> parse_one_date('31.08-01.09.67')
    '31.08.1967'
    >>> parse_one_date('31.12.1965-01.01.1966')
    '31.12.1965'
    >>> parse_one_date('31.12.65-01.01.66')
    '31.12.1965'
    >>> parse_one_date('31.12.65-01.01.1966')
    '31.12.1965'
    >>> parse_one_date('31.12.1965-01.01.66')
    '31.12.1965'
    >>> parse_one_date('31.12.1965-01.66')
    Traceback (most recent call last):
    ValueError: not enough values to unpack (expected 3, got 2)
    """
    interval = raw_date.split("-")
    ##print("interval ", interval)
    if len(interval)==1:#one date 13.10.1968
        start_parts = interval[0].split(".") #["13","10","1968"]
    else: #few dates 12-13.10.1968
        # complete the start date from parts of the end date
        end_day, end_month, end_year = interval[1].split(".")
        try:
          start_parts = interval[0].strip().split(".")
        except AttributeError:
          print("start_parts ", start_parts) 
        if len(start_parts)==1: #one month 12-13.10.1968
          start_parts.extend([end_month, end_year])
        elif len(start_parts)==2: #two month 31.05-01.06.1978
          start_parts.append(end_year)
        elif len(start_parts)==3: #two month 31.05.-01.06.1978
          if start_parts[-1]=="":
            start_parts = start_parts[:2]
            start_parts.append(end_year) 
        #if there is len = 3 (31.12.1987-01.01.1988)
        #the first values will be remembered

    start_date = ".".join(start_parts)
    return expand_date(start_date)

def parse_date_list(raw_dates):
    """
    Returns evening date of observations.

    For more information look at parse_one_date()

    >>> parse_date_list('13.03.1956;14.03.1956')
    ['13.03.1956', '14.03.1956']
    >>> parse_date_list('13.04.76;14.04.76')
    ['13.04.1976', '14.04.1976']
    >>> parse_date_list('01-02.01.1964;02-03.01.1964')
    ['01.01.1964', '02.01.1964']
    >>> parse_date_list('01-02.01.64;02-03.01.64')
    ['01.01.1964', '02.01.1964']
    >>> parse_date_list('31.08-01.09.1967;01-02.09.1967')
    ['31.08.1967', '01.09.1967']
    >>> parse_date_list('31.08-01.09.67;01-02.09.67')
    ['31.08.1967', '01.09.1967']
    >>> parse_date_list('31.12.1965-01.01.1966;01-02.01.1966')
    ['31.12.1965', '01.01.1966']
    >>> parse_date_list('31.12.65-01.01.66;01-02.01.66')
    ['31.12.1965', '01.01.1966']
    >>> parse_date_list('31.12.65-01.01.1966;01-02.01.1966')
    ['31.12.1965', '01.01.1966']
    >>> parse_date_list('31.12.1965-01.01.66;01-02.01.1966')
    ['31.12.1965', '01.01.1966']
    """
    return [parse_one_date(raw_date)
        for raw_date in raw_dates.split(";")]

def get_date_cards(raw_dates):
  """
  returns dict of keyword-value pairs for the FITS headers for our raw
  local sidereal time of the start of observations.

  >>> get_date_cards('13.03.1956')
  {'DATEORIG': '13.03.1956'}
  >>> get_date_cards('31.12.1965-01.01.66;01-02.01.1966')
  {'DATEORIG': '31.12.1965', 'DATEOR1': '31.12.1965', 'DATEOR2': '01.01.1966'}
  >>> get_date_cards('01-02.01.1964')
  {'DATEORIG': '01.01.1964'}
  """
  dates = parse_date_list(raw_dates)
  if len(dates)==1:
    return {"DATEORIG": dates[0]}
  else:
    retval = {"DATEORIG": dates[0]}
    retval.update(dict(
      (f"DATEOR{n+1}", val) for n, val in enumerate(dates)))
    return retval

def get_date_cards(raw_dates):
  """
  returns dict of keyword-value pairs for the FITS headers for our raw
  local sidereal time of the start of observations.

  >>> get_date_cards('13.03.1956')
  {'DATEORIG': '13.03.1956'}
  >>> get_date_cards('31.12.1965-01.01.66;01-02.01.1966')
  {'DATEORIG': '31.12.1965', 'DATEOR1': '31.12.1965', 'DATEOR2': '01.01.1966'}
  >>> get_date_cards('01-02.01.1964')
  {'DATEORIG': '01.01.1964'}
  """
  dates = parse_date_list(raw_dates)
  if len(dates)==1:
    return {"DATEORIG": dates[0]}
  else:
    retval = {"DATEORIG": dates[0]}
    retval.update(dict(
      (f"DATEOR{n+1}", val) for n, val in enumerate(dates)))
    return retval

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~DATE OBS~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

def get_sid_delta(dates, sid_times):
  """
  Returns delta (hours, float) list for sidereal times.
  Delta between midnight and obs time.

  dates -- list of obs dates from obs log ["31.12.1989","01.01.1990"]
  sid_times -- list of SIDEREAL obs times from obs log, XX.XX hours (hh:mm:ss or floats)

  >>> get_sid_delta(["31.12.1989","01.01.1990"],[7.45,7.56])
  [1.7090326129862063, 1.7530447602092671]
  >>> get_sid_delta(["08.02.1964"], ["3:15:00","3:30:00"])
  [-5.007863908919145]
  """
  longitude = longitude = (76+57/60+57/3600)*u.degree # longitude of Kamenskoye Plato Observatory
  coef = 24/(23+56/60+4/3600)
  delta_initial = 6*coef
  dates_ymd = []
  #we have to rewrite dates from DD.MM.YYYY format to YYYY-MM-DD format
  for i in range(0,len(dates)):
    if "." in dates[i]:
      d = dates[i].split(".")
      dates_ymd.append(f"{d[2]}-{d[1]}-{d[0]}".replace(" ",""))

  if len(dates) == 1:
    lst_mid = (Time(f"{dates_ymd[0]} 00:00:00").sidereal_time('mean',longitude=longitude).value - delta_initial)%24
    return [get_one_sid_delta(lst_mid,sid_times[0])]

  elif len(dates) == 2:
    lst_mid_1 = (Time(f"{dates_ymd[0]} 00:00:00").sidereal_time('mean',longitude=longitude).value - delta_initial)%24
    lst_mid_3 = (Time(f"{dates_ymd[1]} 00:00:00").sidereal_time('mean',longitude=longitude).value - delta_initial)%24
    return [get_one_sid_delta(lst_mid_1,sid_times[0]),get_one_sid_delta(lst_mid_3,sid_times[1])]

def get_one_sid_delta(lst_mid,sid_time):
    """
    Returns delta in parts of hour between midnight time and
    time from observational log.
    Delta is positive if observation was made after midnight
    and negative if before.
    lst_mid -- local sidereal time XX.XX hours (floats!)
    sid_time -- obs sidereal time XX.XX hours (hh:mm:ss or floats)

    >>> "{:.5f}".format(get_one_sid_delta(13,"17:00:00"))
    '4.00000'
    >>> "{:.5f}".format(get_one_sid_delta(1,23))
    '2.00000'
    >>> "{:.5f}".format(get_one_sid_delta(1,4))
    '3.00000'
    >>> "{:.5f}".format(get_one_sid_delta(15,10))
    '5.00000'
    """

    if ":" in str(sid_time):
        sid_time  = api.dmsToDeg(sid_time, ":")%24
    if lst_mid>=0 and lst_mid<=12:

        if sid_time>=12 and sid_time<24:

            delta = lst_mid - sid_time

            if abs(delta) > 8 and abs(delta) < 24: #before mid
                delta = 24 % abs(delta)
            elif abs(delta) > 24:
                delta = abs(delta) % 24

            else: #after mid
                delta = delta

        elif sid_time>=0 and sid_time<=12:#before
            delta = -(lst_mid - sid_time)

    elif lst_mid>=12 and lst_mid<24:

        if sid_time>=12 and sid_time<24:#before
            delta = -(lst_mid - sid_time)

        elif sid_time>=0 and sid_time<=12:
            delta = sid_time - lst_mid

            if abs(delta) > 8: #after mid
                delta = delta%24
            else:  #before mid
                delta = -delta

   # coef = 24/(23+56/60+4/3600)   # because sidereal time not equal usual time. it is 23:56:04, not 24 hour

    return delta#*coef

def get_lt_from_st(dates, sid_times):
  """
  Returns local date-time FUNCTION of observation from sidereal time
  and doesn't take into accaunt real delta between
  UT and local time (DLS and DT).

  dates -- list of obs dates from obs log
  sid_times -- list of SIDEREAL obs times from obs log ["hh:mm:ss"]

  >>> get_lt_from_st(["09.02.1989"], ["10:24:06"])
  [<Time object: scale='utc' format='iso' value=1989-02-10 02:00:58.509>]
  >>> get_lt_from_st(["14.09.1964","15.09.1964"], ["01:24:06","20:42:06"])
  [<Time object: scale='utc' format='iso' value=1964-09-15 02:45:12.063>, <Time object: scale='utc' format='iso' value=1964-09-15 21:59:15.508>]
  """

  delta_i = get_sid_delta(dates, sid_times) #list. may contain 1 or 2 elements
  #we have to rewrite dates from DD.MM.YYYY format to YYYY-MM-DD format
  dates_ymd = []
  for i in range(0,len(dates)):
    if "." in dates[i]:
      d = dates[i].split(".")
      dates_ymd.append(f"{d[-1]}-{d[1]}-{d[0]}")

  if len(dates_ymd) == 1: #given date is date of beginning of whole night obeservations
    return [Time(f"{dates_ymd[0]} 00:00:00") + 1*u.day + delta_i[0]*u.hour] #so we add 1 day, because we need midnight
    #of observational night (for more info see parse_date_list function because dates goes from there)

  elif len(dates_ymd) == 2:
    return [Time(f"{dates_ymd[0]} 00:00:00") + 1*u.day + delta_i[0]*u.hour,Time(f"{dates_ymd[1]} 00:00:00") + 1*u.day + delta_i[1]*u.hour]

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~CHECK SUN AND ALTITUDE~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

def get_object_altitude(dec,phi,hour_angle):
  """

  Returns altitude of object in degrees (float)

  dec -- [float, deg] declanation of object
  phi -- [float, deg] latitud of observatory
  hour_angle -- [float, deg] hour angle of object (LST-RA)

  >>> "{:.5f}".format(get_object_altitude(-29.5596111111111111,43.17666666666666,21.40750000000000003))
  '14.65550'
  >>> "{:.5f}".format(get_object_altitude(8.869166666666667,43.17666666666666,1.041111111111111))
  '55.68041'

  """
  return 90 - np.arccos(np.sin(phi*u.degree)*np.sin(dec*u.degree)+np.cos(phi*u.degree)*np.cos(dec*u.degree)*np.cos(hour_angle*u.degree)).to_value("degree")

def sun_set_rise_time(date,observatory):
  """
  Returns sunset and sunrise time for observational point
  Sometimes function define wrong date of sunset/sunrise
  because parameters ("next","near","previous") are not
  universal.

  date -- time function
  observatory -- astroplan object with neccessary data about observatation place

  >>> sun_set_rise_time(Time("1987-08-12 00:00:00"),observatory= Observer(name='observatory',location=EarthLocation.from_geodetic('76d57m58.00s','43d10m36.00s')))
  (<Time object: scale='utc' format='jd' value=2447019.3312281347>, <Time object: scale='utc' format='jd' value=2447019.748774269>)
  >>> sun_set_rise_time(Time("1964-01-23 00:00:00"),observatory= Observer(name='observatory',location=EarthLocation.from_geodetic('76d57m58.00s','43d10m36.00s')))
  (<Time object: scale='utc' format='jd' value=2438417.2391776997>, <Time object: scale='utc' format='jd' value=2438417.8487855475>)
  """

  if Time(f"{date.iso[:10]} 00:00:00")-date < 30*u.second:
    date = Time(f"{date.iso[:10]} 00:00:00")

  sunset = observatory.sun_set_time(date, which='previous')+6*u.hour
  delta = date.datetime.day - sunset.datetime.day
  if delta != 1 and delta < 27 and delta > 30: # also check for end of month (28,29,30,31)
    sunset =observatory.sun_set_time(date, which='nearest')+6*u.hour
    delta = date.datetime.day - sunset.datetime.day
    if delta != 1 and delta < 27 and delta > 30: # also check for end of month (28,29,30,31)
      raise ValueError(f"Cannot define sunset time for {date.iso} -- {sunset}")

  try:
    sunrise = observatory.sun_rise_time(date, which='nearest')+6*u.hour
  except TypeError:
    sunrise = observatory.sun_rise_time(date, which='previous')+6*u.hour
  # print("sunrise ", sunrise)

  sunrise = sunrise.flatten()[0] #somewhy sometimes becomes an array

  delta = date.datetime.day - sunrise.datetime.day
  if date.datetime.day - sunrise.datetime.day != 0:
    sunrise = observatory.sun_rise_time(date, which='next')+6*u.hour
    delta = date.datetime.day - sunrise.datetime.day
    if date.datetime.day - sunrise.datetime.day != 0:
      raise ValueError(f"Cannot define sunset time for {date.iso} -- {sunset}")

  return sunset, sunrise

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~DATE-TIME UT~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

def get_delta_real(date):

  """
  Returns true delta (float, hours)
  date - time function of date of observ

  >>> get_delta_real(Time("1964-08-13 00:00:00.000"))
  <Quantity 6. h>
  >>> get_delta_real(Time("1984-03-25 03:45:54.000"))
  <Quantity 7. h>

  """
  sunday = Time("2022-05-01 00:00:00")
  y = date.datetime.year#year of observation
  m = date.datetime.month#month of observation
  d = date.datetime.day#day of observation
  hour = date.datetime.hour#day of observation

  if y >= 1981 and y < 1991:
      if m == 3:
          if d >=25 and d <= 31:
              modulo = (date - sunday).value%7
              if modulo < 1:
                  if int(hour) >= 3:
                      delta=7*u.hour
                  else:
                      delta= 6*u.hour
              else:
                  t = Time(f"{y}-{m}-23 00:00:00")
                  modulo = 2
                  while modulo >= 1:
                      t = t + 1*u.day
                      modulo = (t - sunday).value % 7
                      continue
                  else:
                      if date < t:
                          delta = 6*u.hour
                      else:
                          delta = 7*u.hour

          else:
              delta = 6*u.hour

      elif m == 9:
          if d >=24 and d <= 30:
              modulo = (date - sunday).value%7
              if modulo < 1:
                  if int(hour) >= 3:
                      delta = 6*u.hour
                  else:
                      delta = 7*u.hour
              else:
                  t = Time(f"{y}-{m}-23 00:00:00")
                  modulo = 2
                  while modulo >= 1:
                      t = t + 1*u.day
                      modulo = (t - sunday).value % 7
                      continue
                  else:
                      if date < t:
                          delta = 7*u.hour
                      else:
                          delta = 6*u.hour
          else:
              delta = 7*u.hour

      elif m > 3 and m < 9:
          delta = 7*u.hour
      else:
          delta = 6*u.hour

  elif y == 1991:
      if m == 3:
          if d >=25 and d <= 31:
              modulo = (date - sunday).value%7
              if modulo < 1:
                  if int(hour) >= 3:
                      delta = 6*u.hour
                  else:
                      delta = 5*u.hour
              else:
                  t = Time(f"{y}-{m}-23 00:00:00")
                  modulo = 2
                  while modulo >= 1:
                      t = t + 1*u.day
                      modulo = (t - sunday).value % 7
                  else:
                      if date < t:
                          delta = 5*u.hour
                      else:
                          delta = 6*u.hour
          else:
              delta = 5*u.hour

      elif m == 9:
          if d >=24 and d <= 30:
              modulo = (date - sunday).value%7
              if modulo < 1:
                  if int(hour) >= 3:
                      delta = 5*u.hour
                  else:
                      delta = 6*u.hour
              else:
                  t = Time(f"{y}-{m}-23 00:00:00")
                  modulo = 2
                  while modulo >= 1:
                      t = t + 1*u.day
                      modulo = (t - sunday).value % 7
                  else:
                      if date < t:
                          delta = 6*u.hour
                      else:
                          delta = 5*u.hour
          else:
              delta = 6*u.hour

      elif m > 3 and m < 9:
          delta = 6*u.hour
      else:
          delta = 5*u.hour

  elif y == 1992:
      if m == 1:
          if d <19:
              delta = 5*u.hour
          else:
              delta = 6*u.hour

      elif m == 3:
          if d >=25 and d <= 31:
              modulo = (date - sunday).value%7
              if modulo < 1:
                  if int(hour) >= 3:
                      delta = 7*u.hour
                  else:
                      delta = 6*u.hour
              else:
                  t = Time(f"{y}-{m}-23 00:00:00")
                  modulo = 2
                  while modulo >= 1:
                      t = t + 1*u.day
                      modulo = (t - sunday).value % 7
                  else:
                      if date < t:
                          delta = 6*u.hour
                      else:
                          delta = 7*u.hour
          else:
              delta = 6*u.hour

      elif m == 9:
          if d >=24 and d <= 30:
              modulo = (date - sunday).value%7
              if modulo < 1:
                  if int(hour) >= 3:
                      delta = 6*u.hour
                  else:
                      delta = 7*u.hour
              else:
                  t = Time(f"{y}-{m}-23 00:00:00")
                  modulo = 2
                  while modulo >= 1:
                      t = t + 1*u.day
                      modulo = (t - sunday).value % 7
                  else:
                      if date < t:
                          delta = 7*u.hour
                      else:
                          delta = 6*u.hour
          else:
              delta = 7*u.hour

      elif m > 3 and m < 9 and m!=1:
          delta = 7*u.hour
      else: #2,10,11,12
          delta = 6*u.hour

  elif y >= 1993 and y < 1996:
      if m == 3:
          if d >=25 and d <= 31:
              modulo = (date - sunday).value%7
              if modulo < 1:
                  if int(hour) >= 3:
                      delta = 7*u.hour
                  else:
                      delta = 6*u.hour
              else:
                  t = Time(f"{y}-{m}-23 00:00:00")
                  modulo = 2
                  while modulo >= 1:
                      t = t + 1*u.day
                      modulo = (t - sunday).value % 7
                  else:
                      if date < t:
                          delta = 6*u.hour
                      else:
                          delta = 7*u.hour
          else:
              delta = 6*u.hour

      elif m == 9:
          if d >=24 and d <= 30:
              modulo = (date - sunday).value%7
              if modulo < 1:
                  if int(hour) >= 3:
                      delta = 6*u.hour
                  else:
                      delta = 7*u.hour
              else:
                  t = Time(f"{y}-{m}-23 00:00:00")
                  modulo = 2
                  while modulo >= 1:
                      t = t + 1*u.day
                      modulo = (t - sunday).value % 7
                  else:
                      if date < t:
                          delta = 7*u.hour
                      else:
                          delta = 6*u.hour
          else:
              delta = 7*u.hour

      elif m > 3 and m < 9:
          delta = 7*u.hour
      else:
          delta = 6*u.hour

  elif y >= 1996 and y < 2005:
      if m == 3:
          if d >=25 and d <= 31:
              modulo = (date - sunday).value%7
              if modulo < 1:
                  if int(hour) >= 3:
                      delta = 7*u.hour
                  else:
                      delta = 6*u.hour
              else:
                  t = Time(f"{y}-{m}-23 00:00:00")
                  modulo = 2
                  while modulo >= 1:
                      t = t + 1*u.day
                      modulo = (t - sunday).value % 7
                  else:
                      if date < t:
                          delta = 6 *u.hour
                      else:
                          delta = 7*u.hour
          else:
              delta = 6*u.hour

      elif m == 10:
          if d >=25 and d <= 31:
              modulo = (date - sunday).value%7
              if modulo < 1:
                  if int(hour) >= 3:
                      delta = 6*u.hour
                  else:
                      delta = 7*u.hour
              else:
                  t = Time(f"{y}-{m}-23 00:00:00")
                  modulo = 2
                  while modulo >= 1:
                      t = t + 1*u.day
                      modulo = (t - sunday).value % 7
                  else:
                      if date < t:
                          delta = 7*u.hour
                      else:
                          delta = 6*u.hour
          else:
              delta = 7*u.hour

      elif m > 3 and m < 10:
          delta = 7*u.hour
      else:
          delta = 7*u.hour
  elif y <=1980 or y >= 2005:
      delta = 6*u.hour

  return delta

def convert_local_date_time_UT(dates, obs_times):
  """
  Returns list of local observational time in UT in fits format.
  It takes into accaunt real delta.

  Will be used for headers only, may be additional column

  dates -- list of obs dates from obs log
  obs_times -- list observational time given in obs log

  >>> convert_local_date_time_UT(["14.09.1964","15.09.1964"], ["01:24:06","20:42:06"])
  ['1964-09-14T19:24:05.999', '1964-09-16T14:42:05.999']
  >>> convert_local_date_time_UT(["25.03.1984"], ["04:24:06"])
  ['1984-03-25T21:24:06.000']

  """
  obs_times_hms = []
  for i in range(0,len(obs_times)):
    #conversation hh:mm:ss to XX.XX
    obs_time = api.dmsToDeg(obs_times[i], ":")%24 #%24 because somewhere we have time like 24:05:30
    obs_times_hms.append(api.hoursToHms(obs_time))
  dates_ymd = []
  #we have to rewrite dates from DD.MM.YYYY format to YYYY-MM-DD format
  for i in range(0,len(dates)):
    d = dates[i].split(".")
    dates_ymd.append(f"{d[2]}-{d[1]}-{d[0]}".replace(" ",""))
  if len(dates_ymd) == 1:
    date_time = Time(f"{dates_ymd[0]} {obs_times_hms[0]}") + 1*u.day #+1day because in our dates list
    #we have only first date of obs (for more info see parse_date_list function)
    delta_real = get_delta_real(date_time)
    return [(date_time - delta_real).fits]

  elif len(dates_ymd) == 2:
    date_time_1 = Time(f"{dates_ymd[0]} {obs_times_hms[0]}") + 1*u.day
    if len(obs_times_hms) < 4:
      date_time_2 = Time(f"{dates_ymd[1]} {obs_times_hms[1]}") + 1*u.day
    elif len(obs_times_hms) == 4:
      date_time_2 = Time(f"{dates_ymd[1]} {obs_times_hms[3]}") + 1*u.day
    delta_real_1 = get_delta_real(date_time_1)
    delta_real_2 = get_delta_real(date_time_2)
    return [(date_time_1 - delta_real_1).fits,(date_time_2 - delta_real_2).fits]

def dmsToDeg(dms,splitter=":"):
  """
  Convert degrees:minutes:seconds format
  to degree values.

  >>> dmsToDeg("-54:26:30",splitter=":")
  -54.44167
  >>> dmsToDeg("14:15:00",splitter=":")
  14.25
  """
  try:
    dms_s = dms.replace("-","").split(splitter)
  except AttributeError:
    print("dms_s ", dms_s)
  deg = float(dms_s[0]) + float(dms_s[1])/60 + float(dms_s[-1])/3600
  if "-" in dms:
    return round(-deg,5)
  else:
    return round(deg,5)

def hoursToHms(hours):
  """
  Convert hours to
  hours:minutes:seconds format.

  >>> hoursToHms(12.5)
  '12:30:00'
  >>> hoursToHms(2.2)
  '02:12:00'
  """
  hours = hours%24 #because could be 24.05
  h = int(hours)
  mi = (hours - h)*60
  m = int(mi)
  se = (mi - m)*60
  s = int(se)
  if h<10:
    h = f"0{h}"
  if m<10:
    m = f"0{m}"
  if s<10:
    s = f"0{s}"

  return f"{h}:{m}:{s}"

def degToHms(deg):
  """
  Convert degrees to hours and to
  hours:minutes:seconds format.

  >>> degToHms(352.6)
  '23:30:24'
  >>> degToHms(12.4)
  '00:49:36'
  """
  hours = abs(deg) * 24 / 360
  return hoursToHms(hours)

def degToDms(deg):
  """
  Convert degrees to
  degrees:minutes:seconds format.

  >>> degToDms(52.41)
  '52:24:35'
  >>> degToDms(-148.56)
  '-148:33:36'
  """
  if deg<0:
    deg = abs(deg)
    sign = "-"
  else:
    sign = ""
  d = int(deg)
  mi = (deg - d)*60
  m = int(mi)
  se = (mi - m)*60
  s = int(se)
  if d<10:
    d = f"0{d}"
  if m<10:
    m = f"0{m}"
  if s<10:
    s = f"0{s}"

  return f"{sign}{d}:{m}:{s}"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~TTEESSTT~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

def run_tests(*args):
  """
  runs all doctests and exits the program.
  """
  import doctest
  sys.exit(doctest.testmod()[0])

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~HEADER CLASS~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class PAHeaderAdder(api.AnetHeaderProcessor):


  def __init__(self, *args, **kwargs):
    super().__init__(*args, **kwargs)  # Вызов конструктора родительского класса
    self.fits_file = None  # Добавление своей переменной
    self.fits_name = None  # Добавление своей переменной

  @staticmethod
  def addOptions(optParser):
    api.AnetHeaderProcessor.addOptions(optParser)
    optParser.add_option("--test", help="Run unit tests, then exit",
      action="callback", callback=run_tests)

  def _createAuxiliaries(self, dd):
    log_path = os.path.join(dd.rd.resdir, "/var/gavo/inputs/logbook_archival", "logbook_galaxy.csv")
    self.platemeta = pd.read_csv(log_path, encoding="utf-8")
    # Приведение колонки "ID" в нижний регистр и замена "с" на "c"
    # self.platemeta["ID"] = self.platemeta["ID"].str.lower().str.replace("с", "c", regex=False)

 
  def NOobjectFilter(self, inName):
    """throws out funny-looking objects from inName as well as objects
    near the border.
    """
    width = max(data_fits.field("X_IMAGE"))
    height = max(data_fits.field("Y_IMAGE"))
    badBorder = 0.2
    data_fits = data_fits[data_fits.field("ELONGATION")<1.2]
    data_fits = data_fits[data_fits.field("X_IMAGE")>width*badBorder]
    data_fits = data_fits[data_fits.field("X_IMAGE")<width-width*badBorder]
    data_fits = data_fits[data_fits.field("Y_IMAGE")>height*badBorder]
    data_fits = data_fits[data_fits.field("Y_IMAGE")<height-height*badBorder]

    # the extra np.array below works around a bug in several versions
    # of pyfits that would write the full, not the filtered array
    hdu = api.pyfits.BinTableHDU(np.array(data_fits))
    hdu.writeto("foo.xyls")
    hdulist.close()
    os.rename("foo.xyls", inName)

  def _shouldRunAnet(self, srcName, header):
    return False 

  def _isProcessed(self, srcName):
    hdr = self.getPrimaryHeader(srcName)
    self.fits_file = fits.open(srcName)
    if "/" in srcName: 
      self.fits_name = srcName.split("/")[-1].replace("–","-").encode("utf-8").decode("utf-8") 
      #print(self.fits_name)
    return "RA-ORIG" in hdr and "A_ORDER" in hdr and hdr

  def _mungeHeader(self, srcName, hdr):
    name = srcName.split('_')
    plateid = name[-1].split('.')[0].lower().replace("с", "c").replace("-", "").replace(" ", "")
    dateobs_ = name[-3].lower()
    object_ = name[-4].split('/')[-1].lower().replace("-", "").replace(" ", "").replace('sky', '').replace('ny', '')
# Фильтрация записей в DataFrame
    filtered_data = self.platemeta[
        (self.platemeta["ID"] == plateid) &
        (self.platemeta["DATE-OBS"].str.lower() == dateobs_) &
        (self.platemeta["OBJECT"].str.lower().str.replace("-", "").str.replace(" ", "").str.contains(object_))
    ]

    if not filtered_data.empty:
        platedata = filtered_data.iloc[0]  # Берем первую подходящую запись
    else:
        with open("not_in_dj.txt", "a") as txt_file:
            txt_file.write(srcName + "\n")
        return None

    thismeta = platedata

    objtype = platedata["OBJECT-TYPE"] #we will add the column with data later
    try:
      for k,v in platedata.items():
        if isinstance(v, str) and (v == " " or v == "  " or v == ""):
          platedata[k] = None
    except AttributeError:
      print("AttributeError data")


    #if some columns are renamed it is easier to fix it here
    #and in the end when we are saving table
    plate_id  =platedata["ID"]
    obj_name  =platedata["OBJECT"]
    ra        =platedata["RA"]
    dec       =platedata["DEC"]
    date_obs  =platedata["DATE-OBS"]
    exptime   =platedata["EXPTIME"]
    tms_lst   =platedata["TMS-LST"]
    tme_lst   =platedata["TME-LST"]
    tms_lt    =platedata["TMS-LT"]
    tme_lt    =platedata["TME-LT"]
    telescope =platedata["TELESCOPE"]
    observer  =platedata["OBSERVER"]
    filters   =platedata["FILTER"]
    obj_type  =platedata["OBJECT-TYPE"]
    focus     =platedata["FOCUS"]
    platenotes=platedata["PLATNOTE"]
    scannotes =platedata["SCANNOTE"]
    obsnotes  =platedata["OBSNOTE"]
    notes     =platedata["NOTES"]
    skycond   =platedata["SKYCOND"]

    grid =platedata['Решетка']
    #gap = platedata['Щель']
    eop = platedata['ЭОП']
    callimator = platedata['Коллиматор']
    #scale = platedata['Масштаб камеры']
    cathode = platedata['Катод']
    camera = platedata['Камера']
    #angle = platedata['Позиционный угол']
    #section = platedata['Сечение']
    spectrograph = platedata['Спектрограф']
    #wavelenght = platedata['Длины волн']

    if focus is not None and focus==focus:
      focus = focus
    else:
      focus = 0

    #print('findmepam')
    if grid is not None and grid==grid: 
      grid = translate_to_english(grid)
    else:
      grid = None
    if eop is not None and eop==eop: 
      eop = translate_to_english(eop)
    else:
      eop = None  
    if callimator is not None and callimator==callimator: 
      callimator = translate_to_english(callimator)
    else:
      callimator = None  
    if cathode is not None and cathode==cathode: 
      cathode = translate_to_english(cathode)
    else:
      cathode = None  
    if camera is not None and camera==camera: 
      camera = translate_to_english(camera)
    else:
      camera = None  

    def clean_and_translate(text):
      """
      Обрабатывает текст: удаляет лишние символы, выполняет перевод на английский.
      """
      if text and isinstance(text, str):
          return translate_to_english(text.replace('\n', ';')).replace('\\n', ' ').replace('\n', ' ').replace(':', '')
      return None
    platenotes = clean_and_translate(platenotes)
    scannotes = clean_and_translate(scannotes)
    obsnotes = clean_and_translate(obsnotes)
    notes = clean_and_translate(notes)
    skycond = clean_and_translate(skycond)

    def clean_and_translate(text, transliterate=False):
      """
      Обрабатывает текст: удаляет лишние символы, выполняет перевод на английский
      и, при необходимости, транслитерацию.
      """
      if text and isinstance(text, str):
          text = translate_to_english(text.replace('\n', ';')).replace('\\n', ' ').replace('\n', ' ').replace(':', '')
          if transliterate:
              text = translit(text, 'ru', reversed=True)
          return text
      return None
    spectrograph = clean_and_translate(spectrograph, transliterate=True)

    instrume = f'intensifier: {eop if eop is not None else ""}; callimator: {callimator if callimator is not None else ""}, cathode: {cathode if cathode is not None else ""}, camera: {camera if camera is not None else ""}'

    #~~~~~~~~~~~~~~~~~~~COORDINATES~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~SIMBAD-QUERY~~~~~~~~~
    ra_simbad = []
    dec_simbad = []
    for obj in obj_name.replace('\n','').replace(",",";").split(";"):
      simbad_table = Simbad.query_object(obj)
      if simbad_table:#if object data there is in Simbad
        ra_simbad.append(":".join(simbad_table["RA"].data[0].split(" ")))
        dec_simbad.append(":".join(simbad_table["DEC"].data[0].split(" ")))
      else:#if not
        ra_simbad.append(None)
        dec_simbad.append(None)

    ra_simbad = [ra_s for ra_s in ra_simbad if str(ra_s) != 'nan']
    dec_simbad = [dec_s for dec_s in dec_simbad if str(dec_s) != 'nan']

    if len(ra_simbad)==0:
      ra_simbad = None
      dec_simbad = None

    #~~~~~~~~~COORDS EDITED~~~~~~~~~
    if ra==ra and ra!=None:#if there is data in obs log
      if ra=="" or ra==" " or ra=="  ":
        ra_edit = None#there is no data in neither obs log or Simbad
      else:
        ra_edit = reformat_ra(ra) # hh:mm:ss
    else:#if there is no data in obs log
      if ra_simbad == ra_simbad:#if there is data in Simbad
        ra_edit = ra_simbad#list of hh:mm:ss format ra
      else:#if there is not data in Simbad
        ra_edit = None#there is no data in neither obs log or Simbad
    if dec == dec and dec!=None:#if there is data in obs log
      if dec=="":
        dec_edit = None#there is no data in neither obs log or Simbad
      else:
        dec_edit = reformat_dec(dec) # dd:mm:ss
    else:#if there is no data in obs log
      if dec_simbad == dec_simbad:#if there is data in Simbad
        dec_edit=dec_simbad#list of hh:mm:ss format ra
      else:#if there is not data in Simbad
        dec_edit = None#there is no data in neither obs log or Simbad
    if dec_edit:
      dec_deg = dec_to_deg(dec_edit[0])
    else:
      decdeg = None
    if ra_edit:
      ra_deg = ra_to_deg(ra_edit[0])
    else:
      ra_deg = None

    #~~~~~~~~~~~~~~~~~~~DATE AND TIME ORIG~~~~~~~~~~~~~~~~~~~~~~

    tms_lt_edit  = None
    tme_lt_edit  = None
    tms_lst_edit = None
    tme_lst_edit = None

    if tms_lt:
      tms_lt_edit=reformat_time(tms_lt)
    if tme_lt:
      tme_lt_edit=reformat_time(tme_lt)
    if tms_lst:
      tms_lst_edit=reformat_time(tms_lst)
    if tme_lst:
      tme_lst_edit=reformat_time(tme_lst)

    if tms_lt_edit:
      obs_times = tms_lt_edit
    else:
      obs_times = tms_lst_edit #then lst or None

    if date_obs == date_obs and date_obs!=None:
      date_obs_orig = parse_date_list(date_obs) #returns first date (12-13.02.1987 --> 12.02.1987)

    else:
      date_obs_orig = None
    #~~~~~~~~~~~~~~~~~~~DATE AND TIME EDITED (UT)~~~~~~~~~~~~~~~~~~~~~~

    time_format = ""

    if obs_times!=None and date_obs_orig!=None:
      dates_0 = date_obs_orig[0].replace(" ","").split(".") #we need only the first date
      # for i in range(0,len(dates_0)): #because somewhate there are occure spaces (?)
      #   dates_0 = dates_0.replace(" ","")
      # print("dates_0 ",dates_0)
      try:
        obs_time = api.dmsToDeg(obs_times[0], ":")%24  #we need only first data just for time type checking
      except AttributeError:
        print("AttributeError 1", obs_times)
      #%24 because somewhere we have time like 24:05:30
      if obs_times[0].split(":")[0] == "24":
        time_split = obs_times[0].split(":")
        obs_times[0] = "00:"+time_split[1]+":"+time_split[2]
      if obs_time > 12 and  obs_time < 24:
        obs_date_tf = Time(f"{dates_0[-1]}-{dates_0[1]}-{dates_0[0]} {obs_times[0]}")
      else:
        obs_date_tf = Time(f"{dates_0[-1]}-{dates_0[1]}-{dates_0[0]} {obs_times[0]}")  + 1*u.day
        #+1 day because we have the first date of observations, but they were done after midnight
      # print("date ",obs_date_tf)

      date_sun = Time(f"{dates_0[-1]}-{dates_0[1]}-{dates_0[0]} 00:00:01") + 1*u.day #+1 day because we have the first date of observations, but we
      #need midnight, so there should be next date from given. We need the date_sun to calculate sunset and sunrise
      # print("date_sun ",date_sun)
      sunset, sunrise = sun_set_rise_time(date_sun,observatory)

      if obs_date_tf > sunset and obs_date_tf < sunrise: #check as if it is LT
        obs_sidt = obs_date_tf.sidereal_time("apparent",observatory.location.lon).value+6

        if ra_edit[0]==ra_edit[0] and ra_edit[0]!=None:
          #hh:mm:ss to float
          ra_float = api.dmsToDeg(ra_edit[0], ":") #we pretend we have degrees because conversation hh:mm:ss to XX.XX
          delta = abs(ra_float - obs_time)
          dec_float = api.dmsToDeg(dec_edit[0], ":")
          phi = observatory.location.lat.value
          hour_angle = obs_sidt - ra_float
          altitude = get_object_altitude(dec_float,phi,hour_angle)

          if altitude > 10:
            time_format = "LT "
            date_obs_edit = convert_local_date_time_UT(date_obs_orig, obs_times) #UT

          else:#too low, so we suppose ST is given
            ra_float = api.dmsToDeg(ra_edit[0], ":") #we pretend we have degrees because conversation hh:mm:ss to XX.XX
            delta = abs(ra_float - obs_time)
            dec_float = api.dmsToDeg(dec_edit[0], ":")
            phi = observatory.location.lat.value
            hour_angle = obs_time - ra_float # we pretend that obs_time is ST
            altitude = get_object_altitude(dec_float,phi,hour_angle)

            if altitude > 10:
              time_format = "LST "
              obs_lt = get_lt_from_st(date_obs_orig, obs_times)
              date_obs_edit = obs_lt - get_delta_real(obs_lt)
            else:
              time_format = "Neither LT nor ST"########################################################################
              date_obs_edit = None
              counter =+ 1
        else:
          time_format = "LT " #because observational time at night and we will believe that the time is okay for object too
          date_obs_edit = convert_local_date_time_UT(date_obs_orig, obs_times) #UT

      else:#it is not LT because time is not at night, so probably it is ST
        if ra_edit[0]==ra_edit[0] and ra_edit[0]!=None:
          #hh:mm:ss to float
          # print(i,ra_edit[0])
          ra_float = api.dmsToDeg(ra_edit[0], ":") #we pretend we have degrees because conversation hh:mm:ss to XX.XX
          delta = abs(ra_float - obs_time)
          dec_float = api.dmsToDeg(dec_edit[0], ":")
          phi = observatory.location.lat.value
          hour_angle = obs_time - ra_float # we suppose that obs_time is ST
          altitude = get_object_altitude(dec_float,phi,hour_angle)

          if altitude > 10:
            time_format = "LST "
            obs_lt = get_lt_from_st(date_obs_orig, obs_times)[0]
            date_obs_edit = obs_lt - get_delta_real(obs_lt)

          else:
            time_format = "Neither LT nor ST"  ########################################################################
            date_obs_edit = None
            counter =+ 1

        else:
          time_format = "LST "
          obs_lt = get_lt_from_st(date_obs_orig, obs_times)[0]
          date_obs_edit = obs_lt - get_delta_real(obs_lt)

    elif obs_times!=None and date_obs_orig!=None and date_obs_orig==None:
      time_format = ""

    elif obs_times==None and date_obs_orig!=None and date_obs_orig!=None:
      if ra_edit[0]:
        try:
          obs_st = api.dmsToDeg(ra_edit[0], ":") #we pretend we have degrees because conversation hh:mm:ss to XX.XX
        except AttributeError:
          print("AttributeError 2", ra_edit)
        delta_st = get_sid_delta(date_obs_orig, [obs_st])[0]
        dates_0 = date_obs_orig[0].replace(" ","").split(".") #we need only the first date
        date_sun = Time(f"{dates_0[-1]}-{dates_0[1]}-{dates_0[0]} 00:00:01") + 1*u.day #+1 day because we have the first date of observations, but we
        obs_lt = date_sun + delta_st*u.hour
        date_obs_edit = obs_lt - get_delta_real(obs_lt)
        time_format = "Time from RA "
      else:
        dates_0 = date_obs_orig[0].replace(" ","").split(".") #we need only the first date
        date_mid = Time(f"{dates_0[-1]}-{dates_0[1]}-{dates_0[0]} 00:00:01") + 1*u.day
        date_obs_edit = date_mid - get_delta_real(date_mid)
        time_format = "Midnight "

    else: #we have nothing
      date_obs_edit = None
 
    #~~~~~~~~~~~~~~~~~~~TRANSLITERATION ~~~~~~~~~~~~~~~~~~~~~~
    try:
      if observer is not None and observer == observer:
        observer_edit = translit(observer, 'ru', reversed=True)
      else:
        observer_edit = 'Denissyuk E.K.'
    except AttributeError:
      observer_edit = 'Denissyuk E.K.'
    try:
      if emulsion is not None and emulsion==emulsion:
        emulsion_edit = translit(emulsion, 'ru', reversed=True) #cause there some ru names
      else:
        emulsion_edit = None
    except AttributeError:
      emulsion_edit = None
    print('findmeöpöö')

    #~~~~~~~~~~~~~~~~~~~DICTIONARY ~~~~~~~~~~~~~~~~~~~~~~

    if filters is not None and filters==filters:
      #Remove spaces, dots; replace commas and pluses with semicolon; use lower case
      filters_edit = filters #[FILTERS_ENG["".join(filt).lower()] for filt in filters.replace(" ","").replace(".","").replace(",",";").replace("+",";").split(";")]
    else:
      filters_edit = None

    if exptime is not None and exptime==exptime:
      numexp=len(parse_exposure_times(exptime))
      variable_arguments = get_exposure_cards(exptime)
    else:
      numexp = None
      variable_arguments = {"EXPTIME": None} 

    #~~~~~~~~~~~~~~~HEADER WITH EDITED DATA~~~~~~~~~~~~~~~~~~
    def safe_update(arguments, key, value):
      """
      Добавляет ключ и значение в словарь, если значение не None или NaN.
      """
      if value is not None and value == value:  # Проверка на NaN
          arguments[key] = value
    safe_update(variable_arguments, "OBJTYPE", objtype)
    safe_update(variable_arguments, "DATEORIG", date_obs)
    safe_update(variable_arguments, "RA_ORIG", ra_edit[0] if ra_edit else None)
    safe_update(variable_arguments, "DEC_ORIG", dec_edit[0] if dec_edit else None)
      
    if obj_name is not None and obj_name==obj_name:
      variable_arguments.update(get_object_cards(obj_name))#.split(";")[0]
    else:
      object_name = None
    #  variable_arguments.update(get_object_cards(obj_name))

    if tms_lst is not None and tms_lst==tms_lst:
      variable_arguments.update(get_time_start_cards(tms_lst, time_format))
    elif tms_lt is not None and tms_lt==tms_lt:
      variable_arguments.update(get_time_start_cards(tms_lt, time_format))
    else:
      variable_arguments.update({"TMS-ORIG":None})

    if tme_lst is not None and tme_lst==tme_lst:
      variable_arguments.update(get_time_end_cards(tme_lst, time_format))
    elif tme_lt is not None and tme_lt==tme_lt:
      variable_arguments.update(get_time_end_cards(tme_lt, time_format))
    else:
      variable_arguments.update({"TME-ORIG":None})

    if filters_edit is not None and filters_edit==filters_edit:
      variable_arguments.update(get_filters_cards(filters_edit))

    if not ra_edit:
      ra_edit = [None]
    if not dec_edit:
      dec_edit=[None]
    if not plate_size:
      plate_size = [None, None]
    if date_obs_edit:
      if type(date_obs_edit)==list:
        date_obs_edit=date_obs_edit[0]
      else:
        date_obs_edit=date_obs_edit.fits

    if obj_type is not None and obj_type==obj_type:
      obj_type = obj_type
    else:
      obj_type = 'unknown'
    
    print('findmeüpüp')

    new_hdr = fitstricks.makeHeaderFromTemplate(
      fitstricks.WFPDB_TEMPLATE,
      originalHeader = hdr,
      DATE_OBS = date_obs_edit,
      RA_ORIG = ra_edit[0],
      DEC_ORIG = dec_edit[0],
      RA_DEG = ra_deg,
      DEC_DEG = dec_deg,
      OBSERVER = observer_edit,
      OBSERVAT = "Fesenkov Astrophysical Institute",
      SITELONG = 43.17667,
      SITELAT = 76.96611,
      SITEELEV = 1450,
      TELESCOP = "AZT-8",
      NUMEXP = numexp,
      SCANAUTH = "Shomshekova S., Umirbayeva A., Moshkina S., Aktay L.",
      ORIGIN = "Contant",
      FOCLEN = 11000,
      FOCUS = focus,
      OTA_DIAM = 700,
      SCANERS1 = 2400,
      SCANERS2 = 2400,
      PRE_PROC = "Cleaning from dust with a squirrel brush and from contamination from the glass (not an emulsion) with paper napkins",
      PID = plate_id,
      NOTES = notes,
      PLATNOTE = platenotes,
      SCANNOTE = scannotes,
      OBSNOTE = obsnotes,
      EMULSION = emulsion_edit,
      DETNAME = "Photographic film",
      SKYCOND = skycond,
      GRATING = grid,
      INSTRUME = instrume,
      FILENAME = self.fits_name.replace('.fit',''),
      **variable_arguments)
    self.fits_file[0].header = new_hdr
    self.fits_file.writeto("/var/gavo/inputs/astroplates/spectra_unsorted/header_done/"+self.fits_name, output_verify="fix",overwrite=True) 
    return new_hdr

if __name__=="__main__":
  api.procmain(PAHeaderAdder, "spectra_agn_archive/q", "import")
