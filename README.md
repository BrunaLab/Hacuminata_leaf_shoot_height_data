
# Hacuminata_leaf_shoot_height_data

<!-- badges: start -->
<!-- badges: end -->

This repository is to clean and organize data on leaf length, leaf area (individual leaves, total plant leaf area), shoot number, and height of _Heliconia acuminata_ plants found at reserve 1501 of the Biological Dynamics of Forest Fragments Project (Manaus, Brazil).

The data are from a pilot study testing for costs of reproduction in *H. acuminata* conducted during 1998-1999 field season. Plants were assigned to one of four treatments: (1) fertilizer addition + manually hand-pollinate all open flowers with pollen from other plants, (2) Manually hand-pollinate, (3) fertilizer addition, (4) Control plants. At the time I knew relatively little about _H. acuminata_ growth and reproduction; I soon realized the treatments were unlikely to be effective because of the way the fertilizer was being applied and the difficulty I was having hand pollinating plants. However, the data set has value for its detailed breakdown of plant allometry. For each plant I measured:

1. Height to the top of the tallest leaf
2. Number of shoots
3. The length of all leaves
4. Production of flowers, fruits, and seeds

Using No. 3 one can then calculate:

5. Total leaf number
6. Area of each leaf (using the regression equation found in [Bruna et al. 2002](https://www.jstor.org/stable/3072265))
7. Total plant leaf area


This repository has the raw data (```data_raw```), the code used to clean and organize it (in the ```r_code``` folder) and the clean data (```data_clean```).

The clean data has the following columns
1. plant_id: plant's unique ID Number.
2. trt: experimental treatments. 

      (a) fert_pollen = fertilizer addition + hand pollination
      (b) pollen = hand pollination / no fertilizer addition 
      (c) fert = fertlizier addition / no hand pollination
      (d) control = no fertilization, no hand-pollination)
      
3. flrs: number of flowers the plant had in the 1998 repro season 
4. frts_collected: number of fruits collected from the plant in the 1998 repro season 
5. dev_frts: number of developing fruits the plant in the 1998 repro season 
6. sds_collected: number of seeds collected from the plant in the 1998 repro season 
7. total_la_jan: total plant leaf area (i.e., sum of individual leaf areas) in Jan 1998
8. shoots_jan: Number of vegetative shoots a plant had in Jan 1998
9. ht_jan: height of the plant in January 1998
10. shoots_aug: Number of vegetative shoots a plant had in August 1998
11. total_la_aug: total plant leaf area (i.e., sum of individual leaf areas) in August 1998
12. lvs_aug: no. of leaves the plant had in August 1998
13. ht_aug: height of the plant in August 1998




