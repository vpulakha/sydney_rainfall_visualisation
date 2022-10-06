## A brief visualisation of rainfall data for Sydney, Australia from 1900 to 2022. 

## 2022 has been an extraordinarily wet year in Sydney and I wanted to understand how 
## the rainfall data of 2022 compares to the historical data maintained by the
## Australian Bureau of Meteorology (BOM) (http://www.bom.gov.au/).  
## The BOM allows you to download weather related data going all the way back to 1850's
## 

# Download packages - I was trying to keep the number of packages to a minimum.
# I think you can get away with just using ggplot2 and base R but I like to 
# use the data.table package (it is absolutely amazing for large data sets)
# I used ggrepl for text annotation and ggthemes for a clean chart background

library(ggplot2)
library(data.table)
library(ggrepel) #Package to annotate the chart with text
library(ggthemes) # Package for background themes of the chart


# Read the BOM Rainfall Data from 1900 to September 2022 from a local CSV file
# I download the BOM Rainfall data for a specific station in Sydney from the BOM website.
# If you want to download the data for a specfic location/region/station, you can go to the following link:
# http://www.bom.gov.au/climate/data/?ref=ftr
# and enter the details of the weather station in your area and download the data. A zip file will be downloaded. 
# The zip file contains three files - two files with data in two different formats and 1 files with some explanation 
# of the data such station ID, the data range.  The data are provided in two formats: 
# as one month per line and 12 months per line.

# NOTE: For this visualisation, I used the first format - one month per line (the suffix of the file in *Data1.csv)
# This visulaisation assumes that you are going to use the first format.  If you want to use the second
# format, then you will need to reshape the file from "Wide" format to "long" format using the reshape package.

# Read the rainfall data.
rainfall <- fread("~/Documents/customers/Datasets/weather/Sydney-Rainfall-Data-Visualisation/IDCJAC0001_066160/IDCJAC0001_066160_Data1.csv")

# Convert the year as a factor
rainfall$Year <- as.factor(rainfall$Year)

# simplify the rainfall column name
names(rainfall)[5] <- "rainfall_mm"

# At the time of writing/developing this chart, we have not completed the month of October and therefore,
# I had to download the data for the current number of days in October. 

# Get the latest October data
oct_rainfall <- fread("~/Documents/customers/Datasets/weather/Sydney-Rainfall-Data-Visualisation/IDCJDW2124.202210.csv")
rainfall <- rbind(rainfall, list("IDCJAC0001", 66160, as.factor("2022"), 10, sum(oct_rainfall$`Rainfall (mm)`), "Y"))

# Convert month numbers to month names - for example, 1 = Jan, 2 = Feb., etc.
rainfall$month_name <- as.factor(month.abb[rainfall$Month])
rainfall$month_name = factor(rainfall$month_name, levels = month.abb)


# create an ordered data.frame from highest to lowest rainfall.  I do this so that you can use the order
# for highlighting some specific years of interest.
x <- rainfall[, .(annual_rainfall = sum(rainfall_mm)), by=Year]
# Order this by descending order
setorder(x, -annual_rainfall)

# Create a chart attributes dataframe which maps the year to the colour and size of the line 
attributes <- as.data.table(data.frame(Year = unique(rainfall$Year),cols = "gray", lsize = 0.5))

# set the colour and line attributes for the current year - last row (for this visualisation, it is 2022)
attributes[nrow(attributes),"cols"] <- "#D43F3A"
attributes[nrow(attributes),"lsize"] <- 1.5

# Set the attributes for the second highest year (this was 1950 in my dataset)
attributes[as.integer(x[2,1]),]$cols = "#5CB85C"
attributes[as.integer(x[2,1]),]$lsize <- 1.0

# A function to format the y-axis units -  to add "mm" to the y-axis values
addmm <- function(x, ...) #<== function will add " mm" to any number, and allows for any additional formatting through "format".
  format(paste0(x, " mm"), ...)

# The plot part using ggplot
# A few details:
# 1.Created a cumulative rainfall by year: rainfall[,cs := cumsum(rainfall_mm), by=list(Year)]
# 2. Used the colours and line size from the attributes data frame
# 3. Set the y-axis to the right
# 4. Annotated the years using the ggrepel attributes
# 5. Using theme_clean() 
# 6. Set font sizes 

ggplot(rainfall[,cs := cumsum(rainfall_mm), by=list(Year)], aes(x = as.character(month_name), y = cs, group = Year, color = Year, label=Year)) + 
  geom_line(aes(size=Year)) + scale_color_manual(values = attributes$cols)+ scale_size_manual(values=attributes$lsize)+theme_clean()+theme(legend.position = "none") + scale_x_discrete(limits = month.abb)+
  labs(subtitle="Cumulative Monthly Rainfall (mm) from 1900 - 2022 (till October 6th)",
       x= "Month", y="",
       title = "Sydney breaks rainfall records, smashing past 1950 high-water mark",
       caption="Source: Australian Government - Bureau of Meteorology - Data from Station ID 66160 - Sydney Centennial Park, NSW") + 
  scale_y_continuous(labels = addmm, position = "right", limits = c(0, 2250), breaks = c(0, 250,500,750,1000,1250,1500,1750,2000, 2250))+
  theme(plot.title = element_text(size = 20))+theme(plot.subtitle = element_text(size=14)) +  
  geom_text_repel(
    data          = subset(rainfall, (Year == "2022" & month_name == "Oct") | (Year == "1950" & month_name == "Dec")), 
    nudge_y       = 25,
    segment.size  = 0.4,
    segment.color = "grey50",
    direction     = "y",
    fontface = 'bold'
  ) 



