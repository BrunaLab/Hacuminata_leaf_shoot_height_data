
**Data on leaf area, shoot number, and height of reproductive _H. acuminata_**

<!-- badges: start -->
[![DOI](https://zenodo.org/badge/371151042.svg)](https://zenodo.org/badge/latestdoi/371151042)
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
3. yr: year in which measurements conducted
4. mo: month measurements made (1= January, 8=August)
5. trt: experimental treatment applied at whole-plant level

      (a) fert_pollen = fertilizer addition + hand pollination
      (b) pollen = hand pollination / no fertilizer addition 
      (c) fert = fertlizier addition / no hand pollination
      (d) control = no fertilization, no hand-pollination)

6. shoots: Number of vegetative shoots a plant had 
7. ht: height of the plant
8. lvs: no. of leaves the plant had
9. total_la: total plant leaf area (i.e., sum of individual leaf areas) 
10. flrs: number of flowers the plant had in (1998 repro season)
11. dev_frts: number of developing fruits the plant in the 1998 repro season, if flowers produced 
12. frts_collected: number of fruits collected from the plant in the 1998 repro season (can be NA because no dev_fruits, or because none collected)
13. sds_collected: number of seeds collected from the plant in the 1998 repro season (can be NA because no flowers produced, or none collected)
14. sds_per_fruit: number of seeds per fruit in the 1998 flowering season (can be NA because no flowers produced, or none collected)



**Note the numbers of dev_fruits will be NA when no flowers produced)



## Citation

@dataset{emilio_m_bruna_2021_5041931,
  author       = {Emilio M. Bruna},
  title        = {{Leaf number, leaf area, shoot number, and height 
                   of reproductive H. acuminata}},
  month        = jun,
  year         = 2021,
  publisher    = {Zenodo},
  version      = {v1.0.0},
  doi          = {10.5281/zenodo.5041931},
  url          = {https://doi.org/10.5281/zenodo.5041931}
}



