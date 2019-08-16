library(tidyverse)
library(googlesheets)
library(ids)

### do not run

# load data from google forms
# inspired by Łukasz Prokulski:
# https://blog.prokulski.science/index.php/2017/10/17/ankieta-wyniki/

# my_sheets <- gs_ls() # log manually to google account
# df <- gs_read(gs_title(as.character(my_sheets[1, 1])))
# rows <- nrow(df[df$`Czy studiujesz na Wydziale Zarządzania UŁ?` == "Tak" &
#                df$`Sygnatura czasowa` > "2019-05-04 00:00:00 UTC", ])
# df <- df %>% 
#   filter(`Czy studiujesz na Wydziale Zarządzania UŁ?` == "Tak",
#                     `Sygnatura czasowa` > "2019-05-04 00:00:00 UTC") %>% 
#   mutate(id = ids::adjective_animal(rows)) %>%
#   select(-`Adres e-mail`, -`Submission ID (skip this field)`, -contains("print"))
# write_csv(df, "survey_data.csv")

### run

df <- read_csv("survey_data.csv")

# from wide to long data representation, results are:
## 3 variables: urls (search result), search order (1. - 5.), browser mode (normal/incognito), 
## obs. total == n*10, as each person has 10 urls: 5 normal mode + 5 incognito
df_long <- df %>% 
  gather(`1. na Twojej liście wyszukiwania (wklej pełny adres)`:`5. na Twojej liście wyszukiwania (wklej pełny adres)`,
         `1. na Twojej liście wyszukiwania (wklej pełny adres)_1`:`5. na Twojej liście wyszukiwania (wklej pełny adres)_1`,
         key = search_order, value = urls) %>% 
  mutate(browser_mode = ifelse(test = grepl("_1", search_order),
                               yes = "incognito",
                               no = "normal")) %>% 
  mutate(search_order_short = substr(search_order, 1, 1))

# url cleaning
url_summary <- df_long %>% 
  group_by(urls) %>% 
  summarise(count = n()) %>%
  arrange(-count)

clean_googlesearch_url <- function(googlesearch_url){
  if (grepl(pattern = "https://www.google.",
           x = as.character(googlesearch_url))) {
    stringr::str_extract(string = as.character(googlesearch_url),
                         pattern = "(?<=url=)(.*?)(?=&)")
  } else {
    return(as.character(googlesearch_url))
  }
}

url_summary$clean_googlesearch_url <- sapply(url_summary$urls, clean_googlesearch_url)
url_summary$url_first_clean <- ifelse(test = is.na(url_summary$clean_googlesearch_url),
                                     yes = url_summary$urls, 
                                     no = url_summary$clean_googlesearch_url)

url_first_clean <- url_summary %>% 
  group_by(url_first_clean) %>% 
  summarise(count = sum(count)) %>%
  arrange(-count)

# url_last_clean$count %>% sum()

# write_csv(url_first_clean, "url_first_clean.csv")


