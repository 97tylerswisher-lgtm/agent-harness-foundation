# hooks

Kiro reads every `*.json` file in this folder. A `.md` file here is ignored.

## harness-checks.json

Two command hooks. Each runs a script from `scripts/` and feeds its output back to the agent:
on exit 0 the script's stdout enters the agent's context; on a non-zero exit its stderr does.
Neither hook costs credits.

| Hook | Trigger | Command | Effect |
| --- | --- | --- | --- |
| Check every spec after a task | `PostTaskExecution` | `scripts/check-spec.ps1 -All` | every folder under `.kiro/specs/` is checked when a spec task finishes; a `FAIL` line reaches the agent |
| Redaction check when the agent stops | `AgentStop` | `scripts/check-redaction.ps1` | the repo is scanned for `scripts/banned-terms.txt` terms when the agent stops; each hit reaches the agent |

The hooks make the two checks mechanical. The steering still tells the agent to run the
scripts by hand; the hooks remove the case where it forgets.

## Where they run

- Only inside Kiro. The scripts work unchanged from a terminal; the hooks do not.
- Only if the site allows command hooks. A locked-down workspace may block local shell
  actions. If the hook panel shows the hooks as blocked, run the scripts by hand.
- Both commands are plain Windows PowerShell 5.1 with no modules and no network.

## Verify the trigger names once

The trigger names follow the Kiro 1.0 hooks docs (`https://kiro.dev/docs/hooks/types/`).
Kiro 0.x used `.kiro.hook` files with a different format; 1.0 shows those with a legacy badge.
Open the IDE's hook panel once after cloning and confirm that both hooks load without a
format warning and that `PostTaskExecution` and `AgentStop` appear in its trigger list. If a
name differs, change the `trigger` value in `harness-checks.json` to the panel's spelling.

## Disable a hook

Add `"enabled": false` to that hook's object in `harness-checks.json`:

```json
{
  "name": "Redaction check when the agent stops",
  "enabled": false,
  "trigger": "AgentStop",
  "action": { "type": "command", "command": "powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-redaction.ps1" }
}
```

Delete the file to remove both hooks.
