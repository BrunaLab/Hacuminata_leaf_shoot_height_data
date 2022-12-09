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
  relocate(trt,ht,shoots,lvs,.after=plant_id)
# 
rm(ht_aug98)

ha_size_aug98$yr<-as.factor("1998")
ha_size_aug98$mo<-as.factor("08")

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

ha_size_jan98$yr<-as.factor("1998")
ha_size_jan98$mo<-as.factor("01")

names(ha_size_aug98)
names(ha_size_jan98)
ha_size_data <- 
  bind_rows(ha_size_jan98, ha_size_aug98) %>% 
    # Change the treatment ID from numbers to useful codes
    mutate(trt=case_when( 
    trt == "1" ~ "fert_pollen",
    trt == "2" ~ "pollen",
    trt == "3" ~ "fert",
    trt == "4" ~ "control",
    TRUE ~ as.character(trt))
    ) %>% 
  arrange(plant_id,yr,mo) %>% 
  mutate(trt=as.factor(trt))
  

# replace NA in frts and seeds with zero ----------------------------------

ha_size_data <- replace_na(
  ha_size_data,
  list(frts_collected = 0, sds_collected = 0)
)


# quick visualizations ----------------------------------------------------

hist(ha_size_data$flrs)



plant_repro_summary<-ha_size_data %>% 
  group_by(plant_id) %>% 
  filter(mo=="01") %>% 
  select(flrs, dev_frts,frts_collected,sds_collected) %>% 
  ungroup() %>% 
  summarize(
    mean_flrs=mean(flrs, na.rm=TRUE),
    mean_frts_dev=mean(dev_frts, na.rm=TRUE),
    mean_frts_collect=mean(frts_collected, na.rm=TRUE),
    mean_sds=mean(sds_collected, na.rm=TRUE),
    sd_flrs=sd(flrs, na.rm=TRUE),
    sd_frts_dev=mean(dev_frts, na.rm=TRUE),
    sd_frts_collect=sd(frts_collected, na.rm=TRUE),
    sd_sds=sd(sds_collected, na.rm=TRUE)
            ) %>% 
  pivot_longer(
    cols = starts_with("mean"),
    values_to = 'mean',
    names_prefix = "mean_",
    names_to= 'stage') 
plant_repro_summary
#TODO: there has to be a tidy way to do this
plant_repro_summary$sd<-NA
plant_repro_summary$sd[1]<-plant_repro_summary$sd_flrs[1]
plant_repro_summary$sd[2]<-plant_repro_summary$sd_frts_dev[1]
plant_repro_summary$sd[3]<-plant_repro_summary$sd_frts_collect[1]
plant_repro_summary$sd[4]<-plant_repro_summary$sd_sds[1]


plant_repro_summary
plant_repro_summary <-plant_repro_summary %>% 
  select(stage,mean,sd)


ranges<-ha_size_data %>% 
  filter(mo=="01") %>%  
  summarize(range_flrs=range(flrs, na.rm=TRUE),
            range_dev_frts=range(dev_frts, na.rm=TRUE),
            range_frts_collected=range(frts_collected, na.rm=TRUE),
            summarize(range_sds=range(sds_collected, na.rm=TRUE))
            )

  

plant_repro_summary


hist(ha_size_data$frts_collected)
hist(ha_size_data$sds_collected)


# save as a CSV file ------------------------------------------------------
write_csv(ha_size_data, "./data_clean/ha_size_data_1998_cor.csv")

# TODO: need to do the following

# 108 missing in Jan
# what is difference btween seeds collected and sds?
# need to change the jan data to the import leaf-level data and add it up,
# i.e., enter the original data from notebooks
