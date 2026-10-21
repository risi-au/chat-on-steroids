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

## Merged onto upstream 2.1.44 (2026-10-21)

Upstream `origin/main` (`05926b21`, release 2.1.44) was merged into local `main`
(`c0109758`) with both native-approval commits intact. Only `approval-wait.ts`
and `approval-wait.test.ts` conflicted: the merged `ApprovalWaitDeps` keeps
upstream's `previous()` recovery row and the local `autoApproveWorkerCard()`
relay, and `isCoreApprovalCard()` stays next to them. Two upstream checks newly
covered the local setting: `feature-parity` pins the default `multiAgent` shape
(now including `autoApproveWorkerCoreCards: false`) and the 2.1.44 i18n test
requires every static label in all catalogs, so the setting's label and help
text were translated into the twelve locales. Its help text says "this plugin"
instead of "this connector", as 2.1.44 requires.

Verification: `npm run typecheck` clean; `npm test` 9,687 passed / 16 failed,
where fifteen failures reproduce identically on untouched `origin/main`
(`app-proxy` 1, `skill-library` 6, `codex-plugin-snapshot` 8 — they read this
machine's real Codex/skill folders) and `mcp.test.ts > answers usage without the
identity notice` passes alone (189/189) and only trips under full-suite load.
`npm run dist:dir:linux:x64` assembled 2.1.44; the asar reports 2.1.44 and
contains `autoApproveWorkerCoreCards` and the `auto-allowed Core request` relay.

Handoff: `switch-to-native-approvals.sh` now reads the expected version from
`package.json` instead of hardcoding 2.1.42. It ran through a transient
systemd unit once the worker showed no running tool calls: 2.1.42 exited, the
old staged tree moved to `release/linux-unpacked-2.1.42-native-bak`, 2.1.44
started as pid 2562575, `control-api/endpoint.json` reports 2.1.44. Saved config
kept every value; only the new upstream `ui.rotateStopFallback` default and
`ui.lastSeenVersion` changed, and `multiAgent.autoApproveWorkerCoreCards` stays
true. The bridge is paired with extension 2.1.44. Auto-connect is off in this
config, so the fresh process starts disconnected until Connect is pressed. The
official install in `~/.local/opt/Chat On Steroids/` is untouched and remains
the rollback.

## Fork and remotes (2026-10-21)

Upstream is read-only for this account, so the repo now has a fork of its own:

- `origin` — `https://github.com/risi-au/chat-on-steroids.git` (our fork; `main`
  is pushed here and is the tracking branch)
- `upstream` — `https://github.com/totec448-spec/chat-on-steroids.git` (official
  source, read-only)

Forking also brought eight commits that landed upstream after the 2.1.44 tag, so
`upstream/main` (`3683afc9`) was merged into `main` (`f541cc1d`) on top of the
verified merge. Only `src/main/bridge.ts` overlapped: the auto-merge kept the
local `approvalWaitDeps.autoApproveWorkerCard` relay (the config gate and the
recorded `origin.kind === 'worker'` check) beside upstream's queued-Stop
changes, and `isCoreApprovalCard` in `approval-wait.ts` is unchanged. `npm run
typecheck` is clean and `bridge-turn-rotation`, `renderer-state`,
`approval-wait` and `feature-parity` pass (205 tests). The running app is still
the 2.1.44 build from `c88ccc40`; these later commits are CI, release-note and
test changes plus one queued-Stop fix, so they are not built or installed here.

Because the repo is now a fork, the upstream workflows (`codeql`,
`draft-release-notes`, `issue-version`, `needs-info`, `pr-not-ready`,
`pr-triage`, `release-checklist`, `similar-issues`, `verify-release`) all gate on
`github.repository == 'totec448-spec/chat-on-steroids'`, so they do nothing in
the fork. Pushing here never builds or publishes a release.

Future upstream updates: `git fetch upstream && git merge upstream/main` on
`main`, keeping the two native-approval commits intact, then push to `origin`.
