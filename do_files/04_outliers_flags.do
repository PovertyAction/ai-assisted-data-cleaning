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
log using "${log_dir}/04_outliers_flags.log", replace text name(module04)

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
// Step 1: Compute Q1, Q3, IQR
summarize hh_income_monthly, detail
// local q1  = r(p25)
// local q3  = r(p75)
// local iqr = `q3' - `q1'
// local lower = `q1' - 1.5 * `iqr'
// local upper = `q3' + 1.5 * `iqr'

// TODO: Create income_flag and income_flag_reason




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

* ─── TODO: Replace Negative Values with .o (IPA Convention) ─────────────────
/*
  EXERCISE 3: Any negative value in a household-level numeric variable
  (hh_income_monthly, hh_expenditure, hh_savings) is implausible and should
  be recoded to .o (out of range / other) per IPA extended missing value
  conventions.

  * COPILOT PROMPT: Loop over the variables hh_income_monthly, hh_expenditure,
  *   and hh_savings. For each variable, replace any value less than 0 with .o
  *   (the IPA "out of range" extended missing value code).
  *   Report how many replacements were made for each variable.
*/

// TODO: Replace negative values in hh_* variables with .o
di "=== Replacing Negative Values with .o ==="

// Your code here:
// foreach var of varlist hh_income_monthly hh_expenditure hh_savings {
//     count if `var' < 0 & !missing(`var')
//     replace `var' = .o if `var' < 0
// }




* ─── TODO: Export Flag Summary ───────────────────────────────────────────────
/*
  EXERCISE 4: Export a summary of the flagging results as a CSV.

  * COPILOT PROMPT: Create a summary table with one row per flag type, showing
  *   the variable name, the number of flagged observations, and the flag reason.
  *   Export the table to "${outputs}/flag_summary.csv" using export delimited.
  *
  *   Hint: Use preserve/restore, then create a small dataset manually with
  *   gen varname = "", gen n_flagged = ..., etc., then export and restore.
*/

// TODO: Export flag summary
di "=== Exporting Flag Summary ==="

// Your code here:




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
