#set the environment value AZURE_DEVOPS_EXT_PAT with the PAT value to fully automatize the process
#If it doesn' work, pipe the variable into the login command

#Variables
orgUrl="https://jmi.visualstudio.com"
projectName="TestTeamProject"
patCode=$(<PATTokens.txt)
export AZURE_DEVOPS_EXT_PAT=$patCode
repoName="JMI.$projectName"

customersTeamName="$projectName-customers"
developersTeamName="$projectName-developers"
devOpsAdminsTeamName="$projectName-devOpsAdmins"
managersTeamName="$projectName-managers"
releaseManagersTeamName="$projectName-releaseManagers"

#1
az extension add --name azure-devops

#2
#az login --tenant [tenantId] in case of needed
#az account set -s [subscriptionId]
#az account show

echo $patCode | az devops login --verbose --org $orgUrl
#az devops login

#3-Team project
az devops project create --org $orgUrl --name $projectName -s git --visibility private

#3b-Teams
az devops team create --name $customersTeamName --description "Customers team" --org $orgUrl -p $projectName
az devops team create --name $developersTeamName --description "Developers team" --org $orgUrl -p $projectName
az devops team create --name $devOpsAdminsTeamName --description "DevOps managers team" --org $orgUrl -p $projectName
az devops team create --name $managersTeamName --description "Managers team" --org $orgUrl -p $projectName
az devops team create --name $releaseManagersTeamName --description "Release managers team" --org $orgUrl -p $projectName

#3c-Areas
az boards area project create --name "0-Requirements" --org $orgUrl --project $projectName

az boards area project create --name "1-Management" --org $orgUrl --project $projectName

az boards area project create --name "2-Architecture" --org $orgUrl --project $projectName
az boards area project create --name "2.1-POC" --org $orgUrl --path "\\$projectName\\Area\\2-Architecture" --project $projectName
az boards area project create --name "2.2-Design" --org $orgUrl --path "\\$projectName\\Area\\2-Architecture" --project $projectName
az boards area project create --name "2.3-Documentation" --org $orgUrl --path "\\$projectName\\Area\\2-Architecture" --project $projectName

az boards area project create --name "4-Development" --org $orgUrl --project $projectName
az boards area project create --name "4.1-UI" --org $orgUrl --path "\\$projectName\\Area\\4-Development" --project $projectName
az boards area project create --name "4.2-API" --org $orgUrl --path "\\$projectName\\Area\\4-Development" --project $projectName
az boards area project create --name "4.3-Persistance" --org $orgUrl --path "\\$projectName\\Area\\4-Development" --project $projectName
az boards area project create --name "4.4-Containerization" --org $orgUrl --path "\\$projectName\\Area\\4-Development" --project $projectName
az boards area project create --name "4.5-ARM" --org $orgUrl --path "\\$projectName\\Area\\4-Development" --project $projectName

az boards area project create --name "5-Tests" --org $orgUrl --project $projectName
az boards area project create --name "5.1-Unit tests" --org $orgUrl --path "\\$projectName\\Area\\5-Tests" --project $projectName
az boards area project create --name "5.2-Integration tests" --org $orgUrl --path "\\$projectName\\Area\\5-Tests" --project $projectName
az boards area project create --name "5.3-Deployment tests" --org $orgUrl --path "\\$projectName\\Area\\5-Tests" --project $projectName
az boards area project create --name "5.4-Load tests" --org $orgUrl --path "\\$projectName\\Area\\5-Tests" --project $projectName
az boards area project create --name "5.5-Running tests" --org $orgUrl --path "\\$projectName\\Area\\5-Tests" --project $projectName
az boards area project create --name "5.6-Security tests" --org $orgUrl --path "\\$projectName\\Area\\5-Tests" --project $projectName

az boards area project create --name "6-DevOps" --org $orgUrl --project $projectName

az boards area project create --name "7-Others" --org $orgUrl --project $projectName
az boards area project create --name "7.1-Code review" --org $orgUrl --path "\\$projectName\\Area\\7-Others" --project $projectName
az boards area project create --name "7.2-Pair programming" --org $orgUrl --path "\\$projectName\\Area\\7-Others" --project $projectName
az boards area project create --name "7.3-Meetings" --org $orgUrl --path "\\$projectName\\Area\\7-Others" --project $projectName
az boards area project create --name "7.4-Assistance" --org $orgUrl --path "\\$projectName\\Area\\7-Others" --project $projectName

#3d
#Note: the missing 'Area' part in the path is due to the API does not take it into account for boards and team memberships
az boards area team add --path "\\$projectName\\0-Requirements" --team $customersTeamName --include-sub-areas true --org $orgUrl --project $projectName --set-as-default

az boards area team add --path "\\$projectName\\1-Management" --team $managersTeamName --include-sub-areas true --org $orgUrl --project $projectName --set-as-default
az boards area team add --path "\\$projectName\\0-Requirements" --team $managersTeamName --include-sub-areas true --org $orgUrl --project $projectName
az boards area team add --path "\\$projectName\\5-Tests" --team $managersTeamName --include-sub-areas true --org $orgUrl --project $projectName
az boards area team add --path "\\$projectName\\7-Others" --team $managersTeamName --include-sub-areas true --org $orgUrl --project $projectName

az boards area team add --path "\\$projectName\\4-Development" --team $developersTeamName --include-sub-areas true --org $orgUrl --project $projectName --set-as-default
az boards area team add --path "\\$projectName\\0-Requirements" --team $developersTeamName --include-sub-areas true --org $orgUrl --project $projectName
az boards area team add --path "\\$projectName\\5-Tests" --team $developersTeamName --include-sub-areas true --org $orgUrl --project $projectName
az boards area team add --path "\\$projectName\\7-Others" --team $developersTeamName --include-sub-areas true --org $orgUrl --project $projectName

#az boards area team add --path "\\$projectName\\0-Requirements" --team $devOpsAdminsTeamName --include-sub-areas true --org $orgUrl --project $projectName
#az boards area team add --path "\\$projectName\\2-Architecture" --team $devOpsAdminsTeamName --include-sub-areas true --org $orgUrl --project $projectName
#az boards area team add --path "\\$projectName\\4-Development" --team $devOpsAdminsTeamName --include-sub-areas true --org $orgUrl --project $projectName
#az boards area team add --path "\\$projectName\\5-Tests" --team $devOpsAdminsTeamName --include-sub-areas true --org $orgUrl --project $projectName
#az boards area team add --path "\\$projectName\\6-DevOps" --team $devOpsAdminsTeamName --include-sub-areas true --org $orgUrl --project $projectName --set-as-default
#az boards area team add --path "\\$projectName\\7-Others" --team $devOpsAdminsTeamName --include-sub-areas true --org $orgUrl --project $projectName

az boards area team add --path "\\$projectName\\6-DevOps" --team $devOpsAdminsTeamName --include-sub-areas true --org $orgUrl --project $projectName --set-as-default
az boards area team add --path "\\$projectName" --team $devOpsAdminsTeamName --include-sub-areas true --org $orgUrl --project $projectName
az boards area team add --path "\\$projectName\\6-DevOps" --team $devOpsAdminsTeamName --include-sub-areas true --org $orgUrl --project $projectName --set-as-default #in order to solve settings issues

az boards area team add --path "\\$projectName\\0-Requirements" --team $releaseManagersTeamName --include-sub-areas true --org $orgUrl --project $projectName --set-as-default

#3e Delete the default team
az devops team delete -id "$projectName Team" --org $orgUrl --project $projectName -y

#Example
#az boards area team add --team 'ContosoTeam' --path '\ContosoProject\MyProjectAreaName'

#4-Get the Project Administrators group Id
projectAdminGroupDescriptor=$(az devops security group list -p $projectName --org $orgUrl --query "graphGroups[?contains(principalName,'Project Administrators')].descriptor" -o tsv)
projectContributorGroupDescriptor=$(az devops security group list -p $projectName --org $orgUrl --query "graphGroups[?contains(principalName,'Contributors')].descriptor" -o tsv)
projectReaderGroupDescriptor=$(az devops security group list -p $projectName --org $orgUrl --query "graphGroups[?contains(principalName,'Readers')].descriptor" -o tsv)

teamManagerDescriptor=$(az devops security group list -p $projectName --org $orgUrl --query "graphGroups[?contains(principalName,'$managersTeamName')].descriptor" -o tsv)


#5-Query an org level
#specialistGroupDescriptor=$(az devops security group list --org $orgUrl --scope organization --query "graphGroups[?contains(principalName,'Specialists')].descriptor" -o tsv)

#6-Add membership to a Team project group
az devops security group membership add --org $orgUrl --group-id $projectContributorGroupDescriptor --member-id $teamManagerDescriptor

#8-Create a repo
az repos create --name $repoName -p $projectName --org $orgUrl

#9-Add policies
repositoryId=$(az repos show --repository $repoName --org $orgUrl --project $projectName --query id -o tsv)
az repos policy comment-required create --blocking true --branch master --enabled true --repository-id $repositoryId --org $orgUrl --project $projectName
az repos policy work-item-linking create --blocking true --branch master --enabled true --repository-id $repositoryId --org $orgUrl --project $projectName

#10-Wikis
az devops wiki create --name "$projectName.Wiki" --org $orgUrl --project $projectName --type projectwiki

# TODO: add default queries and dashboards