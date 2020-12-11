#set the environment value AZURE_DEVOPS_EXT_PAT with the PAT value to fully automatize the process
#If it doesn' work, pipe the variable into the login command

az extension add --name azure-devops

#$pat | az devops login
az devops login

az devops project create --org $orgUrl --name MyNewProject

