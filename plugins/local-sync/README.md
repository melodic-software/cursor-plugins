# local-sync

Keeps Melodic Cursor marketplace plugins current on a personal machine by
copying `plugins/<name>/` into `~/.cursor/plugins/local/<name>/`.

## Usage

From the `cursor-plugins` repo root:

```powershell
pwsh -File scripts/sync-local.ps1
# or a subset:
pwsh -File scripts/sync-local.ps1 -Plugin hello,local-sync
```

```bash
bash scripts/sync-local.sh
bash scripts/sync-local.sh hello local-sync
```

In Cursor (after this plugin is itself local-synced once): run **`/sync-local`**.

Then **Developer: Reload Window**.
