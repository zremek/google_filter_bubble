library(tidyverse)
library(stringdist)

df = read_csv("df_final.csv")

df_normal <- t(combn(df$normal, 2))
colnames(df_normal) <- c("i", "ii")

df_normal <- as_tibble(df_normal)


df_normal <- df_normal %>%
  mutate(dist_osa = stringdist::stringdist(a = i,
                                           b = ii,
                                           method = "osa"))

summary(df_normal$dist_osa)         


df_incognito <- t(combn(df$incognito, 2))
colnames(df_incognito) <- c("i", "ii")

df_incognito <- as_tibble(df_incognito)


df_incognito <- df_incognito %>%
  mutate(dist_osa = stringdist::stringdist(a = i,
                                           b = ii,
                                           method = "osa"))

summary(df_incognito$dist_osa)

qplot(x = dist_osa, data = df_normal, 
      geom = "bar", xlab = "osa: normal between users")

qplot(x = dist_osa, data = df_incognito, 
      geom = "bar", xlab = "osa: private between users")

qplot(x = dist_osa, data = df, 
      geom = "bar", xlab = "private vs normal - same user")
