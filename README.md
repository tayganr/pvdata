# :rocket: Starter Kit

This starter kit will:
* Provision an Azure Data Lake Storage Gen2 Account
* Create a Container (e.g. `data`)
* Upload sample data.
* Provide your existing Azure Purview account read access to ADLS (i.e. `Storage Blob Data Reader`).

## :thinking: Prerequisites

* Access to an **Azure subscription**. Note: If you don't have access to an Azure subscription, you may be able to start with a [free account](https://www.azure.com/free).
* Your must have the necessary **privleges** within your Azure subscription in order to successfully deploy the template. Note: The account being used to deploy the template must be able to create a resource group, create resources, and perform role assignments (e.g. `Owner` on a resource group).
* The Azure subscription must have the following [resource providers](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types#azure-portal) registered. 
    * Microsoft.Authorization
    * Microsoft.Storage
    * Microsoft.Purview
    * Microsoft.ManagedIdentity
    * Microsoft.EventHub

## :books: Steps

1. [Deploy Azure Template](./steps/step01.md)
1. [Register a Data Source](./steps/step02.md)
1. [Scan a Data Source](./steps/step03.md)
