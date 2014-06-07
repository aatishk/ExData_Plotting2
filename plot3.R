# set the file url
fileurl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"

# create a temporary directory
td = tempdir()

# create the placeholder file
tf = tempfile(tmpdir=td, fileext=".zip")

# download into the placeholder file (curl method needed for Mac OS X)
download.file(fileurl, tf, method="curl")

# Files to extract
fnameNEI = "summarySCC_PM25.rds"
fnameSCC = "Source_Classification_Code.rds"

# unzip the file to the temporary directory
unzip(tf, files=fnameSCC, exdir=td, overwrite=TRUE)
unzip(tf, files=fnameNEI, exdir=td, overwrite=TRUE)

# fpath is the full path to the extracted file
fpathNEI = file.path(td, fnameNEI)
fpathSCC = file.path(td, fnameSCC)

## Read R Data Sets
NEI <- readRDS(fpathNEI)
SCC <- readRDS(fpathSCC)

# Plot 3
# convert type from character to factor
NEI$type <- as.factor(NEI$type)
table2_baltimore_year_type_Emissions <- aggregate(Emissions ~ year+type, baltimore_NEI, sum)
library(ggplot2)

png(file="plot3.png")
number_ticks <- function(n) {function(limits) pretty(limits, n)}
qplot(year, Emissions, data=table2_baltimore_year_type_Emissions, 
      facets = .~ type, xlab="Year", ylab=expression("Total PM" [2.5]*" Emissions"),
      main=expression("Total PM" [2.5]*" Emissions in Baltimore City as per source type")) +
  scale_x_continuous(breaks=number_ticks(3)) + geom_line() + geom_point()
dev.off()