## Exercise 1: Migrate the on-premises database to Azure SQL Database

Duration: 45 minutes

In this exercise, you use the Microsoft Data Migration Assistant (DMA) to assess the `ContosoInsurance` database for a migration to Azure SQL Database. The assessment generates a report detailing any feature parity and compatibility issues between the on-premises database and Azure SQL Database.

> DMA helps you upgrade to a modern data platform by detecting compatibility issues that can impact database functionality on your new version of SQL Server or Azure SQL Database. DMA recommends performance and reliability improvements for your target environment and allows you to move your schema, data, and uncontained objects from your source server to your target server. To learn more, read the **Data Migration Assistant documentation** here `https://docs.microsoft.com/sql/dma/dma-overview?view=azuresqldb-mi-current`.

### Task 1: Configure the ContosoInsurance database on the Sql2008-UniqueId VM

Before you begin the assessment, you need to configure the `ContosoInsurance` database on your SQL Server 2008 R2 instance. In this task, you execute a SQL script against the `ContosoInsurance` database on the SQL Server 2008 R2 instance.

> **Note**: There is a known issue with screen resolution when using an RDP connection to Windows Server 2008 R2, which may affect some users. This issue presents itself as very small, hard to read text on the screen. The workaround for this is to use a second monitor for the RDP display, which should allow you to scale up the resolution to make the text larger.

1. On the LabVM provided to you, type remote in the search box on taskbar, and choose **Remote Desktop Connection** from the items.

   ![The Sql2008-UniqueId virtual machine is highlighted in the list of resources.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/rdp-01.png?raw=true "RDP")

2. On the  Remote Desktop Connection dialog, enter **Sqlvm DNS Name** in computer field and select **Connect**. You can get **Sqlvm DNS Name** from the environment details tab.

   ![The Sql2008-UniqueId virtual machine is highlighted in the list of resources.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/rdp-02.png?raw=true "RDP")

3. Enter the following credentials when prompted, and then select **OK**:

   - **Username**: `demouser`
   - **Password**: `Password.1!!`

   ![The credentials specified above are entered into the Enter your credentials dialog.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/rdp-03.png?raw=true "Enter your credentials")
   
4. Select **Yes** to connect, if prompted that the identity of the remote computer cannot be verified.

   ![In the Remote Desktop Connection dialog box, a warning states that the identity of the remote computer cannot be verified, and asks if you want to continue anyway. At the bottom, the Yes button is circled.](./media/remote-desktop-connection-identity-verification-sqlserver2008.png "Remote Desktop Connection dialog")

5. Once connected to the Sql2008-UniqueId VM, search for ```sql server``` into  Windows Start menu of Sql2008-UniqueId VM and select **Microsoft SQL Server Management Studio 17** from the results and open it.

   ![SQL Server is entered into the Windows Start menu search box, and Microsoft SQL Server Management Studio 17 is highlighted in the search results.](media/start-menu-ssms-17.png "Windows start menu search")

6. In the SSMS **Connect to Server** dialog, enter **SQL2008-UniqueId** into the Server name box, ensure **Windows Authentication** is selected, and then select **Connect**.

   ![The SQL Server Connect to Search dialog is displayed, with SQLSERVER2008 entered into the Server name and Windows Authentication selected.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/ssms1.png?raw=true "Connect to Server")

7. Once connected, expand **Databases** under SQL2008-UniqueId in the Object Explorer, and then select **ContosoInsurance** from the list of databases.

   ![The ContosoInsurance database is highlighted in the list of databases.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/ssms2.png?raw=true "Databases")

8. Next, you execute a script in SSMS, which resets the `sa` password, enable mixed mode authentication, create the `WorkshopUser` account, and change the database recovery model to FULL. To create the script, open a new query window in SSMS by selecting **New Query** in the SSMS toolbar.

    ![The New Query button is highlighted in the SSMS toolbar.](./media/ssms-new-query.png "SSMS Toolbar")

9. Copy and paste the SQL script below into the new query window:

    ```sql
    USE master;
    GO

    -- SET the sa password
    ALTER LOGIN [sa] WITH PASSWORD=N'Password.1!!';
    GO

    -- Enable Mixed Mode Authentication
    EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
    N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 2;
    GO

    -- Create a login and user named WorkshopUser
    CREATE LOGIN WorkshopUser WITH PASSWORD = N'Password.1!!';
    GO

    EXEC sp_addsrvrolemember
        @loginame = N'WorkshopUser',
        @rolename = N'sysadmin';
    GO

    USE ContosoInsurance;
    GO

    IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'WorkshopUser')
    BEGIN
        CREATE USER [WorkshopUser] FOR LOGIN [WorkshopUser]
        EXEC sp_addrolemember N'db_datareader', N'WorkshopUser'
    END;
    GO

    -- Update the recovery model of the database to FULL
    ALTER DATABASE ContosoInsurance SET RECOVERY FULL;
    GO
    ```

10. To run the script, select **Execute** from the SSMS toolbar.

    ![The Execute button is highlighted in the SSMS toolbar.](./media/ssms-execute.png "SSMS Toolbar")

11. For Mixed Mode Authentication and the new `sa` password to take effect, you must restart the SQL Server (MSSQLSERVER) Service on the Sql2008-UniqueId VM. To do this, you can use SSMS. Right-click the SQL2008-UniqueId instance in the SSMS Object Explorer, and then select **Restart** from the context menu.

    ![In the SSMS Object Explorer, the context menu for the SQL2008-UniqueId instance is displayed, and Restart is highlighted.](./media/ssms-object-explorer-restart-sqlserver2008.png "Object Explorer")

12. When prompted about restarting the MSSQLSERVER service, select **Yes**. The service takes a few seconds to restart.

    ![The Yes button is highlighted on the dialog asking if you are sure you want to restart the MSSQLSERVER service.](./media/ssms-restart-service.png "Restart MSSQLSERVER service")

### Task 2: Perform assessment for migration to Azure SQL Database

Contoso would like an assessment to see what potential issues they might need to address in moving their database to Azure SQL Database. In this task, you use the [Microsoft Data Migration Assistant](https://docs.microsoft.com/sql/dma/dma-overview?view=sql-server-2017) (DMA) to perform an assessment of the `ContosoInsurance` database against Azure SQL Database (Azure SQL DB). Data Migration Assistant (DMA) enables you to upgrade to a modern data platform by detecting compatibility issues that can impact database functionality on your new version of SQL Server or Azure SQL Database. It recommends performance and reliability improvements for your target environment. The assessment generates a report detailing any feature parity and compatibility issues between the on-premises database and the Azure SQL DB service.

> **Note**: The Database Migration Assistant should be installed on your Sql2008-UniqueId VM. If the Database Migration Assistant is not installed, follow the steps below to install it.

  - Navigate to `C:\` drive and find the DataMigrationAssitant.exe file as shown below and
    install the assistant by selecting `Next -> I accept the terms in the License Agreement -> Next -> Install -> Finish.` 

    ![DMA path](./media/dma-downloaded-file-path.png "DMA path")

  - It can also be downloaded from the [Microsoft Download Center](https://www.microsoft.com/download/details.aspx?id=53595).

1. On the Sql2008-UniqueId VM, launch DMA from the Windows Start menu by typing "data migration" into the search bar, and then selecting **Microsoft Data Migration Assistant** in the search results.

   ![In the Windows Start menu, "data migration" is entered into the search bar, and Microsoft Data Migration Assistant is highlighted in the Windows start menu search results.](media/windows-start-menu-dma.png "Data Migration Assistant")

2. In the DMA dialog, select **+** from the left-hand menu to create a new project.

   ![The new project icon is highlighted in DMA.](media/dma-new.png "New DMA project")

3. In the New project pane, set the following:

   - **Project type**: Select Assessment.
   - **Project name**: Enter Assessment
   - **Assessment type**: Select Database Engine.
   - **Source server type**: Select SQL Server.
   - **Target server type**: Select Azure SQL Database.

   ![New project settings for doing an assessment of a migration from SQL Server to Azure SQL Database.](media/dma-new-project-to-azure-sql-db.png "New project settings")

4. Select **Create**.

5. On the **Options** screen, ensure **Check database compatibility** and **Check feature parity** are both checked, and then select **Next**.

   ![Check database compatibility and check feature parity are checked on the Options screen.](media/dma-options.png "DMA options")

6. On the **Sources** screen, enter the following into the **Connect to a server** dialog that appears on the right-hand side:

   - **Server name**: Enter ```Sql2008-uniqueid```. For example: Sql2008-176667
   - **Authentication type**: Select **SQL Server Authentication**.
   - **Username**: Enter **WorkshopUser**
   - **Password**: Enter **Password.1!!**
   - **Encrypt connection**: Check this box.
   - **Trust server certificate**: Check this box.

   ![In the Connect to a server dialog, the values specified above are entered into the appropriate fields.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/sqlserver1.png?raw=true "Connect to a server")

7. Select **Connect**.

8. On the **Add sources** dialog that appears next, check the box for `ContosoInsurance` and select **Add**.

   ![The ContosoInsurance box is checked on the Add sources dialog.](media/dma-add-sources.png "Add sources")

9. Select **Start Assessment**.

   ![Start assessment](media/dma-start-assessment-to-azure-sql-db.png "Start assessment")

10. Take a moment to review the assessment for migrating to Azure SQL DB. The SQL Server feature parity report shows that Analysis Services and SQL Server Reporting Services are unsupported, but these do not affect any objects in the `ContosoInsurance` database, so won't block a migration.

    ![The feature parity report is displayed, and the two unsupported features are highlighted.](media/dma-feature-parity-report.png "Feature parity")

11. Now, select **Compatibility issues** so you can review that report as well.

    ![The Compatibility issues option is selected and highlighted.](media/dma-compatibility-issues.png "Compatibility issues")

> The DMA assessment for a migrating the `ContosoInsurance` database to a target platform of Azure SQL DB reveals that there are no issues or features preventing Contoso from migrating their database to Azure SQL DB. You can select **Export Assessment** at the top right to save the report as a JSON file, if desired.

### Task 3: Migrate the database schema using the Data Migration Assistant

After you have reviewed the assessment results and you have ensured the database is a candidate for migration to Azure SQL Database, use the Data Migration Assistant to migrate the schema to Azure SQL Database.

1. On the Sql2008-UniqueId VM, return to the Data Migration Assistant, and select the New **(+)** icon in the left-hand menu.

2. In the New project dialog, enter the following:

   - **Project type**: Select Migration.
   - **Project name**: Enter Migration
   - **Source server type**: Select SQL Server.
   - **Target server type**: Select Azure SQL Database.
   - **Migration scope**: Select Schema only.

   ![The above information is entered in the New project dialog box.](media/data-migration-assistant-new-project-migration.png "New Project dialog")

3. Select **Create**.

4. On the **Select source** tab, enter the following:

   - **Server name**: Enter ```Sql2008-uniqueid```. For example: Sql2008-176667
   - **Authentication type**: Select **SQL Server Authentication**.
   - **Username**: Enter **WorkshopUser**
   - **Password**: Enter **Password.1!!**
   - **Encrypt connection**: Check this box.
   - **Trust server certificate**: Check this box.
   - Select **Connect**, and then ensure the `ContosoInsurance` database is selected from the list of databases.

   ![The Select source tab of the Data Migration Assistant is displayed, with the values specified above entered into the appropriate fields.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/data-migration-assistant-migration-select-source.png?raw=true "Data Migration Assistant Select source")

5. Select **Next**.

6. For the **Select target** tab, retrieve the server name associated with your Azure SQL Database. In the [Azure portal](https://portal.azure.com), navigate to your **SQL database** resource by selecting **Resource groups** from Azure services list, selecting the **hands-on-lab-SUFFIX** resource group, and then selecting the **ContosoInsurance** SQL database resource from the list of resources.

   ![The contosoinsurance SQL database resource is highlighted in the list of resources.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/resources-azure-sql-database.png?raw=true "SQL database")

7. On the Overview blade of your SQL database, copy the **Server name**.

   ![The server name value is highlighted on the SQL database Overview blade.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/sql-database-server-name.png?raw=true "SQL database")

8. Return to DMA, and on the **Select target** tab, enter the following:

   - **Server name**: Paste the server name of your Azure SQL Database you copied above.
   - **Authentication type**: Select SQL Server Authentication.
   - **Username**: Enter **demouser**
   - **Password**: Enter **Password.1!!**
   - **Encrypt connection**: Check this box.
   - **Trust server certificate**: Check this box.
   - Select **Connect**, and then ensure the `ContosoInsurance` database is selected from the list of databases.

   ![The Select target tab of the Data Migration Assistant is displayed, with the values specified above entered into the appropriate fields.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/data-migration-assistant-migration-select-target.png?raw=true "Data Migration Assistant Select target")

9. Select **Next**.

10. On the **Select objects** tab, leave all the objects checked, and select **Generate SQL script**.

    ![The Select objects tab of the Data Migration Assistant is displayed, with all the objects checked.](media/data-migration-assistant-migration-select-objects.png "Data Migration Assistant Select target")

11. On the **Script & deploy schema** tab, review the script. Notice the view also provides a note that there are not blocking issues.

    ![The Script & deploy schema tab of the Data Migration Assistant is displayed, with the generated script shown.](media/data-migration-assistant-migration-script-and-deploy-schema.png "Data Migration Assistant Script & deploy schema")

12. Select **Deploy schema**.

13. After the schema is deployed, review the deployment results, and ensure there were no errors.

    ![The schema deployment results are displayed, with 23 commands executed and 0 errors highlighted.](media/data-migration-assistant-migration-deployment-results.png "Schema deployment results")

14. Next, open SSMS on the Sql2008-UniqueId VM, and connect to your Azure SQL Database, by selecting **Connect->Database Engine** in the Object Explorer, and then entering the following into the Connect to server dialog:

    - **Server name**: Paste the server name of your Azure SQL Database you copied above.
    - **Authentication type**: Select SQL Server Authentication.
    - **Username**: Enter **demouser**
    - **Password**: Enter **Password.1!!**
    - **Remember password**: Check this box.

    ![The SSMS Connect to Server dialog is displayed, with the Azure SQL Database name specified, SQL Server Authentication selected, and the demouser credentials entered.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/ssms-connect-azure-sql-database.png?raw=true "Connect to Server")

15. Select **Connect**.

16. Once connected, expand **Databases**, and expand **ContosoInsurance**, then expand **Tables**, and observe the schema has been created.

    ![In the SSMS Object Explorer, Databases, ContosoInsurance, and Tables are expanded, showing the tables created by the deploy schema script.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/ssms-databases-contosoinsurance-tables.png?raw=true "SSMS Object Explorer")

### Task 4: Retrieve connection information for SQL databases

In this task, you use the Azure Cloud shell to retrieve the IP address of the Sql2008-UniqueId VM, which is needed to connect to your Sql2008-UniqueId VM from DMS.

1. In the [Azure portal](https://portal.azure.com), select the Azure Cloud Shell icon from the top menu.

   ![The Azure Cloud Shell icon is highlighted in the Azure portal's top menu.](media/cloud-shell-icon.png "Azure Cloud Shell")

2. In the Cloud Shell window that opens at the bottom of your browser window, select **PowerShell**.

   ![In the Welcome to Azure Cloud Shell window, PowerShell is highlighted.](media/cloud-shell-select-powershell.png "Azure Cloud Shell")

3. Now you need to select **Advanced settings** and specify the subscription, region and resource group for the new storage account as mentioned below: 

   Click on **Show Advanced Settings**.

      ![](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/storage1.png?raw=true.png "Azure Cloud Shell")

   Use exisiting hands-on-lab-SUFFIX resource group and for:

   - **storage account**: Create new and enter sa{uniqueid}, for example: sa176667.

   - **file share**: Create new and enter fs{uniqueid}, for example: fs176667
 

   ![In the You have no storage mounted dialog, a subscription has been selected, and the Create Storage button is highlighted.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/storage2.png?raw=true "Azure Cloud Shell")

  Then select **Create Storage**.

4. After a moment, a message that you have successfully requested a Cloud Shell appears, and a PS Azure prompt is displayed.

   ![In the Azure Cloud Shell dialog, a message is displayed that requesting a Cloud Shell succeeded, and the PS Azure prompt is displayed.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/cloud-shell-ps-azure-prompt.png?raw=true "Azure Cloud Shell")

5. At the prompt, enter the following command, **replacing `<your-resource-group-name>`** with the name of your resource group **hands-on-lab-SUFFIX** :

   ```powershell
   $resourceGroup = "<your-resource-group-name>"
   ```

6. Next, retrieve the public IP address of the Sql2008-uniqueid VM, which is used to connect to the database on that server. Enter and run the following PowerShell command:(Make sure to replace the Uniqueid and run the command)

   ```powershell
   az vm list-ip-addresses -g $resourceGroup -n Sql2008-uniqueid --output table
   ```
- Replace Sql2008-UniqueId with name of your SQLVM. It will look similar to the one as following:
    ```
    az vm list-ip-addresses -g $resourceGroup -n Sql2008-176667 --output table
    ```

   > **Note**: If you have multiple Azure subscriptions, and the account you are using for this hands-on lab is not your default account, you may need to run `az account list --output table` at the Azure Cloud Shell prompt to output a list of your subscriptions, then copy the Subscription Id of the account you are using for this lab, and then run `az account set --subscription <your-subscription-id>` to set the appropriate account for the Azure CLI commands.

7. Within the output of the command above, locate and copy the value of the `ipAddress` property within the `publicIPAddresses` object. Paste the value into a text editor, such as Notepad.exe, for later reference.

   ![The output from the az vm list-ip-addresses command is displayed in the Cloud Shell, and the publicIpAddress for the Sql2008-UniqueId VM is highlighted.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/cloud-shell-az-vm-list-ip-addresses.png?raw=true "Azure Cloud Shell")

8. Next, run a second command to retrieve the server name of your Azure SQL Database:

   ```powershell
   az sql server list -g $resourceGroup
   ```

   ![The output from the az sql server list command is displayed in the Cloud Shell, and the fullyQualifiedDomainName for the server is highlighted.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/cloud-shell-az-sql-server-list.png?raw=true "Azure Cloud Shell")

9. Copy the **fullyQualifiedDomainName** value into a text editor for use below.

### Task 5: Migrate the database using the Azure Database Migration Service

At this point, you have migrated the database schema using DMA. In this task, you migrate the data from the `ContosoInsurance` database into the new Azure SQL Database using the Azure Database Migration Service.

> The [Azure Database Migration Service](https://docs.microsoft.com/azure/dms/dms-overview) integrates some of the functionality of Microsoft existing tools and services to provide customers with a comprehensive, highly available database migration solution. The service uses the Data Migration Assistant to generate assessment reports that provide recommendations to guide you through the changes required prior to performing a migration. When you're ready to begin the migration process, Azure Database Migration Service performs all of the required steps.

1. In the [Azure portal](https://portal.azure.com), navigate to your Azure Database Migration Service by selecting **Resource groups** from Azure services list, selecting the **hands-on-lab-SUFFIX** resource group, and then selecting the **contoso-dms-UniqueId** Azure Database Migration Service in the list of resources.

   ![The contoso-dms Azure Database Migration Service is highlighted in the list of resources in the hands-on-lab-SUFFIX resource group.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/resource-group-dms-resource.png?raw=true "Resources")

2. On the Azure Database Migration Service blade, select **+New Migration Project**.

   ![The New migration project blade is displayed, with the values specified above entered into the appropriate fields.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/dms-add-new-migration-project.png?raw=true "New migration project")

3. On the New migration project blade, enter the following:

   - **Project name**: Enter DataMigration
   - **Source server type**: Select SQL Server.
   - **Target server type**: Select Azure SQL Database.
   - **Choose type of activity**: Select **Data Migration**.

   ![The New migration project blade is displayed, with the values specified above entered into the appropriate fields.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/migration-1.png?raw=true "New migration project")

4. Select **Create and run activity**.

5. On the Migration Wizard **Select source** blade, enter the following:

   - **Source SQL Server instance name**: Enter the IP address of your Sql2008-UniqueId VM that you copied into a text editor in the previous task. For example, `51.143.12.114`.
   - **Authentication type**: Select SQL Authentication.
   - **Username**: Enter **WorkshopUser**
   - **Password**: Enter **Password.1!!**
   - **Connection properties**: Check both Encrypt connection and Trust server certificate.

   ![The Migration Wizard Select source blade is displayed, with the values specified above entered into the appropriate fields.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/migration1.png?raw=true "Migration Wizard Select source")

1. On the Migration Wizard  **Select Database** blade, select **ContosoInsurance** database.

   ![](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/migration-2.png?raw=true)

1. Select **Next : Select target**.

1. On the Migration Wizard **Select target** blade, enter the following:

   - **Target server name**: Enter the `fullyQualifiedDomainName` value of your Azure SQL Database (e.g., contosoinsurance-288892.database.windows.net), which you copied in the previous task.
   - **Authentication type**: Select SQL Authentication.
   - **Username**: Enter **demouser**
   - **Password**: Enter **Password.1!!**
   - **Connection properties**: Check Encrypt connection.

   ![The Migration Wizard Select target blade is displayed, with the values specified above entered into the appropriate fields.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/migration2.png?raw=true "Migration Wizard Select target")

1. Select **Next : Map to target databases**.

1. On the Migration Wizard **Map to target databases** blade, confirm that **ContosoInsurance** is checked as the source database, and that it is also the target database on the same line.

   ![The Migration Wizard Map to target database blade is displayed, with the ContosoInsurance line highlighted.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/migration3.png?raw=true "Migration Wizard Map to target databases")

1. Select **Next : Configure migration settings**.

1. On the Migration Wizard **Configure migration settings** blade, expand the **ContosoInsurance** database and verify all the tables are selected.

    ![The Migration Wizard Configure migration settings blade is displayed, with the expand arrow for ContosoInsurance highlighted, and all the tables checked.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/migration4.png?raw=true "Migration Wizard Configure migration settings")

1. Select **Next : Summary**.

1. On the Migration Wizard **Summary** blade, enter the following:

    - **Activity name**: Enter ContosoDataMigration

    ![The Migration Wizard summary blade is displayed, with ContosoDataMigration entered into the name field.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/migration5.png?raw=true "Migration Wizard Summary")

1. Select **Start migration**.

1. Monitor the migration on the status screen that appears. Select the refresh icon in the toolbar to retrieve the latest status.

    ![On the Migration job blade, the Refresh button is highlighted, and a status of Full backup uploading is displayed and highlighted.](media/dms-migration-wizard-status-running.png "Migration status")

    > The migration takes approximately 2 - 3 minutes to complete.

1. When the migration is complete, you should see the status as **Completed**, but may also see a status of **Warning**.

    ![On the Migration job blade, the status of Completed is highlighted.](media/dms-migration-wizard-status-complete.png "Migration with Completed status")

    ![On the Migration job blade, the status of Completed is highlighted.](media/dms-migration-wizard-status-warning.png "Migration with Warning status")

1. When the migration is complete, select the **ContosoInsurance** migration item.

    ![The ContosoInsurance migration item is highlighted on the ContosoDataMigration blade.](media/dms-migration-completion.png "ContosoDataMigration details")

1. Review the database migration details.

    ![A detailed list of tables included in the migration is displayed.](media/dms-migration-details.png "Database migration details")
    
1. Click on close button to navigate back to the MigrateData page.

    ![A detailed list of tables included in the migration is displayed.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/dms-migration-details-1.png?raw=true "Database migration details")

1. If you received a status of "Warning" for your migration, you can find more details by selecting **Download report** from the ContosoDataMigration screen.

    ![The Download report button is highlighted on the DMS Migration toolbar.](media/dms-toolbar-download-report.png "Download report")

    > **Note**: The **Download report** button will be disabled if the migration completed without warnings or errors.

1. The reason for the warning can be found in the Validation Summary section. In the report below, you can see that a storage object schema difference triggered a warning. However, the report also reveals that everything was migrated successfully.

    ![The output of the database migration report is displayed.](media/dms-migration-wizard-report.png "Database migration report")

1. Click on **Next** button.

