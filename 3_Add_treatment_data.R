library(dplyr)
library(tidyr)

# Set working directory
setwd("C:/Users/cs2276/OneDrive - University of Cambridge/Desktop/20251112_WP17-018_RNAi-MSBP2/Cy3_files")

# Correct the replicate number if necessary!
reps <- 3

# Get csv files
image_files <- list.files(path = ".", pattern = "\\.tif$", full.names = TRUE)

for (file in image_files) {
  # Extract the name of the file
  filename <- basename(file)
  base_name <- sub("\\.tif$", "", filename)

  # Get "zero" scores
  zero_data <- sub("\\.tif$", "_zero.csv", filename) %>% read.csv(.)
  
  # Set filename as csv file
  filename <- sub("\\.tif$", ".csv", filename)
  
  # Get the whole leaf treatment (e.g. no LsNRC (-), LsNRC1, LsNRC0)
  filename_parts <- strsplit(base_name, "_")[[1]]
  whole_leaf_treatment <- filename_parts[1]
  # ...and patch treatments
  patch_treatments <- filename_parts[2]
  patch_treatment_list <- strsplit(patch_treatments, ",")[[1]]
  # Replicate the treatment ids by the number of reps (above)
  replicated_treatment_list <- rep(patch_treatment_list, each = reps)
  
  ############# Note: Multiple leaf treatments script will only work correctly if the same number of patches appear
  ############# on both sides of the leaf! May need to make this more flexible!
  if (grepl(",", whole_leaf_treatment)) {
    print(paste("File ", filename, " has multiple treatments at whole leaf level"))
    # Split whole leaf treatments into a list
    wlt_parts <- strsplit(whole_leaf_treatment, ",")[[1]]
    # Replicate by half of the total number of treatments (i.e. assuming there are the same number of patches on either side)
    rep_wlt_parts <- rep(wlt_parts, each = length(replicated_treatment_list)/2)
    replicated_treatment_list <- paste(rep_wlt_parts, replicated_treatment_list, sep = "_")
  } else {
    print(paste("File ", filename, " has single treatment at whole leaf level"))
    replicated_treatment_list <- paste(whole_leaf_treatment, replicated_treatment_list, sep = "_")
  }
 
  ## Add treatment data to dataframe
  data <- read.csv(filename)
  data$Treatment <- replicated_treatment_list
  ## Split into full leaf treatment and patch treatment
  data <- data %>%
    separate(Treatment, into = c("full_leaf_treatment", "patch_treatment"), sep = "_", remove = FALSE)
  
  ## Add zero scores to dataframe
  all_cols <- union(names(data), names(zero_data))
  # Make function to add NA scores to missing columns, before combining dfs
  add_missing_cols <- function(df, all_cols) {
    missing <- setdiff(all_cols, names(df))
    for (col in missing) {
      df[[col]] <- NA
    }
    # Reorder columns to match all_cols
    df <- df[all_cols]
    return(df)
  }

  data <- add_missing_cols(data, all_cols)
  zero_data <- add_missing_cols(zero_data, all_cols)
  data <- bind_rows(data, zero_data)
  
  ### Add column "Zeroed_data"
  av_zero <- mean(zero_data$Mean)
  data$Zeroed_Mean <- data$Mean - av_zero
  
  # Output annotated file
  output_filename <- paste0(base_name, "_ann.csv")
  print(paste("Average zero score is ", av_zero, " for ", output_filename))
  write.csv(data, output_filename, row.names = FALSE)
}


