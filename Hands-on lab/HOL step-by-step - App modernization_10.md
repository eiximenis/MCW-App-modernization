## Exercise 6: Upload policy documents into blob storage

Duration: 10 minutes.

Contoso is currently storing all of their scanned PDF documents on a shared local network. They have asked to be able to store them in the cloud automatically from a workflow. In this exercise, you provide a storage account to store the files in a blob container. Then, you provide a way to bulk upload their existing PDFs.

### Task 1: Create container for storing PDFs in Azure storage

In this task, you create a new blob container in your storage account for the scanned PDF policy documents.

1. In the [Azure portal](https://portal.azure.com), navigate to your **Storage account** resource by selecting **Resource groups** from Azure services list, selecting the **hands-on-lab-SUFFIX** resource group, and then selecting the **contosoUniqueId** Storage account resource from the list of resources.

   ![The Storage Account resource is highlighted in the list of resources.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/storageaccount3.png?raw=true "Storage account")

2. From the Storage account Overview blade, select **Containers** under services.

   ![Containers is selected on the Overview blade of the Storage account.](media/storage-account-containers.png "Storage account")

3. On the Container blade, select **+ Container** to create a new container, and in the New container dialog, enter "policies" as the container name. Leave the Public access level set to **Private (no anonymous access)**, and then select **Create**.

   ![The New container dialog is displayed with a name of "policies" entered, and the Public access level set to Container (anonymous read access for containers and blobs).](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/storageaccount.png?raw=true "Container")

4. After the container has been created, select it on the Container blade, then select **Properties** from the left-hand menu, and copy the URL from the policies - Properties blade. Paste the copied URL into a text editor for later reference.

   ![The policies container is selected, with the Properties blade selected, and the URL of the storage container highlighted.](media/e5-04.png "Container properties")

5. Next retrieve the access key for your storage account, which you need to provide to AzCopy below to connect to your storage container. On your Storage account blade in the Azure portal, select **Access keys** from the left-hand menu, click on **Show Keys** and copy the **key1 Key** value to a text editor for use below.

   ![Access Keys is selected on the Storage account. On the blade, access keys and buttons to copy are displayed](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/storageaccount2.png?raw=true "Access Keys")

### Task 2: Create a SAS token

In this task, you generate a shared access signature (SAS) token for your storage account. This is used later in the lab to allow your Azure Function to retrieve files from the `policies` storage account container.

1. On your Storage account blade in the Azure portal, and select **Shared access signature** from the left-hand menu.

   ![The Shared access signature menu item is highlighted.](media/storage-shared-access-signature.png "Storage account")

2. On the Shared access signature blade, set the following configuration:

   - **Allowed services**: Select **Blob** and uncheck all other services.
   - **Allowed resource types**: Uncheck **Service** and check **Container** and **Object**.
   - **Allowed permissions**: Select **Read** and **List** and uncheck all the other boxes.
   - **Expiry date/time End**: Select this and choose a date a few days or weeks in the future. For this hands-on lab, the date can be any date/time beyond when you plan on completing the lab.

   ![The SAS token configuration settings specified above are entered into the Generate SAS form.](media/storage-sas-token-config.png "Shared access signature configuration")

3. Select **Generate SAS and connection string** and then copy the SAS token value by selecting the Copy to clipboard button to the right of the value.

   ![On the Share access signature blade, the Generate SAS and connection string button is highlighted, and the copy to clipboard button is highlighted to the right of the SAS token value.](media/storage-shared-access-signature-generate.png "Shared access signature")

4. Paste the SAS token into a text editor for later use.

### Task 3: Bulk upload PDFs to blob storage using AzCopy

In this task, you download and install [AzCopy](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy). You then use AzCopy to copy the PDF files from the "on-premises" location into the policies container in Azure storage.

1. On your LabVM, open a web browser and download the latest version of AzCopy from <https://aka.ms/downloadazcopy>

2. Run the downloaded installer, accepting the license agreement and all the defaults, to complete the AzCopy install.

3. Launch a Command Prompt window (Select search on the task bar, type **cmd**, and select Enter) on your LabVM.

4. At the Command prompt, change the directory to the AzCopy directory. By default, it is installed to `C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy` (On a 32-bit machine, change `Program Files (x86)` to `Program Files` ). You can do this by running the command:

   ```bash
   cd C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy
   ```

5. Enter the following command at the command prompt. The tokenized values should be replaced as follows:

   - `[FILE-SOURCE]`: This is the path to the `policy-documents` folder your downloaded copy of the GitHub repo. If you used the extraction path of `C:\MCW`, the path is `C:\MCW\MCW-App-modernization-master\Hands-on lab\lab-files\policy-documents`.
   - `[STORAGE-CONTAINER-URL]`: This is the URL to your storage account's policies container, which you copied in the last step of the previous task. (e.g., <https://contosojt7yc3zphxfda.blob.core.windows.net/policies>)
   - `[STORAGE-ACCOUNT-KEY]`: This is the blob storage account key you copied previously in this task. (e.g., `eqgxGSnCiConfgshXQ1rFwBO+TtCH6sduekk6s8PxPBxHWOmFumycTeOlL3myb8eg4Ba2dn7rtdHnk/1pi6P/w==`)

   ```bash
   AzCopy /Source:"[FILE-SOURCE]" /Dest:"[STORAGE-CONTAINER-URL]" /DestKey:"[STORAGE-ACCOUNT-KEY]" /S
   ```

6. The final command should resemble the following:

   ```bash
   AzCopy /Source:"C:\MCW\MCW-App-modernization-master\Hands-on lab\lab-files\policy-documents" /Dest:"https://contosojt7yc3zphxfda.blob.core.windows.net/policies" /DestKey:"XJT3us2KT1WQHAQBbeotrRCWQLZayFDNmhLHt3vl2miKOHeXasB7IUlw2+y4afH6R/03wbTiRK9SRqGXt9JVqQ==" /S
   ```

7. In the output of the command, you should see that 650 files were transferred successfully.

   ![The output of the AzCopy command is displayed.](media/e5-06.png "AzCopy output")

8. You can verify the upload by navigating to the policies container in your Azure Storage account.

   ![The policies Container with the Overview blade selected shows the list of uploaded files.](media/e5-07.png "Policies Container")

9. Click on Next button.

