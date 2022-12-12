# Data from 1998 pilot study on potential costs of reproduction in Heliconia
# acuminata. Conducted at the BDFFPs Camp 41.

# load packages -----------------------------------------------------------

library(tidyverse)
library(readxl)




# load individual datafiles -----------------------------------------------

# Plant Size at T0
ha_size_aug98 <- read_xls("./data_raw/LEAF_AREAS_AUG_1998.xls", skip = 1) %>%
  rename(
    "plant_id" = "PLANT #",
    "shoots" = "SHOOTS",
    "lf_length" = "LF LGTH",
    "prop_missing" = "% MISSING"
  ) %>%
  fill(shoots, .direction = "down") %>% # fill in shoot no. for each plant
  select(
    -"...8",
    -"LF AREA",
    -"AREA MISS",
    -"TOTAL AREA"
  ) # we are going to delete the values of
# some variables which were calculated with
# formulas in excel and recalculate them here

# Correct the data type for plant id no
ha_size_aug98$plant_id <- as.factor(ha_size_aug98$plant_id)
# Plant heights
AREAS <- read_xls("./data_raw/AREAS.xls")
ht_aug98 <- AREAS %>%
  select(
    `PLANT ID#`,
    `HEIGHT-AUG 98`,
    treatment
  ) %>%
  rename(
    "plant_id" = `PLANT ID#`,
    "ht" = `HEIGHT-AUG 98`,
    "trt" = "treatment"
  )

ht_aug98$plant_id <- as.factor(ht_aug98$plant_id)
ht_aug98$trt <- as.factor(ht_aug98$trt)


# calculate area of leaves ------------------------------------------------

# change NA in prop_missing to zeros
ha_size_aug98 <- ha_size_aug98 %>%
  replace_na(list(prop_missing = 0))

# Using this regression equation
# sqrt(lf_area)=1.721+0.35*lf_length
# calculate the area of a leaf based on its length

ha_size_aug98 <- ha_size_aug98 %>%
  mutate(lf_area = ((1.721 + 0.35 * lf_length)^2))

# calculate the amount of leaf area missing
ha_size_aug98 <- ha_size_aug98 %>%
  mutate(lf_area_missing = (lf_area * prop_missing))

# calculate the corrected area of each leaf
ha_size_aug98 <- ha_size_aug98 %>%
  mutate(lf_area_corrected = (lf_area - lf_area_missing))


# calculate total plant leaf area -----------------------------------------

# summarize the total leaf area of a plant
ha_size_aug98 <- ha_size_aug98 %>%
  group_by(plant_id) %>%
  mutate(total_la = round(sum(lf_area_corrected), digits = 1)) %>%
  mutate(lvs = n()) %>%
  slice(1) %>%
  select(plant_id, shoots, total_la, lvs)

# The number of shoots for plant 79 is a typo, should be 5
ha_size_aug98$shoots <- ifelse(ha_size_aug98$plant_id == "79", 5,
  ha_size_aug98$shoots
)









# add height data to LA data ----------------------------------------------
ha_size_aug98 <- left_join(ha_size_aug98, ht_aug98) %>%
  relocate(trt, ht, shoots, lvs, .after = plant_id)
#
rm(ht_aug98)

ha_size_aug98$yr <- as.factor("1998")
ha_size_aug98$mo <- as.factor("08")

ha_size_aug98 <- ha_size_aug98 %>%
  select(
    plant_id,
    trt,
    lvs,
    shoots,
    total_la,
    ht,
    yr,
    mo
  )

summary(ha_size_aug98)


# Jan 1998 data -----------------------------------------------------------
colnames(AREAS)
ha_size_jan98 <- AREAS %>%
  select(
    "plant_id" = `PLANT ID#`,
    "trt" = treatment,
    "flrs" = "# OF FLRS 98",
    "frts_collected" = "FRUITS COLLECTED 98",
    "dev_frts" = "# OF DEV FRTS 98",
    "sds_collected" = "#seeds collected 1998",
    "total_la" = "AREA-JAN 98",
    "shoots" = "SHOOTS JAN 98",
    "ht" = "HEIGHT-JAN 98"
  )

ha_size_jan98$plant_id <- as.factor(ha_size_jan98$plant_id)
ha_size_jan98$trt <- as.factor(ha_size_jan98$trt)

ha_size_jan98$yr <- as.factor("1998")
ha_size_jan98$mo <- as.factor("01")

names(ha_size_aug98)
names(ha_size_jan98)
ha_size_data <-
  bind_rows(ha_size_jan98, ha_size_aug98) %>%
  # Change the treatment ID from numbers to useful codes
  mutate(trt = case_when(
    trt == "1" ~ "fert_pollen",
    trt == "2" ~ "pollen",
    trt == "3" ~ "fert",
    trt == "4" ~ "control",
    TRUE ~ as.character(trt)
  )) %>%
  arrange(yr, mo, dev_frts, frts_collected, sds_collected) %>%
  mutate(trt = as.factor(trt)) %>%
  mutate(sds_per_frt = sds_collected / frts_collected) %>%
  relocate(dev_frts, .before = "frts_collected") %>%
  relocate(c(shoots, ht, total_la), .after = "trt") %>%
  relocate(sds_per_frt, .after = "sds_collected") %>%
  relocate(lvs, .before = "total_la")


rm(AREAS,
   ha_size_aug98,
   ha_size_jan98
   )

# names(ha_size_data)


# add the ranges of values for each repro variable ------------------------

# 
# 
# ranges <- ha_size_data %>%
#   filter(mo == "01") %>%
#   summarize(
#     flrs = range(flrs, na.rm = TRUE),
#     frts_dev = range(dev_frts, na.rm = TRUE),
#     frts_collect = range(frts_collected, na.rm = TRUE),
#     sds_collected = range(sds_collected, na.rm = TRUE)
#   ) %>%
#   mutate(range = c("low", "high"), .before = 1) %>%
#   pivot_longer(
#     cols = "flrs":"sds_collected",
#     values_to = "value",
#     names_to = "stage"
#   ) %>%
#   pivot_wider(
#     id_cols = "stage",
#     names_from = "range"
#   ) %>%
#   mutate(range = paste(low, high, sep = "-")) %>%
#   select(-low, -high)


# summarize mean, sd, range of each repro variable for each trt -----------------------


plant_repro_summary_trt <- ha_size_data %>%
  group_by(plant_id,trt) %>%
  filter(mo == "01") %>%
  select(trt,flrs, dev_frts, frts_collected, sds_collected, sds_per_frt) %>%
  ungroup() %>%
  group_by(trt) %>% 
  summarise(across("flrs":"sds_per_frt",
    list(
      mean = mean,
      sd = sd,
      low = min,
      high = max
    ),
    na.rm = TRUE,
    .names = "{fn}_{col}"
  )) %>%
  pivot_longer(
    cols = starts_with("mean_"),
    names_to = "stage",
    names_prefix = "mean_",
    values_to = "mean",
    values_drop_na = FALSE
  ) %>%
  pivot_longer(
    cols = starts_with("sd_"),
    names_to = "stagesd",
    names_prefix = "sd_",
    values_to = "sd",
    values_drop_na = FALSE
  ) %>%
  unite("range_flrs", low_flrs, high_flrs, sep = "-") %>%
  unite("range_dev_frts", low_dev_frts, high_dev_frts, sep = "-") %>%
  unite("range_frts_collected", low_frts_collected, high_frts_collected, sep = "-") %>%
  unite("range_sds_collected", low_sds_collected, high_sds_collected, sep = "-") %>%
  unite("range_sds_per_frt", low_sds_per_frt, high_sds_per_frt, sep = "-") %>%
  pivot_longer(
    cols = starts_with("range_"),
    names_to = "stagerange",
    names_prefix = "range_",
    values_to = "range",
    values_drop_na = FALSE
  ) %>%
  filter((stage == stagesd) == TRUE) %>%
  filter((stage == stagerange) == TRUE) %>%
  select(trt,stage, mean, sd, range)

plant_repro_summary_trt


# add sample size for each reprod variable --------------------------------




n_plants_flrs <- ha_size_data %>%
  filter(mo == "01") %>%
  filter(!is.na(flrs)) %>%
  group_by(trt) %>% 
  summarize(n = n_distinct(plant_id))
n_plants_flrs <- n_plants_flrs %>%
  mutate(stage = "flrs")

n_plants_frts_dev <- ha_size_data %>%
  filter(mo == "01") %>%
  filter(!is.na(dev_frts)) %>%
  group_by(trt) %>% 
  summarize(n = n_distinct(plant_id))
n_plants_frts_dev <- n_plants_frts_dev %>%
  mutate(stage = "dev_frts")

n_plants_frts_coll <- ha_size_data %>%
  filter(mo == "01") %>%
  filter(!is.na(frts_collected)) %>%
  group_by(trt) %>% 
  summarize(n = n_distinct(plant_id))
n_plants_frts_coll <- n_plants_frts_coll %>%
  mutate(stage = "frts_collected")

n_plants_sds <- ha_size_data %>%
  filter(mo == "01") %>%
  filter(!is.na(sds_collected)) %>%
  group_by(trt) %>% 
  summarize(n = n_distinct(plant_id))
n_plants_sds <- n_plants_sds %>%
  mutate(stage = "sds_collected")

n_plants_sds_per_frt <- ha_size_data %>%
  filter(mo == "01") %>%
  filter(!is.na(sds_per_frt)) %>%
  group_by(trt) %>% 
  summarize(n = n_distinct(plant_id))
n_plants_sds_per_frt <- n_plants_sds_per_frt %>%
  mutate(stage = "sds_per_frt")

n_plants_stages <- bind_rows(
  n_plants_flrs,
  n_plants_frts_dev,
  n_plants_frts_coll,
  n_plants_sds,
  n_plants_sds_per_frt
)


plant_repro_summary_trt <- plant_repro_summary_trt %>%
  left_join(n_plants_stages)
plant_repro_summary_trt


rm(n_plants_flrs,
   n_plants_frts_dev,
   n_plants_frts_coll,
   n_plants_sds,
   n_plants_sds_per_frt,
   n_plants_stages
)





#  summary all trts combined ----------------------------------------------




plant_repro_summary_overall <- ha_size_data %>%
  group_by(plant_id) %>%
  filter(mo == "01") %>%
  select(flrs, dev_frts, frts_collected, sds_collected, sds_per_frt) %>%
  ungroup() %>%
  summarise(across("flrs":"sds_per_frt",
                   list(
                     mean = mean,
                     sd = sd,
                     low = min,
                     high = max
                   ),
                   na.rm = TRUE,
                   .names = "{fn}_{col}"
  )) %>%
  pivot_longer(
    cols = starts_with("mean_"),
    names_to = "stage",
    names_prefix = "mean_",
    values_to = "mean",
    values_drop_na = FALSE
  ) %>%
  pivot_longer(
    cols = starts_with("sd_"),
    names_to = "stagesd",
    names_prefix = "sd_",
    values_to = "sd",
    values_drop_na = FALSE
  ) %>%
  unite("range_flrs", low_flrs, high_flrs, sep = "-") %>%
  unite("range_dev_frts", low_dev_frts, high_dev_frts, sep = "-") %>%
  unite("range_frts_collected", low_frts_collected, high_frts_collected, sep = "-") %>%
  unite("range_sds_collected", low_sds_collected, high_sds_collected, sep = "-") %>%
  unite("range_sds_per_frt", low_sds_per_frt, high_sds_per_frt, sep = "-") %>%
  pivot_longer(
    cols = starts_with("range_"),
    names_to = "stagerange",
    names_prefix = "range_",
    values_to = "range",
    values_drop_na = FALSE
  ) %>%
  filter((stage == stagesd) == TRUE) %>%
  filter((stage == stagerange) == TRUE) %>%
  select(stage, mean, sd, range)

plant_repro_summary_overall


# add sample size for each reprod variable --------------------------------




n_plants_flrs <- ha_size_data %>%
  filter(mo == "01") %>%
  filter(!is.na(flrs)) %>%
  summarize(n = n_distinct(plant_id))
n_plants_flrs <- n_plants_flrs %>%
  mutate(stage = "flrs")

n_plants_frts_dev <- ha_size_data %>%
  filter(mo == "01") %>%
  filter(!is.na(dev_frts)) %>%
  summarize(n = n_distinct(plant_id))
n_plants_frts_dev <- n_plants_frts_dev %>%
  mutate(stage = "dev_frts")

n_plants_frts_coll <- ha_size_data %>%
  filter(mo == "01") %>%
  filter(!is.na(frts_collected)) %>%
  summarize(n = n_distinct(plant_id))
n_plants_frts_coll <- n_plants_frts_coll %>%
  mutate(stage = "frts_collected")

n_plants_sds <- ha_size_data %>%
  filter(mo == "01") %>%
  filter(!is.na(sds_collected)) %>%
  summarize(n = n_distinct(plant_id))
n_plants_sds <- n_plants_sds %>%
  mutate(stage = "sds_collected")

n_plants_sds_per_frt <- ha_size_data %>%
  filter(mo == "01") %>%
  filter(!is.na(sds_per_frt)) %>%
  summarize(n = n_distinct(plant_id))
n_plants_sds_per_frt <- n_plants_sds_per_frt %>%
  mutate(stage = "sds_per_frt")

n_plants_stages <- bind_rows(
  n_plants_flrs,
  n_plants_frts_dev,
  n_plants_frts_coll,
  n_plants_sds,
  n_plants_sds_per_frt
)


plant_repro_summary_overall <- plant_repro_summary_overall %>%
  left_join(n_plants_stages)
plant_repro_summary_overall


rm(n_plants_flrs,
   n_plants_frts_dev,
   n_plants_frts_coll,
   n_plants_sds,
   n_plants_sds_per_frt,
   n_plants_stages
)




# histograms of each repro variable ---------------------------------------


hist(ha_size_data$flrs)
hist(ha_size_data$dev_frts)
hist(ha_size_data$frts_collected)
hist(ha_size_data$sds_collected)
hist(ha_size_data$sds_per_frt)

# save as a CSV file ------------------------------------------------------
write_csv(ha_size_data, "./data_clean/ha_size_data_1998_cor.csv")
write_csv(plant_repro_summary_trt, "./data_clean/plant_repro_summary_trt.csv")
write_csv(plant_repro_summary_overall, "./data_clean/plant_repro_summary_overall.csv")

# TODO: need to do the following

# 108 missing in Jan
# what is difference btween seeds collected and sds?
# need to change the jan data to the import leaf-level data and add it up,
# i.e., enter the original data from notebooks
