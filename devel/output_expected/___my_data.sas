libname IPUMS "data";
filename ASCIIDAT "__my_data.dat";

proc format cntlout = IPUMS.__my_data_f;

value $ RECTYPE_f
  "H" = "Household record"
  "P" = "Person record"
;

value EMPSTAT_f
  1  = "Employed"
  2  = "Unemployed"
  98 = "Unknown"
  99 = "Not in universe"
;

run;

data IPUMS.__my_data;
infile ASCIIDAT pad missover lrecl=3;

input
  RECTYPE $ 1-1
  EMPSTAT   2-3
;

label
  RECTYPE = "Record type"
  EMPSTAT = "Employment status"
;

format
  RECTYPE  RECTYPE_f.
  EMPSTAT  EMPSTAT_f.
;

run;

