Copy this file to `.kiro/specs/<kebab-name>/cards/interface-card.md`, one per spec. The
operator fills it from the existing scripts, outside the IDE. Signatures only; never a body,
formula, or query. Delete these instruction lines when done.

# Interface card: <job name>

## How to fill it

- One entry per existing script or macro the job calls.
- Arguments carry a type and a one-line meaning. Values are placeholders, never real ones.
- Side effects list every file written and every external system touched.
- The invocation line is the exact form the runner uses. It is copied into the Invocations
  section of `design.md`.

## Entry points

### <Entry point 1, for example "ExportSummary macro">

- Kind: <Excel VBA macro, MATLAB function, PowerShell script, SQL stored procedure>
- Lives in: <the file by role, for example "the shared macro workbook">
- Signature: `<Name(argument1 As Type, argument2 As Type) As ReturnType>`
- Arguments:
  - `<argument1>` (<type>): <meaning>
  - `<argument2>` (<type>): <meaning>
- Returns or produces: <a return value, or a file at <generic path pattern>>
- Side effects: <files written, workbooks opened, external systems touched, or "none">
- Preconditions: <what must exist before the call, for example "the input file is closed">
- Failure signal: <exit code, error dialog, empty output, log line>
- Invocation:

  ```powershell
  <exact command the runner uses, for example a COM call or matlab -batch "<call>">
  ```

### <Entry point 2>

- Kind: <>
- Lives in: <>
- Signature: `<>`
- Arguments:
  - `<argument>` (<type>): <meaning>
- Returns or produces: <>
- Side effects: <>
- Preconditions: <>
- Failure signal: <>
- Invocation:

  ```powershell
  <exact command>
  ```

## Environment

- Tools available on the machine: <names and versions by role, for example "Excel with
  macros enabled, MATLAB with the batch flag, PowerShell 5.1">
- Tools not available: <for example "no Python, no Node">
- Working directory the runner starts in: <relative to the repo root>

## Review

- Filled by: <the operator, on <date>>
- Checklist run: <yes, on <date>>
