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

Create Blob Storage
Parameters
STORAGE_ACCOUNT="fwdaysdemostorage"
CONTAINER_NAME="objects"

az deployment group create \
--resource-group "$NAME_RG" \
--template-file ./DevOps/Blob_storage_service.bicep \
--parameters \
  storageAccountName="$STORAGE_ACCOUNT" \
  containerName="$CONTAINER_NAME"


----

Create Azure Container Registry
Timing around 1 min
Parameters
ACR="fwdays"

az deployment group create \
--resource-group "$NAME_RG" \
--template-file ./DevOps/ACR.bicep \
--parameters \
  acr="$ACR"

----

Create App registration
Timing around 1 min

APP_NAME="fwDays-demo"
APP_ID=$(az ad app create --display-name "${APP_NAME}"  | jq -r .appId)

az ad app credential reset \
  --id "${APP_ID}" \
  --years 2


SERVICE_PRINCIPAL_ID=$(az ad sp create \
  --id "${APP_ID}" \
  | jq -r .id)


----
Update config.json to use right keys

---
Create Key Vault
Timing around 1 min

az deployment group create \
--resource-group "$NAME_RG" \
--template-file ./DevOps/Key_Vault.bicep \
--parameters \
   objectId="$SERVICE_PRINCIPAL_ID"

Grant own permissions to generate certificate and all permissions in secrets
Generate certificate and upload to project directory PFX and CER to azure app registration

----
Sample 1. Issues with query usage
Create new project webapi
dotnet new webapi in Query directory

----

Renaming controller, remove testing data, add Dapr Components include sample methods
dotnet add package Dapr.Client --version 1.8.0

----
Configure Components to use new certificate and new App registration ID and Tenant ID


----
Run DAPR locally to validate query app
dapr run --app-id cosmosdbapp --app-port 5298 --dapr-http-port 50001 --components-path Components dotnet run

----
Create Docker file 
docker build --platform linux/amd64 -t query:latest -f ./Query/dockerfile .

---
Tag Docker file 
docker tag query:latest fwdays.azurecr.io/query:latest

---
Push Docker file 
docker push fwdays.azurecr.io/query:latest

----
Upload new docker image to ACR

----
Create Container Apps
az deployment group create \
--resource-group "$NAME_RG" \
--template-file ./DevOps/ContainerAppsCosmosDB.bicep

----
Added Cosmos DB API as workaround
dotnet add package Microsoft.Azure.Cosmos --version 3.30.1

----
Add new methods using cosmosDB API to explain results

https://github.com/microsoft/azure-container-apps/issues/155 

----
Sample 2. Issues with using http requests

----
Create a web api project called Request
Renaming controller, remove testing data, add Dapr Components include sample methods
dotnet add package Dapr.Client --version 1.8.0

----
Configure Components to use new certificate and new App registration ID and Tenant ID

---
Generating testing data
https://www.utilities-online.info/base64

----
Testing locally
dapr run --app-id uploadblobapp --app-port 5298 --dapr-http-port 50001 --components-path Components dotnet run

increase max http request
dapr run --app-id uploadblobapp --app-port 5298 --dapr-http-port 50001 --dapr-http-max-request-size 16 --components-path Components dotnet run

----
Create Docker file 
docker build --platform linux/amd64 -t request:latest -f ./Request/dockerfile .

----
Upload new docker image to ACR

----
Create Container Apps
az deployment group create \
--resource-group "$NAME_RG" \
--template-file ./DevOps/ContainerAppsBlob.bicep


----
https://github.com/microsoft/azure-container-apps/issues/116
https://github.com/microsoft/azure-container-apps/issues/411#issuecomment-1260117320
https://learn.microsoft.com/en-us/cli/azure/containerapp/dapr?view=azure-cli-latest#az-containerapp-dapr-enable
az containerapp dapr enable -n uploadblobapp -g "$NAME_RG" --dapr-app-id uploadblobapp --dapr-http-max-request-size 16



Note 
kill the process kill -9 $(lsof -ti:port)
If container apps does not see dapr component, you can re-create revision of apps