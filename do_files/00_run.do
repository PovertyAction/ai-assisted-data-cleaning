/*==============================================================================
  Project:    Tech Hubs Session 8 – AI Applications in Research
  File:       00_run.do
  Purpose:    Master do-file — runs the full data-cleaning training pipeline
  Author:
  Date:
  Modified:
================================================================================
  Usage:
    Full pipeline:   do do_files/00_run.do
    Single module:   do do_files/00_run.do "02_string_cleaning"
    Via just:        just stata-run
                     just stata-script 02_string_cleaning

  Notes:
  - Uses setroot to find the project root via the .here marker file.
  - Loads config.do for user-specific path overrides (gitignored).
  - Defines ${today} for timestamped log file names.
  - Modules run in order: 01 → 02 → 03 → 04 → 05.
  - Run setup/generate_synthetic_data.do once before this script.

  References:
  - IPA Data Cleaning Guide: https://data.poverty-action.org/data-cleaning/
  - IPA Stata Coding Standards: https://data.poverty-action.org/software/stata/
==============================================================================*/

* ─── Environment ─────────────────────────────────────────────────────────────
clear all
macro drop _all
capture log close _all
set more off
set seed 123456789

* ─── Find Project Root ────────────────────────────────────────────────────────
/*
  setroot walks up the directory tree from c(pwd) and sets ${root} to the
  folder containing the .here marker file. Install with: ssc install setroot
  Run setup.do once to install setroot and all project packages.
*/
capture setroot, verbose
if _rc != 0 {
    di as error _n "{hline 70}"
    di as error "ERROR: Cannot find project root."
    di as error "{hline 70}"
    di as text "Current directory: `c(pwd)'"
    di as text _n "Solutions:"
    di as text "  1. Run setup.do first (installs setroot):"
    di as text "       do setup.do"
    di as text "  2. Change to project directory before running:"
    di as text "       cd /path/to/project"
    di as text "       do do_files/00_run.do"
    di as error "{hline 70}"
    exit 601
}
global project_path "${root}"

* ─── Define Paths ─────────────────────────────────────────────────────────────
/*
  Load user-specific overrides from config.do (gitignored).
  If config.do doesn't exist, defaults are used.
  Copy config.do.template to config.do to customise your data path.
*/
capture confirm file "${project_path}/config.do"
if _rc == 0 {
    di as text "Loading config.do..."
    do "${project_path}/config.do"
}
else {
    di as text "No config.do found — using default paths."
    di as text "Tip: copy config.do.template to config.do to customise paths."
}

* Default paths (used if not set in config.do)
if "${data}"    == "" global data    "${project_path}/data"
if "${logs}"    == "" global logs    "${project_path}/logs"
if "${outputs}" == "" global outputs "${project_path}/outputs"

* Paths always derived from project root (never in config.do)
global scripts "${project_path}/do_files"

* Date stamp for log file names
global today = subinstr("`c(current_date)'", " ", "_", .)

* ─── Ensure Output Directories Exist ─────────────────────────────────────────
capture mkdir "${logs}"
capture mkdir "${outputs}"
capture mkdir "${data}/intermediate"
capture mkdir "${data}/final"

* Create date-based log subfolder so each run's logs are grouped together
global log_dir "${logs}/${today}"
capture mkdir "${log_dir}"

* ─── Open Master Log ──────────────────────────────────────────────────────────
cap log close master
log using "${log_dir}/00_run.log", replace text name(master)

* ─── System Info ──────────────────────────────────────────────────────────────
di _n "{hline 70}"
di "Tech Hubs Session 8 — AI Applications in Research"
di "Data Cleaning Pipeline"
di "{hline 70}"
di "Project root : ${project_path}"
di "Data folder  : ${data}"
di "Outputs      : ${outputs}"
di "Today        : `c(current_date)'"
di "Stata version: `c(stata_version)'"
di "{hline 70}"

* ─── Runner Pattern ───────────────────────────────────────────────────────────
/*
  Pass a module name as an argument to run only that module.
  Example: do do_files/00_run.do "02_string_cleaning"
*/
args script_to_run

if "`script_to_run'" != "" {
    di _n "{hline 70}"
    di "RUNNING SINGLE MODULE: `script_to_run'.do"
    di "{hline 70}"
    do "${scripts}/`script_to_run'.do"
    log close master
    exit
}

* ─── Pipeline Control Switches ────────────────────────────────────────────────
* Set to 0 to skip a module during development
local run_01_data_cleaning     = 1
local run_02_string_cleaning   = 1
local run_03_deduplication     = 1
local run_04_outliers_flags    = 1
local run_05_labeling_codebook = 1

di _n "{hline 70}"
di "PIPELINE CONFIGURATION"
di "{hline 70}"
di "01 Data cleaning    : " cond(`run_01_data_cleaning',     "YES", "NO")
di "02 String cleaning  : " cond(`run_02_string_cleaning',   "YES", "NO")
di "03 Deduplication    : " cond(`run_03_deduplication',     "YES", "NO")
di "04 Outliers / flags : " cond(`run_04_outliers_flags',    "YES", "NO")
di "05 Labeling         : " cond(`run_05_labeling_codebook', "YES", "NO")
di "{hline 70}"

* ─── Run Modules ──────────────────────────────────────────────────────────────

if `run_01_data_cleaning' {
    di _n "{hline 70}"
    di "MODULE 01: Data Cleaning"
    di "{hline 70}"
    do "${scripts}/01_data_cleaning.do"
}

if `run_02_string_cleaning' {
    di _n "{hline 70}"
    di "MODULE 02: String Cleaning"
    di "{hline 70}"
    do "${scripts}/02_string_cleaning.do"
}

if `run_03_deduplication' {
    di _n "{hline 70}"
    di "MODULE 03: Deduplication"
    di "{hline 70}"
    do "${scripts}/03_deduplication.do"
}

if `run_04_outliers_flags' {
    di _n "{hline 70}"
    di "MODULE 04: Outliers and Flags"
    di "{hline 70}"
    do "${scripts}/04_outliers_flags.do"
}

if `run_05_labeling_codebook' {
    di _n "{hline 70}"
    di "MODULE 05: Labeling and Codebook"
    di "{hline 70}"
    do "${scripts}/05_labeling_codebook.do"
}

* ─── Completion ───────────────────────────────────────────────────────────────
di _n "{hline 70}"
di "PIPELINE COMPLETED SUCCESSFULLY"
di "{hline 70}"
di "Outputs written to:"
di "  ${outputs}/missing_summary.csv"
di "  ${outputs}/dedup_log.csv"
di "  ${outputs}/flag_summary.csv"
di "  ${outputs}/codebook.xlsx"
di "  ${data}/final/hh_clean_final.dta"
di _n "Logs written to:"
di "  ${log_dir}/"
di "{hline 70}"

log close master
