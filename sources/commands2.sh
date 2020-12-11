#set the environment value AZURE_DEVOPS_EXT_PAT with the PAT value to fully automatize the process
#If it doesn' work, pipe the variable into the login command

#Variables
orgUrl="https://jmi.visualstudio.com"
projectName="TestTeamPoject"
patCode=$(<PATTokens.txt)
export AZURE_DEVOPS_EXT_PAT=$patCode

customersTeamName="$projectName-customers"
developersTeamName="$projectName-developers"
devOpsAdminsTeamName="$projectName-devOpsAdmins"
managersTeamName="$projectName-customers"
releaseManagersTeamName="$projectName-releaseManagers"

#1
az extension add --name azure-devops

#2
#az login --tenant [tenantId] in case of needed
#az account set -s [subscriptionId]
#az account show

#echo $patCode | az devops login --verbose --org $orgUrl
az devops login

#3
az devops project create --org $orgUrl --name $projectName -s git --visibility private

#3b
az devops team create --name $customersTeamName --description "Customers team" --org $orgUrl -p $projectName
az devops team create --name $developersTeamName --description "Developers team" --org $orgUrl -p $projectName
az devops team create --name $devOpsAdminsTeamName --description "DevOps managers team" --org $orgUrl -p $projectName
az devops team create --name $managersTeamName --description "Managers team" --org $orgUrl -p $projectName
az devops team create --name $releaseManagersTeamName --description "Release managers team" --org $orgUrl -p $projectName

#3c
az boards area project create --name "0-Requirements"
                              --org $orgUrl
                              --project $projectName

az boards area project create --name "1-Management"
                              --org $orgUrl
                              --project $projectName

az boards area project create --name "2-Architecture"
                              --org $orgUrl
                              --project $projectName

az boards area project create --name "4-Development"
                              --org $orgUrl
                              --project $projectName

az boards area project create --name "5-Tests" --org $orgUrl --project $projectName

az boards area project create --name "Unit tests" --org $orgUrl --path "\\$projectName\\Area\\5-Tests" --project $projectName

az boards area project create --name "Integration tests"
                              --org $orgUrl
                              --path "/5-Tests"
                              --project $projectName

#3d
az boards area team add --path
                        --team
                        [--detect {false, true}]
                        [--include-sub-areas {false, true}]
                        [--org]
                        [--project]
                        [--set-as-default]

#Example
#az boards area team add --team 'ContosoTeam' --path '\ContosoProject\MyProjectAreaName'

#4-Get the Project Administrators group Id
$projAdminGroupDescriptor = az devops security group list -p $projectName --org $orgUrl --query "graphGroups[?contains(principalName,'Project Administrators')].descriptor" -o tsv

#5-Query an org level
$specialistGroupDescriptor = az devops security group list --org $orgUrl --scope organization --query "graphGroups[?contains(principalName,'Specialists')].descriptor" -o tsv

#6-Add membership to a Team project group
az devops security group membership add --org $orgUrl --group-id $projAdminGroupDescriptor --member-id $specialistGroupDescriptor

#7-Check if a git repo exists
az devops security group membership add --org $orgUrl --group-id $projAdminGroupDescriptor --member-id $specialistGroupDescriptor

#8-Create a repo
az repos create --name $RepoName -p $ProjectName --org $orgUrl

#9-Add policies
az repos policy comment-required create --blocking true
                                        --branch master
                                        --enabled true
                                        --repository-id feature1
                                        --org https://jmitest.visualstudio.com
                                        --project AZ400-TrainingDay1

az repos policy work-item-linking create --blocking true
                                        --branch master
                                        --enabled true
                                        --repository-id feature1
                                        --org https://jmitest.visualstudio.com
                                        --project AZ400-TrainingDay1