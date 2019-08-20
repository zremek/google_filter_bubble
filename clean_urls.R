library(tidyverse)

### clean urls inside df_long

# use our function to extract base urls form pasted google search urls 
df_long$clean_googlesearch_url <- sapply(df_long$urls, clean_googlesearch_url)
df_long$clean_googlesearch_url <- ifelse(test = is.na(df_long$clean_googlesearch_url),
                                      yes = df_long$urls, 
                                      no = df_long$clean_googlesearch_url)

# clean AMPs https://developers.google.com/amp/
df_long$clean_amp_s_url <- ifelse(test = grepl(pattern = "google.com/amp/s|google.pl/amp/s",
                                               x = df_long$clean_googlesearch_url),
                                  yes = gsub(pattern = "www.google.com/amp/s/|www.google.pl/amp/s/",
                                             replacement = "", x = df_long$clean_googlesearch_url),
                                  no = df_long$clean_googlesearch_url)

# distinct(df_long, clean_amp_s_url) %>% 
#   arrange(clean_amp_s_url) %>% 
#   print(n = Inf)

# clean urls form android phones 
# df_long %>% select(clean_amp_s_url, id, search_order_short, browser_mode) %>% 
#   filter(grepl("-android-", clean_amp_s_url)) %>% 
#   View()

df_long %>% select(clean_amp_s_url, id, search_order_short, browser_mode) %>% 
  filter(id %in% c("idiotic_dalmatian"))
df_long %>% select(clean_amp_s_url, id, search_order_short, browser_mode) %>% 
  filter(id %in% c("topaz_caudata"))
df_long %>% select(clean_amp_s_url, id, search_order_short, browser_mode) %>% 
  filter(id %in% c("aquamarine_sambar"))
df_long %>% select(clean_amp_s_url, id, search_order_short, browser_mode) %>% 
  filter(id %in% c("semipetrified_anaconda"))

# there are four urls containing "-android-", each for one person
# we can't idetify exact search result for those urls
# thus we need to remove records with ids listed above
df_long_clean <- df_long %>% 
  filter(id != "idiotic_dalmatian" &
           id != "topaz_caudata" &
           id != "aquamarine_sambar" &
           id != "semipetrified_anaconda")

# remove characters after ".html"
df_long_clean$clean_html_url <- gsub(pattern = "\\.html(.*)", replacement = "\\.html",
                                     x = df_long_clean$clean_amp_s_url)

# change no-urls to actual urls and unify urls
distinct(df_long_clean, clean_html_url) %>%
  filter(grepl("http", clean_html_url) == FALSE) %>% 
  arrange(clean_html_url) %>% 
  print(n = Inf)

change_no_urls <- function(pattern, replacement, string){
  for (i in 1:length(string)){
    if (grepl(pattern = pattern,
              x = string[i])) {
      string[i] <- replacement
    } else {
      string[i] <- string[i]
    }
  }
  return(string)
}

df_long_clean <- df_long_clean %>%
  mutate(clean_no_url = clean_html_url,
         clean_no_url = change_no_urls("adamowicz.pl|Adamowicz pl",
                                       "http://adamowicz.pl/",
                                       clean_no_url),
         clean_no_url = change_no_urls("youtube|YouTube|UC2NkYSiMMmX4uwWelr1HS_w",
                                       "https://www.youtube.com/channel/UC2NkYSiMMmX4uwWelr1HS_w/",
                                       clean_no_url),
         clean_no_url = change_no_urls("Bialysto", "https://bialystok.onet.pl/",
                                       clean_no_url),
         clean_no_url = change_no_urls("ebook",
                                       "https://www.facebook.com/Pawel.Adamowicz/",
                                       clean_no_url),
         clean_no_url = change_no_urls("prost",
                                       "https://www.wprost.pl/tematy/10149225/pawel-adamowicz.html",
                                       clean_no_url),
         clean_no_url = change_no_urls("okfm",
                                       "http://www.tokfm.pl/Tokfm/7,103085,24865623,smierc-pawla-adamowicza-koniec-obserwacji-psychiatrycznej-stefana.amp",
                                       clean_no_url),
         clean_no_url = change_no_urls("Tró|m.troj",
                                       "https://www.trojmiasto.pl/wiadomosci/Pawel-Adamowicz-o1.html",
                                       clean_no_url),
         clean_no_url = change_no_urls("ysol",
                                       "https://tysol.pl/a33204--video-Gdansk-Przed-grobem-Pawla-Adamowicza-zmiana-warty-zolnierzy-w-pruskich-mundurach-",
                                       clean_no_url),
         clean_no_url = change_no_urls("witter.c",
                                       "https://twitter.com/adamowiczpawel", clean_no_url),
         clean_no_url = change_no_urls("tvn24.pl ",
                                       "https://www.tvn24.pl/krakow,50/zakonczyla-sie-obserwacja-psychiatryczna-zabojcy-adamowicza,942086.html",
                                       clean_no_url),
         clean_no_url = change_no_urls("ikip",
                                       "https://pl.wikipedia.org/wiki/Pawe%C5%82_Adamowicz",
                                       clean_no_url))

distinct(df_long_clean, clean_no_url) %>% arrange(clean_no_url) %>% print(n = Inf)

# top domain
df_long_clean <- df_long_clean %>% 
  mutate(url_top_domain = str_extract(string = clean_no_url, 
                                      pattern = regex("(?<=//)(.*?)(?=/)")))

### warning ###
# remove record containing http://predykator.pl/metody-badawcze.html
# it's pasted 10 times by one person, not valid google search result for P. Adamowicz

df_long_clean <- df_long_clean %>% 
  filter(grepl("http://predykator.pl/metody-badawcze.html",
               clean_no_url) == FALSE)

top_domains <- df_long_clean %>% 
  group_by(url_top_domain) %>% 
  count() %>% 
  arrange(url_top_domain) 
top_domains$letter_top_domain <- LETTERS[1:length(top_domains$url_top_domain)]
top_domains$letter_top_domain[27:30] <- c("Ł","Ó", "Ż", "Ź") # to have 30 distinct letters

df_long_clean <- left_join(x = df_long_clean,
          y = top_domains,
          by = "url_top_domain")

df_long_clean %>% select(id,
                         browser_mode,
                         search_order_short,
                         letter_top_domain,
                         clean_no_url) %>% 
  filter(id %in% c("reportable_crayfish", "bioclimatic_whapuku")) %>% 
  arrange(id, browser_mode, search_order_short)

# there are ids with the same top domain pasted multiple times for one browser mode  
# ex. "bioclimatic_whapuku"
# "reportable_crayfish" looks ok - browser_mode * search_order is distinct

## check distinct domains in a results by mode

conc_letter_top_domain <- df_long_clean %>% select(id,
                         browser_mode,
                         search_order_short,
                         letter_top_domain,
                         clean_no_url) %>% 
  arrange(id, browser_mode, search_order_short) %>% 
  group_by(id, browser_mode) %>% 
  summarise(paste = paste0(letter_top_domain, collapse = "")) %>% 
  spread(key = browser_mode, value = paste)


conc_letter_top_domain$distinct_chars_incognito <- sapply(
  conc_letter_top_domain$incognito,
  function(x) sum(!!str_count(x, top_domains$letter_top_domain)))

conc_letter_top_domain$distinct_chars_normal <- sapply(
  conc_letter_top_domain$normal,
  function(x) sum(!!str_count(x, top_domains$letter_top_domain)))

# different browser mode, the same results (domains in order)?
conc_letter_top_domain <- conc_letter_top_domain %>% 
  mutate(incognito_equal_to_normal = incognito == normal)
table(conc_letter_top_domain$incognito_equal_to_normal) # 33 TRUE

### check urls for less than 5 unique domains

df <- left_join(x = conc_letter_top_domain,
                y = df,
                by = "id")
df %>% 
  filter(distinct_chars_incognito < 5 |
           distinct_chars_normal < 5) # 27 ids

df_long_clean %>% 
  group_by(id, browser_mode) %>% 
  count(clean_no_url) %>%
  filter(n > 1) %>% 
  arrange(-n) %>% View()

ids_27 <- 
  df_long_clean %>% 
  group_by(id, browser_mode) %>% 
  count(clean_no_url) %>%
  filter(n > 1) %>% 
  group_by(id) %>%
  select(id) %>% 
  distinct() # 27 ids

ids_21 <- 
  df_long_clean %>% 
  group_by(id, browser_mode) %>% 
  count(clean_html_url) %>%
  filter(n > 1) %>% 
  group_by(id) %>%
  select(id) %>% 
  distinct() # 21 ids

### fix
df %>% filter(
  id %in% filter(ids_27, id %in% ids_21$id == FALSE))
