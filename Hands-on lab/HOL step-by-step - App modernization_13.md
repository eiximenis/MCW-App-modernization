## Exercise 9: Create an app in PowerApps

Duration: 15 minutes

Since creating mobile apps is a long development cycle, Contoso is interested in using PowerApps to create mobile applications to add functionality not currently offered by their app rapidly. In this scenario, they want to be able to edit the Policy lookup values (Silver, Gold, Platinum, etc.), which they are unable to do in the current app. In this task, you get them up and running with a new app created in PowerApps, which connects to the `ContosoInsurance` database and performs basic CRUD (Create, Read, Update, and Delete) operations against the Policies table.

### Task 1: Sign up for a PowerApps account

1. Go to <https://web.powerapps.com> and sign up for a new account, using the same account you have been using in Azure.

2. You may receive an email asking you to verify your account request, with a link to continue the process.

3. Download and install **PowerApps Studio** from the Microsoft store: <https://www.microsoft.com/en-us/store/p/powerapps/9nblggh5z8f3>

> **Note**: If you are unable to install PowerApps on the LabVM, you can run install it on your local machine and run the steps for this exercise there.

### Task 2: Create new SQL connection

1. From the PowerApps website, expand the **Data** option from the left-hand navigation menu, then select **Connections**.

2. Select the **+ New connection** button.

   ![Connections is highlighted in the left-hand menu and the Create a connection button is highlighted.](media/powerapps-new-connection.png "PowerApps Connections")

3. Type **SQL** into the search box, and then select the SQL Server item in the list below.

   ![In the New connection section, the search field is set to SQL. In the item list below, SQL Server is selected.](media/powerapps_create_connection.png "PowerApps New Connection")

4. Within the SQL Server connection dialog, enter the following:

   - **Authentication Type**: Select **SQL Server Authentication**.
   - **SQL Server name**: Enter the server name of your Azure SQL database. For example, `contosoinsurance-jjbp34uowoybc.database.windows.net`.
   - **SQL Database name**: Enter **ContosoInsurance**
   - **Username**: Enter **demouser**
   - **Password**: Enter **Password.1!!**

   ![The SQL Server dialog box fields are completed.](media/powerapps_connection_sqlserver.png "SQL Server dialog box")

5. Select **Create**.

### Task 3: Create a new app

1. Open the PowerApps Studio application you downloaded previously and sign in with your PowerApps account.

2. Select **New** on the left-hand side and in the browser windows that opens confirm your country/region and select **Get started**.

3. Then **select the right arrow** next to the **Start with your data** list.

   ![In the PowerApps Studio, the New button on the left is selected. The right arrow to the right of Create an app from your data is also selected.](media/powerapps_new.png "PowerApps Studio")

4. Select the **SQL Server connection** you created in the previous task.

   ![PowerApps - New option from left-hand side highlighted, as well as previously-created SQL Server connection. ](media/powerapps_create_newapp.png "PowerApps Studio")

5. Select the **policies** table from the Choose a table list.

   ![PowerApps - Previously-created Connection from the left-hand menu highlighted, as well as the Policies table. ](media/powerapps_select_table.png "PowerApps Studio")

6. Select **Connect**.

### Task 4: Design app

1. The new app is automatically created and displayed within the designer. Select the title for the first page (currently named [dbo].[Policies]) and edit the text in the field to read **Policies**.

   ![All of the Policy options display.](media/powerapps-update-app-title.png "Policies section")

2. Select the **DetailScreen1** screen in the left-hand menu.

   ![On the Home tab, under Screens, DetailScreen1 is selected.](media/powerapp_select_detailsscreen.png "DetailScreen")

3. Reorder the fields on the form by selecting them, then dragging them by the **Card: <field_name>** tag to the desired location. The new order should be **Name**, **Description**, **DefaultDeductible**, then **DefaultOutOfPocketMax**.

   ![In the dbo.policies window, the new order of the fields displays.](media/powerapp_reorder_fields.png "dbo.policies window")

4. On the form, edit the **DefaultDeductible** and **DefaultOutOfPocketMax** labels to be **Default Deductible** and **Default Out of Pocket Max**, respectively. To do so, select the field and type the new title in quotes within the formula field.

   > **Hint**: You need to select **Unlock** in order to change fields.

5. Rename the screen title to Policy by typing "Policy" in quotation marks within the formula field.

   ![The formula field is set to "Policy".](media/powerapp_update_fields_names.png "Formula field")

6. Select EditScreen on the left-hand menu.

7. Repeat steps 4-6 on the edit screen.

### Task 5: Edit the app settings and run the app

1. Select **File** on the top menu.

   ![The File menu is highlighted in the PowerApps page.](media/power-apps-file-menu.png "Power Apps")

2. Select **Name + icon** under Settings and enter in a new **Name**, such as "PolicyConnect Plus".

   ![In PowerShell App Studio, under Settings, Name + icon is selected, and the Name is set to PolicyConnectPlus.](media/powerapps-settings-name-icon.png "PowerShell App Studio")

3. Select **Save** on the left-hand menu to save the app to the cloud, then select the **Save** button below.

   ![The Save menu is highlighted on the left-hand menu and the Save button is highlighted on the Save form.](media/powerapps-save.png "Save App")

4. After saving, select the left arrow on top of the left-hand menu.

   ![The left arrow on top of the left-hand menu highlighted. ](media/powerapp_save_app.png "PowerShell App Studio")

5. Select **BrowseScreen1** from the left-hand menu and then select the **Run** button on the top menu to preview the app. You should be able to view the current policies, edit their values, and create new policies.

   ![The Run button is highlighted in the toolbar.](media/powerapp_run_app.png "PowerShell App Studio")

6. Browse through the various policies in the app to explore the functionality.

