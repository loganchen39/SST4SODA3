#!/glade/u/apps/ch/opt/python/3.6.8/gnu/8.3.0/pkg-library/20190627/bin/python3
# #!/usr/bin/python

import os
import calendar
import datetime


START_YEAR = 2021
END_YEAR   = 2021

jday_20210103 = datetime.date(2021, 1 , 3 )
jday_20211231 = datetime.date(2021, 12, 31)

jday = jday_20210103
while jday <= jday_20211231:
    str_curr_jday = jday.strftime("%Y%m%d")
    print(str_curr_jday)
    jday += datetime.timedelta(days=5)
