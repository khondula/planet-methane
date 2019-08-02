# methane concentration to flux

# water temperature = air temperature × 0.67 + 7.45

library(LakeMetabolizer)
# get air temperature from Dover AFB and 
# calculate water temperature using regression
library(GSODR)
library(dplyr)

# from NEON sdg function
##### Constants #####
cGas<-8.3144598 #universal gas constant (J K-1 mol-1)
cKelvin <- 273.15 #Conversion factor from Kelvin to Celsius
cPresConv <- 0.000001 # Constant to convert mixing ratio from umol/mol (ppmv) to mol/mol. 
# Unit conversions from kPa to Pa, m^3 to L, cancel out.
cT0 <- 298.15#Henry's law constant T0
cConcPerc <- 100 #Convert to percent
#Henry's law constants and temperature dependence from Sander (2015) DOI: 10.5194/acp-15-4399-2015
ckHCO2 <- 0.00033 #mol m-3 Pa, range: 0.00031 - 0.00045
ckHCH4 <- 0.000014 #mol m-3 Pa, range: 0.0000096 - 0.000092
ckHN2O <- 0.00024 #mol m-3 Pa, range: 0.00018 - 0.00025
cdHdTCO2 <- 2400 #K, range: 2300 - 2600
cdHdTCH4 <- 1900 #K, range: 1400-2400

# ppmv source CH4 1.85 ppmv
calc_sat_concCH4 <- function(waterTemp, baro){
  ckHCH4 <- 0.000014 #mol m-3 Pa, range: 0.0000096 - 0.000092
  cdHdTCH4 <- 1900 #K, range: 1400-2400
  cKelvin <- 273.15 #Conversion factor from Kelvin to Celsius
  cT0 <- 298.15#Henry's law constant T0
  cPresConv <- 0.000001 # Constant to convert mixing ratio from umol/mol (ppmv) to mol/mol. 
  satConcCH4 <-  (ckHCH4 * exp(cdHdTCH4*(1/(waterTemp + cKelvin) - 1/cT0))) * 
    1.85 * baro * cPresConv  
  sat_conc_ch4_umol <- satConcCH4*1e6
  return(sat_conc_ch4_umol)
}

gsod_data <- get_GSOD(years = 2017:2018, station = "724088-13707") # dover AFB airport
gsod_data$STP_kPa <- gsod_data$STP*0.1
gsod_data <- gsod_data %>% 
  # mutate(air_temp_C = (TEMP-32)*(5/9)) %>%
  mutate(water_temp_C = TEMP * 0.67 + 7.45) 

range(gsod_data$water_temp_C)

write.csv(gsod_data, "gsod_data.csv", row.names = FALSE)
# then assume same k600 and calculate flux
gsod_data <- readr::read_csv('gsod_data.csv') %>% filter(YEARMODA > as.Date("2017-09-30") & YEARMODA < as.Date("2018-10-01"))

k600.2.kGAS.base(k600 = 0.5, gas = "CH4", temperature = 28.019) # m/day
k600.2.kGAS.base(k600 = 0.5, gas = "CH4", temperature = -0.882) # m/day

gsod_kgas <- gsod_data %>%
  filter(YEARMODA > as.Date("2017-09-30") & YEARMODA < as.Date("2018-10-01")) %>%
  dplyr::select(YEARMODA, water_temp_C, STP_kPa) %>%
  mutate(kgas05_md = purrr::map_dbl(water_temp_C, ~k600.2.kGAS.base(0.5, gas = "CH4", temperature = .x))) %>% 
  mutate(kgas025_md = purrr::map_dbl(water_temp_C, ~k600.2.kGAS.base(0.25, gas = "CH4", temperature = .x))) %>% 
  mutate(kgas075_md = purrr::map_dbl(water_temp_C, ~k600.2.kGAS.base(0.75, gas = "CH4", temperature = .x))) %>% 
  mutate(satCH4_umol = purrr::map2_dbl(.x = water_temp_C, .y = STP_kPa, ~calc_sat_concCH4(waterTemp = .x, baro = .y)))

# sept 8,9,10 have NAs for baro pressure, need to interpolate

gsod_kgas %>% 
  write_csv("gsod_kgas.csv")

gsod_kgas %>% 
  ggplot(aes(x = YEARMODA, y = kgas05_md)) +
  geom_point() + theme_bw()

gsod_kgas %>% 
  ggplot(aes(x = YEARMODA, y = satCH4_umol)) +
  geom_point() + theme_bw()

# Flux = k * (Csur - Ceq)

# same concentration of umol = 5, how does flux change throughout the year?

gsod_kgas %>%
  mutate(flux5a = kgas05_md*(5 - satCH4_umol)) %>%
  mutate(flux5b = kgas025_md*(5 - satCH4_umol)) %>%
  mutate(flux5c = kgas075_md*(5 - satCH4_umol)) %>%
  mutate(flux1 = kgas05_md*(1 - satCH4_umol)) %>%
  mutate(flux10 = kgas05_md*(10 - satCH4_umol)) %>%
  ggplot(aes(x = YEARMODA, y = flux5a)) +
  geom_point() +
  geom_point(aes(y = flux5b), pch = 21) +
  geom_point(aes(y = flux5c), pch = 21) +
  geom_point(aes(y = flux1), col = "pink") +
  geom_point(aes(y = flux10), col = "red") +
  ylim(c(0,6)) +
  ylab("Flux (mmol per m2 per day)")

# C eq same for the whole year, based on global average atmospheric ch4 (1.85 ppm)
# calculate the equilibrium concentration of 1.85 ppm in water


# convert atmospheric ch4 to Ceq in water using... 
# 1850 ppb * 1/1000 --> 1.85 ppm --> 1.85 uatm
1850/1000

# convert umol to utam 

R_LatmKmol <- 0.082057338
tempK = tempC + 273.15
umolL = uatm/(R_LatmKmol * tempK)

uatm = umolL * (R_LatmKmol * tempK)

uatm = 10 * R_LatmKmol * (30 + 273.15) # pressure in water

uatm - 1.85


246.9068