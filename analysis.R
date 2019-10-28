library(stringdist)
library(tidyverse)
library(irr)
library(combinat)
library(DescTools)

# https://journal.r-project.org/archive/2014-1/loo.pdf

df <- df %>%
  mutate(dist_osa = stringdist::stringdist(a = incognito,
                                           b = normal,
                                           method = "osa"),
         dist_dl = stringdist::stringdist(a = incognito,
                                          b = normal,
                                          method = "dl"))

# check for permutations

is_x_permutation_of_y <- function(x, y) {
  tmp <- combinat::permn(unlist(strsplit(y, "")))
  x %in% lapply(tmp, function(z) paste(z, collapse = ""))  
}

df$is_incognito_permutation_of_normal <- NA

for (i in 1:dim(df)[1]) {
  df$is_incognito_permutation_of_normal[i] <- 
    is_x_permutation_of_y(df$incognito[i], df$normal[i])
}

# a <- NA
# for (i in 1:dim(df)[1]) {
#   a[i] <- is_x_permutation_of_y(df$normal[i], df$incognito[i])
# }
# 
# table(df$is_incognito_permutation_of_normal == a) # it's symetrical as it should be
# table(a)

## visual check
# ggplot(df) +
#   geom_bar(aes(x = dist_osa, fill = is_incognito_permutation_of_normal))
# 
# df %>% filter(dist_osa > 0) %>% 
#   select(incognito, normal, dist_osa, is_incognito_permutation_of_normal) %>% 
#   View()

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

### tests

# kruskal.test(dist_osa ~ `Do eksperymentu trzeba przygotować aparaturę. Czy potrafisz włączyć tryb prywatny (incognito) w swojej przeglądarce internetowej?`,
#              data = df)
# kruskal.test(dist_osa ~ `Rodzaj studiów`, data = df)
# kruskal.test(dist_osa ~ `Twoja płeć`, data = df)
# kruskal.test(dist_osa ~ `Rodzaj studiów`, data = df)
# kruskal.test(dist_osa ~ `Twój rok urodzenia`, data = df)
# # all not significant
# 
# 

#### compute indexes


## conservative -- liberal as 'światopogląd' (worldview) https://cbos.pl/SPISKOM.POL/2015/K_085_15.PDF 
# 2nd question has reversed wording (use "8 -" shortcut)
# cons_lib_index higher == more conservative

cor(df[,20:22]) %>% View()
df$cons_lib_index <- df[[20]] + (8 - df[[21]]) + df[[22]]
  

## Internet users' information privacy concerns: 'control' https://pubsonline.informs.org/doi/abs/10.1287/isre.1040.0032
# 3rd has reversed wording
# privacy_index higher == higher control

cor(df[,27:29]) %>% View()
df$privacy_index <- df[[27]] + df[[28]] + (8 - df[[29]])


ggplot(df) +
  geom_point(aes(x = cons_lib_index, y = privacy_index, 
                 colour = ordered(dist_osa)),
             size = 7, position = 'jitter', alpha = 3/4)


ggplot(df %>% filter(dist_osa > 0)) +
  geom_point(aes(x = cons_lib_index, y = privacy_index, 
                 colour = ordered(dist_osa), shape = is_incognito_permutation_of_normal),
             size = 7, position = 'jitter', alpha = 3/4)

summary(df$cons_lib_index)
summary(df$privacy_index)

DescTools::JonckheereTerpstraTest(x = df$cons_lib_index,
                                  g = ordered(df$dist_osa),
                                  alternative = c("decreasing"))

DescTools::JonckheereTerpstraTest(x = df$privacy_index,
                                  g = ordered(df$dist_osa),
                                  alternative = "increasing")

DescTools::JonckheereTerpstraTest(x = df$cons_lib_index,
                                  g = ordered(df$dist_osa),
                                  alternative = c("two.sided"))

DescTools::JonckheereTerpstraTest(x = df$privacy_index,
                                  g = ordered(df$dist_osa),
                                  alternative = "two.sided",
                                  nperm = 10000)

lm(formula = is_incognito_permutation_of_normal ~ privacy_index + cons_lib_index + `Rodzaj studiów` +
     `Twój rok urodzenia` + `Twoja płeć`,
   data = df) %>% summary()

plot(df[[22]], df$dist_osa)

DescTools::JonckheereTerpstraTest(x = df$`Konkordat:`,
                                  g = ordered(df$dist_osa),
                                  alternative = c("two.sided"))
DescTools::JonckheereTerpstraTest(x = df$`Przerywanie ciąży:`,
                                  g = ordered(df$dist_osa),
                                  alternative = c("two.sided"))
DescTools::JonckheereTerpstraTest(x = df$`Związki osób tej samej płci:`,
                                  g = ordered(df$dist_osa),
                                  alternative = c("two.sided"))

DescTools::JonckheereTerpstraTest(x = df[[27]],
                                  g = ordered(df$dist_osa),
                                  alternative = c("two.sided"))
DescTools::JonckheereTerpstraTest(x = df[[28]],
                                  g = ordered(df$dist_osa),
                                  alternative = c("two.sided"))
DescTools::JonckheereTerpstraTest(x = df[[29]],
                                  g = ordered(df$dist_osa),
                                  alternative = c("two.sided"))

DescTools::JonckheereTerpstraTest(x = df$`Konkordat:`,
                                  g = ordered(df$dist_osa),
                                  alternative = c("decreasing"))
DescTools::JonckheereTerpstraTest(x = df$`Przerywanie ciąży:`,
                                  g = ordered(df$dist_osa),
                                  alternative = c("decreasing"))
DescTools::JonckheereTerpstraTest(x = df$`Związki osób tej samej płci:`,
                                  g = ordered(df$dist_osa),
                                  alternative = c("decreasing"))

DescTools::JonckheereTerpstraTest(x = df[[27]],
                                  g = ordered(df$dist_osa),
                                  alternative = c("decreasing"))
DescTools::JonckheereTerpstraTest(x = df[[28]],
                                  g = ordered(df$dist_osa),
                                  alternative = c("decreasing"))
DescTools::JonckheereTerpstraTest(x = df[[29]],
                                  g = ordered(df$dist_osa),
                                  alternative = c("decreasing"))

ggplot(df) + geom_jitter(aes(x = `Przerywanie ciąży:`, y = dist_osa))
