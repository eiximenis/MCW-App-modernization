## Exercise 2: Post upgrade database enhancements

Duration: 30 minutes

In this exercise you explore some of the security features of Azure SQL Database, and review some of the security benefits that come with running your database in Azure. [SQL Database Advance Data Security](https://docs.microsoft.com/azure/sql-database/sql-database-advanced-data-security) (ADS) provides advanced SQL security capabilities, including functionality for discovering and classifying sensitive data, surfacing and mitigating potential database vulnerabilities, and detecting anomalous activities that could indicate a threat to your database.

> **Note**: Advanced Data Security was enabled on the database with the ARM template, so you do not need to do that here.

### Task 1: Configure SQL Data Discovery and Classification

In this task, you look at the [SQL Data Discovery and Classification](https://docs.microsoft.com/sql/relational-databases/security/sql-data-discovery-and-classification?view=sql-server-2017) feature of Advanced Data Security. Data Discovery & Classification introduces a new tool for discovering, classifying, labeling & reporting the sensitive data in your databases. It introduces a set of advanced services, forming a new SQL Information Protection paradigm aimed at protecting the data in your database, not just the database. Discovering and classifying your most sensitive data (business, financial, healthcare, etc.) can play a pivotal role in your organizational information protection stature.

1. In the [Azure portal](https://portal.azure.com), navigate to your **SQL database** resource by selecting **Resource groups** from Azure services list, selecting the **hands-on-lab-SUFFIX** resource group, and then selecting the **ContosoInsurance** SQL database resource from the list of resources.

   ![The contosoinsurance SQL database resource is highlighted in the list of resources.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/resources-azure-sql-database.png?raw=true "SQL database")

2. On the SQL database blade, select **Data Discovery & Classification** under security from the left-hand menu.

   ![Advanced Data Security is highlighted in the menu. Data Discovery & Classification option is highlighted to select.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/datadiscovery.png?raw=true "Advance Data Security")

3. On the **Data Discovery & Classification** blade, select the info link with the message **We have found 7 columns with classification recommendations**.

   ![The recommendations link on the Data Discovery & Classification blade is highlighted.](media/ads-data-discovery-and-classification-recommendations-link.png "Data Discovery & Classification")

4. The classification engine scans the database and provides a list of recommended column classifications. Look over the list of recommendations to get a better understanding of the types of data and classifications are assigned, based on the built-in classification settings. In the list of classification recommendations, note the recommended classification for the **dbo - people - DOB** field (Confidential - GDPR).

   ![The DOB recommendation is highlighted in the recommendations list.](media/ads-data-discovery-and-classification-recommendations-dob.png "Data Discovery & Classification")

5. Contoso is very concerned about the potential cost of any GDPR violations, and would like to label any GDPR fields as _Highly Confidential - GDPR_. To update this, select **+ Add classification** in the Data Discovery & Classification toolbar.

   ![The +Add classification button is highlighted in the toolbar.](media/ads-data-discovery-and-classification-add-classification.png "Data Discovery & Classification")

6. In the Add classification dialog, quickly expand the **Sensitivity label** field, and review the various built-in labels you can choose from. You can also add your own labels, should you desire.

   ![The list of built-in Sensitivity labels is displayed.](media/ads-data-discovery-and-classification-sensitivity-labels.png "Data Discovery & Classification")

7. In the Add classification dialog, enter the following:

   - **Schema name**: Select dbo.
   - **Table name**: Select people.
   - **Column name**: Select DOB (date).
   - **Information type**: Select Date Of Birth.
   - **Sensitivity level**: Select Highly Confidential - GDPR.

   ![The values specified above are entered into the Add classification dialog.](media/ads-data-discovery-and-classification-add-dob-classification.png "Add classification")

8. Select **Add classification**.

9. After adding the new classification, the **dbo - people - DOB** field disappears from the recommendations list, and the number of recommendations drop by 1.

10. Select **Save** on the toolbar to save the changes.

    ![The Save button is highlighted on the Data Discovery & Classification toolbar.](media/ads-data-discovery-and-classification-save.png "Save")

11. To accept the remaining recommendations, you can check the **Select all** option and then select **Accept selected recommendations**.

    ![Classification tab on Data Discovery & Classification window showing a list of classification recommendations for ContosoInsurance database. Select all checkbox is highlighted and selected. Accept selected recommendations button is highlighted.](media/e2-05.png "Accept selected recommendations")

12. Select **Save** on the toolbar to save the changes.

    ![The Save button is highlighted on the Data Discovery & Classification toolbar.](media/ads-data-discovery-and-classification-save.png "Save")

13. When the save completes, select the **Overview** tab on the Data Discovery & Classification blade to view a report with a full summary of the database classification state.

    ![The overview dashboard is displayed.](media/ads-data-discovery-and-classification-overview.png "Overview report")

### Task 2: Review Advanced Data Security Vulnerability Assessment

In this task, you review an assessment report generated by ADS for the `ContosoInsurance` database. The [SQL Vulnerability Assessment service](https://docs.microsoft.com/azure/sql-database/sql-vulnerability-assessment) is a service that provides visibility into your security state, and includes actionable steps to resolve security issues, and enhance your database security.

1. Return to the `ContosoInsurance` SQL database blade, from the left-hand menu select **Security Center** under security.

2. On the **Security Center | Getting started** blade click on **Close** button.

   ![ContosoInsurance Azure SQL database into Azure Portal. Advanced Data Security is highlighted in the menu. Vulnerability Assessment section is highlighted](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/e2-06-1.png?raw=true "VulnerabilityAssessment")

3. Now on the **Security center** blade click on **View additional findings in Vulnerability Assessment**.

   ![ContosoInsurance Azure SQL database into Azure Portal. Advanced Data Security is highlighted in the menu. Vulnerability Assessment section is highlighted](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/e2-06.png?raw=true "Vulnerability Assessment")

4. On the Vulnerability Assessment blade, select **Scan** on the toolbar.

   ![Vulnerability Assessment window with Scan Option highlighted](media/e2-07.png "Scan Option")

5. When the scan completes, a dashboard displaying the number of failing and passing checks, along with a breakdown of the risk summary by severity level is displayed.

   ![Vulnerability Assessment window with the assessment results](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/e2-08.png?raw=true "Vulnerability Assessment results")

6. In the scan results, take a few minutes to browse both the Failed and Passed checks, and review the types of checks that are performed. In the **Failed** the list, select any of the failed checks to view the detailed description.

   ![The details of the VA1143 - Transparent data encryption should be enabled finding are displayed with the description, impact, and remediation fields highlighted.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/vulnerability-assessment-failed-va1143-details.png?raw=true "Vulnerability Assessment")

   > The details for each finding provide more insight into the reason for the finding. Of note are the fields describing the finding, the impact of the recommended settings, and details on how to remediate the finding.

### Task 3: Enable Dynamic Data Masking

In this task, you enable [Dynamic Data Masking](https://docs.microsoft.com/sql/relational-databases/security/dynamic-data-masking?view=sql-server-ver15) (DDM) into your Azure SQL Database to limit access to sensitive data in the database through query results. This feature helps prevent unauthorized access to sensitive data by enabling customers to designate how much of the sensitive data to reveal with minimal impact on the application layer. It’s a policy-based security feature that hides the sensitive data in the result set of a query over designated database fields, while the data in the database is not changed.

> For example, a service representative at a call center may identify callers by several digits of their credit card number, but those data items should not be fully exposed to the service representative. A masking rule can be defined that masks all but the last four digits of any credit card number in the result set of any query. As another example, an appropriate data mask can be defined to protect personally identifiable information (PII) data, so that a developer can query production environments for troubleshooting purposes without violating compliance regulations.

1. Return to the Overview blade of your SQL database in the [Azure portal](https://portal.azure.com), and select **Dynamic Data Masking** from the left-hand menu.

   ![Dynamic Data Masking is highlighted in the left-hand menu.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/datamasking.png?raw=true "Dynamic Data Masking")

2. On the Dynamic Data Masking blade, you may see a few recommended fields to mask that have been flagged as they may contain sensitive data. For our case, we want to apply a mask to the `DOB` field on the `people` table to provide more protection to GDPR data. To do this, select **+ Add mask** in the Dynamic Data Masking toolbar.

   ![Dynamic Data Masking window with recommended fields. The +Add mask button in the toolbar is highlighted.](media/e2-02.png "Dynamic Data Masking")

3. On the Add masking rule blade, enter the following:

   - **Schema**: Select dbo.
   - **Table**: Select people.
   - **Column**: Select DOB (date).
   - **Masking field format**: Select Default value (0, xxx, 01-01-1900).
   - Select **Add**.

   ![On the Add masking rule dialog, the values specified above are entered into the form, and the Add button is highlighted.](media/ddm-add-masking-rule.png "Dynamic Data Masking")

4. Select **Save** and click on **Ok** on the **Success** dialog.

   ![The Save button is highlighted on the DDM toolbar.](media/ddm-save.png "Dynamic Data Masking")

5. To view the impact of the Dynamic Data Masking, return to SSMS on your Sql2008-UniqueId VM and run a few queries against the `people` table. On your Sql2008-UniqueId VM, open SSMS and connect to the Azure SQL Database, by selecting **Connect->Database Engine** in the Object Explorer, and then entering the following into the Connect to server dialog:

   - **Server name**: Paste the server name of your Azure SQL Database, as you've done previously.
   - **Authentication type**: Select SQL Server Authentication.
   - **Username**: Enter **demouser**
   - **Password**: Enter **Password.1!!**
   - **Remember password**: Check this box.

   ![The SSMS Connect to Server dialog is displayed, with the Azure SQL Database name specified, SQL Server Authentication selected, and the demouser credentials entered.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/ssms-connect-azure-sql-database.png?raw=true "Connect to Server")

6. Select **Connect**.

7. Once connected, expand Databases, right-click the `ContosoInsurance` database and select **New Query**.

   ![In the SSMS Object explorer, the context menu for the ContosoInsurance database is displayed, and New Query is highlighted.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/ssms.png?raw=true "SSMS")

8. To be able to test the mask applied to the `people.DOB` field, you need to create a user in the database that can be used for testing the masked field. This is because the `demouser` account you used to log in is a privileged user, so the mask is not be applied. In the new query window, paste the following SQL script into the new query window:

   ```sql
   USE [ContosoInsurance];
   GO

   CREATE USER DDMUser WITHOUT LOGIN;
   GRANT SELECT ON [dbo].[people] TO DDMUser;
   ```

   > The SQL script above creates a new user in the database named `DDMUser`, and grants that user `SELECT` rights on the `dbo.people` table.

9. Select **Execute** from the SSMS toolbar to run the query. A message that the commands completed successfully should appear in the Messages pane.

   ![The Execute button is highlighted on the SSMS toolbar.](./media/ssms-execute.png "Execute")

10. With the new user created, run a quick query to observe the results. Select **New Query** again, and paste the following into the new query window.

    ```sql
    USE [ContosoInsurance];
    GO

    EXECUTE AS USER = 'DDMUser';
    SELECT TOP 10 * FROM [dbo].[people];
    REVERT;
    ```

11. Select **Execute** from the toolbar, and examine the Results pane. Notice the `DOB` field is masked as `1900-01-01`, as defined by the mask format applied in the Azure portal.

    ![In the query results, the DOB field is highlighted, showing how all the birth dates are masked, and displaying as 1900-01-01, as defined in the mask format applied in the Azure portal.](media/ssms-masked-results.png "SSMS Query Results")

12. For comparison, run the following query in a new query window to see how the data looks when running as a privileged user.

    ```sql
    SELECT TOP 10 * FROM [dbo].[people]
    ```

    ![In the query results, the DOB field is highlighted, showing how all the birth dates appear as the actual birth date, and not a masked value.](media/ssms-unmasked-results.png "SSMS Query Results")



13. Click on **Next** button.
