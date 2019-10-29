df_md %>% gather(incognito, normal, key = "browser_mode", value = "search_res") %>% 
  group_by(search_res, browser_mode) %>% count() %>% 
  filter(browser_mode == "normal") %>% dim()

df_md %>% gather(incognito, normal, key = "browser_mode", value = "search_res") %>% 
  group_by(search_res, browser_mode) %>% count() %>% 
  filter(browser_mode == "incognito") %>% dim()

df_md %>% gather(incognito, normal, key = "browser_mode", value = "search_res") %>% 
  group_by(search_res) %>% count() %>% 
  dim()
