# Script to download indicator data
# and prepare it to the heatmap.

library(countrycode, quietly = TRUE)
library(reshape2, quietly = TRUE)
library(crayon, quietly = TRUE)
library(dplyr, quietly = TRUE)
library(RJSONIO)

FILE_PATH = "data/indicator_data"

downloadAndClean <- function(p = NULL, verbose = FALSE) {
	if (is.null(p)) stop("Provide a path.")
  
  cat("-----------------------------------------\n")

	# Downloading file.
	cat("Downloading file ... \n")
	u = "https://docs.google.com/spreadsheets/d/1L7O4QFetHdHUdsIv4xgb2rGLGQxIlEYIy-bLXMu5wVU/export?format=csv&gid=1499327503"
	download.file(u, paste0(p, ".csv"), method = 'wget')
	cat("done.\n")

	# Cleaning file.
	d = read.csv(paste0(p, ".csv"), skip = 1, na.strings = '', header = FALSE)
  n = lapply(d[1,], function(x) as.character(x))
	d = d[5:nrow(d),]
	names(d) <- n
	names(d)[1:2] <- c("iso", "location")
  
  
  cat("Cleaning ...\n")
  # Adding iso codes for the countries.
	d$iso <- countrycode(d$iso, "country.name", "iso3c")
	d$iso <- countrycode(d$iso, "iso3c", "country.name")
  
  # Converting data points into a logical test so
  # we can evaluate if that is missing or not.
  d[3:ncol(d)] <- is.na(d[3:ncol(d)])
  
  
  cat("Performing analysis ...\n")
  cat("-----------------------------------------------\n")
  
	# Melting
	d_melt <- melt(d, id.vars = c("iso", "location"), na.rm = FALSE)
  
  # Summary data per country.
  a_country <- data.frame(
    iso = aggregate(value ~ iso, data = d_melt, length)$iso,
    total_values = aggregate(value ~ iso, data = d_melt, length)$value,
    total_values_available = aggregate(value ~ iso, data = subset(d_melt, value == FALSE), length)$value
    )
  a_country$share <- round(with(a_country, total_values_available / total_values), 2)
  
  # Summary data per location.
	a_location <- data.frame(
	  iso = aggregate(value ~ location, data = d_melt, length)$location,
	  total_values = aggregate(value ~ location, data = d_melt, length)$value,
	  total_values_available = aggregate(value ~ location, data = subset(d_melt, value == FALSE), length)$value
	)
	a_location$share <- round(with(a_location, total_values_available / total_values), 2)
	a_location$country <- countrycode(a_location$iso, "country.name", "iso3c")
	a_location  <- a_location[is.na(a_location$country),]  # cleaning national measurements
  
  
  # Indicators per country
  indicator_assessment <- dcast(subset(d_melt, value == FALSE), variable ~ iso)
	names(indicator_assessment)[1] <- "Indicator"
  
  # Adding total
	indicator_assessment$"Eastern_Africa" <- round(
    apply(
      indicator_assessment[2:ncol(indicator_assessment)],
      1,
      mean
    ), 
    0
  )
	indicator_assessment <- arrange(indicator_assessment, Eastern_Africa)
  names(indicator_assessment)[12] <- "Eastern Africa"

  # Average completeness:
  m = paste0(round(mean(a_country$share),2) * 100, "%")
  cat(silver("AVERAGE COUNTRY COMPLETENESS: ") %+% red(m) %+% "\n")
	m = paste0(round(mean(a_location$share),2) * 100, "%")
	cat(silver("AVERAGE LOCATION COMPLETENESS: ") %+% red(m) %+% "\n")
  
  
  ## Writting output.
  # Summary data per country.
  sink(paste0(p, "_summary_country", ".json"))
  cat(toJSON(a_country))
  sink()
  
  # Summary data per location.
	sink(paste0(p, "_summary_location", ".json"))
	cat(toJSON(a_location))
	sink()
  
	# Indicator assessment
	sink(paste0(p, "_indicator_assessment", ".json"))
	cat(toJSON(indicator_assessment))
	sink()

	write.csv(indicator_assessment, paste(p, "_indicator_assessment", ".csv"), row.names = FALSE)
	
  
}

downloadAndClean(FILE_PATH)