###################################################################
##                                                               ##
## IPUMS USER: note that you'll need to enter the path to the    ##
## folder containing your data file.                             ##
##                                                               ##
## For instance, if the data file were in the 'C:' drive in a    ##
## folder called IPUMS, the "file=" statements would read:       ##
##                                                               ##
##    file="C:\\IPUMS\\usa_00001.dat"                            ##
##                                                               ##
## If you are an SPSS/STATA/SAS user, and are unfamiliar with R, ##
## a good R-reference is available at                            ##
## <http://www.statmethods.net/index.html>.                      ##
##                                                               ##
###################################################################

data <- readLines(con=file.path("ipumsi_00115.dat", fsep = .Platform$file.sep))
type <- strtrim(data,1)
hh <- data[type=="H"]
per <- data[type=="P"]
write(hh, file="usa_00002_hh.dat", ncolumns=1)
write(per, file="usa_00002_per.dat", ncolumns=1)

unsortedhh <- read.fwf(file="usa_00002_hh.dat",
	widths=c(1,4,10,12,2,1),
	colClasses=c("character","numeric","numeric","character","numeric","numeric"),
	col.names=c("RECTYPE","SAMPLE","SERIAL","WTHH","GQ","URBAN"),
	header=FALSE, na.strings=NA, fill=TRUE)

unsortedper <- read.fwf(file="usa_00002_per.dat",
	widths=c(1,4,10,3,12,1,4,3,1,1,3,1,1,1,1,1,3,3,3,3,1),
	colClasses=c("character","numeric","numeric","numeric","character","numeric","numeric","numeric","numeric","numeric","numeric","numeric","numeric","numeric","numeric","numeric","numeric","numeric","numeric","numeric","numeric"),
	col.names=c("RECTYPE","SAMPLEP","SERIALP","PERNUM","WTPER","RELATE","RELATED","AGE","SEX","MARST","MARSTD","PA70A402","PA60A402","CR73A401","CR84A401","MARST_HEAD","MARSTD_HEAD","MARSTD_MOM","MARSTD_POP","MARSTD_SP","CR73A401_HEAD"),
	header=FALSE, na.strings=NA, fill=TRUE)

unsorted <- rbind(unsortedhh,unsortedper)
usa_00002 <- unsorted[order(unsorted$serial,unsorted$rectype,unsorted$pernum),]
row.names(usa_00002) <- NULL
attach(usa_00002)

SAMPLE <- ordered(SAMPLE,
  levels = c(0321,0322,0323,0324,0511,0401,0402,0403,0404,0681,0682,0683,0761,0762,0763,0764,0765,1121,1161,1241,1242,1243,1244,1521,1522,1523,1524,1525,1561,1562,1701,1702,1703,1704,1705,1881,1882,1883,1884,2181,2182,2183,2184,2185,8181,2501,2502,2503,2504,2505,2506,2881,3001,3002,3003,3004,3241,3242,3481,3482,3483,3484,3561,3562,3563,3564,3681,3761,3762,3763,3801,4001,4041,4042,4171,4581,4582,4583,4584,4841,4842,4843,4844,4845,4846,4961,4962,5281,5282,5283,6021,5911,5912,5913,5914,5915,6081,6082,6083,6201,6202,6203,6421,6422,6423,7041,7042,6461,6462,7051,7241,7242,7243,7101,7102,7103,8001,8002,8261,8262,8401,8402,8403,8404,8405,8406,8621,8622,8623,8624),
  labels = c("Argentina 1970","Argentina 1980","Argentina 1991","Argentina 2001","Armenia 2001","Austria 1971","Austria 1981","Austria 1991","Austria 2001","Bolivia 1976","Bolivia 1992","Bolivia 2001","Brazil 1960","Brazil 1970","Brazil 1980","Brazil 1991","Brazil 2000","Belarus 1999","Cambodia 1998","Canada 1971","Canada 1981","Canada 1991","Canada 2001","Chile 1960","Chile 1970","Chile 1982","Chile 1992","Chile 2002","China 1982","China 1990","Colombia 1964","Colombia 1973","Colombia 1985","Colombia 1993","Colombia 2005","Costa Rica 1963","Costa Rica 1973","Costa Rica 1984","Costa Rica 2000","Ecuador 1962","Ecuador 1974","Ecuador 1982","Ecuador 1990","Ecuador 2001","Egypt 1996","France 1962","France 1968","France 1975","France 1982","France 1990","France 1999","Ghana 2000","Greece 1971","Greece 1981","Greece 1991","Greece 2001","Guinea 1983","Guinea 1996","Hungary 1970","Hungary 1980","Hungary 1990","Hungary 2001","India 1983","India 1987","India 1993","India 1999","Iraq 1997","Israel 1972","Israel 1983","Israel 1995","Italy 2001","Jordan 2004","Kenya 1989","Kenya 1999","Kyrgyz Republic 1999","Malaysia 1970","Malaysia 1980","Malaysia 1991","Malaysia 2000","Mexico 1960","Mexico 1970","Mexico 1990","Mexico 1995","Mexico 2000","Mexico 2005","Mongolia 1989","Mongolia 2000","Netherlands 1960","Netherlands 1971","Netherlands 2001","Palestine 1997","Panama 1960","Panama 1970","Panama 1980","Panama 1990","Panama 2000","Philippines 1990","Philippines 1995","Philippines 2000","Portugal 1981","Portugal 1991","Portugal 2001","Romania 1977","Romania 1992","Romania 2002","Vietnam 1989","Vietnam 1999","Rwanda 1991","Rwanda 2002","Slovenia 2002","Spain 1981","Spain 1991","Spain 2001","South Africa 1996","South Africa 2001","South Africa 2007","Uganda 1991","Uganda 2002","United Kingdom 1991","United Kingdom 2001","United States 1960","United States 1970","United States 1980","United States 1990","United States 2000","United States 2005","Venezuela 1971","Venezuela 1981","Venezuela 1990","Venezuela 2001"))

GQ <- ordered(GQ,
  levels = c(00,10,20,21,22,29,99),
  labels = c("Vacant","Households","Group quarters, n.s.","Institutions","Other group quarters","1-person unit created by splitting large household","Unknown"))

URBAN <- ordered(URBAN,
  levels = c(0,1,2,9),
  labels = c("NIU (not in universe)","Rural","Urban","Unknown"))

RELATE <- ordered(RELATE,
  levels = c(1,2,3,4,5,6,9),
  labels = c("Head","Spouse/partner","Child","Other relative","Non-relative","Other relative or non-relative","Unknown"))

RELATED <- ordered(RELATED,
  levels = c(1000,2000,2100,2200,3000,3100,3200,3300,3400,3500,3600,4000,4100,4110,4120,4130,4200,4210,4211,4220,4300,4310,4400,4410,4420,4430,4431,4432,4500,4510,4600,4700,4800,4810,4820,4830,4900,4910,4920,4930,5000,5100,5110,5111,5112,5113,5120,5130,5140,5150,5200,5210,5220,5221,5222,5223,5300,5310,5311,5320,5330,5340,5350,5400,5500,5510,5520,5600,5610,5620,5900,6000,9999),
  labels = c("Head","Spouse/partner","Spouse","Unmarried partner","Child","Biological child","Adopted child","Stepchild","Child/child-in-law","Child/child-in-law/grandchild","Child of unmarried partner","Other relative","Grandchild","Grandchild or great grandchild","Great grandchild","Great-great grandchild","Parent/parent-in-law","Parent","Stepparent","Parent-in-law","Child-in-law","Unmarried partner of child","Sibling/sibling-in-law","Sibling","Stepsibling","Sibling-in-law","Sibling of spouse/partner","Spouse/partner of sibling","Grandparent","Great grandparent","Parent/grandparent/ascendant","Aunt/uncle","Other specified relative","Nephew/niece","Cousin","Sibling of sibling-in-law","Other relative, not elsewhere classified","Other relative with same family name","Other relative with different family name","Other relative, not specified (secondary family)","Non-relative","Friend/guest/visitor/partner","Partner/friend","Friend","Partner/roommate","Housemate/roommate","Visitor","Ex-spouse","Godparent","Godchild","Employee","Domestic employee","Relative of employee, n.s.","Spouse of servant","Child of servant","Other relative of servant","Roomer/boarder/lodger/foster child","Boarder","Boarder or guest","Lodger","Foster child","Tutored/foster child","Tutored child","Employee, boarder or guest","Other specified non-relative","Agregado","Temporary resident, guest","Group quarters","Group quarters, non-inmates","Institutional inmates","Non-relative, n.e.c.","Other relative or non-relative","Unknown"))

AGE <- ordered(AGE,
  levels = c(000,001,002,003,004,005,006,007,008,009,010,011,012,013,014,015,016,017,018,019,020,021,022,023,024,025,026,027,028,029,030,031,032,033,034,035,036,037,038,039,040,041,042,043,044,045,046,047,048,049,050,051,052,053,054,055,056,057,058,059,060,061,062,063,064,065,066,067,068,069,070,071,072,073,074,075,076,077,078,079,080,081,082,083,084,085,086,087,088,089,090,091,092,093,094,095,096,097,098,099,100,999),
  labels = c("Less than 1 year","1 year","2 years","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81","82","83","84","85","86","87","88","89","90","91","92","93","94","95","96","97","98","99","100+","Not reported/missing"))

SEX <- ordered(SEX,
  levels = c(1,2,9),
  labels = c("Male","Female","Unknown"))

MARST <- ordered(MARST,
  levels = c(0,1,2,3,4,9),
  labels = c("NIU (not in universe)","Single/never married","Married/in union","Separated/divorced/spouse absent","Widowed","Unknown/missing"))

MARSTD <- ordered(MARSTD,
  levels = c(000,100,110,200,210,211,212,213,214,215,216,217,220,300,310,320,330,331,332,333,334,340,350,360,400,410,420,999),
  labels = c("NIU (not in universe)","Single/never married","Engaged","Married or consensual union","Married, formally","Married, civil","Married, religious","Married, civil and religious","Married, civil or religious","Married, traditional/customary","Married, monogamous","Married, polygamous","Consensual union","Separated/divorced/spouse absent","Separated or divorced","Separated or annulled","Separated","Separated legally","Separated de facto","Separated from marriage","Separated from consensual union","Annulled","Divorced","Married, spouse absent","Widowed","Widowed or divorced","Widowed, divorced, or separated","Unknown/missing"))

PA70A402 <- ordered(PA70A402,
  levels = c(1,2),
  labels = c("Male","Female"))

PA60A402 <- ordered(PA60A402,
  levels = c(1,2),
  labels = c("Male","Female"))

CR73A401 <- ordered(CR73A401,
  levels = c(1,2),
  labels = c("Male","Female"))

CR84A401 <- ordered(CR84A401,
  levels = c(1,2),
  labels = c("Male","Female"))

MARST_HEAD <- ordered(MARST_HEAD,
  levels = c(0,1,2,3,4,9),
  labels = c("NIU (not in universe)","Single/never married","Married/in union","Separated/divorced/spouse absent","Widowed","Unknown/missing"))

MARSTD_HEAD <- ordered(MARSTD_HEAD,
  levels = c(000,100,110,200,210,211,212,213,214,215,216,217,220,300,310,320,330,331,332,333,334,340,350,360,400,410,420,999),
  labels = c("NIU (not in universe)","Single/never married","Engaged","Married or consensual union","Married, formally","Married, civil","Married, religious","Married, civil and religious","Married, civil or religious","Married, traditional/customary","Married, monogamous","Married, polygamous","Consensual union","Separated/divorced/spouse absent","Separated or divorced","Separated or annulled","Separated","Separated legally","Separated de facto","Separated from marriage","Separated from consensual union","Annulled","Divorced","Married, spouse absent","Widowed","Widowed or divorced","Widowed, divorced, or separated","Unknown/missing"))

MARSTD_MOM <- ordered(MARSTD_MOM,
  levels = c(000,100,110,200,210,211,212,213,214,215,216,217,220,300,310,320,330,331,332,333,334,340,350,360,400,410,420,999),
  labels = c("NIU (not in universe)","Single/never married","Engaged","Married or consensual union","Married, formally","Married, civil","Married, religious","Married, civil and religious","Married, civil or religious","Married, traditional/customary","Married, monogamous","Married, polygamous","Consensual union","Separated/divorced/spouse absent","Separated or divorced","Separated or annulled","Separated","Separated legally","Separated de facto","Separated from marriage","Separated from consensual union","Annulled","Divorced","Married, spouse absent","Widowed","Widowed or divorced","Widowed, divorced, or separated","Unknown/missing"))

MARSTD_POP <- ordered(MARSTD_POP,
  levels = c(000,100,110,200,210,211,212,213,214,215,216,217,220,300,310,320,330,331,332,333,334,340,350,360,400,410,420,999),
  labels = c("NIU (not in universe)","Single/never married","Engaged","Married or consensual union","Married, formally","Married, civil","Married, religious","Married, civil and religious","Married, civil or religious","Married, traditional/customary","Married, monogamous","Married, polygamous","Consensual union","Separated/divorced/spouse absent","Separated or divorced","Separated or annulled","Separated","Separated legally","Separated de facto","Separated from marriage","Separated from consensual union","Annulled","Divorced","Married, spouse absent","Widowed","Widowed or divorced","Widowed, divorced, or separated","Unknown/missing"))

MARSTD_SP <- ordered(MARSTD_SP,
  levels = c(000,100,110,200,210,211,212,213,214,215,216,217,220,300,310,320,330,331,332,333,334,340,350,360,400,410,420,999),
  labels = c("NIU (not in universe)","Single/never married","Engaged","Married or consensual union","Married, formally","Married, civil","Married, religious","Married, civil and religious","Married, civil or religious","Married, traditional/customary","Married, monogamous","Married, polygamous","Consensual union","Separated/divorced/spouse absent","Separated or divorced","Separated or annulled","Separated","Separated legally","Separated de facto","Separated from marriage","Separated from consensual union","Annulled","Divorced","Married, spouse absent","Widowed","Widowed or divorced","Widowed, divorced, or separated","Unknown/missing"))

CR73A401_HEAD <- ordered(CR73A401_HEAD,
  levels = c(1,2),
  labels = c("Male","Female"))

###############################################################################
##                                                                           ##
## IPUMS USER: If you'd like to see the full variable names                  ##
## instead of the shorthand form (i.e. "Household weight" instead of "hhwt") ##
## please install the Hmisc package as explained here:                       ##
## <http://www.statmethods.net/interface/packages.html>.                     ##
##                                                                           ##
## Once Hmisc has been installed, please run the following code:             ##
##                                                                           ##
###############################################################################

library(Hmisc)
label(RECTYPE) <- "Record type"
label(SAMPLE) <- "IPUMS sample identifier"
label(SERIAL) <- "Serial number"
label(WTHH) <- "Household weight"
label(GQ) <- "Group quarters status"
label(URBAN) <- "Urban-rural status"
label(SAMPLEP) <- "IPUMS sample identifier [person version]"
label(SERIALP) <- "Serial number [person version]"
label(PERNUM) <- "Person number"
label(WTPER) <- "Person weight"
label(RELATE) <- "Relationship to household head [general version]"
label(RELATED) <- "Relationship to household head [detailed version]"
label(AGE) <- "Age"
label(SEX) <- "Sex"
label(MARST) <- "Marital status [general version]"
label(MARSTD) <- "Marital status [detailed version]"
label(PA70A402) <- "Sex"
label(PA60A402) <- "Sex"
label(CR73A401) <- "Sex"
label(CR84A401) <- "Sex"
label(MARST_HEAD) <- "Marital status [of head; general version]"
label(MARSTD_HEAD) <- "Marital status [of head; detailed version]"
label(MARSTD_MOM) <- "Marital status [of mother; detailed version]"
label(MARSTD_POP) <- "Marital status [of father; detailed version]"
label(MARSTD_SP) <- "Marital status [of spouse; detailed version]"
label(CR73A401_HEAD) <- "Sex [of head]"

