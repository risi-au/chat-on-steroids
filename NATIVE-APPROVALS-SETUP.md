# Native Core worker approvals: staged build

The source change is committed locally as `800760a` and built as CoS
2.1.42. It uses the **existing CoS approval relay**, not the Brave approval
extension, and only applies to recorded CoS workers with enabled Core cards.
The default is **Off**; no currently running program was replaced.

## Switching to the staged version

1. Wait for all active CoS prime/worker work to finish. Do not interrupt an
   in-progress merge, test, push, or board report.
2. Quit the installed CoS application normally. Its configuration and
   recorded sessions remain in the same user profile.
3. Run `/home/rishi/Work/working-projects/cos-core-tool-description-fix/launch-patched-cos.sh`.
   The launcher refuses to start while the original CoS process is alive.
4. In the CoS **Settings > Sub-agents** panel, enable
   **Automatically allow Core tools for sub-agents**.
5. Disable the earlier **CoS Routine Approval Guard** Brave extension to avoid
   two competing approval mechanisms. Keep the official CoS browser extension.
6. With a harmless worker command that actually prompts for Core permission,
   verify the native app logs `auto-allowed Core request`, then verify the
   worker's command result. Passing simulated tests is not a live-provider test.

The staged build is reversible: quit it, then start the original installed
CoS. The original application files are unchanged.

## Verification performed

- TypeScript typecheck passed.
- The native approval test file passed (17 tests).
- Configuration + MCP + approval tests passed (300, 16 skipped).
- Production Electron/Vite build passed.
- Linux x64 unpacked application was assembled.
- The package's full native-runtime smoke test failed because Sharp segfaults
  under Electron on this host; the same test segfaults with the existing,
  untouched CoS 2.1.41 installation. This is a **known unresolved baseline
  issue**, so the staged build has not been declared a fully smoke-tested
  installer and has not replaced the installed app.

This mode cannot independently prove a Herdr instruction is safe. It relies on
CoS's recorded worker origin and your explicit one-time setting. It may also
allow warned Core actions; ordinary/prime chats and non-Core plugins are not
automatically allowed.
