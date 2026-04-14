/*==============================================================================
  Project:    Tech Hubs Session 8 – AI Applications in Research
  File:       03_deduplication.do
  Purpose:    Identify duplicate records and keep the most recent per hhid
  Author:
  Date:
  Modified:
================================================================================
  Inputs:
    ${data}/intermediate/hh_strings_cleaned.dta

  Outputs:
    ${data}/intermediate/hh_deduped.dta
    ${outputs}/dedup_log.csv

  Notes:
  - Requires Module 02 to have run first.
  - ~30 intentional duplicates exist in the synthetic data for this exercise.
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
cap log close module03
log using "${log_dir}/03_deduplication.smcl", replace smcl name(module03)

di _n "{hline 70}"
di "MODULE 03: Deduplication"
di "{hline 70}"

* ─── Load Data ───────────────────────────────────────────────────────────────
use "${data}/intermediate/hh_strings_cleaned.dta", clear

local obs_start = `c(N)'
di "Observations at start: `obs_start'"

* ─── TODO: Report Duplicates on hhid ─────────────────────────────────────────
/*
  EXERCISE 1: Identify duplicate household IDs in the dataset.

  * COPILOT PROMPT: Use the duplicates command to report how many observations
  *   share the same hhid value. Show both the number of groups and the number
  *   of excess observations (i.e. the duplicates).
*/

// TODO: Report duplicates on hhid
di "=== Duplicate Report ==="

// Your code here:



* ─── TODO: Tag Duplicates ────────────────────────────────────────────────────
/*
  EXERCISE 2: Create a flag variable that marks duplicate records.

  * COPILOT PROMPT: Create a variable called is_duplicate that equals 1 for any
  *   observation whose hhid appears more than once in the dataset, and 0
  *   otherwise.
  *   Then relabel and recode so 0 = unique, 1 = duplicate.
*/

// TODO: Create is_duplicate flag variable

// Your code here:

* ─── TODO: Export Duplicate Observations ─────────────────────────────────────
/*
  EXERCISE 3: Export all duplicate records to a CSV for review.

  * COPILOT PROMPT: Export all duplicate observations into an excel sheet.
  *   where is_duplicate == 1 to a XLSX file in the outputs folder. Name the file
  *   "hh_duplicates.xlsx".
*/
di "=== Exporting Duplicate Records ==="
export excel using "${outputs}/hh_duplicates.xlsx" if is_duplicate == 1, firstrow(variables) replace 

* ─── TODO: Keep Most Recent Record per hhid ──────────────────────────────────
/*
  EXERCISE 4: For each hhid that appears more than once, keep only the record
  with the most recent survey_date.

  * COPILOT PROMPT: Sort the dataset by hhid and survey_date (ascending).
  *   Then use bysort to keep only the last observation per hhid — the most
  *   recent record. Use: bysort hhid (survey_date): keep if _n == _N
  *   After keeping, confirm that hhid is now unique with isid.
*/

// TODO: Keep the most recent record per hhid
di "=== Deduplication: Keeping Most Recent Record ==="

// Your code here:


***** Validate Uniqueness *****
isid hhid
di "PASS: hhid is unique after deduplication."

local obs_end = `c(N)'
di "Observations removed: " `obs_start' - `obs_end'
di "Observations remaining: `obs_end'"



* ─── Save ────────────────────────────────────────────────────────────────────
di _n "=== Saving ==="
save "${data}/intermediate/hh_deduped.dta", replace
di "Saved: ${data}/intermediate/hh_deduped.dta"

* ─── Close Log ───────────────────────────────────────────────────────────────
di _n "{hline 70}"
di "MODULE 03 COMPLETE"
di "{hline 70}"
log close module03
