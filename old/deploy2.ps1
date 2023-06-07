# Declaration of Resource Prefix parameter -ResourcePrefix. This parameter value is added as prefix to the names of your resources.
param(
    [Parameter(Mandatory=$true)]
    [string]
    $Organization,

    [Parameter(Mandatory=$true)]
    [string]
    $Project,

    [Parameter(Mandatory=$true)]
    [string]
    $RepoName
)

#Full url to azure devops organization
$OrgUrl = 'https://dev.azure.com/'+$Organization+'/'

#Pipeline name
$NewPipeline = 'Main Build'

# Install azure devops extension module is not installed.
if($(az extension show --name azure-devops) -eq ""){
    az extension add --name azure-devops
}

#Create pipeline
az pipelines create --name $NewPipeline --repository $RepoName --organization $OrgUrl --project $Project --branch master --repository-type tfsgit --yml-path 'src/azure-pipelines.yml'
