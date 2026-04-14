/*==============================================================================
  Project:    Tech Hubs Session 8 – AI Applications in Research
  File:       01_data_cleaning.do
  Purpose:    Load raw data, inspect quality, check identifiers, save working copy
  Author:
  Date:
  Modified:
================================================================================
  Inputs:
    ${data}/raw/household_survey_raw.dta

  Outputs:
    ${data}/intermediate/hh_working.dta
    ${outputs}/missing_summary.csv

  Notes:
  - Run setup/generate_synthetic_data.do once before this script.
  - Can be run standalone or via 00_run.do.
==============================================================================*/

* ─── Standalone Initialisation ───────────────────────────────────────────────
* When run directly (not via 00_run.do), initialise paths here.
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
    capture mkdir "${data}/intermediate"

    global log_dir "${logs}/${today}"
    capture mkdir "${log_dir}"
}

* ─── Open Log ────────────────────────────────────────────────────────────────
cap log close module01
log using "${log_dir}/01_data_cleaning.log", replace text name(module01)

di _n "{hline 70}"
di "MODULE 01: Data Cleaning"
di "{hline 70}"

* ─── Load Raw Data ────────────────────────────────────────────────────────────
use "${data}/raw/household_survey_raw.dta", clear

di "Observations loaded: `c(N)'"
di "Variables loaded:    `c(k)'"

* ─── Describe and Explore ────────────────────────────────────────────────────
di _n "=== Dataset Description ==="
describe

di _n "=== Codebook Summary ==="
codebook, compact

* ─── Missing Value Overview ──────────────────────────────────────────────────
di _n "=== Missing Value Summary ==="
misstable summarize, all

* ─── Check Identifier ────────────────────────────────────────────────────────
di _n "=== Identifier Check: hhid ==="

* Assert hhid is never missing (this should always hold)
assert !missing(hhid), fast
di "PASS: hhid has no missing values."

* Check uniqueness — duplicates are expected and handled in Module 03
capture isid hhid
if _rc != 0 {
    di as text "NOTE: hhid is not unique — duplicates present."
    di as text "      Deduplication is covered in Module 03."
    duplicates report hhid
}
else {
    di "PASS: hhid is unique."
}

* ─── Basic Variable Checks ───────────────────────────────────────────────────
di _n "=== Numeric Variable Summaries ==="
summarize hh_income_monthly hh_expenditure hh_savings age edu_level

di _n "=== Categorical Variable Frequencies ==="
tab district_name, sort missing
tab occupation_raw, sort missing
tab edu_level, missing

* ─── TODO: Missing Value Summary Export ──────────────────────────────────────
/*
  EXERCISE: Use GitHub Copilot to generate the code below.

  * COPILOT PROMPT: Using the missings command, create a summary table with each
  *   variable name, the count of missing values, and the percentage missing.
  *   Export the result as a CSV to "${outputs}/missing_summary.csv".
  *
  *   Tip: Type "missings report" and let Copilot suggest the syntax.
  *   Then use "export delimited" to write the CSV.
*/

// TODO: Generate and export missing value summary table
// Example starter: missings report, gen(n_miss)




* ─── Save Working Copy ────────────────────────────────────────────────────────
di _n "=== Saving Working Copy ==="
save "${data}/intermediate/hh_working.dta", replace
di "Saved: ${data}/intermediate/hh_working.dta"

* ─── Close Log ───────────────────────────────────────────────────────────────
di _n "{hline 70}"
di "MODULE 01 COMPLETE"
di "{hline 70}"
log close module01
