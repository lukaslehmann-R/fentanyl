#scrape...


library(rvest)
library(stringr)
library(tidyverse)
library(here)
library(tidyverse)
library(httr) # for web requests and handling

url <- "https://www.cbp.gov/about/contact/ports/field-office"

rvest_session <- rvest::session(url, 
                                httr::add_headers(
                                  `From` = "lukasklehmann@outlook.com", 
                                  `UserAgent` = R.Version()$version.string
                                )
)

maybe_urls1 <- rvest_session |> 
  html_elements(xpath = "//*[contains(concat(' ', @class, ' '), concat(' ', 'field--label-hidden', ' '))]")|>
  html_text2()

maybe_urls1

maybe_urls2 <- data.frame(city = maybe_urls1, stringsAsFactors = FALSE)

maybe_urls3 <- maybe_urls2 %>%
  mutate(name_lower = tolower(city)) %>%
  filter(city != " ") %>%
  mutate(dashes = gsub(" ","-",name_lower)) %>%
  mutate(probs_url = paste0("https://www.cbp.gov/about/contact/ports/field-office/",dashes)) %>%
  slice(-21, -22)  # Drop rows 21 and 22

all_urls <- maybe_urls3$probs_url

all_urls

tempwd <- here::here("scraping")
# 'here' creates a path to the data directory

dir.create(tempwd, recursive = TRUE)
# Create directories if they don't exist

setwd(tempwd)
# Set working directory to tempwd

user_agent_string <- paste("R/", R.version$major, ".", R.version$minor, " ", R.Version()$platform, sep="")
# Customize the user agent string with R version and platform information

folder <- paste0(tempwd, "/html_articles/")
#concatenate the tempwd path with "/html_articles/" to create another path
folder
dir.create(folder, recursive = TRUE)



for (i in seq_along(all_urls)) {
  # Generate file name by removing the specified URL part and replacing slashes with underscores
  sanitized_url <- gsub("https://www.cbp.gov/about/contact/ports/field-office/", "", all_urls[i])
  file_name <- gsub("[/:*?\"<>|]", "_", sanitized_url) # Replace invalid characters
  
  # Add .html extension to the file name to ensure it's recognized as an HTML file
  file_path <- paste0(folder, file_name, ".html")
  
  # Check and create subdirectories if necessary
  dir.create(dirname(file_path), recursive = TRUE, showWarnings = FALSE)
  
  if (!file.exists(file_path)) {
    response <- httr::GET(all_urls[i], 
                          httr::add_headers(`From` = "lukasklehmann@outlook.com", 
                                            `User-Agent` = user_agent_string),
                          httr::write_disk(file_path, overwrite = TRUE))
    if (httr::status_code(response) == 200) {
      cat("Downloaded ", file_name, "\n")
    } else {
      cat("Error downloading", all_urls[i], ": Response code", httr::status_code(response), "\n")
    }
    Sys.sleep(5)
  }
}

list_files <- list.files(folder) #list of file names that match the regex
list_files_path <- list.files(folder, full.names = TRUE) #full file paths including directory paths of matched files

length(list_files)



######got the files

# Assuming list_files_path is defined and contains the paths to your HTML files
# Initialize vectors to store scraped data
city <- character()
address <- character()
phone <- character()

city

# Loop through each file and read its content
for (i in seq_along(list_files_path)) {
  
  html_out <- read_html(list_files_path[i])
  
  # Extract authors
  city_nodes <- html_elements(html_out, xpath = '//*[contains(concat( " ", @class, " " ), concat( " ", "field--label-hidden", " " ))]')
  if (length(city_nodes) > 0) {
    city[i] <- paste(html_text(city_nodes), collapse = ", ")
  } else {
    city[i] <- NA  # Use NA for missing data
  }
  
  # Extract address
  address_nodes <- html_elements(html_out, xpath = '//*[contains(concat( " ", @class, " " ), concat( " ", "field--name-field-location-address", " " ))]//*[contains(concat( " ", @class, " " ), concat( " ", "address", " " ))]')
  if (length(address_nodes) > 0) {
    address[i] <- html_text(address_nodes[1])  # Assuming only one address per document
  } else {
    address[i] <- NA
  }

# Extract publish date
phone_nodes <- html_elements(html_out, xpath = '//*[contains(concat( " ", @class, " " ), concat( " ", "field--name-field-phone", " " ))]//*[contains(concat( " ", @class, " " ), concat( " ", "field__item", " " ))]')
if (length(phone_nodes) > 0) {
  phone[i] <- html_text(phone_nodes[1])
} else {
  phone[i] <- NA
}
  
}

# Creating a dataframe from the vectors
scraped_data2 <- data.frame(
  city_name = city,
  address_info = address,
  phone_number = phone,
  stringsAsFactors = FALSE  # Avoid converting strings to factors
)

scraped_data3 <- scraped_data2 %>%
  mutate(city = sapply(str_split(city_name, ","), function(x) str_trim(x[3])))


library(tidyverse)
write_csv(scraped_data, "scraped_data.csv")





###### second round of scraping
# 
# //th//*[contains(concat( " ", @class, " " ), concat( " ", "survey-processed", " " ))]


url <- "https://www.cbp.gov/border-security/along-us-borders/border-patrol-sectors"

rvest_session <- rvest::session(url, 
                                httr::add_headers(
                                  `From` = "lukasklehmann@outlook.com", 
                                  `UserAgent` = R.Version()$version.string
                                )
)


maybe_urls2 <- rvest_session |> 
  html_elements(xpath = "//th//*[contains(concat(' ', @class, ' '), concat(' ', 'survey-processed', ' '))]") |>
  html_text()

th_elements <- rvest_session |> 
  html_elements("th") |>
  html_text()


th_elements1 <- data.frame(sector = th_elements, stringsAsFactors = FALSE)

# Remove the first two rows and clean the text
cleaned_text <- th_elements1 %>%
  slice(-1, -2) %>%                              # Drop rows 1 and 2
  mutate(sector = str_trim(sector)) %>%          # Trim leading and trailing whitespace
  mutate(sector = str_remove_all(sector, "\n"))  # Remove newline characters

# Display cleaned data frame
print(cleaned_text)

cleaned_text <- cleaned_text %>%
  mutate(name_lower = tolower(sector)) %>%
  filter(sector != " ") %>%
  mutate(dashes = gsub(" ","-",name_lower)) %>%
  mutate(probs_url = paste0("https://www.cbp.gov/border-security/along-us-borders/border-patrol-sectors/",dashes))

tempwd <- here::here("scraping2")
# 'here' creates a path to the data directory

dir.create(tempwd, recursive = TRUE)
# Create directories if they don't exist

setwd(tempwd)
# Set working directory to tempwd

user_agent_string <- paste("R/", R.version$major, ".", R.version$minor, " ", R.Version()$platform, sep="")
# Customize the user agent string with R version and platform information

folder <- paste0(tempwd, "/html_articles/")
#concatenate the tempwd path with "/html_articles/" to create another path
folder
dir.create(folder, recursive = TRUE)

all_urls <- cleaned_text$probs_url

all_urls


for (i in seq_along(all_urls)) {
  # Generate file name by removing the specified URL part and replacing slashes with underscores
  sanitized_url <- gsub("https://www.cbp.gov/border-security/along-us-borders/border-patrol-sectors/", "", all_urls[i])
  file_name <- gsub("[/:*?\"<>|]", "_", sanitized_url) # Replace invalid characters
  
  # Add .html extension to the file name to ensure it's recognized as an HTML file
  file_path <- paste0(folder, file_name, ".html")
  
  # Check and create subdirectories if necessary
  dir.create(dirname(file_path), recursive = TRUE, showWarnings = FALSE)
  
  if (!file.exists(file_path)) {
    response <- httr::GET(all_urls[i], 
                          httr::add_headers(`From` = "lukasklehmann@outlook.com", 
                                            `User-Agent` = user_agent_string),
                          httr::write_disk(file_path, overwrite = TRUE))
    if (httr::status_code(response) == 200) {
      cat("Downloaded ", file_name, "\n")
    } else {
      cat("Error downloading", all_urls[i], ": Response code", httr::status_code(response), "\n")
    }
    Sys.sleep(5)
  }
}


missing_two <-c("https://www.cbp.gov/border-security/along-us-borders/border-patrol-sectors/detroit-sector",
                "https://www.cbp.gov/border-security/along-us-borders/border-patrol-sectors/spokane-sector")

for (i in seq_along(missing_two)) {
  # Generate file name by removing the specified URL part and replacing slashes with underscores
  sanitized_url <- gsub("https://www.cbp.gov/border-security/along-us-borders/border-patrol-sectors/", "", missing_two[i])
  file_name <- gsub("[/:*?\"<>|]", "_", sanitized_url) # Replace invalid characters
  
  # Add .html extension to the file name to ensure it's recognized as an HTML file
  file_path <- paste0(folder, file_name, ".html")
  
  # Check and create subdirectories if necessary
  dir.create(dirname(file_path), recursive = TRUE, showWarnings = FALSE)
  
  if (!file.exists(file_path)) {
    response <- httr::GET(missing_two[i], 
                          httr::add_headers(`From` = "lukasklehmann@outlook.com", 
                                            `User-Agent` = user_agent_string),
                          httr::write_disk(file_path, overwrite = TRUE))
    if (httr::status_code(response) == 200) {
      cat("Downloaded ", file_name, "\n")
    } else {
      cat("Error downloading", missing_two[i], ": Response code", httr::status_code(response), "\n")
    }
    Sys.sleep(5)
  }
}

list_files <- list.files(folder) #list of file names that match the regex
list_files_path <- list.files(folder, full.names = TRUE) #full file paths including directory paths of matched files

length(list_files)


# Assuming list_files_path is defined and contains the paths to your HTML files
# Initialize vectors to store scraped data
city <- character()
address <- character()
phone <- character()


# Loop through each file and read its content
for (i in seq_along(list_files_path)) {
  
  html_out <- read_html(list_files_path[i])
  
  # Extract authors
  city_nodes <- html_elements(html_out, xpath = '//*[(@id = "page-title")]//*[contains(concat( " ", @class, " " ), concat( " ", "field--label-hidden", " " ))]')
  if (length(city_nodes) > 0) {
    city[i] <- paste(html_text(city_nodes), collapse = ", ")
  } else {
    city[i] <- NA  # Use NA for missing data
  }
  
  # Extract address
  address_nodes <- html_elements(html_out, xpath = '//p[(((count(preceding-sibling::*) + 1) = 4) and parent::*)] | //p[(((count(preceding-sibling::*) + 1) = 3) and parent::*)] | //*[(@id = "1-1")]//p[(((count(preceding-sibling::*) + 1) = 2) and parent::*)] | //*[(@id = "1-1")]//p[(((count(preceding-sibling::*) + 1) = 1) and parent::*)]')
  if (length(address_nodes) > 0) {
    address[i] <- paste(html_text(address_nodes), collapse = ", ")  # Assuming only one address per document
  } else {
    address[i] <- NA
  }
  # 
  # # Extract publish date
  # phone_nodes <- html_elements(html_out, xpath = '//*[contains(concat( " ", @class, " " ), concat( " ", "field--name-field-phone", " " ))]//*[contains(concat( " ", @class, " " ), concat( " ", "field__item", " " ))]')
  # if (length(phone_nodes) > 0) {
  #   phone[i] <- html_text(phone_nodes[1])
  # } else {
  #   phone[i] <- NA
  # }
  
}

# Creating a dataframe from the vectors
scraped_data1 <- data.frame(
  city_name = city,
  address_info = address,
  # phone_number = phone,
  stringsAsFactors = FALSE  # Avoid converting strings to factors
)

scraped_data1$address_info

# Extract phone numbers using regex and place them in a new column
scraped_data1$phone_numbers <- regmatches(scraped_data1$address_info, gregexpr("\\(\\d{3}\\) \\d{3}-\\d{4}|\\d{1}-\\d{3}-\\d{3}-\\d{4}", scraped_data1$address_info))

# If multiple phone numbers are present in a single entry, combine them into a single string
scraped_data1$phone_numbers <- sapply(scraped_data1$phone_numbers, function(x) paste(x, collapse = ", "))


# Assuming scraped_data1 is your dataframe and address_info is the column
scraped_data1$address1 <- sub(".*Sector Headquarters Mailing Address\\s*", "", scraped_data1$address_info)

# Create a new dataframe with rows 8 and 20
removed_rows_df <- scraped_data1[c(8, 20), ]

# Remove rows 8 and 20 from the original dataframe
scraped_data1 <- scraped_data1[-c(8, 20), ]

scraped_data1 <- scraped_data1 %>%
  mutate(clean1 = gsub("-", "", address1))

scraped_data1 <- scraped_data1 %>%
  mutate(clean2 = gsub(":", "", clean1)) %>%
  select(city_name, clean2, phone_numbers)

# Add the new column clean2 with specified values
removed_rows_df$clean2 <- c("1816 17th Street NE, Grand Forks, ND 58203.", 
                            "4035 S. Ave. A, Yuma AZ 85365")
removed_rows_df <- removed_rows_df %>%
  select(city_name, clean2, phone_numbers)

# Combine the dataframes back together
combined_df <- rbind(scraped_data1, removed_rows_df)

# Use regex to extract the address up to and including the zip code
combined_df$clean2 <- sub("(.*\\d{5})(?:-\\d{4})?.*", "\\1", combined_df$clean2)

combined_df$clean2

combined_df$phone_numbers[combined_df$city_name == "Yuma Sector Arizona"] <- "(928) 341-6500"


scraped_data4 <- scraped_data3 %>%
  mutate(city = gsub(" Field Office", "", city)) %>%
  mutate(city = paste(city, "Field Office")) %>%
  select(city, address_info, phone_number) %>%
  mutate(clean2 = gsub("- -", "", address_info)) %>%
  select(city, clean2, phone_number)

scraped_data4$clean2

# # Format the addresses to add new lines between components
# scraped_data4$clean2 <- gsub("([a-zA-Z0-9.#]+\\s*[a-zA-Z]*)\\s*(Suite|Room|Floor|,?\\s*#\\d+|St\\.?|Ave\\.?|Blvd\\.?|Rd\\.?|Dr\\.?)\\s*(\\d+)?", 
#                              "\\1\n\\2 \\3\n", scraped_data4$clean2)
# 
# # Add a new line before city, state, and country
# scraped_data4$clean2 <- gsub("(\\d{5})([A-Z])", "\\1\n\\2", scraped_data4$clean2)
# 
# # Add a new line before 'United States'
# scraped_data4$clean2 <- gsub("(United States)", "\n\\1", scraped_data4$clean2)
# 
# # Clean up any extra spaces or newlines
# scraped_data4$clean2 <- gsub("\\s*\n\\s*", "\n", scraped_data4$clean2) # Removes any extra spaces around newlines
# scraped_data4$clean2 <- trimws(scraped_data4$clean2) # Trim leading and trailing whitespace
# 
# ####
# # First, let's fix the United States splitting issue
# scraped_data4$clean2 <- gsub("United\\nSt\\nates", "United States", scraped_data4$clean2)
# 
# # Add a new line before 'United States' for proper separation
# scraped_data4$clean2 <- gsub("United States", "\nUnited States", scraped_data4$clean2)
# 
# # Separate components like Suite, Room, Floor from the preceding text
# scraped_data4$clean2 <- gsub("(\\d+\\s\\w[\\w\\s]*)\\s*(Suite|Room|Floor|Ste\\.?|Fl\\.?|#)", "\\1\n\\2", scraped_data4$clean2)
# 
# # Add new lines before the city, state, and ZIP code part
# scraped_data4$clean2 <- gsub("(\\d{5})([A-Z])", "\\1\n\\2", scraped_data4$clean2)
# 
# # Clean up any extra spaces or incorrect newlines
# scraped_data4$clean2 <- gsub("\\n\\s*", "\n", scraped_data4$clean2)  # Fix newlines with leading spaces
# scraped_data4$clean2 <- gsub("\\s+\\n", "\n", scraped_data4$clean2)  # Remove spaces before newlines
# scraped_data4$clean2 <- trimws(scraped_data4$clean2)  # Trim leading and trailing whitespace


# scraped_data4$clean2
# 
# # Replace all instances where there's a lowercase letter followed by an uppercase letter without space, which indicates a mistake in breaking
# scraped_data4$clean2 <- gsub("([a-z])([A-Z])", "\\1 \\2", scraped_data4$clean2)
# 
# # Insert new lines after each of these patterns: commas, "Suite", "Room", "Floor", state and ZIP codes, and "United States"
# scraped_data4$clean2 <- gsub(", ", ",\n", scraped_data4$clean2)
# scraped_data4$clean2 <- gsub(" Suite ", "\nSuite ", scraped_data4$clean2)
# scraped_data4$clean2 <- gsub(" Room ", "\nRoom ", scraped_data4$clean2)
# scraped_data4$clean2 <- gsub(" Floor", "\nFloor", scraped_data4$clean2)
# scraped_data4$clean2 <- gsub("([A-Z]{2}) (\\d{5}(-\\d{4})?)", "\\1 \\2\n", scraped_data4$clean2)
# scraped_data4$clean2 <- gsub("United States", "\nUnited States", scraped_data4$clean2)
# 
# # Remove any unnecessary leading or trailing whitespace
# scraped_data4$clean2 <- trimws(scraped_data4$clean2)

scraped_data4$clean2


# Add a space where there's a transition from letters to numbers or numbers to letters
scraped_data4$clean2 <- gsub("([a-zA-Z])([0-9])", "\\1 \\2", scraped_data4$clean2)
scraped_data4$clean2 <- gsub("([0-9])([a-zA-Z])", "\\1 \\2", scraped_data4$clean2)

# Add a space where there's a transition from lowercase to uppercase letters with no space
scraped_data4$clean2 <- gsub("([a-z])([A-Z])", "\\1 \\2", scraped_data4$clean2)


scraped_data4 <- scraped_data4 %>%
  rename(city_name = city,
         phone_numbers = phone_number)

# Combine the dataframes using rbind
final_df <- rbind(combined_df, scraped_data4)

write.csv(final_df, "final_df.csv")


# # Clean and format the addresses
# scraped_data$clean2 <- gsub("(\\d+\\s\\w.*)(Suite|Room|#|Floor|Ste\\.?|Apt\\.?|Fl\\.?)(\\s?\\d+.*)?\\n(.*\\d{5})\\nUnited States",
#                             "\\1, \\2 \\3\n\\4\nUnited States",
#                             scraped_data$clean2)
# 
# # Further cleanup to ensure consistent formatting
# scraped_data$clean2 <- gsub("\n\n", "\n", scraped_data$clean2) # Remove any double new lines
# scraped_data$clean2 <- gsub("\\s+", " ", scraped_data$clean2) # Remove extra spaces
# scraped_data$clean2 <- trimws(scraped_data$clean2) # Trim leading and trailing whitespace
# 
# # Add a new line after each part of the address
# scraped_data$clean2 <- gsub(",?\\s*", "\n", scraped_data$clean2)

# scraped_data <- scraped_data %>%
#   mutate(city = sapply(str_split(city_name, ","), function(x) str_trim(x[3])))





