if (!require("ripums")) stop("Reading IPUMS data into R requires the ripums package. It can be installed using the following command: install.packages('ripums')")
data <- read_ipums_micro("__my_data.xml")
