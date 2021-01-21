![Microsoft Cloud Workshops](https://github.com/Microsoft/MCW-Template-Cloud-Workshop/raw/master/Media/ms-cloud-workshop.png "Microsoft Cloud Workshops")

<div class="MCWHeader1">
App modernization
</div>

<div class="MCWHeader2">
Hands-on lab step-by-step guide
</div>

<div class="MCWHeader3">
June 2020
</div>

Information in this document, including URL and other Internet Web site references, is subject to change without notice. Unless otherwise noted, the example companies, organizations, products, domain names, e-mail addresses, logos, people, places, and events depicted herein are fictitious, and no association with any real company, organization, product, domain name, e-mail address, logo, person, place or event is intended or should be inferred. Complying with all applicable copyright laws is the responsibility of the user. Without limiting the rights under copyright, no part of this document may be reproduced, stored in or introduced into a retrieval system, or transmitted in any form or by any means (electronic, mechanical, photocopying, recording, or otherwise), or for any purpose, without the express written permission of Microsoft Corporation.

Microsoft may have patents, patent applications, trademarks, copyrights, or other intellectual property rights covering subject matter in this document. Except as expressly provided in any written license agreement from Microsoft, the furnishing of this document does not give you any license to these patents, trademarks, copyrights, or other intellectual property.

The names of manufacturers, products, or URLs are provided for informational purposes only and Microsoft makes no representations and warranties, either expressed, implied, or statutory, regarding these manufacturers or the use of the products with any Microsoft technologies. The inclusion of a manufacturer or product does not imply endorsement of Microsoft of the manufacturer or product. Links may be provided to third party sites. Such sites are not under the control of Microsoft and Microsoft is not responsible for the contents of any linked site or any link contained in a linked site, or any changes or updates to such sites. Microsoft is not responsible for webcasting or any other form of transmission received from any linked site. Microsoft is providing these links to you only as a convenience, and the inclusion of any link does not imply endorsement of Microsoft of the site or the products contained therein.

© 2020 Microsoft Corporation. All rights reserved.

Microsoft and the trademarks listed at <https://www.microsoft.com/en-us/legal/intellectualproperty/Trademarks/Usage/General.aspx> are trademarks of the Microsoft group of companies. All other trademarks are property of their respective owners.

**Contents**

<!-- TOC -->

- [App modernization hands-on lab step-by-step](#app-modernization-hands-on-lab-step-by-step)
  - [Abstract and learning objectives](#abstract-and-learning-objectives)
  - [Overview](#overview)
  - [Solution architecture](#solution-architecture)
  - [Requirements](#requirements)
  - [Exercise 1: Migrate the on-premises database to Azure SQL Database](#exercise-1-migrate-the-on-premises-database-to-azure-sql-database)
    - [Task 1: Configure the ContosoInsurance database on the Sql2008-UniqueId VM](#task-1-configure-the-contosoinsurance-database-on-the-sqlserver2008-vm)
    - [Task 2: Perform assessment for migration to Azure SQL Database](#task-2-perform-assessment-for-migration-to-azure-sql-database)
    - [Task 3: Migrate the database schema using the Data Migration Assistant](#task-3-migrate-the-database-schema-using-the-data-migration-assistant)
    - [Task 4: Retrieve connection information for SQL databases](#task-4-retrieve-connection-information-for-sql-databases)
    - [Task 5: Migrate the database using the Azure Database Migration Service](#task-5-migrate-the-database-using-the-azure-database-migration-service)
  - [Exercise 2: Post upgrade database enhancements](#exercise-2-post-upgrade-database-enhancements)
    - [Task 1: Configure SQL Data Discovery and Classification](#task-1-configure-sql-data-discovery-and-classification)
    - [Task 2: Review Advanced Data Security Vulnerability Assessment](#task-2-review-advanced-data-security-vulnerability-assessment)
    - [Task 3: Enable Dynamic Data Masking](#task-3-enable-dynamic-data-masking)
  - [Exercise 3: Configure Key Vault](#exercise-3-configure-key-vault)
    - [Task 1: Add Key Vault access policy](#task-1-add-key-vault-access-policy)
    - [Task 2: Create a new secret to store the SQL connection string](#task-2-create-a-new-secret-to-store-the-sql-connection-string)
    - [Task 3: Create a service principal](#task-3-create-a-service-principal)
    - [Task 4: Assign the service principal access to Key Vault](#task-4-assign-the-service-principal-access-to-key-vault)
  - [Exercise 4: Deploy Web API into Azure App Services](#exercise-4-deploy-web-api-into-azure-app-services)
    - [Task 1: Connect to the LabVM](#task-1-connect-to-the-labvm)
    - [Task 2: Open starter solution with Visual Studio](#task-2-open-starter-solution-with-visual-studio)
    - [Task 3: Update Web API to use Key Vault](#task-3-update-web-api-to-use-key-vault)
    - [Task 4: Copy KeyVault configuration section to API App in Azure](#task-4-copy-keyvault-configuration-section-to-api-app-in-azure)
    - [Task 5: Deploy the API to Azure](#task-5-deploy-the-api-to-azure)
  - [Exercise 5: Deploy web application into Azure App Services](#exercise-5-deploy-web-application-into-azure-app-services)
    - [Task 1: Add API App URL to Web App Application settings](#task-1-add-api-app-url-to-web-app-application-settings)
    - [Task 2: Deploy web application to Azure](#task-2-deploy-web-application-to-azure)
  - [Exercise 6: Upload policy documents into blob storage](#exercise-6-upload-policy-documents-into-blob-storage)
    - [Task 1: Create container for storing PDFs in Azure storage](#task-1-create-container-for-storing-pdfs-in-azure-storage)
    - [Task 2: Create a SAS token](#task-2-create-a-sas-token)
    - [Task 3: Bulk upload PDFs to blob storage using AzCopy](#task-3-bulk-upload-pdfs-to-blob-storage-using-azcopy)
  - [Exercise 7: Create serverless API for accessing PDFs](#exercise-7-create-serverless-api-for-accessing-pdfs)
    - [Task 1: Add application settings to your Function App](#task-1-add-application-settings-to-your-function-app)
    - [Task 2: Add project environment variables](#task-2-add-project-environment-variables)
    - [Task 3: Create an Azure Function in Visual Studio](#task-3-create-an-azure-function-in-visual-studio)
    - [Task 4: Test the function locally](#task-4-test-the-function-locally)
    - [Task 5: Deploy the function to your Azure Function App](#task-5-deploy-the-function-to-your-azure-function-app)
    - [Task 6: Enable Application Insights on the Function App](#task-6-enable-application-insights-on-the-function-app)
    - [Task 7: Add Function App URL to your Web App Application settings](#task-7-add-function-app-url-to-your-web-app-application-settings)
    - [Task 8: Test document retrieval from web app](#task-8-test-document-retrieval-from-web-app)
    - [Task 9: View Live Metrics Stream](#task-9-view-live-metrics-stream)
  - [Exercise 8: Add Cognitive Search for policy documents](#exercise-8-add-cognitive-search-for-policy-documents)
    - [Task 1: Add Azure Cognitive Search to Storage account](#task-1-add-azure-cognitive-search-to-storage-account)
    - [Task 2: Review search results](#task-2-review-search-results)
  - [Exercise 9: Create an app in PowerApps](#exercise-9-create-an-app-in-powerapps)
    - [Task 1: Sign up for a PowerApps account](#task-1-sign-up-for-a-powerapps-account)
    - [Task 2: Create new SQL connection](#task-2-create-new-sql-connection)
    - [Task 3: Create a new app](#task-3-create-a-new-app)
    - [Task 4: Design app](#task-4-design-app)
    - [Task 5: Edit the app settings and run the app](#task-5-edit-the-app-settings-and-run-the-app)
  - [After the hands-on lab](#after-the-hands-on-lab)
    - [Task 1: Delete Azure resource groups](#task-1-delete-azure-resource-groups)
    - [Task 2: Delete the contoso-apps service principal](#task-2-delete-the-contoso-apps-service-principal)

<!-- /TOC -->

# App modernization hands-on lab step-by-step

