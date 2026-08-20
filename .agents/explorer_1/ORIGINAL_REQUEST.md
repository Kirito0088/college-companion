## 2026-07-24T08:08:23Z
You are Explorer 1. Your task is to investigate the git branch `backup/glass-ui` in `c:\Projects\college_companion`.
Your working directory is `c:\Projects\college_companion\.agents\explorer_1`. Create your directory and files there.

Objective:
1. Run git commands (e.g., `git show backup/glass-ui:...`, `git log backup/glass-ui`, `git diff main..backup/glass-ui`, or `git checkout/branch` queries using `run_command` in `c:\Projects\college_companion`) to discover all Riverpod StreamProviders created in `backup/glass-ui`.
2. Locate providers such as `assignmentsStreamProvider`, `safeBunkStreamProvider`, `calendarEventsStreamProvider`, `dashboardSnapshotProvider`, `resourcesStreamProvider`, and any other providers, state notifiers, or stream helpers in that branch.
3. Record their exact code, function signatures, return types, repository calls, imports, and parameters.
4. Distinguish between data provider logic vs visual/styling code in `backup/glass-ui`. Identify any glassmorphism or neon styling that MUST NOT be copied over.
5. Write your complete analysis to `c:\Projects\college_companion\.agents\explorer_1\analysis.md` and write a handoff report in `c:\Projects\college_companion\.agents\explorer_1\handoff.md`.
6. Send your results back to parent using `send_message`.
