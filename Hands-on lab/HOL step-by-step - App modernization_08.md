## Exercise 4: Deploy Web API into Azure App Services

Duration: 45 minutes

The developers at Contoso have been working toward migrating their apps to the cloud, and they have provided you with a starter solution developed using ASP.NET Core 2.2. As such, most of the pieces are already in place to deploy the apps to Azure, as well as configure them to communicate with the new app services. Since the required services have already been provisioned, what remains is to integrate Azure Key Vault into the API, apply application-level configuration settings, and then deploy the apps from the Visual Studio starter solution. In this task, you apply application settings to the Web API using the Azure Portal. Once the application settings have been set, you deploy the Web App and API App into Azure from Visual Studio.

### Task 1: Open starter solution with Visual Studio

In this task, you open the `Contoso` starter solution in Visual Studio. The Visual Studio solution contains the following projects:

- **Contoso.Azure**: Common library containing helper classes used by other projects within the solution to communicate with Azure services.
- **Contoso.Data**: Library containing data access objects.
- **Contoso.FunctionApp**: Contains an Azure Function that is used to retrieve policy documents from Blob storage.
- **Contoso.Web**: ASP.NET Core 2.2 PolicyConnect web application.
- **Contoso.WebApi**: ASP.NET Core 2.2 Web API used by the web application to communicate with the database.

> **Note**: Make sure you are performing the below tasks in LabVM.

1. In File Explorer, navigate to `C:\MCW\MCW-App-modernization-master\Hands-on lab\lab-files\src` and double-click the `Contoso.sln` file to open the solution in Visual Studio.

   ![The Contoso.sln file is highlighted in the folder specified above.](media/file-explorer-vs-solution.png "File explorer")

2. If prompted about how to open the file, select **Visual Studio 2019** and then select **OK**.

   ![Visual Studio 2019 is highlighted in the How do you want to open this file? dialog.](media/solution-file-open-with.png "Visual Studio 2019")

3. Sign in to Visual Studio using your Azure account credentials. You can get the Azure Account credentials from **Environment Details** page

   ![The Sign in button is highlighted on the Visual Studio Welcome screen.](media/visual-studio-sign-in.png "Visual Studio 2019")

4. When prompted with a security warning, uncheck **Ask me for every project in this solution**, and then select **Create**.

   ![On the security warning dialog, the Ask me for every project in this solution box is unchecked and highlighted.](media/visual-studio-security-warning.png "Visual Studio")

### Task 2: Update Web API to use Key Vault

In this task, you update the `Contoso.WebApi` project to use Azure Key Vault for storing and retrieving application secrets. You start by adding the connection information to the `appsettings.json` file in the `Contoso.WebApi` project, and then add some code to enable the use of Azure Key Vault.

> The required NuGet package to enable interaction with Key Vault has already been referenced in the project to save time. The package added to facilitate this is: `Microsoft.Extensions.Configuration.AzureKeyVault`.

1. In Visual Studio, expand the `Contoso.WebApi` project in the Solution Explorer, locate the `Program.cs` file and open it by double-clicking on it.

   ![In the Visual Studio Solution Explorer, the Program.cs file is highlighted under the Contoso.WebApi project.](media/vs-api-program-cs.png "Solution Explorer")

2. In the `Program.cs` file, locate the `TODO #1` block (line 23) within the `CreateWebHostBuilder` method.

   ![The TODO #1 block is highlighted within the Program.cs code.](media/vs-program-cs-todo-1.png "Program.cs")

3. Complete the code within the block, using the following code, to add Key Vault to the configuration, and provide Key Vault with the appropriate connection information.

   ```csharp
   config.AddAzureKeyVault(
       KeyVaultConfig.GetKeyVaultEndpoint(buildConfig["KeyVaultName"]),
       buildConfig["KeyVaultClientId"],
       buildConfig["KeyVaultClientSecret"]
   );
   ```

4. Save `Program.cs`. The updated `CreateWebHostBuilder` method should now look like the following:

   ![Screenshot of the updated Program.cs file.](media/vs-program-cs-updated.png "Program.cs")

5. Next, you update the `Startup.cs` file in the `Contoso.WebApi` project. Locate the file in the Solution Explorer and double-click it.

6. In the previous exercise, you added the connection string for your Azure SQL Database to Key Vault, and assigned the secret a name of `SqlConnectionString`. Using the code below, update the `TODO #2` block (line 38), within the `Startup.cs` file's `Configuration` property. This allows your application to retrieve the connection string from Key Vault using the secret name.

   ![The TODO #2 block is highlighted within the Startup.cs code.](media/vs-startup-cs-todo-2.png "Startup.cs")

   ```csharp
   services.AddDbContext<ContosoDbContext>(options =>
       options.UseSqlServer(Configuration["SqlConnectionString"]));
   ```

7. Save `Startup.cs`. The updated `Configuration` property now looks like the following:

   ![Screenshot of the updated Startup.cs file.](media/vs-startup-cs-updated.png "Startup.cs")

8. Your Web API is now fully configured to retrieve secrets from Azure Key Vault.

### Task 3: Copy KeyVault configuration section to API App in Azure

Before deploying the Web API to Azure, you need to add the required application settings into the configuration for the Azure API App. In this task, you use the advanced configuration editor in your API App to add in the configuration settings required to connect to and retrieve secrets from Key Vault.

1. In the [Azure portal](https://portal.azure.com), navigate to your **API App** by selecting **Resource groups** from Azure services list, selecting the **hands-on-lab-SUFFIX** resource group, and selecting the **contoso-api-UniqueId** App service from the list of resources.

   ![The API App resource is highlighted in the list of resources.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/apiapp.png?raw=true "API App")

2. On the API App blade, select **Configuration** on the left-hand menu.

   ![The Configuration item is highlighted in the API App left-hand menu.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/api-app-configuration-menu.png?raw=true "API App")

3. On the Application settings tab of the Configuration blade, select **Advanced edit** under Application settings. The Advanced edit screen allows you to paste JSON directly into the configuration.

   ![Advanced edit is highlighted on the Application settings tab.](media/api-app-configuration-advanced-edit.png "API App")

4. We are going to use the Advanced editor to add all three of the Key Vault settings at once. To do this, we are going to replace the content of the Advanced editor with the following, which you need to update as follows:

    - `<your-key-vault-name>`: ```contoso-kv-UniqueId```, Get UniqueId value from Environment Details under Azure Credentials tab  and replace with UniqueId in contoso-kv-UniqueId.
    - `<Application Id>`: you can retrieve this value from Service Principal Details under Environment Details tab.
    - `<Secret Key>`:  you can retrieve this valuefrom Service Principal Details under Environment Details tab.

   ```json
   [
     {
       "name": "KeyVaultName",
       "value": "<your-key-vault-name>"
     },
     {
       "name": "KeyVaultClientId",
       "value": "<Application Id>"
     },
     {
       "name": "KeyVaultClientSecret",
       "value": "<Secret Key>"
     }
   ]
   ```

5. The final contents of the editor should look similar to the following:

   ```json
   [
     {
       "name": "KeyVaultName",
       "value": "contoso-kv-281470"
     },
     {
       "name": "KeyVaultClientId",
       "value": "94ee2739-794b-4038-a378-573a5f52918c"
     },
     {
       "name": "KeyVaultClientSecret",
       "value": "nokf54VBF*DO"
     }
   ]
   ```

6. Select **OK**.

7. Select **Save** on the Configuration blade and then select **Continue** when prompted about restarting the app.

   ![The Save button is highlighted on the toolbar.](media/api-app-configuration-save.png "Save")

### Task 4: Deploy the API to Azure

In this task, you use Visual Studio to deploy the API project into an API App in Azure.

1. In Visual Studio, right-click on the **Contoso.WebApi** project in the Solution Explorer and select **Publish** from the context menu.

   ![The Contoso.WebApi project is selected, and Publish is highlighted in the context menu.](media/e4-02.png "Publish Web API")

2. On the **Publish** dialog, select **Azure** in the Target box and select **Next**.

   ![In the Publish dialog, Azure is selected and highlighted in the Target box. The Next button is highlighted.](media/vs-publish-to-azure.png "Publish API App to Azure")

3. Next, in the **Specific target** box, select **Azure App Service (Windows)**.

   ![In the Publish dialog, Azure App Service (Windows) is selected and highlighted in the Specific Target box. The Next button is highlighted.](media/vs-publish-specific-target.png "Publish API App to Azure")

4. Finally, in the **App Service** box, select your subscription, expand the hands-on-lab-SUFFIX resource group, and select the Web App "contoso-api-uniqueid"

   ![In the Publish dialog, The Contoso API App is selected and highlighted under the hands-on-lab-SUFFIX resource group.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/webapp0.png?raw=true "Publish API App to Azure")

5. Select **Finish**.

6. Back on the Visual Studio Publish page for the `Contoso.WebApi` project, select **Publish** to start the process of publishing your Web API to your Azure API App.

   ![The Publish button is highlighted next to the newly created publish profile on the Publish page.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/webapp1.png?raw=true "Publish")

7. In the Visual Studio **Web Publish Activity** view, you should see a status that indicates the Web API was published successfully, along with the URL to the site.

   ![Web Publish Activity view with the publish process status and API site url](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/webapp2.png?raw=true "Web Publish Activity")

   > If you don't see the **Web Publish Activity** view, you can find it on View menu-> Other Windows -> Web Publish Activity

8. A web browser should open to the published site. If not, open the URL of the published Web API in a browser window. Initially, you should see a message that the page cannot be found.

   ![A page can't be found error message is displayed in the web browser.](media/web-api-publish-page-not-found.png "Page not found")

9. To validate the API App is function property, add `/swagger` to the end of the URL in your browser's address bar (e.g., <https://contoso-api-288892.azurewebsites.net/swagger/>). This brings up the Swagger UI page of your API, which displays a list of the available API endpoints.

   ![Swagger screen displayed for the API App.](media/swagger-ui.png "Validate published Web API")

   > **Note**: [Swagger UI](https://swagger.io/tools/swagger-ui/) automatically generates visual documentation for REST APIs following the OpenAPI Specification. It makes it easy for developers to visualize and interact with the API's endpoints without having any of the implementation logic in place.

10. You can test the functionality of the API by selecting one of the `GET` endpoints, and selecting **Try it out**.

    ![The Try it out button is highlighted under the Dependents GET endpoint](media/swagger-try-it-out.png "Swagger")

11. Select **Execute**.

    ![The Execute button is displayed.](media/swagger-execute.png "Swagger")

12. In the Response, you should see a Response Code of 200, and JSON objects in the Response body.

    ![Retrieve service principal details](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/status200.png?raw=true "Status 200")


13. Click on **Next** button.

