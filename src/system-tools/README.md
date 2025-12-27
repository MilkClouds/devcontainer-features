
# System tools (system-tools)

Create a dev user and install base OS packages.

## Example Usage

```json
"features": {
    "ghcr.io/MilkClouds/devcontainer-features/system-tools:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| username | Username to create | string | vscode |
| userUid | User UID | string | 1000 |
| userGid | User GID | string | 1000 |
| packages | Additional apt packages to install (space/comma-separated). See src/system-tools/install.sh for the default package list. | string | - |
| excludePackages | Apt packages to skip from the default install list (space/comma-separated). See src/system-tools/install.sh for the default package list. | string | - |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/MilkClouds/devcontainer-features/blob/main/src/system-tools/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
