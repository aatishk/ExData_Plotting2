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

# Plot 2
baltimore_NEI <- NEI[NEI$fips == "24510", ]
table_baltimore_year_Emissions <- aggregate(Emissions ~ year, baltimore_NEI, sum)

png(file="plot2.png")
plot(table_baltimore_year_Emissions$year, table_baltimore_year_Emissions$Emissions,
     type="b", xlab="Year", ylab=expression("Total PM" [2.5]*" Emissions"),
     main=expression("Total PM" [2.5]*" Emissions in Baltimore City [1999-2008]"))
dev.off()

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

# Plot 4, 5, 6
NEI <- NEI[, c("fips", "SCC", "Emissions", "year")]
SCC <- SCC[, c("SCC", "EI.Sector")]
NEI2 <- merge(NEI, SCC, by="SCC")

# Plot 4
NEI2$coal <- grepl("[Cc]oal",NEI2$EI.Sector)
NEI2_coal <- NEI2[NEI2$coal == TRUE, ]

png(file="plot4.png")
table_year_Emissions <- aggregate(Emissions ~ year, NEI2_coal, sum)
plot(table_year_Emissions$year, table_year_Emissions$Emissions, type="b", xlab="Year",
     ylab=expression("Coal Combustion PM"[2.5]*" Emissions"), 
     main=expression("Coal Combustion PM"[2.5]*" Emissions in US [1999-2008]"))
dev.off()

# plot 5
NEI2$vehicle <- grepl("[Vv]ehicle",NEI2$EI.Sector)
NEI2_vehicles_baltimore <- NEI2[NEI2$vehicle == TRUE & NEI$fips == "24510", ]
table_baltimore_year_Emissions <- aggregate(Emissions ~ year, NEI2_vehicles_baltimore, sum)

png(file="plot5.png")
plot(table_baltimore_year_Emissions$year, table_baltimore_year_Emissions$Emissions,
     type="b", xlab="Year", ylab=expression("Vehicular PM" [2.5]*" Emissions"),
     main=expression("Vehicular PM" [2.5]*" Emissions in Baltimore City [1999-2008]"))
dev.off()

# Plot 6
NEI2_vehicles_los_angeles <- NEI2[NEI2$vehicle == TRUE & NEI$fips == "06037", ]
table_los_angeles_year_Emissions <- aggregate(Emissions ~ year, NEI2_vehicles_los_angeles, sum)

png(file="plot6.png")
plot(table_baltimore_year_Emissions$year, table_baltimore_year_Emissions$Emissions,
     type="b", xlab="Year", ylab=expression("Vehicular PM" [2.5]*" Emissions"), ylim = c(0,120), 
     main=expression("Vehicular PM" [2.5]*" Emissions in Baltimore City vs. Los Angeles"))
lines(table_los_angeles_year_Emissions$year, table_los_angeles_year_Emissions$Emissions, 
      type="b", col=2)
legend("topright",c("Baltimore City", "Los Angeles"), lty=c(1,1), col=c(1,2))
dev.off()

