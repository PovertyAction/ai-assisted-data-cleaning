/*==============================================================================
  Project:    Tech Hubs Session 8 – AI Applications in Research
  File:       02_string_cleaning.do
  Purpose:    Standardise string variables: trim, case, and category recoding
  Author:
  Date:
  Modified:
================================================================================
  Inputs:
    ${data}/intermediate/hh_working.dta

  Outputs:
    ${data}/intermediate/hh_strings_cleaned.dta

  Notes:
  - Requires Module 01 to have run first.
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
cap log close module02
log using "${log_dir}/02_string_cleaning.log", replace text name(module02)

di _n "{hline 70}"
di "MODULE 02: String Cleaning"
di "{hline 70}"

* ─── Load Data ───────────────────────────────────────────────────────────────
use "${data}/intermediate/hh_working.dta", clear

di "Observations: `c(N)'"

* ─── Identify String Variables ───────────────────────────────────────────────
di _n "=== String Variables Before Cleaning ==="
describe, varlist
* List string variables
ds, has(type string)
di "String variables: `r(varlist)'"

* ─── TODO: Trim All String Variables ─────────────────────────────────────────
/*
  EXERCISE 1: Trim leading and trailing spaces from every string variable.

  * COPILOT PROMPT: Use a foreach loop over all string variables to trim leading
  *   and trailing whitespace from each one.
  *   Use "ds, has(type string)" to get the list of string variables, then loop
  *   with: replace varname = strtrim(varname)
*/

// TODO: Trim all string variables
// Hint: ds, has(type string) lists all string variables




* ─── TODO: Standardise respondent_name to Title Case ────────────────────────
/*
  EXERCISE 2: Standardise respondent_name so the first letter of each word
  is capitalised and all others are lowercase ("title case").

  * COPILOT PROMPT: Convert respondent_name to title case so that each word
  *   starts with a capital letter and the rest are lowercase.
  *   Use the proper() function in Stata: replace respondent_name = proper(respondent_name)
*/

// TODO: Convert respondent_name to title case
// Preview before:
di "=== respondent_name sample (before) ==="
list respondent_name in 1/10, noobs

// Your code here:


// Preview after:
di "=== respondent_name sample (after) ==="
list respondent_name in 1/10, noobs

* ─── TODO: Clean district_name ──────────────────────────────────────────────
/*
  EXERCISE 3: Standardise district_name — convert to lowercase, trim spaces,
  and collapse any multiple internal spaces into a single space.

  * COPILOT PROMPT: Clean the district_name variable by:
  *   1. Converting to lowercase with lower()
  *   2. Trimming leading/trailing spaces with strtrim()
  *   3. Collapsing multiple internal spaces into one with itrim()
  *   Apply all three in a single replace statement.
*/

// TODO: Clean district_name
// Preview before:
di "=== district_name (before) ==="
tab district_name, sort missing

// Your code here:


// Preview after:
di "=== district_name (after) ==="
tab district_name, sort missing

* ─── TODO: Recode occupation_raw to Canonical Categories ────────────────────
/*
  EXERCISE 4: Recode the raw occupation string into five canonical categories:
  "Farmer", "Teacher", "Trader", "Laborer", "Other".

  Raw values include mixed-case versions and variations (e.g. "farmer", "FARMER",
  "farming", "Farmer").

  * COPILOT PROMPT: Create a new variable called occupation_clean that maps
  *   occupation_raw to one of five canonical categories using a series of
  *   replace statements with inlist() or strmatch().
  *   Start from the lowercase version of occupation_raw for case-insensitive
  *   matching. Label each category clearly. Set unmatched values to "Other".
  *
  *   Categories to map:
  *   - "Farmer"  : farmer, farming, smallholder farmer, subsistence farmer
  *   - "Teacher" : teacher, primary teacher, secondary teacher
  *   - "Trader"  : trader, small trader, petty trader, market trader
  *   - "Laborer" : laborer, casual laborer, day laborer, labourer
  *   - "Other"   : everything else
*/

// TODO: Create occupation_clean from occupation_raw
// Preview raw values:
di "=== occupation_raw (before) ==="
tab occupation_raw, sort missing

// Your code here:
// Step 1: Create a temporary lowercase version for matching
gen occ_lower = lower(strtrim(occupation_raw))

// Step 2: Create occupation_clean (fill in the mappings)
gen occupation_clean = ""

// TODO: Use replace + inlist() to map each category
// Example:
// replace occupation_clean = "Farmer" if inlist(occ_lower, "farmer", "farming")




// Step 3: Default unmapped values to "Other"
replace occupation_clean = "Other" if occupation_clean == "" & occupation_raw != ""

// Clean up the temporary variable
drop occ_lower

// Preview result:
di "=== occupation_clean (after) ==="
tab occupation_clean, sort missing

* ─── Validation ──────────────────────────────────────────────────────────────
* Confirm no new missing values were introduced in key variables
assert !missing(hhid)
assert !missing(district_name)

* Confirm occupation_clean is fully populated for non-missing raw values
assert occupation_clean != "" if !missing(occupation_raw)

di "PASS: String cleaning validation checks passed."

* ─── Save ────────────────────────────────────────────────────────────────────
di _n "=== Saving ==="
save "${data}/intermediate/hh_strings_cleaned.dta", replace
di "Saved: ${data}/intermediate/hh_strings_cleaned.dta"

* ─── Close Log ───────────────────────────────────────────────────────────────
di _n "{hline 70}"
di "MODULE 02 COMPLETE"
di "{hline 70}"
log close module02
