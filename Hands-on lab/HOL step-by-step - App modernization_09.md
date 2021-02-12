## Exercise 5: Deploy web application into Azure App Services

Duration: 10 minutes

In this exercise, you update the `Contoso.Web` web application to connect to your newly deployed API App and then deploy the web app into Azure App Services.

### Task 1: Add API App URL to Web App Application settings

In this task, you prepare your Web App to work with the API App by adding the URL of your published API App to the Application Settings of your Web App, using the Azure Cloud Shell and Azure CLI.

1. In the [Azure portal](https://portal.azure.com), select the Azure Cloud Shell icon from the menu at the top right of the screen.

   ![The Azure Cloud Shell icon is highlighted in the Azure portal's top menu.](media/cloud-shell-icon.png "Azure Cloud Shell")

2. In the Cloud Shell window that opens at the bottom of your browser window, select **PowerShell**.

   ![In the Welcome to Azure Cloud Shell window, PowerShell is highlighted.](media/cloud-shell-select-powershell.png "Azure Cloud Shell")

3. After a moment, you are presented with a PS Azure prompt.

   ![In the Azure Cloud Shell dialog, a message is displayed that requesting a Cloud Shell succeeded, and the PS Azure prompt is displayed.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/cloud-shell-ps-azure-prompt.png?raw=true "Azure Cloud Shell")

4. At the Cloud Shell prompt, run the following command to retrieve both your API App URL and your Web App, making sure to replace `<your-resource-group-name>` with your resource group name:

   ```powershell
   $resourceGroup = "<your-resource-group-name>"
   az webapp list -g $resourceGroup --output table
   ```

   > **Note**: If you have multiple Azure subscriptions, and the account you are using for this hands-on lab is not your default account, you may need to run `az account list --output table` at the Azure Cloud Shell prompt to output a list of your subscriptions, then copy the Subscription Id of the account you are using for this lab, and then run `az account set --subscription <your-subscription-id>` to set the appropriate account for the Azure CLI commands.

5. In the output, copy two values for use in the next step. Copy the **DefaultHostName** value for your API App (the resource name starts with contoso-**api**) and also copy the Web App **Name** value (the resource name starts with contoso-**web**).

   ![The Web App Name and API App DefaultHostName values are highlighted in the output of the command above.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/webapp7-new.png?raw=true "Azure Cloud Shell")

6. Next replace the tokenized values in the following command as specified below, and then run it from the Azure Cloud Shell command prompt.

   - `<your-web-app-name>`: Replace with your Web App name, which you copied in the previous step.
   - `<your-api-default-host-name>`: Replace with the default hostname of your API app that you copied into a text editor previously.

   ```powershell
   $webAppName = "<your-web-app-name>"
   $defaultHostName = "<your-api-default-host-name>"
   az webapp config appsettings set -n $webAppName -g $resourceGroup --settings "ApiUrl=https://$defaultHostName"
   ```

7. In the output, you should see the newly added setting in your Web App's application settings.

   ![The ApiUrl app setting in highlighted in the output of the previous command.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/webapp8.png?raw=true "Azure Cloud Shell")

### Task 2: Deploy web application to Azure

In this task, you publish the `Contoso.Web` application into an Azure Web App.
1. In Visual Studio on your LabVM, right-click the `Contoso.Web` project in the Solution Explorer, and then select **Manage NuGet Packages** from the context menu.

   ![Publish in highlighted in the context menu for the Contoso.Web project.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/nuget1.png?raw=true "Publish")

2. On the **NuGet Package Manager** blade, select **Browse** then search for and select **Microsoft.NET.Sdk.Razor** package. Click on **Install** to install the package.

    ![Publish in highlighted in the context menu for the Contoso.Web project.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/nuget2.png?raw=true "Publish")

3. On the **Preview features** blade, click on **Ok**.

    ![Publish in highlighted in the context menu for the Contoso.Web project.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/nuget3.png?raw=true "Publish")

4. On the **License Acceptance** blade, click on **I Accept**

    ![Publish in highlighted in the context menu for the Contoso.Web project.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/nuget4.png?raw=true "Publish")

5. Once the package installation is done,  right-click the `Contoso.Web` project in the Solution Explorer, and then select **Publish** from the context menu.

   ![Publish in highlighted in the context menu for the Contoso.Web project.](media/vs-web-publish.png "Publish")

2. On the **Publish** dialog, select **Azure** in the Target box and select **Next**.

   ![In the Publish dialog, Azure is selected and highlighted in the Target box. The Next button is highlighted.](media/vs-publish-to-azure.png "Publish Web App to Azure")

3. Next, in the **Specific target** box, select **Azure App Service (Windows)**.

   ![In the Publish dialog, Azure App Service (Windows) is selected and highlighted in the Specific Target box. The Next button is highlighted.](media/vs-publish-specific-target.png "Publish Web App to Azure")

4. Finally, in the **App Service** box, select your subscription, expand the hands-on-lab-SUFFIX resource group, and select the Web App "contoso-web-uniqueid"

   ![In the Publish dialog, The Contoso Web App is selected and highlighted under the hands-on-lab-SUFFIX resource group.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/webapp4.png?raw=true "Publish Web App to Azure")

5. Select **Finish**.

10. Back on the Visual Studio Publish page for the `Contoso.Web` project, select **Publish** to start the process of publishing your Web API to your Azure API App.

   ![The Publish button is highlighted next to the newly created publish profile on the Publish page.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/webapp6.png?raw=true "Publish")

11. In the Visual Studio **Web Publish Activity** view, observe the Publish Succeeded message, along with the URL to the site.

   ![Web Publish Activity view with the publish process status and Web App url](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/webapp5.png?raw=true "Web Publish Activity")

12. A web browser should open to the published site. If not, open the URL of the published Web App in a browser window

13. In the PolicyConnect web page, enter the following credentials to log in, and then select **Log in

   - **Username**: demouser
   - **Password**: Password.1!!

   ![The credentials above are entered into the login screen for the PolicyConnect web site.](media/web-app-login.png "PolicyConnect")

14. Once logged in, select **Managed Policy Holders** from the top menu.

    ![Manage Policy Holders is highlighted in the PolicyConnect web site's menu.](media/web-app-managed-policy-holders.png "PolicyConnect")

    > **Note**: It can take a few seconds for data to appear the first time the page is loaded, as the API must also be initialized.

15. On the Policy Holders page, review the list of policy holder, and information about their policies. This information was pulled from your Azure SQL Database using the connection string stored in Azure Key Vault. Select the **Details** link next to one of the records.

    ![Policy holder data is displayed on the page.](media/web-app-policy-holders-data.png "PolicyConnect")

16. On the Policy Holder Details page, select the link under **File Path**, and notice that the result is a page not found error.

    ![The File Path link is highlighted on the Policy Holder Details page.](media/web-app-policy-holder-details.png "PolicyConnect")

17. Contoso is storing their policy documents on a network file share, so these are not accessible to the deployed web app. In the next exercises, you address that issue.
18. Click on **Next** button.

