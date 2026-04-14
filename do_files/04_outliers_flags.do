/*==============================================================================
  Project:    Tech Hubs Session 8 – AI Applications in Research
  File:       04_outliers_flags.do
  Purpose:    Detect outliers, winsorise, and flag out-of-range values
  Author:
  Date:
  Modified:
================================================================================
  Inputs:
    ${data}/intermediate/hh_deduped.dta

  Outputs:
    ${data}/intermediate/hh_flagged.dta
    ${outputs}/flag_summary.csv

  Notes:
  - Requires Module 03 to have run first.
  - IPA extended missing value convention: .o = out of range / other
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

    global log_dir "${logs}/${today}"
    capture mkdir "${log_dir}"
}

* ─── Open Log ────────────────────────────────────────────────────────────────
cap log close module04
log using "${log_dir}/04_outliers_flags.smcl", replace smcl name(module04)

di _n "{hline 70}"
di "MODULE 04: Outliers and Flags"
di "{hline 70}"

* ─── Load Data ───────────────────────────────────────────────────────────────
use "${data}/intermediate/hh_deduped.dta", clear

di "Observations: `c(N)'"

* ─── Preview Income Distribution ─────────────────────────────────────────────
di _n "=== hh_income_monthly (before flagging) ==="
summarize hh_income_monthly, detail

* ─── TODO: Flag Outliers in hh_income_monthly (IQR Method) ──────────────────
/*
  EXERCISE 1: Flag outliers in hh_income_monthly using the interquartile range
  (IQR) method. An outlier is a value below Q1 - 1.5*IQR or above Q3 + 1.5*IQR.

  * COPILOT PROMPT: Flag outliers in hh_income_monthly using the IQR method.
  *   1. Compute the 25th percentile (Q1), 75th percentile (Q3), and IQR using
  *      summarize with the detail option and r() scalars.
  *   2. Create a variable income_flag that equals 1 if the value is an outlier
  *      and 0 otherwise (exclude missing values from flagging).
  *   3. Create a string variable income_flag_reason that describes why each
  *      flagged observation was flagged: "Below Q1-1.5*IQR" or "Above Q3+1.5*IQR".
*/

// TODO: Detect outliers using the IQR method
di "=== IQR Outlier Detection for hh_income_monthly ==="

// Your code here:
// Step 1: Compute quartiles and IQR using summarize with detail
summarize hh_income_monthly, detail
// Your code here:



* ─── TODO: Winsorise hh_expenditure ─────────────────────────────────────────
/*
  EXERCISE 2: Winsorise hh_expenditure at the 1st and 99th percentiles to
  reduce the influence of extreme values without discarding observations.

  * COPILOT PROMPT: Winsorise the variable hh_expenditure at the 1st and 99th
  *   percentiles using the winsor2 command. Replace the original values in-place.
  *   Command: winsor2 hh_expenditure, cuts(1 99) replace
  *   Then summarize hh_expenditure to confirm the transformation.
*/

// TODO: Winsorise hh_expenditure
di "=== hh_expenditure (before winsorisation) ==="
summarize hh_expenditure, detail

// Your code here:

di "=== hh_expenditure (after winsorisation) ==="
summarize hh_expenditure, detail

* ─── Validation ──────────────────────────────────────────────────────────────
assert !missing(hhid)
isid hhid
di "PASS: hhid still unique and non-missing after flagging."

* ─── Save ────────────────────────────────────────────────────────────────────
di _n "=== Saving ==="
save "${data}/intermediate/hh_flagged.dta", replace
di "Saved: ${data}/intermediate/hh_flagged.dta"

* ─── Close Log ───────────────────────────────────────────────────────────────
di _n "{hline 70}"
di "MODULE 04 COMPLETE"
di "{hline 70}"
log close module04
