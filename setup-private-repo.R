
# --- Setup: libraries ---------------------------------------------------------
# Install packages if needed
if (!requireNamespace("usethis", quietly = TRUE)) install.packages("usethis")
if (!requireNamespace("gitcreds", quietly = TRUE)) install.packages("gitcreds")

library(usethis)

message("▶ Starting private GitHub repo setup (safe, no data).")

# --- 0) Optional: project sanity check ---------------------------------------
# Ensure we are in an RStudio project or a working directory that is your project.
# If needed, setwd("path/to/your/project")

# --- 1) Strong .gitignore (data & secrets OUT) -------------------------------
ignore_patterns <- c(
  # Folders commonly used for raw or sensitive data
  "data/", "data-raw/", "raw/", "private/", "secrets/", "outputs/", "outputs_sensitive/",
  # Typical data formats
  "*.csv", "*.xlsx", "*.xls", "*.rds", "*.RData", "*.parquet",
  "*.sav", "*.zsav", "*.dta", "*.sas7bdat",
  # Local databases and caches
  "*.sqlite", "*.db", "*.feather", ".cache/", "cache/",
  # Secrets / credentials
  ".env", ".Renviron", "*.key", "*.pem",
  # RStudio / OS artifacts
  ".Rproj.user", ".Rhistory", ".RData", ".Ruserdata", ".DS_Store", "Thumbs.db",
  # OAuth / Quarto
  ".httr-oauth", ".quarto"
)

usethis::use_git_ignore(ignore_patterns)
message("✔ .gitignore updated.")

# --- 2) Optional hygiene: add a README (document data access, no raw data) ---
if (!file.exists("README.md")) {
  usethis::use_readme_md(open = FALSE)
  cat("\n# Project README\n\n",
      "This repository stores **code and documentation only**.\n",
      "Sensitive data are kept in secure storage and are **not** tracked in Git.\n\n",
      "## Data access (internal)\n",
      "- Data lives in secure locations (e.g., SharePoint/OneDrive/Azure).\n",
      "- Configure credentials via `.Renviron` and read with `Sys.getenv()`.\n\n",
      "## Reproducibility\n",
      "- Scripts assume data are available locally via secure paths.\n",
      "- Provide synthetic/sample data for tests where feasible.\n",
      sep = "", file = "README.md", append = TRUE)
  message("✔ README.md added.")
}

# --- 3) Initialize Git and make a SAFE first commit --------------------------
# This will initialize a repo if needed and offer to make the first commit.
# Accept when prompted: only non-ignored, safe files are committed.
usethis::use_git()
message("✔ Local Git initialized and initial commit made (safe files only).")

# --- 4) Optional: set global default branch to 'main' ------------------------
# Applies to future repos. (Your current repo may still have 'master' until you rename.)
usethis::git_default_branch_configure("main")
message("✔ Default branch for future repos set to 'main'.")

# Rename the current repo’s branch to main (after the first commit).
# We'll use a shell command via system(); safe if Git is available.
# If this fails (e.g., Windows PATH issues), you can run it in the Terminal instead.
try({
  system("git branch -M main", ignore.stdout = TRUE, ignore.stderr = TRUE)
  message("✔ Current branch renamed to 'main'.")
}, silent = TRUE)

# --- 5) Safety check: ensure no sensitive files are staged -------------------
# Run git status to show you what's staged (informational).
message("ℹ Git status (for your review):")
system("git status")

# --- 6) GitHub token: create/store if missing --------------------------------
sit <- usethis::git_sitrep()
has_pat <- grepl("Personal access token.*https://github.com", capture.output(print(sit)))

if (!has_pat) {
  message("✖ No GitHub Personal Access Token found. Let's create one.")
  message("   In the browser: choose scopes minimally: 'repo' (plus 'workflow' only if you use Actions).")
  usethis::create_github_token()   # opens browser
  message("ℹ Copy the token from GitHub, then paste it at the next prompt.")
  gitcreds::gitcreds_set()         # prompts in the console
  message("✔ Token stored. Re-checking sitrep:")
  print(usethis::git_sitrep())
} else {
  message("✔ GitHub token already configured.")
}

# --- 7) Create PRIVATE GitHub repo and push ----------------------------------
# For personal repo:
usethis::use_github(private = TRUE)

# If you need to create under an org instead, comment the above and uncomment:
# usethis::use_github(private = TRUE, organisation = "YOUR_ORG_NAME")

message("✔ Private GitHub repository created and linked. Safe files pushed.")

# --- 8) Post-setup tips ------------------------------------------------------
message("✅ Done. Next:")
message(" - Invite collaborators: GitHub → Settings → Manage access → Add people.")
message(" - Keep secrets in .Renviron or .env (ignored) and use Sys.getenv().")
message(" - Place data in secure storage; do not commit data to GitHub.")
