# Security Policy

## Supported versions

Only the latest release and the `main` branch receive security fixes.

## Reporting a vulnerability

**Please do not open a public issue for security problems.**

Use GitHub private vulnerability reporting:
[Report a vulnerability](https://github.com/makaDv/CmdCrate/security/advisories/new)

Include:
- what is affected (file, function, parameter),
- steps to reproduce,
- the impact you expect.

You will get a first answer within 7 days. Once a fix is released, the advisory is published and you are credited unless you prefer otherwise.

## Scope

In scope: `CmdCrate.ps1`, `install.ps1`, `apps.json`, `checksums.txt`, the build/CI files in this repository.

Out of scope: vulnerabilities in winget itself or in the third-party apps listed in the catalog. Report those to Microsoft or to the app publisher.

## Security design

- Apps come only from the official `winget` source, by exact ID.
- Package IDs are validated against `^[A-Za-z0-9][A-Za-z0-9._+\-]{0,127}$` before reaching winget.
- No `Invoke-Expression` on data; catalog and import files are parsed as JSON only.
- `install.ps1` verifies SHA256 hashes of downloaded files before running them.
- No telemetry or outbound requests other than GitHub (download) and winget.
