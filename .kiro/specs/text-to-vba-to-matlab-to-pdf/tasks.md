# Tasks: text-to-vba-to-matlab-to-pdf

- [x] 1. Copy the goal contract into the spec folder (`goal-contract.md`)
  - Copy the file unchanged from the `goal-definition` output
  - Check: field 5 (do-not-touch) names the data boundary and the human gate, and Requirement
    5 restates both
  - _Requirements: 5.1, 5.2, 5.3_

- [x] 2. Write the three cards under `cards/` and `fixtures/README.md`
  - Schema card: columns, delimiter, header lines, encoding
  - Edge-case catalog: one row per variation, each pointing at a fixture or "describe only"
  - Interface card: the macro and function signatures, no bodies
  - Check: every catalog row names a fixture or says "describe only"; no real name or value
    in any card
  - _Requirements: 1.2, 1.3, 1.4, 1.5, 1.8, 5.1_

- [x] 3. Generate three synthetic fixtures, 20 rows each
  - `run_001.txt` clean, `run_002.txt` extra comment line, `run_003.txt` comma-delimited
  - Values from formulas; comment lines carry placeholder text
  - Check: each file has 20 data rows and the six schema-card columns
  - _Requirements: 1.1, 1.2, 1.3, 1.8, 5.1_

- [x] 4. Implement the parser in `run-report.ps1`
  - Skip leading `#` lines; stop at `# summary`; detect tab or comma from the header line
  - Parse every field as a double with the invariant culture
  - Stop with exit 1 on a field-count mismatch, naming file and line
  - Check: all three fixtures log "6 columns, 20 rows"
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8_

- [x] 5. Implement step 1 in `run-report.ps1`: Excel via COM
  - Start Excel invisible with alerts off; one new workbook per table; `Value2` on a 2-D array
  - Run the macro when `-MacroName` is given and read the sheet back after it
  - Save `<name>.xlsx` from Excel; write `<name>.csv` from the script with a comma delimiter
  - Quit and release every COM object in `finally`; `-SkipExcel` writes the CSV directly
  - Check: the CSV bytes start with `time_s` (no BOM), fields are separated by `,`, and the
    file contains no `;`
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9_

- [x] 6. Implement step 2 in `run-report.ps1`: MATLAB
  - `Start-Process` with `-batch` and `-logfile`; redirect stdout and stderr to files
  - Log the exit code and wall-clock time; a non-zero code becomes script exit 3
  - Stop with exit 3 when `matlab.exe` is not found
  - Check: with a launcher that exits 1, the script exits 3 and names the file
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 7. Implement step 3 in `run-report.ps1`: PDF check and gate line
  - Exists and size > 0, else exit 4; page count from `/Type /Page` objects
  - Print path, size, and pages; print the gate line; exit 0
  - Check: a hand-written two-page PDF reports 2 pages, not 3
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 8. Write `stubs/make_report.m` and `stubs/README.md`
  - Same signature as the interface card; reads the CSV, plots, prints one PDF
  - Check: the signature line equals the one in `cards/interface-card.md`
  - _Requirements: 3.1_

- [x] 9. Dry run on the fixtures; record the command and output under Verification in
  `design.md`
  - Run from the spec folder with an output folder outside the repo
  - Paste the output and state every edit made to it
  - Check: the Verification section names the exit code and every file produced
  - _Requirements: 1.1, 2.5, 3.2, 4.3_

- [ ] 10. Rerun the dry run on a machine with a working MATLAB license
  - Record PDF sizes and page counts; confirm the stub prints one page
  - Check: step 2 exits 0 for all three fixtures and step 3 reports 1 page each
  - _Requirements: 3.2, 4.2_

- [ ] 11. Human gate: stop and show the operator the PDF list from step 3
  - Do not mark this task done. The operator marks it.
  - _Requirements: 5.2, 5.3_

## Orphan check

- Requirement numbers with no task: none
- Tasks with no requirement line: none
