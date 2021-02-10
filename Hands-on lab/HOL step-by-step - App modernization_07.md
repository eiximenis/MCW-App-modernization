## Exercise 3: Configure Key Vault

Duration: 15 minutes

As part of their efforts to put tighter security controls in place, Contoso has requested that application secrets to be stored in a secure manner, so they aren't visible in plain text in application configuration files. In this exercise, you configure Azure Key Vault, which securely stores application secrets for the Contoso web and API applications, once migrated to Azure.

### Task 1: Add Key Vault access policy

In this task, you add an access policy to Key Vault to allow secrets to be created with your account.

1. In the [Azure portal](https://portal.azure.com), navigate to your **Key Vault** resource by selecting **Resource groups** from Azure services list, selecting the **hands-on-lab-SUFFIX** resource group, and then selecting the **contoso-kv-UniqueId** Key vault resource from the list of resources.

   ![The contosokv Key vault resource is highlighted in the list of resources.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/keyvault1.png?raw=true "Key vault")

2. On the Key Vault blade, select **Access policies** under Settings in the left-hand menu, and then select **+ Add Access Policy**.

   ![The + Add Access Policy link is highlighted on the Access policies blade.](media/key-vault-add-access-policy-link.png "Access policies")

3. In the Add access policy dialog, enter the following:

   - **Configure from template (optional)**: Leave blank.
   - **Key permissions**: Leave set to 0 selected.
   - **Secret permissions**: Select this, and then choose **Select All**, to give yourself full rights to manage secrets.
   - **Certificate permissions**: Leave set to 0 selected.
   - **Select principal**: Click on **None Selected** and enter the email address of the account you are logged into the Azure portal with, select the user object that appears, and then choose **Select**.

   ![The values specified above are entered into the Add access policy dialog.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/accesspolicy1.png?raw=true "Key Vault")
   - **Authorized application**: Leave set to None selected.

   ![The values specified above are entered into the Add access policy dialog.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/accesspolicy2.png?raw=true "Key Vault")

4. Select **Add**.

5. Select **Save** on the Access policies toolbar.

   ![The Save button is highlighted on the Access policies toolbar.](media/key-vault-access-policies-save.png "Key Vault")

### Task 2: Create a new secret to store the SQL connection string

In this task, you add a secret to Key Vault containing the connection string for the `ContosoInsurance` Azure SQL database.

1. First, you need to retrieve the connection string to your Azure SQL Database. In the [Azure portal](https://portal.azure.com), navigate to your **SQL database** resource by selecting **Resource groups** from Azure services list, selecting the **hands-on-lab-SUFFIX** resource group, and then selecting the **ContosoInsurance** SQL database resource from the list of resources.

   ![The contosoinsurance SQL database resource is highlighted in the list of resources.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/resources-azure-sql-database.png?raw=true "SQL database")

2. On the SQL database blade, select **Connection strings** from the left-hand menu, and then copy the ADO.NET connection string.

   ![Connection strings is selected and highlighted in the left-hand menu on the SQL database blade, and the copy button is highlighted next to the ADO.NET connection string](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/sql-db-connection-strings.png?raw=true "Connection strings")

3. Paste the copied connection string into a text editor, such as Notepad.exe. This is necessary because you need to replace the tokenized password value before adding the connection string as a Secret in Key Vault.

4. In the text editor, find and replace the tokenized `{your_password}` value with `Password.1!!`

5. Your connection string should now resemble the following:

   ```csharp
   Server=tcp:contosoinsurance-294876.database.windows.net,1433;Initial Catalog=ContosoInsurance;Persist Security Info=False;User ID=demouser;Password=Password.1!!;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
   ```

6. Copy your updated connection string from the text editor.

7. In the [Azure portal](https://portal.azure.com), navigate back to your **Key Vault** resource by selecting **Resource groups** from Azure services list, selecting the **hands-on-lab-SUFFIX** resource group, and then selecting the **contoso-kv-UniqueId** Key vault resource from the list of resources.

   ![The contosokv Key vault resource is highlighted in the list of resources.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/keyvault1.png?raw=true "Key vault")

8. On the Key Vault blade, select **Secrets** under Settings in the left-hand menu, and then select **+ Generate/Import**.

   ![On the Key Vault blade, Secrets is selected and the +Generate/Import button is highlighted.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/key-vault-secrets.png?raw=true "Key Vault Secrets")

9. On the Create a secret blade, enter the following:

   - **Upload options**: Select Manual.
   - **Name**: Enter **SqlConnectionString**
   - **Value**: Paste the updated SQL connection string you copied from the text editor.

   ![On the Create a secret blade, the values specified above are entered into the appropriate fields.](media/key-vault-secrets-create.png "Create a secret")

10. Select **Create**.

### Task 3: Retrieve service principal details

Your environment has a pre-created Service Principal for which details are provided along. The service principal (SP) is used to provide your web and API apps access to secrets stored in Azure Key Vault.
1. Now to retrieve the details of Service Principal click on **Environment Details** tab then select **Service Principal Details** and you can review it as shown below:

   ![Retrieve service principal details](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/principaldetails.png?raw=true "Retrieve service principal details")

### Task 4: Assign the service principal access to Key Vault

In this task, you assign the service principal you created above to a reader role on your resource group and add an access policy to Key Vault to allow it to view secrets stored there.
1. Enter the following command at the Cloud Shell prompt, by replacing the `<your-resource-group-name>` with the name of your **hands-on-lab-SUFFIX** resource group, and then press **Enter** to run the command:

   ```
   $resourceGroup = "<your-resource-group-name>"
   ```

2. Next, run the following command to get the name of your Key Vault:

   ```powershell
   az keyvault list -g $resourceGroup --output table
   ```

3. In the output from the previous command, copy the value from the `name` field into a text editor. You use it in the next step and also for configuration of your web and API apps.

   ![The value of the name property is highlighted in the output from the previous command.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/keyvault.png?raw=true "Azure Cloud Shell")

4. To assign permissions to your service principal to read Secrets from Key Vault, run the following command, replacing `<your-key-vault-name>` with the name of your Key Vault that you copied in the previous step and pasted into a text editor and replacing **http://contoso-apps** in --spn with the **application id** of the pre-created service principal that you can copy from lab details page.

   ```powershell
   az keyvault set-policy -n <your-key-vault-name> --spn https://contoso-apps --secret-permissions get list
   ```

5. In the output, you should see your service principal appId listed with "get" and "list" permissions for secrets.

   ![In the output from the command above, the secrets array is highlighted.](media/azure-cloud-shell-az-keyvault-set-policy.png "Azure Cloud Shell")
   
6. The Sql2008-UniqueId VM is not needed for the remaining exercises of this hands-on lab, you can close it by clicking on **close** button.

   ![In the output from the command above, the secrets array is highlighted.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/close.png?raw=true "Close button")
