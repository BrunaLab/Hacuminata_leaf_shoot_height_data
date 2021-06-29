



# load packages -----------------------------------------------------------

library(tidyverse)
library(readxl)


# load individual datafiles -----------------------------------------------

# Plant Size at T0
ha_size_aug98<-read_xls("./data_raw/LEAF_AREAS_AUG_1998.xls",skip = 1)

# Correct column names, fill in the number of shoots for each plant
ha_size_aug98<-ha_size_aug98 %>% 
  rename("plant_id" = "PLANT #",
         "shoots_aug" = "SHOOTS",
         "lf_length_aug" = "LF LGTH",
         "prop_missing_aug" = "% MISSING") %>% 
  fill(shoots_aug,.direction="down") %>% 
  select(-"...8",
         -"LF AREA",
         -"AREA MISS",
         -"TOTAL AREA")                 # we are going to delete the values of 
                                  # some variables which were calculated with 
                                  # formulas in excel and recalc them here
  




# Correct the data type for plant id no
ha_size_aug98$plant_id <- as.factor(ha_size_aug98$plant_id)

# change NA in prop_missing to zeros
ha_size_aug98<-ha_size_aug98 %>% 
  replace_na(list(prop_missing_aug=0))


# Using this regression equation
# sqrt(lf_area)=1.721+0.35*lf_length

# calculate the area of a leaf based on its length
ha_size_aug98<-ha_size_aug98 %>% 
  mutate(lf_area_aug=((1.721+0.35*lf_length_aug)^2))

# calculate the amount of leaf area missing
ha_size_aug98<-ha_size_aug98 %>% 
  mutate(lf_area_missing_aug=(lf_area_aug*prop_missing_aug))

# calculate the corrected area of each leaf 

ha_size_aug98<-ha_size_aug98 %>% 
  mutate(lf_area_corrected_aug=(lf_area_aug-lf_area_missing_aug))

# summarize the total leaf area of a plant

ha_size_aug98<-ha_size_aug98 %>% 
  group_by(plant_id) %>% 
  mutate(total_la_aug=round(sum(lf_area_corrected_aug),digits=1)) %>% 
  mutate(lvs_aug=n()) %>% 
  slice(1) %>% 
  select(plant_id,shoots_aug,total_la_aug,lvs_aug)

# The number of shoots for plant 79 is a typo, should be 5
ha_size_aug98$shoots_aug <- ifelse(ha_size_aug98$plant_id=="79", 5, ha_size_aug98$shoots_aug)



# height is in a different file
AREAS<-read_xls("./data_raw/AREAS.xls")
ht_aug98<-AREAS %>% 
  select(`PLANT ID#`,
         `HEIGHT-AUG 98`,
         treatment) %>% 
  rename("plant_id"=`PLANT ID#`,
         "ht_aug"=`HEIGHT-AUG 98`,
         "trt"="treatment")

ht_aug98$plant_id <- as.factor(ht_aug98$plant_id)
ht_aug98$trt <- as.factor(ht_aug98$trt)

ha_size_aug98<-left_join(ha_size_aug98,ht_aug98)

rm(ht_aug98)

# ha_size_aug98$yr<-as.factor("1998")
# ha_size_aug98$mo<-as.factor("08")

ha_size_aug98<-ha_size_aug98 %>% 
  select(plant_id,
         trt,
         lvs,
         shoots,
         total_la,
         ht,
         yr,
         mo)

summary(ha_size_aug98)


# Jan 1998 data -----------------------------------------------------------


colnames(AREAS)
ha_size_jan98<-AREAS %>% 
  select("plant_id"=`PLANT ID#`,
         "trt"= treatment,
         "sds"="SEEDS COLLECTED 98",
         "flrs"="# OF FLRS 98",
         "frts_collected"="FRUITS COLLECTED 98",
         "dev_frts"="# OF DEV FRTS 98",
         "sds_collected"="#seeds collected 1998",
         "total_la_jan"="AREA-JAN 98",
         "shoots_jan"="SHOOTS JAN 98",
         "ht_jan"="HEIGHT-JAN 98") 

ha_size_jan98$plant_id <- as.factor(ha_size_jan98$plant_id)
ha_size_jan98$trt <- as.factor(ha_size_jan98$trt)

# ha_size_jan98$yr<-as.factor("1998")
# ha_size_jan98$mo<-as.factor("01")

ha_size_data<-full_join(ha_size_jan98,ha_size_aug98)

# Change the treatment ID from numbers to useful codes
ha_size_data$trt<-as.character(ha_size_data$trt)
ha_size_data$trt<-gsub("1","fert_pollen",ha_size_data$trt)
ha_size_data$trt<-gsub("2","pollen",ha_size_data$trt)
ha_size_data$trt<-gsub("3","fert",ha_size_data$trt)
ha_size_data$trt<-gsub("4","control",ha_size_data$trt)
ha_size_data$trt<-as.factor(ha_size_data$trt)

#TODO: need to do the following

# 108 missing in Jan
# what is difference btween seeds collected and sds?
# need to change the jan data to the import leaf-level data and add it up

write_csv(ha_size_data,"./data_clean/ha_size_data_1998_cor.csv")