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
  
  
	#############################
	# Visualization ASSESSMENTS #
	#############################
  
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
  
  # Assessment of indicators per country: national
  c = d_melt
  c$is_country <- countrycode(d_melt$location, "country.name", "iso3c")
  c$is_country <- !is.na(c$is_country)
  c_melt <- subset(c, is_country == TRUE & location != "Somali")
  
  
	# Assessment of indicators per country: sub-national
	country_assessment <- dcast(subset(c_melt, value == FALSE), variable ~ iso)
	names(country_assessment)[1] <- "Indicator"
	
	# Adding total
	country_assessment$"East_Africa" <-
	  apply(
	    country_assessment[2:ncol(country_assessment)],
	    1,
	    sum
	  )

  # Inputting indicators that have no data
  country_assessment$Indicator <- as.character(country_assessment$Indicator)
  # country_assessment[nrow(country_assessment) + 1,] <- c("Population", rep(0, ncol(country_assessment) - 1))
  # country_assessment[nrow(country_assessment) + 1,] <- c("Security Incidents", rep(0, ncol(country_assessment) - 1))
  # country_assessment[nrow(country_assessment) + 1,] <- c("Surface Area (sq. km) ", rep(0, ncol(country_assessment) - 1))

  # country_assessment[nrow(country_assessment) + 1,] <- c("Global Acute Malnutrition", rep(0, ncol(country_assessment) - 1))
  # country_assessment[nrow(country_assessment) + 1,] <- c("Disaster Risk Reduction", rep(0, ncol(country_assessment) - 1))

  # Fixing how some countries have 2 to 1.
  country_assessment$Djibouti <- ifelse(country_assessment$Djibouti == 2, 1, country_assessment$Djibouti)
  country_assessment$Ethiopia <- ifelse(country_assessment$Ethiopia == 2, 1, country_assessment$Ethiopia)

  # Re-arranging data.
  country_assessment$East_Africa <- as.numeric(country_assessment$East_Africa)
  country_assessment <- arrange(country_assessment, East_Africa)
  names(country_assessment)[12] <- "East Africa"

  # Removing East Africa from the country assessment column
  country_assessment$"East Africa" <- NULL
  
  # Assessment of indicators per country: sub-national
  melt_grouping <- group_by(d_melt, iso)
	melt_grouping <- summarise(melt_grouping, n_locations = n_distinct(location))
  x <- dcast(melt_grouping, .~ iso)
  
  # Calculating the number of observations per
  # country. 
	indicator_assessment <- dcast(subset(d_melt, value == FALSE), variable ~ iso)
	names(indicator_assessment)[1] <- "Indicator"
  
  # Calculating the relative completeness.
	calculateRelative <- function() {
	  for (i in 2:ncol(indicator_assessment)) {
      n = names(indicator_assessment)[i]
	    a = melt_grouping[melt_grouping$iso == n,][[2]]
      indicator_assessment[i] <- round((indicator_assessment[i] / a),2) * 100
	  }
	  return(indicator_assessment)
	}
  
	indicator_assessment <- calculateRelative()
  
  # Adding total for the region.
	indicator_assessment$"East_Africa" <- round(
    apply(
      indicator_assessment[2:ncol(indicator_assessment)],
      1,
      mean
    ), 
    0
  )

  # Inputting indicators that have no data
	indicator_assessment$Indicator <- as.character(indicator_assessment$Indicator)
  # indicator_assessment[nrow(indicator_assessment) + 1,] <- c("Global Acute Malnutrition", rep(0, ncol(indicator_assessment) - 1))
  # indicator_assessment[nrow(indicator_assessment) + 1,] <- c("Disaster Risk Reduction", rep(0, ncol(indicator_assessment) - 1))

  # Arranging data to look nice.
  indicator_assessment$East_Africa <- as.numeric(indicator_assessment$East_Africa)
	indicator_assessment <- arrange(indicator_assessment, East_Africa)
  names(indicator_assessment)[12] <- "East Africa"
  
  
  
  ########################
  # TERMINAL ASSESSMENTS #
	########################
  
  # Average completeness:
  m = paste0(round(mean(a_country$share),2) * 100, "%")
  cat(silver("AVERAGE COUNTRY COMPLETENESS: ") %+% red(m) %+% "\n")
	m = paste0(round(mean(a_location$share),2) * 100, "%")
	cat(silver("AVERAGE LOCATION COMPLETENESS: ") %+% red(m) %+% "\n")
  
  
  ## Writting output.
  # Summary data per country.
  # sink(paste0(p, "_summary_country", ".json"))
  # cat(toJSON(a_country))
  # sink()
  
  # Summary data per location.
	# sink(paste0(p, "_summary_location", ".json"))
	# cat(toJSON(a_location))
	# sink()
  
	# Indicator assessment
	sink(paste0(p, "_indicator_assessment", ".json"))
	cat(toJSON(indicator_assessment))
	sink()
  
	# Indicator assessment
	sink(paste0(p, "_country_indicator_assessment", ".json"))
	cat(toJSON(country_assessment))
	sink()
	

	write.csv(indicator_assessment, paste0(p, "_indicator_assessment", ".csv"), row.names = FALSE)
	
  
}

downloadAndClean(FILE_PATH)