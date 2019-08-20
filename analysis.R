library(stringdist)
library(tidyverse)

# https://journal.r-project.org/archive/2014-1/loo.pdf

df <- df %>%
  mutate(dist_osa = stringdist::stringdist(a = incognito,
                                           b = normal,
                                           method = "osa"),
         dist_dl = stringdist::stringdist(a = incognito,
                                          b = normal,
                                          method = "dl"))

summary(df$dist_osa)
summary(df$dist_dl)

table(df$dist_osa <= 1)
table(df$dist_dl <= 1)

table(df$dist_osa == 0)
table(df$dist_osa < 1)
table(df$incognito_equal_to_normal)

table(df$dist_dl == 0)
table(df$dist_dl < 1)

table(df$dist_osa)
table(df$dist_dl)
table(df$dist_dl, df$dist_osa)

df %>% 
  filter(dist_osa == 4 & dist_dl == 3) %>% 
  select(incognito, normal)

# export csv to check results in python
# pyxDamerauLevenshtein pkg used by DuckDuckGo

# df %>% 
#   select(id, incognito, normal, dist_osa, dist_dl) %>% 
#   write_csv("to_python.csv")

##### check done in .ipynb file

# The "osa" method form R package stringdist gave results equal 
# to method implemented in damerau_levenshtein_distance 
# form pyxdameraulevenshtein Python package

# export final df to later use
write_csv(df, "df_final.csv")
