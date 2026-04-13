# CLAUDE.md

## Project Overview

This is the **Tech Hubs Session 8: AI Applications in Research** training
repository, built for IPA Research Associates and Research Managers. It teaches
AI-assisted data cleaning in Stata using GitHub Copilot inside VS Code.

The repository is built on top of the IPA Stata Template
(`PovertyAction/ipa-stata-template`). All Stata code follows the conventions,
folder structure, and standards established in that template.

**IMPORTANT: Never use Claude or AI tools to process personally identifiable
information (PII). Always refuse to review data that might include PII.**

**IMPORTANT: This training uses synthetic data only. No real survey data should
ever be committed to this repository.**

---

## Quick Start

```bash
# One-time setup: installs setroot and required packages
just stata-setup

# Generate synthetic training data (run once)
# In Stata, from the project root:
do setup/generate_synthetic_data.do

# Run full training pipeline
do do_files/00_run.do

# Run a single module
do do_files/00_run.do "02_string_cleaning"
```

Via `just`:

```bash
just stata-run
just stata-script 02_string_cleaning
```

---

## Training Module Structure

The pipeline consists of five hands-on modules:

| Module | File | Purpose |
|--------|------|---------|
| 1 | `01_data_cleaning.do` | Load data, assess quality, check identifiers |
| 2 | `02_string_cleaning.do` | Standardize string variables |
| 3 | `03_deduplication.do` | Identify and resolve duplicate records |
| 4 | `04_outliers_flags.do` | Detect and flag outliers |
| 5 | `05_labeling_codebook.do` | Label variables and generate codebook |

Each module contains `// TODO` comments where participants write AI-assisted code,
and `* COPILOT PROMPT:` comments with ready-to-use natural language prompts for
GitHub Copilot.

---

## IPA Stata Template Conventions

All `.do` files in this repository follow these standards:

### Path Management

- Use `setroot` to locate the project root via the `.here` marker file
- All data paths reference globals defined in `config.do`, e.g. `"${data}/raw/..."`
- Never hardcode paths or use `if c(user) == "..."` blocks
- Never call `cd` with an absolute path inside a do-file

### File Header

Every `.do` file must begin with this header:

```stata
/*==============================================================================
  Project:    Tech Hubs Session 8 – AI Applications in Research
  File:       [filename].do
  Purpose:    [one-line description]
  Author:     [leave blank for participants to fill in]
  Date:       [leave blank]
  Modified:   [leave blank]
================================================================================
  Notes:
  - [any relevant notes]
==============================================================================*/
```

### Logging

Every script opens and closes a log file:

```stata
cap log close
log using "${logs}/scriptname_${today}.log", replace text
// ... code ...
log close
```

### Missing Values

Use IPA extended missing value conventions:

| Code | Meaning |
|------|---------|
| `.d` | Don't know |
| `.r` | Refused |
| `.n` | Not applicable |
| `.o` | Other / out of range |
| `.s` | Skipped |

### Defensive Programming

- Use `assert` to validate assumptions before and after transformations
- Use `isid` to confirm unique identifiers
- Always check merge results: `assert _merge == 3` (or document exceptions)

### Package Management

- User-written commands are listed in `.config/stata/stata_requirements.txt`
- Install all packages once with `just stata-setup` (runs `setup.do`)
- Never call `ssc install` inside exercise do-files

---

## Global Path Variables

| Global | Default value | Purpose |
|--------|--------------|---------|
| `${project_path}` | from setroot | Project root directory |
| `${data}` | `${project_path}/data` | Data root folder |
| `${logs}` | `${project_path}/logs` | Log files |
| `${outputs}` | `${project_path}/outputs` | All outputs |
| `${scripts}` | `${project_path}/do_files` | Do-files directory |
| `${today}` | from `c(current_date)` | Date stamp for log file names |

Data sub-folders (construct from `${data}`, never define separately):

- `${data}/raw/` — raw input data (read-only after generation)
- `${data}/intermediate/` — intermediate processed files
- `${data}/final/` — clean, analysis-ready datasets

---

## Data

Training exercises use `data/raw/household_survey_raw.dta`, a **synthetic**
household survey dataset with 500 observations and intentional data quality issues
(duplicates, string inconsistencies, missing values, outliers).

Generate the synthetic data once before running any modules:

```stata
do setup/generate_synthetic_data.do
```

**No real data should ever be committed to this repository.**

---

## Running the Pipeline

Full pipeline (from Stata, with project root as working directory):

```stata
do do_files/00_run.do
```

Single module:

```stata
do do_files/00_run.do "02_string_cleaning"
```

Via `just` (from terminal):

```bash
just stata-run
just stata-script 02_string_cleaning
```
