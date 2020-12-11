#set the environment value AZURE_DEVOPS_EXT_PAT with the PAT value to fully automatize the process
#If it doesn' work, pipe the variable into the login command

#1
az extension add --name azure-devops

#2
#$pat | az devops login
az devops login

#3
az devops project create --org $orgUrl --name MyNewProject

#4-Get the Project Administrators group Id
az devops security group list -p $projectName --org $orgUrl --query "graphGroups[?contains(principalName,'Project Administrators')].descriptor" -o tsv

#5-Query an org level
az devops security group list --org $orgUrl --scope organization --query "graphGroups[?contains(principalName,'Specialists')].descriptor" -o tsv

#6-Add membership to a Team project group
az devops security group membership add --org $orgUrl --group-id $projAdminGroupDescriptor --member-id $specialistGroupDescriptor

#7-Check if a git repo exists
az devops security group membership add --org $orgUrl --group-id $projAdminGroupDescriptor --member-id $specialistGroupDescriptor