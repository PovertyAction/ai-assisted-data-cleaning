/*==============================================================================
  Project:    Tech Hubs Session 8 – AI Applications in Research
  File:       generate_synthetic_data.do
  Purpose:    Generate synthetic household survey dataset for training exercises
  Author:
  Date:
  Modified:
================================================================================
  Outputs:
    data/raw/household_survey_raw.dta   (500 obs + ~30 duplicates = ~530 total)

  Notes:
  - Uses ONLY base Stata commands — no user-written packages required.
  - Run this script ONCE before any training modules.
  - Run from the project root directory:
      do setup/generate_synthetic_data.do
  - NO real data is used. All values are randomly generated.

  Intentional data quality issues (for exercises):
  - ~30 duplicate hhids (with slightly different survey dates)
  - ~15% missing values in hh_income_monthly
  - String inconsistencies in district_name and occupation_raw
  - A handful of extreme outliers in hh_income_monthly
  - Negative values in hh_expenditure for a few observations
==============================================================================*/

* ─── Environment ─────────────────────────────────────────────────────────────
clear all
set more off
set seed 20240101       // fixed seed for reproducibility

* ─── Paths ───────────────────────────────────────────────────────────────────
* This script uses a relative path from the current working directory.
* Run from the project root: do setup/generate_synthetic_data.do

* Create data directories if they do not exist
capture mkdir "data"
capture mkdir "data/raw"
capture mkdir "data/intermediate"
capture mkdir "data/final"
capture mkdir "logs"
capture mkdir "outputs"

* ─── Generate Base Dataset (500 Unique Households) ───────────────────────────
set obs 500

* --- Identifier ---
gen hhid = "HH" + string(_n, "%05.0f")
label variable hhid "Household ID"

* --- Survey Date (random dates in 2024) ---
gen survey_date = td(01jan2024) + floor(runiform() * 330)
format survey_date %td
label variable survey_date "Date of survey interview"

* --- District Name (with deliberate inconsistencies introduced below) ---
gen dist_code = ceil(runiform() * 5)
gen district_name = ""
replace district_name = "Kampala" if dist_code == 1
replace district_name = "Jinja"   if dist_code == 2
replace district_name = "Mbale"   if dist_code == 3
replace district_name = "Gulu"    if dist_code == 4
replace district_name = "Mbarara" if dist_code == 5
drop dist_code
label variable district_name "District name"

* --- Village Name ---
gen village_code = ceil(runiform() * 20)
gen village_name = "Village_" + string(village_code, "%02.0f")
drop village_code
label variable village_name "Village name"

* --- Respondent Name (with deliberate inconsistencies introduced below) ---
* First names (10 options)
local fn1 "John"
local fn2 "Mary"
local fn3 "Peter"
local fn4 "Grace"
local fn5 "David"
local fn6 "Ruth"
local fn7 "Samuel"
local fn8 "Esther"
local fn9 "Daniel"
local fn10 "Alice"

* Last names (10 options)
local ln1 "Okonkwo"
local ln2 "Mensah"
local ln3 "Diallo"
local ln4 "Kamara"
local ln5 "Nkrumah"
local ln6 "Asante"
local ln7 "Boateng"
local ln8 "Owusu"
local ln9 "Traore"
local ln10 "Coulibaly"

gen fn_idx = ceil(runiform() * 10)
gen ln_idx = ceil(runiform() * 10)
gen respondent_name = ""

forvalues i = 1/10 {
    forvalues j = 1/10 {
        replace respondent_name = "`fn`i'' `ln`j''" if fn_idx == `i' & ln_idx == `j'
    }
}
drop fn_idx ln_idx
label variable respondent_name "Name of respondent"

* --- Occupation (raw, with deliberate inconsistencies introduced below) ---
gen occ_code = ceil(runiform() * 5)
gen occupation_raw = ""
replace occupation_raw = "Farmer"  if occ_code == 1
replace occupation_raw = "Teacher" if occ_code == 2
replace occupation_raw = "Trader"  if occ_code == 3
replace occupation_raw = "Laborer" if occ_code == 4
replace occupation_raw = "Other"   if occ_code == 5
drop occ_code
label variable occupation_raw "Occupation (raw, uncleaned)"

* --- Education Level ---
gen edu_level = floor(runiform() * 4)    // 0, 1, 2, or 3
label variable edu_level "Highest education level (0=None, 1=Primary, 2=Secondary, 3=Tertiary)"

* --- Household Income (with ~15% missing and a few outliers) ---
gen hh_income_monthly = round(rnormal(500000, 150000), 100)
replace hh_income_monthly = max(hh_income_monthly, 10000)   // no implausible negatives yet
label variable hh_income_monthly "Monthly household income (local currency)"

* --- Household Expenditure ---
gen hh_expenditure = round(hh_income_monthly * (0.5 + runiform() * 0.4), 100)
label variable hh_expenditure "Monthly household expenditure (local currency)"

* --- Household Savings ---
gen hh_savings = round(hh_income_monthly - hh_expenditure + rnormal(0, 30000), 100)
label variable hh_savings "Monthly household savings (local currency)"

* --- Age ---
gen age = round(20 + runiform() * 45)    // 20–65
label variable age "Age of respondent (years)"

* --- Binary Variables ---
gen female_yn      = (runiform() > 0.45)
gen consent_yn     = (runiform() > 0.05)     // ~95% consent
gen electricity_yn = (runiform() > 0.5)
gen mobile_phone_yn = (runiform() > 0.25)
gen bank_account_yn = (runiform() > 0.6)
gen insurance_yn    = (runiform() > 0.8)

label variable female_yn       "Respondent is female (1=Yes, 0=No)"
label variable consent_yn      "Household gave informed consent (1=Yes, 0=No)"
label variable electricity_yn  "Household has electricity (1=Yes, 0=No)"
label variable mobile_phone_yn "Household has a mobile phone (1=Yes, 0=No)"
label variable bank_account_yn "Household has a bank account (1=Yes, 0=No)"
label variable insurance_yn    "Household has insurance (1=Yes, 0=No)"

* ─── Introduce Intentional Data Quality Issues ────────────────────────────────

* 1. String inconsistencies in district_name (~40% of observations)
replace district_name = lower(district_name) if runiform() < 0.20
replace district_name = upper(district_name) if runiform() < 0.10
replace district_name = district_name + " "  if runiform() < 0.10

* 2. String inconsistencies in respondent_name (~20% of observations)
replace respondent_name = upper(respondent_name)  if runiform() < 0.10
replace respondent_name = lower(respondent_name)  if runiform() < 0.10
replace respondent_name = " " + respondent_name   if runiform() < 0.05

* 3. String inconsistencies in occupation_raw (~35% of observations)
replace occupation_raw = lower(occupation_raw)               if runiform() < 0.15
replace occupation_raw = upper(occupation_raw)               if runiform() < 0.10
replace occupation_raw = "farming"        if occupation_raw == "Farmer"  & runiform() < 0.20
replace occupation_raw = "small trader"   if occupation_raw == "Trader"  & runiform() < 0.20
replace occupation_raw = "casual laborer" if occupation_raw == "Laborer" & runiform() < 0.20
replace occupation_raw = "primary teacher" if occupation_raw == "Teacher" & runiform() < 0.20

* 4. Missing values in hh_income_monthly (~15%)
replace hh_income_monthly = . if runiform() < 0.15

* 5. Extreme outliers in hh_income_monthly (~2% extremely high, ~1% negative)
replace hh_income_monthly = hh_income_monthly * 20 if runiform() < 0.02 & !missing(hh_income_monthly)
replace hh_income_monthly = -abs(hh_income_monthly) if runiform() < 0.01 & !missing(hh_income_monthly)

* 6. Negative values in hh_expenditure (~1%)
replace hh_expenditure = -abs(hh_expenditure) if runiform() < 0.01

* ─── Append ~30 Duplicate Records ────────────────────────────────────────────
* Create duplicates by re-using the first 30 household IDs with slightly
* different survey dates (simulates re-interviews or data entry errors).
preserve
    keep if _n <= 30
    * Give duplicates a later survey date (1–14 days later)
    replace survey_date = survey_date + floor(runiform() * 14 + 1)
    * Introduce minor name variation in some duplicates
    replace respondent_name = upper(respondent_name) if runiform() > 0.7
    tempfile duplicates
    save `duplicates'
restore

append using `duplicates'

* ─── Final Sort and Save ──────────────────────────────────────────────────────
sort hhid survey_date
count
di "Total observations (including duplicates): `r(N)'"

duplicates report hhid

save "data/raw/household_survey_raw.dta", replace

local n_total = `c(N)'
di _n "{hline 60}"
di "Synthetic dataset saved:"
di "  data/raw/household_survey_raw.dta"
di "  Total observations (incl. ~30 duplicate hhids): `n_total'"
di "{hline 60}"
