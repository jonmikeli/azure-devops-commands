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
	
	#Buiding dotted and first letter upper case project name
	tmpProjectName=$(sed -e 's/\b\(.\)/\u\1/g' <<< $projectName)
	trimmedAndDottedProjectName=$(sed 's/ /./g' <<< $tmpProjectName)	
	dottedRepoName="$trimmedCustomerCode.$trimmedAndDottedProjectName"

	echo "================================================"
	echo "  Trimmed customer code: $trimmedCustomerCode"
	echo "  Trimmed project name: $trimmedProjectName"
	echo "  Trimmed and dotted project name: $trimmedAndDottedProjectName"
	echo "  Repo name: $repoName"
	echo "  Dotted repo name: $dottedRepoName"
	echo "================================================"

	customersTeamName="$projectName-Customers"
	developersTeamName="$projectName-Developers"
	devOpsAdminsTeamName="$projectName-DevOps Admins"
	managersTeamName="$projectName-Managers"
	releaseManagersTeamName="$projectName-Release Managers"

	echo "================================================"
	echo "  Customers team name: $customersTeamName"
	echo "  Developers team name: $developersTeamName"
	echo "  DevOps team name: $devOpsAdminsTeamName"
	echo "  Managers team name: $managersTeamName"
	echo "  Release Managers team name: $releaseManagersTeamName"
	echo "================================================"

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

	echo "================================================"
	echo "  API repo name: $apiRepoName"
	echo "  Web repo name: $webRepoName"
	echo "  IaC repo name: $iacRepoName"
	echo "================================================"

	az repos create --name $repoName -p "$projectName" --org $orgUrl --verbose
	az repos create --name $apiRepoName -p "$projectName" --org $orgUrl --verbose
	az repos create --name $webRepoName -p "$projectName" --org $orgUrl --verbose
	az repos create --name $iacRepoName -p "$projectName" --org $orgUrl --verbose

	#9-Add policies
	#9.1-Project default repo
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

	#9.4-IaC repo
	repositoryId=$(az repos show --repository $iacRepoName --org $orgUrl --project "$projectName" --query id -o tsv)
	az repos policy comment-required create --blocking true --branch master --enabled true --repository-id $repositoryId --org $orgUrl --project "$projectName" --verbose
	az repos policy work-item-linking create --blocking true --branch master --enabled true --repository-id $repositoryId --org $orgUrl --project "$projectName" --verbose

	#10-Delete the default repository (created with the team project)
	projectRepositoryId=$(az repos show --repository "$projectName" --org $orgUrl --project "$projectName" --query id -o tsv)
	az repos delete --id $projectRepositoryId --org $orgUrl --project "$projectName" --yes

	#11-Wikis
	az devops wiki create --name "$trimmedProjectName.Wiki" --org $orgUrl --project "$projectName" --type projectwiki --verbose

	#12-Variable groups
	apiCommonVariableGroupName="$apiRepoName.Common"
	webCommonVariableGroupName="$webRepoName.Common"
	iacCommonVariableGroupName="$iacRepoName.Common"

	echo "================================================"
	echo "  API variables group name: $apiCommonVariableGroupName"
	echo "  Web variables group name: $webCommonVariableGroupName"
	echo "  IaC variables group name: $iacCommonVariableGroupName"
	echo "================================================"

	az pipelines variable-group create --name $apiCommonVariableGroupName --variables "Version.Major"="0" "Version.Minor"="1" "Build.Configuration"="Release" --authorize true --description "Common variables for the pipelines (build, release, etc) related to $apiRepoName." --org $orgUrl --project "$projectName"
	az pipelines variable-group create --name $webCommonVariableGroupName --variables "Version.Major"="0" "Version.Minor"="1" "Build.Configuration"="Release" --authorize true --description "Common variables for the pipelines (build, release, etc) related to $webRepoName." --org $orgUrl --project "$projectName"
	az pipelines variable-group create --name $iacCommonVariableGroupName --variables "Version.Major"="0" "Version.Minor"="1" "Build.Configuration"="Release" --authorize true --description "Common variables for the pipelines (build, release, etc) related to $iacRepoName." --org $orgUrl --project "$projectName"	

	#13-Pipeline folders
	az pipelines folder create --path "1-UI" --org $orgUrl --project "$projectName"
	az pipelines folder create --path "1-UI\Web" --org $orgUrl --project "$projectName"
	az pipelines folder create --path "1-UI\Desktop" --org $orgUrl --project "$projectName"
	az pipelines folder create --path "1-UI\Mobile" --org $orgUrl --project "$projectName"
	az pipelines folder create --path "2-API" --org $orgUrl --project "$projectName"
	az pipelines folder create --path "3-Persistance" --org $orgUrl --project "$projectName"
	az pipelines folder create --path "4-IoT" --org $orgUrl --project "$projectName"
	az pipelines folder create --path "4-IoT\Edge" --org $orgUrl --project "$projectName"
	az pipelines folder create --path "5-IaC" --org $orgUrl --project "$projectName"

	#14-Extensions
	#List extensions
	extensionList=$(az devops extension list --org $orgUrl)
	if [ "$extensionList" ];
	then
        echo "Organization extension list loaded."		

		#bleddynrichards.Assembly-Info-Task
		extensionId="Assembly-Info-Task"
		publisherId="bleddynrichards"
		counter=$(echo $extensionList | jq --arg extensionId $extensionId '.[] | select(.extensionId == $extensionId) | length')

		if [ $counter ];		
		then 
			echo "The extension $extensionId is already installed."		
		else
			echo "The extension $extensionId has not been found in the organization. Installing the extension..."
			az devops extension install --extension-id $extensionId --publisher-id $publisherId --org $orgUrl	
		fi

		#agile-extensions.dod
		extensionId="dod"
		publisherId="agile-extensions"
		counter=$(echo $extensionList | jq --arg extensionId $extensionId '.[] | select(.extensionId == $extensionId) | length')

		if [ $counter ];		
		then 
			echo "The extension $extensionId is already installed."		
		else
			echo "The extension $extensionId has not been found in the organization. Installing the extension..."
			az devops extension install --extension-id $extensionId --publisher-id $publisherId --org $orgUrl	
		fi

		#ms.vss-plans
		extensionId="vss-plans"
		publisherId="ms"
		counter=$(echo $extensionList | jq --arg extensionId $extensionId '.[] | select(.extensionId == $extensionId) | length')

		if [ $counter ];		
		then 
			echo "The extension $extensionId is already installed."		
		else
			echo "The extension $extensionId has not been found in the organization. Installing the extension..."
			az devops extension install --extension-id $extensionId --publisher-id $publisherId --org $orgUrl	
		fi

	else
		echo "No organization extension has been loaded."

		az devops extension install --extension-id "Assembly-Info-Task" --publisher-id "bleddynrichards" --org $orgUrl
		az devops extension install --extension-id "dod" --publisher-id "agile-extensions" --org $orgUrl
		az devops extension install --extension-id "vss-plans" --publisher-id "ms" --org $orgUrl
		az devops extension install --extension-id "workitem-feature-timeline-extension" --publisher-id "ms-devlabs" --org $orgUrl
		az devops extension install --extension-id "team-retrospectives" --publisher-id "ms-devlabs" --org $orgUrl
	fi
)

if [ $?  == 0 ];
 then
	echo "The Team Project has been created successfully."
fi