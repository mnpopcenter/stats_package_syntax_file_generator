set more off

clear
quietly infix                ///
  str     rectype   1-1      ///
  long    dwnum     2-7      ///
  byte    hhnum     8-8      ///
  byte    hdfirstd  26-26    ///
  int     fbig_nd   45-48    ///
  byte    baddw     49-49    ///
  float   canton    67-69    ///
  byte    urban     80-80    ///
  byte    dwtype    81-81    ///
  byte    ownershp  82-83    ///
  str     rent      84-87    ///
  using `"xx9999a.dat"'
gen  _line_num = _n
drop if rectype != `"H"'
sort _line_num
save __temp_ipums_hier_H.dta

clear
quietly infix                ///
  str     rectype   1-1      ///
  long    dwnum     2-7      ///
  byte    hhnum     8-8      ///
  byte    hdfirstd  26-26    ///
  int     fbig_nd   45-48    ///
  byte    baddw     49-49    ///
  byte    relate    67-67    ///
  byte    sex       68-68    ///
  int     age       69-71    ///
  float   resprev2  80-83    ///
  byte    socsec    93-93    ///
  byte    edlevel   100-100  ///
  byte    lit       101-101  ///
  float   bigdec    101-110  ///
  double  bigint    101-119  ///
  str     bigstr    101-119  ///
  using `"xx9999a.dat"'
gen  _line_num = _n
drop if rectype != `"P"'
sort _line_num
save __temp_ipums_hier_P.dta

clear
use __temp_ipums_hier_H.dta
append using __temp_ipums_hier_P.dta
sort _line_num
drop _line_num
erase __temp_ipums_hier_H.dta
erase __temp_ipums_hier_P.dta

replace canton   = canton   / 10
replace resprev2 = resprev2 / 1000
replace bigdec   = bigdec   / 100000

format canton   %3.1f
format resprev2 %4.3f
format bigdec   %10.5f
format bigint   %19.0f

label var rectype  `"Record type"'
label var dwnum    `"Dwelling number"'
label var hhnum    `""Household number""'
label var hdfirstd `"Head not first ["dwelling-wide"] {note}"'
label var fbig_nd  `"N of persons in large dwelling before it was split (see FBIG)"'
label var baddw    `"Bad dwelling"'
label var canton   `"Canton "geo area""'
label var urban    `"Urban/Rural"'
label var dwtype   `"Dwelling type"'
label var ownershp `"Occupancy_and_ownership_status........40........50........60........70........80"'
label var rent     `"Monthly rent"'
label var relate   `"Relationship to household head"'
label var sex      `"Sex"'
label var age      `"Age"'
label var resprev2 `"Place of residence 5 years ago - code"'
label var edlevel  `"Educational level"'
label var lit      `"Literacy"'
label var bigdec   `"Big decimal"'
label var bigint   `"Big integer"'
label var bigstr   `"Big string"'

label define hhnum_lbl 1 `"[no label]"'
label values hhnum hhnum_lbl

label define hdfirstd_lbl 0 `"No problem"'
label define hdfirstd_lbl 1 `"One or more households have heads but not as the first person"', add
label values hdfirstd hdfirstd_lbl

label define fbig_nd_lbl 0   `"[no label]"'
label define fbig_nd_lbl 107 `"[no label]"', add
label define fbig_nd_lbl 128 `"[no label]"', add
label define fbig_nd_lbl 154 `"[no label]"', add
label define fbig_nd_lbl 155 `"[no label]"', add
label define fbig_nd_lbl 171 `"[no label]"', add
label define fbig_nd_lbl 191 `"[no label]"', add
label define fbig_nd_lbl 529 `"[no label]"', add
label define fbig_nd_lbl 949 `"[no label]"', add
label values fbig_nd fbig_nd_lbl

label define baddw_lbl 0 `"No problem"'
label define baddw_lbl 1 `"Bad dwelling"', add
label values baddw baddw_lbl

label define urban_lbl 1 `"Urban"'
label define urban_lbl 2 `"Rural"', add
label values urban urban_lbl

label define dwtype_lbl 1 `"Ordinary labels don't have ""skills"""'
label define dwtype_lbl 2 `"Ranch"', add
label define dwtype_lbl 3 `"Improvised"', add
label define dwtype_lbl 4 `"Mobile"', add
label define dwtype_lbl 5 `"Collective dwelling"', add
label values dwtype dwtype_lbl

label define ownershp_lbl 0  `"Occupied:_rented......................40........50........60........70........80........90.......100.......110.......120.......130.......140.......150.......160.......170.......180.......190.......200.......210.......220.......230.......240...."'
label define ownershp_lbl 1  `"Occupied:owned"', add
label define ownershp_lbl 2  `"Occupied: other"', add
label define ownershp_lbl 3  `"Vacant: for rent"', add
label define ownershp_lbl 4  `"Vacant: for sale"', add
label define ownershp_lbl 5  `"Vacant: for vacation"', add
label define ownershp_lbl 6  `"Vacant: Under repair"', add
label define ownershp_lbl 7  `"Vacant: Under construction"', add
label define ownershp_lbl 8  `"Vacant: other"', add
label define ownershp_lbl 9  `"Unknown"', add
label define ownershp_lbl 10 `"Collective dwelling"', add
label values ownershp ownershp_lbl

label define relate_lbl 2 `"Head"'
label define relate_lbl 3 `"Spouse - Partner"', add
label define relate_lbl 4 `"Son/daughter, stepson/stepdaughter"', add
label define relate_lbl 5 `"Other relatives"', add
label define relate_lbl 6 `"Domestic servants and their relatives"', add
label define relate_lbl 7 `"Other non-relatives"', add
label define relate_lbl 8 `"Member in collective dwellings"', add
label values relate relate_lbl

label define sex_lbl 1 `"Male"'
label define sex_lbl 2 `"Female"', add
label values sex sex_lbl

label define socsec_lbl 1 `"Directly covered person"'
label define socsec_lbl 2 `"Covered through family member"', add
label define socsec_lbl 3 `"Not covered"', add
label values socsec socsec_lbl

label values edlevel edlevel_lbl

label define lit_lbl 1 `"Able to read and write"'
label define lit_lbl 2 `"Not able to read and write"', add
label values lit lit_lbl


