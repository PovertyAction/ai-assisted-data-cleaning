# Tech Hubs Session 8: AI Applications in Research

A hands-on training repository for IPA Research Associates and Research Managers.
This session teaches **AI-assisted data cleaning in Stata** using GitHub Copilot
inside VS Code, built on top of the
[IPA Stata Template](https://github.com/PovertyAction/ipa-stata-template).

> [!WARNING]
> NEVER COMMIT DATA FILES TO GITHUB.
>
> NEVER USE AI ASSISTANTS WITH PERSONALLY IDENTIFIABLE DATA.
>
> YOU ARE REQUIRED TO REMOVE IDENTIFYING INFORMATION **BEFORE** CONNECTING AI
> ASSISTANTS OR STORING IN ANY UNENCRYPTED LOCATION.
>
> This training uses **synthetic data only**. No real survey data should ever be
> committed to this repository.

---

## Quick Start

### Prerequisites

- Git ([download](https://git-scm.com/))
- VSCode ([download](https://code.visualstudio.com/download))
- GitHub Copilot Extension for VSCode([download](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot))
- Stata 17+
- Run the following command in your terminal to install just on windows:
    - windows - `winget install Casey.Just`
    - Linux - `brew install just`
- Restart your terminal and proceed with the steps

### Steps

1. **Clone the repository**

   ```bash
   git clone <repo-url>
   cd ai-assisted-data-cleaning
   ```

2. **Configure your Stata path**

   Copy `.env-example` to `.env` and set your Stata executable path:

   ```bash
   # Windows example
   STATA_CMD='C:\Program Files\Stata18\StataSE-64.exe'
   STATA_EDITION='se'

   # macOS example
   # STATA_CMD='/Applications/Stata/StataSE.app/Contents/MacOS/StataSE'
   ```

3. **One-time setup** (installs `setroot` and all required packages)

   ```bash
   just stata-setup
   # or from Stata directly:
   # do setup.do
   ```

4. **Generate the synthetic training dataset** (run once)

   In Stata, from the project root:

   ```bash
   just create-synthetic-data
   # or from Stata directly:
   do setup/generate_synthetic_data.do
   ```

   This creates `data/raw/household_survey_raw.dta` — a synthetic household
   survey with 500 observations and intentional data quality issues.

5. **Run the training pipeline**

   ```bash
   # Full pipeline
   just stata-run

   # Or from Stata directly
   do do_files/00_run.do

   # Run a single module
   just stata-script 02_string_cleaning
   # or: do do_files/00_run.do "02_string_cleaning"
   ```

6. **Check outputs**

   - CSV exports: `outputs/`
   - Codebook: `outputs/codebook.xlsx`
   - Logs: `logs/`
   - Final clean dataset: `data/final/hh_clean_final.dta`

---

## Training Modules

The pipeline consists of five modules, each designed as a hands-on Copilot
exercise. Every module contains `// TODO` comments and `* COPILOT PROMPT:`
comments with ready-to-use natural language prompts.

| Module | File | Topic |
| ------ | ---- | ----- |
| 01 | `do_files/01_data_cleaning.do` | Load data, inspect quality, check identifiers |
| 02 | `do_files/02_string_cleaning.do` | Trim spaces, title case, standardise categories |
| 03 | `do_files/03_deduplication.do` | Detect and resolve duplicate records |
| 04 | `do_files/04_outliers_flags.do` | IQR outlier flagging, winsorisation, `.o` recoding |
| 05 | `do_files/05_labeling_codebook.do` | Variable labels, value labels, codebook export |

### How Each Module Works

Each module:

1. **Runs standalone** — includes an initialisation block that sets up paths if
   the module is run directly, without going through `00_run.do`
2. **Runs as part of the pipeline** — `00_run.do` calls each module in sequence
3. **Contains TODOs** — blank sections where participants write Copilot-assisted code
4. **Contains COPILOT PROMPT comments** — copy the plain-English prompt into
   Copilot Chat or let inline Copilot autocomplete the code

---

## Exercises

Each module contains one or more exercises marked with `// TODO` and
`* COPILOT PROMPT:` comments. The prompts are written in plain English so you
can paste them directly into GitHub Copilot Chat or use them as inline
autocomplete triggers.

### Module 01 — Data Cleaning (`01_data_cleaning.do`)

1. Show missingness information (variable name, count missing, % missing) — key commands: `missings report`

### Module 02 — String Cleaning (`02_string_cleaning.do`)

| # | Exercise | Key commands |
| - | -------- | ------------ |
| 1 | Trim leading and trailing whitespace from every string variable | `ds, has(type string)`, `strtrim()` |
| 2 | Standardise `enumerator_name` to title case | `proper()` |
| 3 | Clean `district_name` — lowercase, trim spaces, collapse internal spaces | `lower()`, `strtrim()`, `itrim()` |
| 4 | Recode `occupation_raw` to five canonical categories: Farmer, Teacher, Trader, Laborer, Other | `inlist()`, `strmatch()` |

### Module 03 — Deduplication (`03_deduplication.do`)

| # | Exercise | Key commands |
| - | -------- | ------------ |
| 1 | Report how many records share the same `hhid` | `duplicates report` |
| 2 | Create an `is_duplicate` flag (0 = unique, 1 = duplicate) | `duplicates tag` |
| 3 | Export all duplicate records to `outputs/hh_duplicates.xlsx` for review | `export excel ... if is_duplicate == 1` |
| 4 | Keep only the most recent record per `hhid` using `survey_date` | `bysort hhid (survey_date): keep if _n == _N`, `isid` |

### Module 04 — Outliers & Flags (`04_outliers_flags.do`)

| # | Exercise | Key commands |
| - | -------- | ------------ |
| 1 | Flag outliers in `hh_income_monthly` using the IQR method; add an `income_flag_reason` string | `summarize, detail`, `r(p25)`, `r(p75)` |
| 2 | Winsorise `hh_expenditure` at the 1st and 99th percentiles | `winsor2 ..., cuts(1 99) replace` |

### Module 05 — Labeling & Codebook (`05_labeling_codebook.do`)

| # | Exercise | Key commands |
| - | -------- | ------------ |
| 1 | Apply descriptive variable labels to all 21 variables in the dataset | `label variable` |
| 2 | Define a `yn_label` (0 = No, 1 = Yes) and apply it to all `_yn` binary variables | `label define`, `label values`, `foreach var of varlist *_yn` |
| 3 | Define an `edu_label` (0–3: No education → Tertiary) and apply it to `edu_level` | `label define`, `label values` |
| 4 | Generate and export a codebook to `outputs/codebook.xlsx` | `ipacodebook` (preferred), or `codebook` + `putexcel` |

---

## Project Structure

```text
├── README.md                           # This file
├── CLAUDE.md                           # AI assistant instructions and conventions
├── .here                               # Project root marker (used by setroot)
├── .env                                # Stata executable config (gitignored — copy from .env-example)
├── .env-example                        # Template for .env
├── config.do.template                  # Template for user-specific data paths
├── config.do                           # User-specific paths (gitignored — copy from template)
├── setup.do                            # One-time setup: installs setroot + packages
│
├── setup/
│   └── generate_synthetic_data.do      # Generates synthetic training data (run once)
│
├── do_files/                           # Stata do-files
│   ├── 00_run.do                       # Master runner (controls pipeline + single-module mode)
│   ├── 01_data_cleaning.do             # MODULE 01: Load data, quality checks, identifier validation
│   ├── 02_string_cleaning.do           # MODULE 02: String standardisation
│   ├── 03_deduplication.do             # MODULE 03: Duplicate detection and resolution
│   ├── 04_outliers_flags.do            # MODULE 04: Outlier detection and flagging
│   └── 05_labeling_codebook.do         # MODULE 05: Variable labels and codebook
│
├── data/
│   ├── raw/                            # Raw input data (read-only after generation)
│   │   └── household_survey_raw.dta    # Synthetic training dataset (generated by setup/)
│   ├── intermediate/                   # Intermediate files produced by modules 01–04
│   └── final/                          # Final clean dataset (produced by module 05)
│
├── outputs/                            # All exported outputs
│   ├── missing_summary.csv             # From module 01
│   ├── dedup_log.csv                   # From module 03
│   ├── flag_summary.csv                # From module 04
│   └── codebook.xlsx                   # From module 05
│
├── logs/
│   ├── setup.log                       # One-time setup log (root level)
│   └── 14_Apr_2026/                    # Date-based subfolder (one per run)
│       ├── 00_run.log
│       ├── 01_data_cleaning.log
│       ├── 02_string_cleaning.log
│       ├── 03_deduplication.log
│       ├── 04_outliers_flags.log
│       └── 05_labeling_codebook.log
├── ado/                                # Local Stata packages (installed by setup.do)
│
├── .config/
│   ├── stata/
│   │   ├── stata_requirements.txt      # Stata package list (installed via require)
│   │   └── install_packages.do         # Package installation script
│   └── quarto/                         # Quarto formatting configuration
│
└── .github/
    └── workflows/                      # CI workflows (code review, pre-commit)
```

---

## Path Resolution and Globals

### How It Works

The project uses [`setroot`](https://github.com/sergiocorreia/setroot) to
automatically locate the project root from any directory by searching upward for
the `.here` marker file. This means:

- **No hardcoded paths** — scripts work regardless of where Stata is launched
- **No `if c(user)` blocks** — paths resolve automatically for every team member
- **Reproducible adopath** — only BASE + local `ado/` directory

### Global Path Variables

After `00_run.do` runs, these globals are available in all modules:

| Global | Default | Purpose |
| ------ | ------- | ------- |
| `${project_path}` | (from setroot) | Project root directory |
| `${data}` | `${project_path}/data` | Data root folder |
| `${logs}` | `${project_path}/logs` | Log files |
| `${outputs}` | `${project_path}/outputs` | All exported outputs |
| `${scripts}` | `${project_path}/do_files` | Do-files directory |
| `${today}` | (from `c(current_date)`) | Date stamp for log file names |

Data sub-folders (never define these separately — always construct from `${data}`):

```stata
"${data}/raw/"           // raw input data
"${data}/intermediate/"  // intermediate processed files
"${data}/final/"         // clean, analysis-ready datasets
```

### Separating Code and Data

If your data lives outside the repo (Dropbox, shared drive, Cryptomator vault):

1. Copy the template:

   ```bash
   cp config.do.template config.do
   ```

2. Edit `config.do` to set your paths:

   ```stata
   global data    "C:/Users/YourName/Dropbox/Project/data"
   global logs    ""   // leave blank to use project root default
   global outputs ""   // leave blank to use project root default
   ```

3. Run as usual — `00_run.do` loads `config.do` automatically.

> [!IMPORTANT]
> **Never commit `config.do`** — it is gitignored because it contains
> machine-specific paths. Always commit `config.do.template`.

---

## Understanding `00_run.do`

The master do-file orchestrates the training pipeline. It uses control switches
to run specific modules:

```stata
// Set to 0 to skip a module during development
local run_01_data_cleaning     = 1
local run_02_string_cleaning   = 1
local run_03_deduplication     = 1
local run_04_outliers_flags    = 1
local run_05_labeling_codebook = 1
```

**Runner pattern** — pass a module name to run only that one:

```stata
do do_files/00_run.do "03_deduplication"
```

Or with `just`:

```bash
just stata-script 03_deduplication
```

> [!TIP]
> If you get a "Root folder of project not found" error, change to the project
> directory in Stata first: `cd /path/to/repo` then re-run.

---

## Advanced Setup

### Task Runner (`just`)

Install `just` to run common tasks with short commands:

```bash
# Windows
winget install --id Casey.Just -e

# macOS/Linux
brew install just
```

Available commands:

```bash
just stata-setup                      # One-time setup (install setroot + packages)
just stata-run                        # Run full training pipeline
just stata-script 02_string_cleaning  # Run a single module
just stata-config                     # Show Stata configuration
just lint-stata                       # Lint all do-files with stata_linter
just fmt-markdown                     # Format Markdown files
just help                             # See all available commands
```

### Full Development Environment

For Python tools and pre-commit hooks:

```bash
just get-started
```

This installs: `uv` (Python), `markdownlint-cli2`, and all Stata packages.

---

## IPA Coding Standards

All do-files in this repository follow IPA Stata standards:

- **Path management** via `setroot` and `${data}` globals — no hardcoded paths
- **Standard file header** with project name, file, purpose, author, date
- **Log open/close** in every script using `${logs}` and `${today}`
- **IPA extended missing values**: `.d` (don't know), `.r` (refused), `.n` (not applicable), `.o` (other/out of range), `.s` (skipped)
- **Defensive programming**: `assert`, `isid`, and merge validation throughout
- **Package management** via `.config/stata/stata_requirements.txt` — no `ssc install` in do-files

---

## Troubleshooting

**`setroot` not found** — Run `do setup.do` first to install required packages.

**"Root folder not found" error** — Change to the project directory in Stata
(`cd /path/to/repo`) before running `do do_files/00_run.do`.

**`household_survey_raw.dta` not found** — Run
`do setup/generate_synthetic_data.do` from the project root first.

**Stata path errors** — Check your `.env` file; ensure paths with spaces are
quoted.

**Package not found** — Run `just stata-setup` (or `do setup.do`) to install
all packages listed in `.config/stata/stata_requirements.txt`.

---

## Acknowledgments

This training is built on the [IPA Stata Template](https://github.com/PovertyAction/ipa-stata-template)
and the following resources:

- **IPA Data Cleaning Guide** — [data.poverty-action.org/data-cleaning](https://data.poverty-action.org/data-cleaning/)
- **IPA Stata Coding Standards** — [data.poverty-action.org/software/stata](https://data.poverty-action.org/software/stata/)
- **Data Carpentry: Stata for Economics** — [datacarpentry.github.io/stata-economics](https://datacarpentry.github.io/stata-economics/) (CC BY 4.0)
- **DIME Analytics Data Handbook** — [worldbank.github.io/dime-data-handbook](https://worldbank.github.io/dime-data-handbook/coding.html)
- **Sean Higgins Stata Guide** — [github.com/skhiggins/Stata_guide](https://github.com/skhiggins/Stata_guide)
- **ipaplots** — [github.com/PovertyAction/ipaplots](https://github.com/PovertyAction/ipaplots)
- **statacons** — [bquistorff.github.io/statacons](https://bquistorff.github.io/statacons/) (MIT)

## License

Released under the MIT License. See [LICENSE](LICENSE) for details.
