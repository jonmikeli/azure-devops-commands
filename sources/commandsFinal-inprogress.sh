#!/bin/bash

#Get parameters
# -organization URL
# -customer name
# -project name
# -PAT code file path

#function to get script parameter values
_get_parameter_values ()
{
	echo "===>>>GET PARAMETER VALUES"

	while getopts "o:c:m:p:f:" option;
	do

		echo ">>>SCRIPT PARAMETERS:$option"
		
		case $option in
			o) orgUrl=$OPTARG;;
			c) customerName=$OPTARG;;
            m) customerCode=$OPTARG;;
			p) projectToBeCreatedName=$OPTARG;;
			f) patFilePath=$OPTARG;;
		esac
	done
	shift $((OPTIND -1))
	
	if [ -z "$orgUrl"]; then
        echo "No organization URL has been found."
        exit 1
	fi

    if [ -z "$customerName"]; then
        echo "No customer name has been found."
        exit 1
	fi

    if [ -z "$customerCode"]; then
        echo "No customer code has been found."
        exit 1
	fi

    if [ -z "$projectToBeCreatedName"]; then
        echo "No project name has been found."
        exit 1
	fi

    if [ -z "$patFilePath"]; then
        echo "No PAT file path has been found."
        exit 1
	fi
	

	echo "===>>>END OF GETTING PARAMETER VALUES"

	echo "Organization URL: $orgUrl"
	echo "Customer name: $customerName"
    echo "Customer code: $customerCode"
	echo "Project name: $projectToBeCreatedName"
	echo "PAT code file path: $patFilePath"
}

#get script parameter values
_get_parameter_values "$@"

#
echo "Starting the Team Project deployment..."

set -e
(
	#Variables
	projectName=${customerName^^}-$projectToBeCreatedName
	patCode=$(<$patFilePath)
	export AZURE_DEVOPS_EXT_PAT=$patCode

	#Replace spaces in the customer name
	trimmedCustomerCode=$(sed 's/ //g' <<< $customerCode)
	trimmedProjectName=$(sed 's/ /-/g' <<< $projectName)
	repoName="$trimmedCustomerCode.$trimmedProjectName"

	customersTeamName="$projectName-Customers"
	developersTeamName="$projectName-Developers"
	devOpsAdminsTeamName="$projectName-DevOps Admins"
	managersTeamName="$projectName-Managers"
	releaseManagersTeamName="$projectName-Release Managers"

	#2-Connect to the organization
	echo $patCode | az devops login --verbose --org $orgUrl

	#Display executed commands
	#set -x
	
	#3-Team project
	az devops project create --org $orgUrl --name "$projectName" -s git --visibility private --verbose

	#3b-Teams
	az devops team create --name "$customersTeamName" --description "Customers team" --org $orgUrl -p "$projectName" --verbose
	az devops team create --name "$developersTeamName" --description "Developers team" --org $orgUrl -p "$projectName" --verbose
	az devops team create --name "$devOpsAdminsTeamName" --description "DevOps managers team" --org $orgUrl -p "$projectName" --verbose
	az devops team create --name "$managersTeamName" --description "Managers team" --org $orgUrl -p "$projectName" --verbose
	az devops team create --name "$releaseManagersTeamName" --description "Release managers team" --org $orgUrl -p "$projectName" --verbose

	#3c-Areas
	az boards area project create --name "0-Requirements" --org $orgUrl --project "$projectName" --verbose

	az boards area project create --name "1-Management" --org $orgUrl --project "$projectName" --verbose

	az boards area project create --name "2-Architecture" --org $orgUrl --project "$projectName" --verbose
	az boards area project create --name "2.1-POC" --org $orgUrl --path "\\$projectName\\Area\\2-Architecture" --project "$projectName" --verbose
	az boards area project create --name "2.2-Design" --org $orgUrl --path "\\$projectName\\Area\\2-Architecture" --project "$projectName" --verbose
	az boards area project create --name "2.3-Documentation" --org $orgUrl --path "\\$projectName\\Area\\2-Architecture" --project "$projectName" --verbose

	az boards area project create --name "4-Development" --org $orgUrl --project "$projectName" --verbose
	az boards area project create --name "4.1-UI" --org $orgUrl --path "\\$projectName\\Area\\4-Development" --project "$projectName" --verbose
	az boards area project create --name "4.2-API" --org $orgUrl --path "\\$projectName\\Area\\4-Development" --project "$projectName" --verbose
	az boards area project create --name "4.3-Persistance" --org $orgUrl --path "\\$projectName\\Area\\4-Development" --project "$projectName" --verbose
	az boards area project create --name "4.4-Containerization" --org $orgUrl --path "\\$projectName\\Area\\4-Development" --project "$projectName" --verbose
	az boards area project create --name "4.5-ARM" --org $orgUrl --path "\\$projectName\\Area\\4-Development" --project "$projectName" --verbose

	az boards area project create --name "5-Tests" --org $orgUrl --project "$projectName" --verbose
	az boards area project create --name "5.1-Unit tests" --org $orgUrl --path "\\$projectName\\Area\\5-Tests" --project "$projectName" --verbose
	az boards area project create --name "5.2-Integration tests" --org $orgUrl --path "\\$projectName\\Area\\5-Tests" --project "$projectName" --verbose
	az boards area project create --name "5.3-Deployment tests" --org $orgUrl --path "\\$projectName\\Area\\5-Tests" --project "$projectName" --verbose
	az boards area project create --name "5.4-Load tests" --org $orgUrl --path "\\$projectName\\Area\\5-Tests" --project "$projectName" --verbose
	az boards area project create --name "5.5-Running tests" --org $orgUrl --path "\\$projectName\\Area\\5-Tests" --project "$projectName" --verbose
	az boards area project create --name "5.6-Security tests" --org $orgUrl --path "\\$projectName\\Area\\5-Tests" --project "$projectName" --verbose

	az boards area project create --name "6-DevOps" --org $orgUrl --project "$projectName" --verbose
	
	az boards area project create --name "7-Others" --org $orgUrl --project "$projectName" --verbose
	az boards area project create --name "7.1-Code review" --org $orgUrl --path "\\$projectName\\Area\\7-Others" --project "$projectName" --verbose
	az boards area project create --name "7.2-Pair programming" --org $orgUrl --path "\\$projectName\\Area\\7-Others" --project "$projectName" --verbose
	az boards area project create --name "7.3-Meetings" --org $orgUrl --path "\\$projectName\\Area\\7-Others" --project "$projectName" --verbose
	az boards area project create --name "7.4-Assistance" --org $orgUrl --path "\\$projectName\\Area\\7-Others" --project "$projectName" --verbose

	az boards area project create --name "8-Technical debt" --org $orgUrl --project "$projectName" --verbose

	#3d
	#Note: the missing 'Area' part in the path is due to the API does not take it into account for boards and team memberships
	az boards area team add --path "\\$projectName\\0-Requirements" --team "$customersTeamName" --include-sub-areas true --org $orgUrl --project "$projectName" --set-as-default --verbose

	az boards area team add --path "\\$projectName\\1-Management" --team "$managersTeamName" --include-sub-areas true --org $orgUrl --project "$projectName" --set-as-default --verbose
	az boards area team add --path "\\$projectName\\0-Requirements" --team "$managersTeamName" --include-sub-areas true --org $orgUrl --project "$projectName" --verbose
	az boards area team add --path "\\$projectName\\5-Tests" --team "$managersTeamName" --include-sub-areas true --org $orgUrl --project "$projectName" --verbose
	az boards area team add --path "\\$projectName\\7-Others" --team "$managersTeamName" --include-sub-areas true --org $orgUrl --project "$projectName" --verbose

	az boards area team add --path "\\$projectName\\4-Development" --team "$developersTeamName" --include-sub-areas true --org $orgUrl --project "$projectName" --set-as-default --verbose
	az boards area team add --path "\\$projectName\\0-Requirements" --team "$developersTeamName" --include-sub-areas true --org $orgUrl --project "$projectName" --verbose
	az boards area team add --path "\\$projectName\\5-Tests" --team "$developersTeamName" --include-sub-areas true --org $orgUrl --project "$projectName" --verbose
	az boards area team add --path "\\$projectName\\7-Others" --team "$developersTeamName" --include-sub-areas true --org $orgUrl --project "$projectName" --verbose
	az boards area team add --path "\\$projectName\\8-Technical debt" --team "$developersTeamName" --include-sub-areas true --org $orgUrl --project "$projectName" --verbose

	az boards area team add --path "\\$projectName\\6-DevOps" --team "$devOpsAdminsTeamName" --include-sub-areas true --org $orgUrl --project "$projectName" --set-as-default --verbose
	az boards area team add --path "\\$projectName" --team "$devOpsAdminsTeamName" --include-sub-areas true --org $orgUrl --project "$projectName" --verbose
	az boards area team add --path "\\$projectName\\6-DevOps" --team "$devOpsAdminsTeamName" --include-sub-areas true --org $orgUrl --project "$projectName" --set-as-default  --verbose #in order to solve settings issues

	az boards area team add --path "\\$projectName\\0-Requirements" --team "$releaseManagersTeamName" --include-sub-areas true --org $orgUrl --project "$projectName" --set-as-default --verbose

	#3e Delete the default team
	#az devops team delete -id "$projectName Team" --org $orgUrl --project $projectName -y

	#4-Get the Project Administrators group Id
	projectAdminGroupDescriptor=$(az devops security group list -p "$projectName" --org $orgUrl --query "graphGroups[?contains(principalName,'Project Administrators')].descriptor" -o tsv)
	projectContributorGroupDescriptor=$(az devops security group list -p "$projectName" --org $orgUrl --query "graphGroups[?contains(principalName,'Contributors')].descriptor" -o tsv)
	projectReaderGroupDescriptor=$(az devops security group list -p "$projectName" --org $orgUrl --query "graphGroups[?contains(principalName,'Readers')].descriptor" -o tsv)
	projectReleaseManagerGroupDescriptor=$(az devops security group list -p "$projectName" --org $orgUrl --query "graphGroups[?contains(principalName,'Contributors')].descriptor" -o tsv)

	customersDescriptor=$(az devops security group list -p "$projectName" --org $orgUrl --query "graphGroups[?contains(principalName,'$customersTeamName')].descriptor" -o tsv)
	managersTeamDescriptor=$(az devops security group list -p "$projectName" --org $orgUrl --query "graphGroups[?contains(principalName,'$managersTeamName')].descriptor" -o tsv)
	developersTeamDescriptor=$(az devops security group list -p "$projectName" --org $orgUrl --query "graphGroups[?contains(principalName,'$developersTeamName')].descriptor" -o tsv)
	devOpsAdminsTeamDescriptor=$(az devops security group list -p "$projectName" --org $orgUrl --query "graphGroups[?contains(principalName,'$devOpsAdminsTeamName')].descriptor" -o tsv)
	releaseManagersDescriptor=$(az devops security group list -p "$projectName" --org $orgUrl --query "graphGroups[?contains(principalName,'$releaseManagersTeamName')].descriptor" -o tsv)

	#6-Add membership to a Team project group
	az devops security group membership add --org $orgUrl --group-id $projectReaderGroupDescriptor --member-id $customersDescriptor --verbose
	az devops security group membership add --org $orgUrl --group-id $projectContributorGroupDescriptor --member-id $managersTeamDescriptor --verbose
	az devops security group membership add --org $orgUrl --group-id $projectContributorGroupDescriptor --member-id $developersTeamDescriptor --verbose
	az devops security group membership add --org $orgUrl --group-id $projectAdminGroupDescriptor --member-id $devOpsAdminsTeamDescriptor --verbose
	az devops security group membership add --org $orgUrl --group-id $projectReleaseManagerGroupDescriptor --member-id $releaseManagersDescriptor --verbose

	#8-Create a repo
	apiRepoName="$repoName.API"
	webRepoName="$repoName.UI.Web"
	iacRepoName="$repoName.IaC"
	az repos create --name $repoName -p "$projectName" --org $orgUrl --verbose
	az repos create --name $apiRepoName -p "$projectName" --org $orgUrl --verbose
	az repos create --name $webRepoName -p "$projectName" --org $orgUrl --verbose
	az repos create --name $iacRepoName -p "$projectName" --org $orgUrl --verbose

	#9-Add policies
	#9.1-Default repo
	repositoryId=$(az repos show --repository $repoName --org $orgUrl --project "$projectName" --query id -o tsv)
	az repos policy comment-required create --blocking true --branch master --enabled true --repository-id $repositoryId --org $orgUrl --project "$projectName" --verbose
	az repos policy work-item-linking create --blocking true --branch master --enabled true --repository-id $repositoryId --org $orgUrl --project "$projectName" --verbose

	#9.2-API repo
	repositoryId=$(az repos show --repository $apiRepoName --org $orgUrl --project "$projectName" --query id -o tsv)
	az repos policy comment-required create --blocking true --branch master --enabled true --repository-id $repositoryId --org $orgUrl --project "$projectName" --verbose
	az repos policy work-item-linking create --blocking true --branch master --enabled true --repository-id $repositoryId --org $orgUrl --project "$projectName" --verbose

	#9.3-Web repo
	repositoryId=$(az repos show --repository $webRepoName --org $orgUrl --project "$projectName" --query id -o tsv)
	az repos policy comment-required create --blocking true --branch master --enabled true --repository-id $repositoryId --org $orgUrl --project "$projectName" --verbose
	az repos policy work-item-linking create --blocking true --branch master --enabled true --repository-id $repositoryId --org $orgUrl --project "$projectName" --verbose

	#10-Delete the default repository
	projectRepositoryId=$(az repos show --repository "$projectName" --org $orgUrl --project "$projectName" --query id -o tsv)
	az repos delete --id $projectRepositoryId --org $orgUrl --project "$projectName" --yes

	#11-Wikis
	az devops wiki create --name "$projectName.Wiki" --org $orgUrl --project "$projectName" --type projectwiki --verbose
)

if [ $?  == 0 ];
 then
	echo "The Team Project has been created successfully."
fi