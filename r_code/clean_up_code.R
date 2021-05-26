



# load packages -----------------------------------------------------------

library(tidyverse)
library(readxl)


# load individual datafiles -----------------------------------------------

# Plant Size at T0
ha_size<-read_xls("./data_raw/LEAF AREAS AUG 1998.xls",skip = 1)

# Correct column names, fill in the number of shoots for each plant
ha_size<-ha_size %>% 
  rename("plant_id" = "PLANT #",
         "shoots" = "SHOOTS",
         "lf_length" = "LF LGTH",
         "prop_missing" = "% MISSING") %>% 
  fill(shoots,.direction="down") %>% 
  select(-"...8",
         -"LF AREA",
         -"AREA MISS",
         -"TOTAL AREA")                 # we are going to delete the values of 
                                  # some variables which were calculated with 
                                  # formulas in excel and recalc them here
  




# Correct the data type for plant id no
ha_size$plant_id <- as.factor(ha_size$plant_id)

# change NA in prop_missing to zeros
ha_size<-ha_size %>% 
  replace_na(list(prop_missing=0))


# Using this regression equation
# sqrt(lf_area)=1.721+0.35*lf_length

# calculate the area of a leaf based on its length
ha_size<-ha_size %>% 
  mutate(lf_area=((1.721+0.35*lf_length)^2))

# calculate the amount of leaf area missing
ha_size<-ha_size %>% 
  mutate(lf_area_missing=(lf_area*prop_missing))

# calculate the corrected area of each leaf 

ha_size<-ha_size %>% 
  mutate(lf_area_corrected=(lf_area-lf_area_missing))

# summarize the total leaf area of a plant

ha_size<-ha_size %>% 
  group_by(plant_id) %>% 
  mutate(total_la=round(sum(lf_area_corrected),digits=1)) %>% 
  mutate(lvs=n()) %>% 
  slice(1) %>% 
  select(plant_id,shoots,total_la,lvs)

# The number of shoots for plant 79 is a typo, should be 5
ha_size$shoots <- ifelse(ha_size$plant_id=="79", 5, ha_size$shoots)



# height is in a different file
AREAS<-read_xls("./data_raw/AREAS.xls")
ht_aug98<-AREAS %>% 
  select(`PLANT ID#`,
         `HEIGHT-AUG 98`,
         treatment) %>% 
  rename("plant_id"=`PLANT ID#`,
         "ht"=`HEIGHT-AUG 98`,
         "trt"="treatment")

ht_aug98$plant_id <- as.factor(ht_aug98$plant_id)
ht_aug98$trt <- as.factor(ht_aug98$trt)

ha_size<-left_join(ha_size,ht_aug98)

rm(ht_aug98)

ha_size$yr<-as.factor("1998")
ha_size$mo<-as.factor("08")

ha_size<-ha_size %>% 
  select(plant_id,
         trt,
         lvs,
         shoots,
         total_la,
         ht,
         yr,
         mo)

summary(ha_size)



