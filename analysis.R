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

# cor(df[,20:22]) %>% View()
df$cons_lib_index <- df[[20]] + (8 - df[[21]]) + df[[22]]
  

## Internet users' information privacy concerns: 'control' https://pubsonline.informs.org/doi/abs/10.1287/isre.1040.0032
# 3rd has reversed wording
# privacy_index higher == higher control

# cor(df[,27:29]) %>% View()
df$privacy_index <- df[[27]] + df[[28]] + (8 - df[[29]])


ggplot(df) +
  geom_point(aes(x = cons_lib_index, y = privacy_index, 
                 colour = ordered(dist_osa)),
             size = 7, position = 'jitter', alpha = 3/4)


ggplot(df %>% filter(dist_osa > -1)) +
  geom_point(aes(x = cons_lib_index, y = privacy_index, 
                 colour = ordered(dist_osa), 
                 shape = is_incognito_permutation_of_normal),
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

# plot(df[[22]], df$dist_osa)

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

kruskal.test(cons_lib_index ~ dist_osa, data = df)
kruskal.test(privacy_index ~ dist_osa, data = df)

ggplot(df, aes(x = cons_lib_index, y = dist_osa)) + geom_point() +
  geom_smooth()

ggplot(df, aes(x = privacy_index, y = dist_osa)) + geom_point() +
  geom_smooth()

ggplot(df, aes(x = ordered(dist_osa), y = privacy_index)) + geom_boxplot() + geom_point()
ggplot(df, aes(x = ordered(dist_osa), y = cons_lib_index)) + geom_boxplot() + geom_point()

ggplot(df, aes(x = is_incognito_permutation_of_normal, y = cons_lib_index)) + geom_boxplot() + geom_point()
ggplot(df, aes(x = is_incognito_permutation_of_normal, y = privacy_index)) + geom_boxplot() + geom_point()

ggplot(df, aes(fill = is_incognito_permutation_of_normal, x = privacy_index)) + geom_bar()
ggplot(df, aes(fill = is_incognito_permutation_of_normal, x = cons_lib_index)) + geom_bar()

kruskal.test(privacy_index ~ is_incognito_permutation_of_normal, df)
kruskal.test(cons_lib_index ~ is_incognito_permutation_of_normal, df)

lm(dist_osa ~ privacy_index, df) %>% summary()
lm(privacy_index ~ dist_osa, df) %>% summary()
lm(privacy_index ~ cons_lib_index, df) %>% summary()

glm(is_incognito_permutation_of_normal ~ 
      cons_lib_index + privacy_index + `Rodzaj studiów` + 
      `Do eksperymentu trzeba przygotować aparaturę. Czy potrafisz włączyć tryb prywatny (incognito) w swojej przeglądarce internetowej?`,
    family=binomial(link = 'logit'), data = df) %>% summary()

ggplot(df, aes(x = is_incognito_permutation_of_normal,
               fill = `Rodzaj studiów`)) + geom_bar( position = "fill")

chisq.test(df$is_incognito_permutation_of_normal,
           df$`Rodzaj studiów`,
           correct = FALSE)


wilcox.test(privacy_index ~ is_incognito_permutation_of_normal, 
            data = df, paired=FALSE, exact=FALSE, conf.int=TRUE)

wilcox.test(cons_lib_index ~ is_incognito_permutation_of_normal, 
            data = df, paired=FALSE, exact=FALSE, conf.int=TRUE)

wilcox.test(dist_osa ~ is_incognito_permutation_of_normal, 
            data = df, paired=FALSE, exact=FALSE, conf.int=TRUE)

ggplot(df, aes(x = is_incognito_permutation_of_normal, y = dist_osa)) + geom_boxplot() + geom_point()

table(df$dist_osa, df$is_incognito_permutation_of_normal)
table(df$`Twój rok urodzenia`, df$is_incognito_permutation_of_normal)

## new feature: normal_count
normal_count <- df %>% group_by(normal) %>% count() %>% rename(normal_count = "n")
df <- left_join(x = df, y = normal_count, by = 'normal')

ggplot(df, aes(x = normal_count, y = dist_osa)) + geom_point()
ggplot(df, aes(x = normal_count)) + geom_bar(aes(fill = ordered(dist_osa)))
ggplot(df, aes(x = normal_count > 1)) + geom_bar(aes(fill = ordered(dist_osa)))
       
wilcox.test(dist_osa ~ normal_count > 2, 
            data = df, paired=FALSE, exact=FALSE, conf.int=TRUE)

ggplot(df, aes(x = normal_count > 1)) + geom_bar(aes(fill = is_incognito_permutation_of_normal))

chisq.test(df$is_incognito_permutation_of_normal,
           df$normal_count > 1,
           correct = FALSE)

chisq.test(df$dist_osa > 1,
           df$normal_count > 2,
           correct = FALSE)

table(df$dist_osa > 1, df$normal_count > 2)

ggplot(df, aes(x = normal_count)) + geom_bar(aes(fill = is_incognito_permutation_of_normal))

ggplot(df) + geom_bar(aes(x = dist_osa, fill = normal_count > 2))
ggplot(df, aes(x = normal_count > 2, y = dist_osa)) + geom_dotplot(binaxis = "y", stackdir = "center")
ggplot(df) + geom_bar(aes(x = normal_count > 2, fill = ordered(dist_osa)))

w <- wilcox.test(dist_osa ~ normal_count > 2, 
            data = df, paired=FALSE, exact=FALSE, conf.int=TRUE)
print(w)

# Field, A., Miles, J., & Field, Z. (2012). 
# Discovering Statistics Using R. SAGE Publications Ltd. pg. 665

rFromWilcox<-function(wilcoxModel, N){
  z<- qnorm(wilcoxModel$p.value/2)
  r<- z/ sqrt(N)
  cat(wilcoxModel$data.name, 'Effect Size, r = ', r)
}

rFromWilcox(w, dim(df)[1])

wilcox.test(cons_lib_index ~ normal_count > 2, 
            data = df, paired=FALSE, exact=FALSE, conf.int=TRUE)

ggplot(df, aes(x = normal_count > 2, y = dist_osa)) + 
  geom_boxplot() +
  geom_dotplot(binaxis = "y", stackdir = "center")

## new feature: incognito_count

incognito_count <- df %>% group_by(incognito) %>% count() %>% rename(incognito_count = "n")
df <- left_join(x = df, y = incognito_count, by = 'incognito')

ggplot(df) + geom_bar(aes(x = ordered(normal_count), fill = ordered(incognito_count)))
ggplot(df) + geom_bar(aes(x = ordered(normal_count > 2), fill = ordered(incognito_count)))
ggplot(df) + geom_count(aes(x = normal_count, y = incognito_count))

lm(normal_count ~ incognito_count, data = df) %>% summary()
cor.test(df$normal_count, df$incognito_count, method = "spearman")

## export final df to later use
# write_csv(df, "df_final.csv")
# 
# write_csv((df_long_clean %>%
#              filter(id %in% df$id)),
#           "df_long_final.csv")
