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

# Plot 1
table_year_Emissions <- aggregate(Emissions ~ year, NEI, sum)

png(file="plot1.png")
plot(table_year_Emissions$year, table_year_Emissions$Emissions, type="b", xlab="Year",
     ylab=expression("Total PM"[2.5]*" Emissions"), 
     main=expression("Total PM"[2.5]*" Emissions in US [1999-2008]"))
dev.off()