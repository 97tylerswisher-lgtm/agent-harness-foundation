---
name: operator-profile-pointer
description: The operator's standing preferences live in one steering file; open it instead of re-deriving them.
type: operator
---

The operator's standing preferences (reply length, ask format, what they decide and what the
session decides, their work context) are in `.kiro/steering/10-operator-profile.md`, which is
always loaded. Do not re-derive or re-ask them; when a preference changes, edit that file.
