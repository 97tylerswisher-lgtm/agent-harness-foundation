# Requirements: text-to-vba-to-matlab-to-pdf

## Introduction

This job turns every delimited text export in a folder into one PDF report per file, through
an existing spreadsheet macro and an existing MATLAB function, and stops when the operator
opens the PDFs. It implements `goal-contract.md` in this folder. Every column name, switch
name, and file pattern below is synthetic and comes from the cards under `cards/`.

## Requirements

### Requirement 1

User Story: As the operator, I want every export file in a folder parsed the same way the
existing macro parses it, so that no file needs hand editing before the report runs.

Acceptance Criteria:

1. WHEN the input folder holds one or more `*.txt` files THE SYSTEM SHALL parse each one per
   `cards/schema-card.md` and list the file name, column count, and row count in the log
2. WHEN a file starts with any number of lines beginning with `#` THE SYSTEM SHALL skip them
   and treat the first other line as the column header
3. WHEN the column header contains a tab THE SYSTEM SHALL split every line on tabs
4. WHEN a line beginning with `# summary` is reached THE SYSTEM SHALL stop reading that file
5. WHEN the `ch04_ue` column is absent THE SYSTEM SHALL continue with the columns present
6. WHEN a data row has a field count that differs from the header THE SYSTEM SHALL stop with
   exit code 1 and a message naming the file and line number
7. WHEN the input folder is missing or holds no `*.txt` file THE SYSTEM SHALL stop with exit
   code 1
8. WHEN the column header contains no tab but contains a comma THE SYSTEM SHALL split every
   line on commas

### Requirement 2

User Story: As the operator, I want the existing macro run without opening Excel by hand, so
that the reshape step is repeatable.

Acceptance Criteria:

1. WHEN step 1 runs THE SYSTEM SHALL start Excel through COM, invisible, with alerts off
2. WHEN a table is parsed THE SYSTEM SHALL place it in a new workbook, header in row 1
3. WHEN `-MacroName` is given THE SYSTEM SHALL open `-MacroWorkbook` and call
   `Application.Run` with that name once per table
4. WHEN the macro halts THE SYSTEM SHALL log the COM error, quit Excel, and exit with code 2
5. WHEN a table is done THE SYSTEM SHALL save `<name>.xlsx` from Excel, write `<name>.csv`
   from the table with a comma delimiter regardless of the machine's list separator, and
   close the workbook
6. WHEN step 1 ends, on success or failure, THE SYSTEM SHALL call `Quit` and release every
   COM object it created
7. WHEN `-SkipExcel` is given THE SYSTEM SHALL write `<name>.csv` directly from the parsed
   table and run no Excel step
8. WHEN `-MacroName` is omitted THE SYSTEM SHALL run no macro
9. WHEN a macro has run on a table THE SYSTEM SHALL write `<name>.csv` from the reshaped
   sheet, not from the parsed table

### Requirement 3

User Story: As the operator, I want the existing MATLAB function called on each CSV with no
window and no dialog, so that the run finishes unattended.

Acceptance Criteria:

1. WHEN step 2 runs THE SYSTEM SHALL start `matlab.exe -batch` with
   `addpath('<FunctionFolder>'); make_report('<csv>','<pdf>')` once per CSV
2. WHEN `matlab.exe` exits THE SYSTEM SHALL log its exit code and wall-clock time
3. WHEN MATLAB writes output THE SYSTEM SHALL keep it in `<name>.matlab.log`,
   `<name>.matlab.stdout.txt`, and `<name>.matlab.stderr.txt` beside the PDF and delete the
   ones that stay empty
4. WHEN `matlab.exe` cannot be found THE SYSTEM SHALL stop with exit code 3 and say to pass
   `-MatlabExe`
5. WHEN the `matlab.exe` exit code is non-zero THE SYSTEM SHALL stop with exit code 3 and a
   message naming the file

### Requirement 4

User Story: As the reviewer, I want to know the PDF is real before I open it, so that I do
not open an empty or missing file.

Acceptance Criteria:

1. WHEN a PDF is missing or has size zero after step 2 THE SYSTEM SHALL stop with exit code 4
2. WHEN a PDF exists THE SYSTEM SHALL count its pages as the number of `/Type /Page` objects,
   excluding `/Type /Pages`, and print the path, size, and page count
3. WHEN every PDF passes THE SYSTEM SHALL print one line naming the human gate and exit 0
4. WHEN the gate line is printed THE SYSTEM SHALL do nothing further

### Requirement 5: scope fence

User Story: As the operator, I want the job to stop at the data boundary and the human gate,
so that no real export, macro body, or function body enters the IDE and no step past the PDF
review runs on its own.

Acceptance Criteria:

1. WHEN a real export file, the real macro workbook, the real MATLAB function, or a rig,
   program, or part identifier would enter the IDE THE SESSION SHALL stop and report instead
   of reading it
2. WHEN step 3 completes THE SESSION SHALL show the operator the PDF list and run no later
   step until the operator responds
3. WHEN a step after the PDF review (filing, mailing, sign-off) would run THE SESSION SHALL
   stop and report

## Checks before showing the operator

- Every done-when criterion in `goal-contract.md` maps to one requirement: done-when 1 to
  1.1 and 3.1; done-when 2 to 1.2, 1.3, and 1.8; done-when 3 to 2.4 and 3.5; done-when 4 to
  4.4 and 5.2. Done-when 5 is a record-keeping criterion; it maps to task 9 in `tasks.md`
  and the Verification section of `design.md`, not to a runtime behavior.
- Every criterion has one condition and one observable behavior.
- No criterion contains a real value, path, name, or identifier. Column names, switch names,
  and file patterns are the synthetic ones from `cards/`.
- Criteria are numbered requirement.item so `tasks.md` can cite them (1.1, 1.2, 2.1).
