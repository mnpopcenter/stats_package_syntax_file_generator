cd "data".

data list file = "__my_data.dat" /
  RECTYPE  1-1 (a)
  EMPSTAT  2-3
.

variable labels
  RECTYPE    "Record type"
  EMPSTAT    "Employment status"
.

value labels
  /RECTYPE
    "H"   "Household record"
    "P"   "Person record"
  /EMPSTAT
    1    "Employed"
    2    "Unemployed"
    98   "Unknown"
    99   "Not in universe"
.

execute.

