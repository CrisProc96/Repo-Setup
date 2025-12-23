
# Repo-Setup

<!-- badges: start -->
<!-- badges: end -->

The goal of Repo-Setup is to ...


# Project README

This repository stores **code and documentation only**.
Sensitive data are kept in secure storage and are **not** tracked in Git.

## Data access (internal)
- Data lives in secure locations (e.g., SharePoint/OneDrive/Azure).
- Configure credentials via `.Renviron` and read with `Sys.getenv()`.

## Reproducibility
- Scripts assume data are available locally via secure paths.
- Provide synthetic/sample data for tests where feasible.
