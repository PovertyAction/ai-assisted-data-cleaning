/*==============================================================================
  Project:    Tech Hubs Session 8 – AI Applications in Research
  File:       05_labeling_codebook.do
  Purpose:    Label variables, apply value labels, and generate codebook
  Author:
  Date:
  Modified:
================================================================================
  Inputs:
    ${data}/intermediate/hh_flagged.dta

  Outputs:
    ${data}/final/hh_clean_final.dta
    ${outputs}/codebook.xlsx

  Notes:
  - Requires Module 04 to have run first.
  - ipacodebook (from ipaclean) is used if available; falls back to putexcel.
  - Can be run standalone or via 00_run.do.
==============================================================================*/

* ─── Standalone Initialisation ───────────────────────────────────────────────
if "${project_path}" == "" {
    clear all
    macro drop _all
    capture log close _all
    set more off

    capture setroot
    if _rc != 0 {
        di as error "ERROR: Cannot find project root. Install setroot first:"
        di as error "  ssc install setroot"
        exit 601
    }
    global project_path "${root}"

    capture confirm file "${project_path}/config.do"
    if _rc == 0 do "${project_path}/config.do"

    if "${data}"    == "" global data    "${project_path}/data"
    if "${logs}"    == "" global logs    "${project_path}/logs"
    if "${outputs}" == "" global outputs "${project_path}/outputs"
    global scripts "${project_path}/do_files"
    global today = subinstr("`c(current_date)'", " ", "_", .)

    capture mkdir "${logs}"
    capture mkdir "${outputs}"
    capture mkdir "${data}/final"

    global log_dir "${logs}/${today}"
    capture mkdir "${log_dir}"
}

* ─── Open Log ────────────────────────────────────────────────────────────────
cap log close module05
log using "${log_dir}/05_labeling_codebook.log", replace text name(module05)

di _n "{hline 70}"
di "MODULE 05: Labeling and Codebook"
di "{hline 70}"

* ─── Load Data ───────────────────────────────────────────────────────────────
use "${data}/intermediate/hh_flagged.dta", clear

di "Observations: `c(N)'"

* ─── TODO: Label All Variables ───────────────────────────────────────────────
/*
  EXERCISE 1: Apply variable labels to every variable in the dataset using the
  label variable command.

  * COPILOT PROMPT: Add a variable label to each of the following variables.
  *   Use clear, human-readable descriptions suitable for a data dictionary.
  *   Variables to label:
  *     hhid               - Household ID (unique identifier)
  *     survey_date        - Date of survey interview
  *     respondent_name    - Name of survey respondent (title case)
  *     district_name      - District name (cleaned, lowercase)
  *     village_name       - Village name
  *     occupation_raw     - Respondent occupation (raw string)
  *     occupation_clean   - Respondent occupation (canonical category)
  *     edu_level          - Highest education level completed (0–3)
  *     hh_income_monthly  - Monthly household income (local currency)
  *     hh_expenditure     - Monthly household expenditure (local currency)
  *     hh_savings         - Monthly household savings (local currency)
  *     age                - Age of respondent in years
  *     female_yn          - Respondent is female (1=Yes, 0=No)
  *     consent_yn         - Household gave informed consent (1=Yes, 0=No)
  *     electricity_yn     - Household has electricity (1=Yes, 0=No)
  *     mobile_phone_yn    - Household has a mobile phone (1=Yes, 0=No)
  *     bank_account_yn    - Household has a bank account (1=Yes, 0=No)
  *     insurance_yn       - Household has insurance (1=Yes, 0=No)
  *     income_flag        - Income flagged as outlier (1=Yes, 0=No)
  *     income_flag_reason - Reason income was flagged
  *     is_duplicate       - Record was a duplicate (1=Yes, 0=No)
*/

// TODO: Label all variables
di "=== Applying Variable Labels ==="

// Your code here:
// label variable hhid              "Household ID (unique identifier)"
// label variable survey_date       "Date of survey interview"
// ...




* ─── TODO: Value Labels for Binary _yn Variables ────────────────────────────
/*
  EXERCISE 2: Define and apply a value label for all binary yes/no variables
  (those with the _yn suffix).

  * COPILOT PROMPT: Define a value label called yn_label where 0 = "No" and
  *   1 = "Yes". Then use a foreach loop to apply it to all variables whose
  *   names end in _yn: female_yn, consent_yn, electricity_yn, mobile_phone_yn,
  *   bank_account_yn, insurance_yn.
  *   Use: label define yn_label 0 "No" 1 "Yes"
  *   Then: label values varname yn_label (in a loop)
*/

// TODO: Define and apply yn_label to all _yn variables
di "=== Applying Value Labels to _yn Variables ==="

// Your code here:
// label define yn_label 0 "No" 1 "Yes"
// foreach var of varlist *_yn {
//     label values `var' yn_label
// }




* ─── TODO: Value Label for edu_level ────────────────────────────────────────
/*
  EXERCISE 3: Define and apply a value label for edu_level (0–3).

  * COPILOT PROMPT: Define a value label called edu_label that maps:
  *   0 = "No education"
  *   1 = "Primary"
  *   2 = "Secondary"
  *   3 = "Tertiary"
  *   Then apply it to the edu_level variable.
*/

// TODO: Define and apply edu_label to edu_level
di "=== Applying Value Label to edu_level ==="

// Your code here:




* Verify labels were applied
di "=== Value Label Check ==="
capture label list yn_label
if _rc == 0 tab female_yn, missing
capture label list edu_label
if _rc == 0 tab edu_level, missing

* ─── TODO: Generate Codebook ─────────────────────────────────────────────────
/*
  EXERCISE 4: Generate a data dictionary / codebook and export it to Excel.

  * COPILOT PROMPT: Use ipacodebook to generate a codebook for the final dataset
  *   and export it to "${outputs}/codebook.xlsx".
  *   If ipacodebook is not available, use the built-in codebook command to
  *   display the codebook in the log, and use putexcel to export a basic
  *   variable list with labels to Excel.
  *
  *   Try first: ipacodebook using "${outputs}/codebook.xlsx", replace
  *   Fallback: codebook
*/

// TODO: Generate and export codebook
di "=== Generating Codebook ==="

// Option A: Use ipacodebook (preferred — requires ipaclean package)
capture ipacodebook using "${outputs}/codebook.xlsx", replace
if _rc == 0 {
    di "Codebook exported with ipacodebook: ${outputs}/codebook.xlsx"
}
else {
    di as text "ipacodebook not available — generating basic codebook."

    // Option B: Built-in codebook in log
    codebook

    // Your code here (optional): use putexcel to write a variable list to Excel
}

* ─── Validation ──────────────────────────────────────────────────────────────
assert !missing(hhid)
isid hhid
di "PASS: Final dataset has unique, non-missing hhid."

* ─── Save Final Dataset ──────────────────────────────────────────────────────
di _n "=== Saving Final Dataset ==="
label data "Tech Hubs Session 8 — Cleaned Household Survey"
save "${data}/final/hh_clean_final.dta", replace
di "Saved: ${data}/final/hh_clean_final.dta"

* ─── Close Log ───────────────────────────────────────────────────────────────
di _n "{hline 70}"
di "MODULE 05 COMPLETE"
di "Final dataset: ${data}/final/hh_clean_final.dta"
di "Codebook:      ${outputs}/codebook.xlsx"
di "{hline 70}"
log close module05
