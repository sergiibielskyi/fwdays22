# Not always your DAPR application works "like a charm" if it runs in Azure Container Apps services. Workshop

This workshop explains some examples of using DAPR application in Azure Container Apps and not always all features from DAPR work as expected. Some issues that is faced with State Management and Pub/Sub components using Query State and HTTP requests.


Prepare Container Apps environment
Timing around 10 min

Parameters
CONTAINERAPPS_ENVIRONMENT="fwdays-env"
NAME_RG="fwdays22"

az deployment group create \
--resource-group "$NAME_RG" \
--template-file ./DevOps/Environment.bicep \
--parameters \
   environmentName="$CONTAINERAPPS_ENVIRONMENT"

----

Create CosmosDB account  
Timing around 3 min

az deployment group create \
--resource-group "$NAME_RG" \
--template-file ./DevOps/Cosmos_db_service.bicep


----

Upload the sample data
From prepared testing data VolcanoData.json from TestingData folder


----

Create Key Vault
Timing around 1 min

APP_NAME="fwDays-demo"
APP_ID=$(az ad app create --display-name "${APP_NAME}"  | jq -r .appId)

az ad app credential reset \
  --id "${APP_ID}" \
  --years 2


SERVICE_PRINCIPAL_ID=$(az ad sp create \
  --id "${APP_ID}" \
  | jq -r .id)


az deployment group create \
--resource-group "$NAME_RG" \
--template-file ./DevOps/Key_Vault.bicep \
--parameters \
   objectId="$SERVICE_PRINCIPAL_ID"

Grant own permissions to generate certificate and all permissions in secrets
Generate certificate and upload to project directory PFX and azure app registration

----

Create new project webapi
dotnet new webapi in Query directory

----

Renaming controller, remove testing data, add Dapr Components include sample methods
dotnet add package Dapr.Client --version 1.8.0


----
Run DAPR locally to validate query app
dapr run --app-id cosmosdb --app-port 5298 --dapr-http-port 50001 --components-path Components dotnet run

----
Create Docker file 
docker build --platform linux/amd64 -t query:latest -f ./Query/dockerfile .

----
Create Container Apps
az deployment group create \
--resource-group "$NAME_RG" \
--template-file ./DevOps/Main.bicep