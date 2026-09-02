---
name: common-pitfalls
description: >-
  Recurring errors and their fixes: markdown lint rules (MD022, MD024, MD029, MD031, MD032,
  MD040, MD060, wrapped-prose list traps), Windows PowerShell 5.1 quirks (no &&, ??, or
  ternary; ANSI default encoding; execution policy), Git Bash line-ending blind spots,
  thin-web-content fallbacks, and locked-down corporate machine constraints. Check before
  creating or editing any markdown file, when an error feels familiar, when a script fails on
  Windows for no clear reason, or when a web fetch returns suspiciously thin content.
---

# Common pitfalls

## When to use this skill

- Before creating or editing any markdown file.
- When an error looks like one seen before, or a PowerShell script fails with no clear cause.
- When a fetched web page comes back with almost no content.
- Before assuming a tool, extension, or service is available on the machine.

When an error repeats more than once, add it here with its fix. Use the format at the end.

## Markdown lint rules

### MD022: blank lines around headings

Problem: a heading with no blank line above or below it.

Fix: one blank line before and one after every heading.

### MD024: no duplicate headings

Problem: two headings in one file with the same text, usually `### API`, `### Usage`,
`### Example`, or `### Overview` repeated per component.

Fix: prefix the heading with the component name (`### Button API`, `### Select API`), or use a
bold label instead of a heading for repeated sub-sections.

### MD029: ordered list prefix

Problem: an ordered list mixes numbering styles, or the linter is configured for the other
style.

Fix: use one numbering style per file: all `1.` or sequential `1. 2. 3.`; sequential is this
repo's default. A fenced code block between two items resets the count, so indent the block
inside the item instead of splitting the list.

### MD031: blank lines around fenced code blocks

Problem: a code fence directly after or before a line of text.

Fix: one blank line before and one after every fenced code block.

### MD032: blank lines around lists

Problem: a list that starts or ends without a blank line separating it from prose.

```markdown
<!-- Bad -->
Some text
- Item 1
More text

<!-- Good -->
Some text

- Item 1

More text
```

### MD040: fenced code block language

Problem: a code fence with no language after the opening backticks.

Fix: always add one. Use `powershell`, `bash`, `json`, `markdown`, `mermaid`, or `text` for
directory trees and plain output.

### MD060: table column spacing

Problem: no space around table pipe separators.

```markdown
<!-- Bad -->
| Header1|Header2 |
|--------|--------|

<!-- Good -->
| Header1 | Header2 |
| ------- | ------- |
```

Fix: one space after every `|` and one space before the next `|`.

### MD004 / MD029: wrapped prose line that starts with `+`, `-`, or `*`

Problem: a long bullet or paragraph wraps, and the continuation line happens to start with
`+`, `-`, or `*` followed by a space. The linter reads it as a new list item and reports
MD004 or MD029. This bites most often in log and handoff prose that uses `+` to mean "and" at
a line break.

```markdown
<!-- Bad: the wrapped line starts with "+ " -->
- The build step carries the full directives
  + the dropped callouts + the surface.

<!-- Good -->
- The build step carries the full directives
  plus the dropped callouts and the surface.
```

Fix: never let a wrapped continuation line start with `+`, `-`, or `*` followed by a space.
Write "plus" or "and", or reflow the line so the symbol is not first.

## PowerShell and Windows quirks

### Windows PowerShell 5.1 lacks newer operators

Problem: a script written for PowerShell 7 fails to parse in Windows PowerShell 5.1, the
version installed by default and the one most likely on a corporate machine.

Symptom: `The token '&&' is not a valid statement separator`, or a parse error at `??` or
`? :`.

Fix: write for 5.1.

- No `&&` or `||` between commands. Use `;` and check `$?` or `$LASTEXITCODE`, or `if`.
- No `??` null-coalescing. Use `if ($null -eq $x) { $x = $default }`.
- No ternary `? :`. Use `if ($cond) { $a } else { $b }`.

### Set-Content writes ANSI by default

Problem: `Set-Content` and `Out-File` in 5.1 default to ANSI or UTF-16. Non-ASCII characters
come out corrupted, and other tools may reject the file.

Fix: always pass `-Encoding utf8`. In 5.1 that writes a byte-order mark. If a consumer rejects
the mark, use `[System.IO.File]::WriteAllText($path, $text,
[System.Text.UTF8Encoding]::new($false))`.

### Execution policy blocks scripts

Symptom: `File ...ps1 cannot be loaded because running scripts is disabled on this system.`

Fix: bypass the policy for that one invocation:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-kiro.ps1
```

`Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` also works when group policy allows it.
On a locked-down machine it often does not, so prefer the per-invocation flag.

### Path length limits

Symptom: file operations fail on deeply nested paths with no clear error.

Fix: keep the repo close to the drive root.

### Git Bash text tools silently strip carriage returns

Symptom: `grep -P '\r'` in Git Bash reports zero CRLF files while a byte-level read finds
many. MSYS text-mode reads drop the `\r` before the pattern sees it, and `git diff` hides it
when `core.autocrlf=true`.

Fix: do line-ending forensics with byte tools only, such as
`[System.IO.File]::ReadAllBytes($path)` or `xxd`. Pin any tree that is read raw at runtime to
`eol=lf` in `.gitattributes`.

## Thin web content

Problem: a plain HTTP fetch does not run JavaScript. Single-page applications return an empty
shell such as `<app-root></app-root>`.

Symptom: under about 500 characters for a page known to have a full body, or only navigation
and footer text.

Fallback chain:

1. Plain fetch first.
1. A headless-browser fetch, if one is available and approved, when the plain fetch returns a
   shell.
1. A web search when the problem is finding the right page, not reading a known one.
1. Ask the operator to paste the content when no rendering path exists. Name the URL and say
   why the fetch came back thin.

## Corporate machine

Assume a locked-down environment until the operator says otherwise.

- No IDE extension installs. Do not plan on a linter, formatter, or viewer that is not
  already present. Probe with one command before relying on a tool.
- MCP servers may be blocked. Design each step so it also works with read, write, and shell
  alone.
- No background daemons, watchers, or scheduled tasks unless the design names one and the
  operator has confirmed the site allows it. Build the one-command runner first; a trigger
  that calls it is a separate spec.
- Prefer one-command scripts: a single `.ps1` under `scripts/` that takes explicit
  parameters, prints what it did, and exits nonzero on failure. Chains of ad hoc shell
  commands do not survive a session handoff.

## Adding new issues

When an issue recurs, add it using this format:

```markdown
### Short issue title

Problem: what goes wrong.

Symptom: how it shows up (error text, behavior).

Fix: the solution, with a short example if one helps.
```
