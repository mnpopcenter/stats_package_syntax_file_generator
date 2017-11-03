if (!require("ripums")) stop("Reading IPUMS data into R requires the ripums package. It can be installed using the following command: install.packages('ripums')")

ddi <- read_ipums_ddi("__my_data.xml")
data <- read_ipums_micro(ddi)
