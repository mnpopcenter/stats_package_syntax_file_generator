set more off

clear
quietly infix           ///
  str     rectype  1-1  ///
  byte    empstat  2-3  ///
  using `"__my_data.dat"'



label var rectype `"Record type"'
label var empstat `"Employment status"'

label define empstat_lbl 1  `"Employed"'
label define empstat_lbl 2  `"Unemployed"', add
label define empstat_lbl 98 `"Unknown"', add
label define empstat_lbl 99 `"Not in universe"', add
label values empstat empstat_lbl


