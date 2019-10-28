library(stringdist)
library(tidyverse)
library(irr)

# https://journal.r-project.org/archive/2014-1/loo.pdf

df <- df %>%
  mutate(dist_osa = stringdist::stringdist(a = incognito,
                                           b = normal,
                                           method = "osa"),
         dist_dl = stringdist::stringdist(a = incognito,
                                          b = normal,
                                          method = "dl"),
         dist_substitution_only = stringdist::stringdist(a = incognito,
                                                         b = normal,
                                                         method = "hamming")) # fix it

df %>% filter(dist_substitution_only > dist_osa) %>% 
  select(dist_osa, dist_substitution_only, incognito, normal)
         # ,
         # dist_transposition_only = stringdist::stringdist(a = incognito,
         #                                                  b = normal,
         #                                                  method = "osa",
         #                                                  weight = c(0.1,0.1,0.1,1)))

# summary(df$dist_osa)
# summary(df$dist_dl)
# 
# table(df$dist_osa <= 1)
# table(df$dist_dl <= 1)
# 
# table(df$dist_osa == 0)
# table(df$dist_osa < 1)
# table(df$incognito_equal_to_normal)
# 
# table(df$dist_dl == 0)
# table(df$dist_dl < 1)
# 
# table(df$dist_osa)
# table(df$dist_dl)
# table(df$dist_dl, df$dist_osa)
# 
# df %>% 
#   filter(dist_osa == 4 & dist_dl == 3) %>% 
#   select(incognito, normal)

# export csv to check results in python
# pyxDamerauLevenshtein pkg used by DuckDuckGo

# df %>% 
#   select(id, incognito, normal, dist_osa, dist_dl) %>% 
#   write_csv("to_python.csv")

##### check done in .ipynb file

# The "osa" method form R package stringdist gave results equal 
# to method implemented in damerau_levenshtein_distance 
# form pyxdameraulevenshtein Python package

## export final df to later use
# write_csv(df, "df_final.csv")

# write_csv((df_long_clean %>%
#   filter(id %in% df$id)),
#   "df_long_final.csv")

# kruskal.test(dist_osa ~ `Do eksperymentu trzeba przygotować aparaturę. Czy potrafisz włączyć tryb prywatny (incognito) w swojej przeglądarce internetowej?`,
#              data = df)
# kruskal.test(dist_osa ~ `Rodzaj studiów`, data = df)
# kruskal.test(dist_osa ~ `Twoja płeć`, data = df)
# kruskal.test(dist_osa ~ `Rodzaj studiów`, data = df)
# kruskal.test(dist_osa ~ `Twój rok urodzenia`, data = df)
# # all not significant
# 
# 

#### normal vs incognito as paired nominal vs nominal problem

ggplot(filter(df, dist_osa > 0)) + 
  geom_bar(aes(x = normal, fill = incognito), 
           position = "dodge") +
  coord_flip()

ggplot(df) + 
  geom_bar(aes(x = normal, fill = incognito), 
           position = "fill") +
  coord_flip()

irr::bhapkar(sapply(df[,2:3], as.factor))

as.factor(df[,2:3])

x <- tibble(a = LETTERS, b = LETTERS)
x$b[2] <- "A"
bhapkar(x)


df_dist_osa_greater_than_zero <- filter(df, dist_osa > 0)
table(df_dist_osa_greater_than_zero$normal, df_dist_osa_greater_than_zero$incognito)
