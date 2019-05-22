# install.packages("deducorrect")
library(deducorrect)
library(tidyverse)

# quick look
df <- read_csv(file = "surv_20190513.csv")
summary(df)
table(df$`Czy studiujesz na Wydziale Zarządzania UŁ?`)
df <- df %>% filter(`Czy studiujesz na Wydziale Zarządzania UŁ?` == "Tak",
                    `Sygnatura czasowa` > "2019-02-28 00:00:00 UTC")
df$`1. na Twojej liście wyszukiwania (wklej pełny adres)` %>% 
  as.factor() %>% summary()

# from wide to long data representation, results are:
## 3 variables: url (search result), search order (1. - 5.), browser mode (normal/incognito), 
## obs. total == n*10, as each person has 10 urls: 5 normal mode + 5 incognito
df_long <- df %>% 
  gather(`1. na Twojej liście wyszukiwania (wklej pełny adres)`:`5. na Twojej liście wyszukiwania (wklej pełny adres)`,
         `1. na Twojej liście wyszukiwania (wklej pełny adres)_1`:`5. na Twojej liście wyszukiwania (wklej pełny adres)_1`,
         key = search_order, value = url) %>% 
  mutate(browser_mode = ifelse(test = grepl("_1", search_order),
                               yes = "incognito",
                               no = "normal")) %>% 
  mutate(search_order_short = substr(search_order, 1, 1))

# url cleaning
url_summary <- df_long %>% group_by(url) %>% 
  summarise(count = n()) %>% arrange(-count)
