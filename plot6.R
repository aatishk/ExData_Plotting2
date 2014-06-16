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

# Link for definition of emission sources: http://www.epa.gov/air/emissions/basic.htm
# http://www.epa.gov/otaq/standards/basicinfo.htm
# common code for plots 4, 5, 6
NEI <- NEI[, c("fips", "SCC", "Emissions", "year")]
SCC <- SCC[, c("SCC", "Data.Category", "EI.Sector")]
NEI2 <- merge(NEI, SCC, by="SCC")

# Common for plots 5, 6
NEI2$vehicle <- grepl("[Vv]ehicle",NEI2$EI.Sector)
NEI2_vehicles_baltimore <- NEI2[NEI2$vehicle == TRUE & NEI$fips == "24510", ]
table_baltimore_year_Emissions <- aggregate(Emissions ~ year, NEI2_vehicles_baltimore, sum)

# Plot 6
NEI2_vehicles_los_angeles <- NEI2[NEI2$vehicle == TRUE & NEI$fips == "06037", ]
table_los_angeles_year_Emissions <- aggregate(Emissions ~ year, NEI2_vehicles_los_angeles, sum)

png(file="plot6_linechart.png")
plot(table_baltimore_year_Emissions$year, table_baltimore_year_Emissions$Emissions,
     type="b", xlab="Year", ylab=expression("Vehicular PM" [2.5]*" Emissions"), ylim = c(0,120), 
     main=expression("Vehicular PM" [2.5]*" Emissions in Baltimore City vs. Los Angeles"))
lines(table_los_angeles_year_Emissions$year, table_los_angeles_year_Emissions$Emissions, 
      type="b", col=2)
legend("topright",c("Baltimore City", "Los Angeles"), lty=c(1,1), col=c(1,2))
dev.off()

emissions <- rbind(table_baltimore_year_Emissions$Emissions, table_los_angeles_year_Emissions$Emissions)
png(file="plot6_barplot.png")
barplot(emissions, names.arg=table_year_Emissions$year, beside=TRUE, 
     xlab="Year", ylab=expression("Vehicular PM" [2.5]*" Emissions"), 
     main=expression("Vehicular PM" [2.5]*" Emissions in Baltimore City vs. Los Angeles"),
     col=c(1,2), legend=c("Baltimore City", "Los Angeles"), args.legend=list(x="topright"))
dev.off()
