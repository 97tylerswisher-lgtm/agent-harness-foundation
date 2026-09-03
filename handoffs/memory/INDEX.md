# Memory index

This folder holds facts a future session would otherwise re-derive: operator preferences,
standing corrections, project facts, and reference pointers. One fact per file. This index is
loaded every session through `.kiro/steering/00-session-opener.md`; the files are opened on
demand. Each row is one line: the file name, a hook that says when the fact applies, and its
type. Never put the memory content here; the hook is enough to decide whether to open the
file.

Types: `operator` (how the operator works), `feedback` (a standing correction), `project` (a
fact about this repo or the job), `reference` (a pointer to a source that answers a question).

Write each hook line with the literal keywords a later search would use (file names, tool
names, the operator's own words); retrieval here is grep and reading, not semantic search.
Keep the index under 200 lines.

| name | one-line hook | type |
| --- | --- | --- |
| `operator-profile-pointer` | any question about how to talk to the operator or what they decide | operator |
| `kiro-specs-only-job-contract` | about to write a plan, task list, or contract outside `.kiro/specs/` | project |
