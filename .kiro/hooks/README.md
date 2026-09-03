# hooks

Kiro reads every `*.json` file in this folder. A `.md` file here is ignored.

## harness-checks.json

Two command hooks and one agent hook. Each command hook runs a script from `scripts/` and feeds
its output back to the agent: on exit 0 the script's stdout enters the agent's context; on a
non-zero exit its stderr does. Neither command hook costs credits. The agent hook sends a
prompt to the agent instead of running a script; it ships disabled.

| Hook | Trigger | Action | Effect |
| --- | --- | --- | --- |
| Check every spec after a task | `PostTaskExec` | command: `scripts/check-spec.ps1 -All` | every folder under `.kiro/specs/` is checked when a spec task finishes; a `FAIL` line reaches the agent |
| Redaction check when the agent stops | `Stop` | command: `scripts/check-redaction.ps1` | the repo is scanned for `scripts/banned-terms.txt` terms when the agent stops; each hit reaches the agent |
| Wrap check when the agent stops | `Stop` | agent: a prompt (disabled) | the agent walks the Before-you-claim-done table in `.kiro/steering/20-method.md` over its last reply and the handoff, fixes unproven claims, and fills missing loop-log decisions |

The hooks make the checks mechanical. The steering still tells the agent to run the scripts
and the claim table by hand; the hooks remove the case where it forgets.

## The wrap check is disabled by default

The wrap check is an agent-action `Stop` hook. It costs one prompt every time the agent
stops, and a prompt that ends with the agent stopping can trigger the hook again. Verify it
once in the IDE before relying on it: enable it, end one short session, and confirm the agent
stops after one pass. Enable it when the site blocks command hooks; the two script checks then
cannot run, and the prompt is the only mechanical check left.

## Where they run

- Only inside Kiro. The scripts work unchanged from a terminal; the hooks do not.
- Only if the site allows command hooks. A locked-down workspace may block local shell
  actions. If the hook panel shows the command hooks as blocked, run the scripts by hand and
  consider enabling the wrap check.
- Both commands are plain Windows PowerShell 5.1 with no modules and no network.

## Verify the trigger names once

The trigger names follow the Kiro 1.0 hooks docs (`https://kiro.dev/docs/hooks/types/`).
Kiro 0.x used `.kiro.hook` files with a different format; 1.0 shows those with a legacy badge.
Open the IDE's hook panel once after cloning and confirm that all three hooks load without a
format warning and that `PostTaskExec` and `Stop` appear in its trigger list. If a
name differs, change the `trigger` value in `harness-checks.json` to the panel's spelling.

## Enable or disable a hook

Set `"enabled"` on that hook's object in `harness-checks.json`. A missing `enabled` field
means enabled.

```json
{
  "name": "Wrap check when the agent stops",
  "enabled": true,
  "trigger": "Stop",
  "action": { "type": "agent", "prompt": "Before you finish: ..." }
}
```

Delete the file to remove all three hooks.
