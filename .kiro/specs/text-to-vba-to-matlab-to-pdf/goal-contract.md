# Goal contract: text-to-vba-to-matlab-to-pdf

Worked example. The job: delimited text files from a test rig land in a folder, an existing
Excel macro reshapes them, an existing MATLAB function turns the result into a multi-plot PDF,
and a person reviews the PDF. Everything here is synthetic.

## 1. Judge

Real: the operator's review of the PDF against the hand-built report they make today.
Proxy: `run-report.ps1` exit 0 plus the step-3 check (PDF exists, size > 0, page count >= 1).
The proxy is annotate-only. It proves the pipeline ran, not that the plots are right.

## 2. Done-when

1. One command turns every `*.txt` in the input folder into `<name>.pdf` in the output folder.
2. The three fixture variations (clean, extra comment line, comma-delimited) all parse.
3. A halted macro or a MATLAB error stops the run with a non-zero exit and a message that
   names the file.
4. The run stops at the human gate. Nothing is automated past it.
5. The dry run on the synthetic fixtures is recorded in `design.md` under Verification.

## 3. Minimum inputs

`cards/schema-card.md`, `cards/edge-case-catalog.md`, `cards/interface-card.md`, and
`fixtures/*.txt` (20 synthetic rows each). Cheapest source for each: a file the operator wrote
outside the IDE. No real export ever enters.

## 4. Roles

One code-worker at the default tier builds `run-report.ps1` and the stubs and runs the dry run.
One fresh-eye critic blind-checks the spec against the cards. The operator is the
classification judge for anything that might be real data.

## 5. Do-not-touch

Real export files, the real `reshape.xlsm`, the real `make_report.m`, and any rig, program, or
part identifier: none enters the IDE or the repo (`steering/40-data-boundary.md`). The human
PDF review is the gate. No step after it (filing, mailing, sign-off) is automated.

## 6. Verification

`run-report.ps1` output with exit code, the PDF paths with size and page count, and the
dry-run record in `design.md`. Run state lands in `handoffs/NEXT_AGENT_HANDOFF.md` at the
closing checkpoint.
