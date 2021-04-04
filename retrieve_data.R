# retrieve_data.R Retrieve data and tidy it

# Load libraries ----
library(tidyverse)
library(readxl)

install.packages("rvest")
library(rvest)

# Custom functions ----

# create_sopi_dataframes()
# Arguments
# sopi_data_unformatted - The unformatted SOPI data when loaded from read_xlsx
# Returns
# A list of three dataframes with the element names
# - volume
# - price
# - revenue
# Purpose
# This creates the three tidy data frames from the untidy SOPI data on MPI's website
create_sopi_dataframes <- function(sopi_data_unformatted){
  
  # Create a list for the outputs
  sopi_dataframes <- list()
  
  # Retrieve each data frame from the unformatted sopi data
  sopi_dataframes$volume <- format_sopi_category(sopi_data_unformatted, seq(2, 20, 3))
  sopi_dataframes$price <- format_sopi_category(sopi_data_unformatted, seq(3, 21, 3)) 
  sopi_dataframes$revenue <- format_sopi_category(sopi_data_unformatted, seq(4, 22, 3))  
  
  return(sopi_dataframes)
}

format_sopi_category <- function(sopi_data_unformatted, rows){
  
  # Retrieve the column names
  sopi_col_headers <- sopi_data_unformatted %>%
    select(1) %>%
    slice(seq(2, 20, 3)) %>%
    pull()
  
  # Turn unformatted data in to matrix
  sopi_data_matrix <- sopi_data_unformatted %>% as.matrix()  
  
  # Retrieves rows and transpose the matrix to tidy
  sopi_data_category <- t(sopi_data_matrix[rows,4:ncol(sopi_data_matrix)])  
  
  # Set the column names
  colnames(sopi_data_category) <- sopi_col_headers
  
  # Create the data frame
  sopi_data_category <- sopi_data_category %>%
    as_tibble() %>%
    mutate(`Years` = str_replace(rownames(sopi_data_category),'F',''),
           across(everything(), ~ as.numeric(.))) %>%
    select(`Years`, everything())
  
  # Return the output
  return(sopi_data_category)
}

get_sopi_data <- function(){
  
  # Get the HTML page that holds the link to the SOPI data
  mpi_url <- read_html('https://www.mpi.govt.nz/science/open-data-and-forecasting/situation-and-outlook-for-primary-industries-data/')
  
  # Retrieve the address of the SOPI data
  mpi_link <- mpi_url %>% 
    html_element('.feature-doc > a:nth-child(1)') %>% 
    html_attr('href')
  
  # Retrieve the extension of the SOPI file
  mpi_ext <- mpi_url %>%
    html_element('.feature-doc > a:nth-child(1)') %>% 
    html_attr('data-ext')
  
  # Build the download link
  mpi_download_link <- paste0('https://www.mpi.govt.nz/',
                              mpi_link,
                              '.',
                              mpi_ext)
  
  # Download the file
  download.file(url = mpi_download_link,
                destfile = './Data/SOPI_data.xlsx',
                mode = 'wb')
  
  # Open the SOPI data
  sopi_data_unformatted <- read_xlsx('./Data/SOPI_data.xlsx', sheet = 'Dairy', skip = 2)
  
  # Retrieve the SOPI data frames
  sopi_dataframes <- create_sopi_dataframes(sopi_data_unformatted)  
  
  # Return the data frames
  return(sopi_dataframes)  
}

# Download, Read and Format data frames ----

# Get the dataframes from the SOPI file
sopi_dataframes <- get_sopi_data()

# Assign the data frames to variables
sopi_volume <- sopi_dataframes$volume
sopi_price <- sopi_dataframes$price
sopi_revenue <- sopi_dataframes$revenue




