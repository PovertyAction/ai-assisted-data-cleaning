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
- Stata 17+
- VS Code with the [GitHub Copilot](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) extension

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

   ```stata
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
|--------|------|-------|
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
│   ├── 05_labeling_codebook.do         # MODULE 05: Variable labels and codebook
│   └── functions.do                    # Reusable helper functions (from IPA template)
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
├── logs/                               # Timestamped Stata log files
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
|--------|---------|---------|
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

For Python tools, pre-commit hooks, and Quarto:

```bash
just get-started
```

This installs: `uv` (Python), `Quarto`, `markdownlint-cli2`, `nbstata` (Stata
in VS Code/Jupyter), and all Stata packages.

### VS Code Integration with nbstata

Run Stata interactively in VS Code (similar to the Ctrl+D workflow):

1. Install the [vscode-stata](https://marketplace.visualstudio.com/items?itemName=kylebutts.vscode-stata) extension
2. Select the nbstata kernel at `.venv/Scripts/python.exe` (Windows) or `.venv/bin/python` (macOS/Linux)
3. Test with the demo files in `do_files/demo/`

### Dependency Tracking with scons

For projects where full rebuilds take more than a few minutes:

```bash
just stata-build    # Only rebuild files whose inputs changed
just stata-clean    # Remove all outputs
```

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
