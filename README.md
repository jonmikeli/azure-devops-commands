# Azure DevOps Commands
This repository contains a set of `az cli` commands related to Azure DevOps operations.

The commands take in charge basic operations when it comes to creating Team Projects.
The script can be useful in contexts where the Team Projects need to be created in an industrialized manner and according to specific rules/configurations.

## Covered steps
 - Team Project creation
 - Teams creation
 - Areas creation
 - Areas and Teams permissions
 - Teams memberships
 - Repository creations
 - Configuration of policies (repository)
 - Wiki creation
 - Structure of folders at pipeline level
 - Group of variables (per repository) with default values
 - Extensions installation

The other fields cannot be scripted for now.

The names of projects, repositories, areas, folders, teams, etc are normed and follow certain types of practices.

## How to use the scripts?
### Scripts
The repository contains two scripts:
 - `createTeamProject.sh`, script launcher
 - `commands.sh`, contains the logic

### How to...
You only need to execute `createTeamProject.sh`.

```bash
createTeamProject.sh
```

This file contains the settings to call the commands inside `commands.sh`.

```bash
./commands.sh \
-o "https://your_organization" \
-c "[customer name]" \
-m "[customer code]" \
-p "[team project name]" \
-f "[path to the file containing the PAT code]"
```