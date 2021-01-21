## Exercise 8: Add Cognitive Search for policy documents

Duration: 15 minutes

Contoso has requested the ability to perform full-text searching on policy documents. Previously, they have not been able to extract information from the documents in a usable way, but they have read about [cognitive search with the Azure Cognitive Search Service](https://docs.microsoft.com/azure/search/cognitive-search-concept-intro), and are interested to learn if it could be used to make the data in their search index more useful. In this exercise, you configure cognitive search for the policies blob storage container.

### Task 1: Add Azure Cognitive Search to Storage account

1. In the [Azure portal](https://portal.azure.com), navigate to your **Storage account** resource by selecting **Resource groups** from Azure services list, selecting the **hands-on-lab-SUFFIX** resource group, and then selecting the **contosoUniqueId** Storage account resource from the list of resources.

   ![The Storage Account resource is highlighted in the list of resources.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/media/local/storageaccount3.png?raw=true "Storage account")

2. On the Storage account blade, select **Add Azure Search** from the left-hand menu, and then on the **Select a search service** tab, select your search service.

   ![Add Azure Search is selected and highlighted in the left-hand menu, and the search service is highlighted on the Select a search service tab.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/add-azure-search-select-a-search-service.png?raw=true "Add Azure Search")

3. Select **Next: Connect to your data**.

4. On the **Connect to your data** tab, enter the following:

   - **Data Source**: Leave the value of **Azure Blob Storage** selected.
   - **Name**: Enter **policy-docs**.
   - **Data to extract**: Select **Content and metadata**.
   - **Parsing mode**: Leave set to **Default**.
   - **Connection string**: Leave this set to the pre-populated connection string for your Storage account.
   - **Container name**: Enter **policies**.

   ![On the Connect to your data tab, the values specified above are entered in to the form.](media/add-azure-search-connect-to-your-data.png "Add Azure Search")

5. Select **Next: Add cognitive skills (Optional)**.

   > **Note**: Skipping this step will cause issues in Task 2, as the Free (Limited enrichments) option restricts the number of documents indexed to 20. If you use the Free cognitive services option, you will receive a message that indexing was stopped after reaching the limit.

6. On the **Add cognitive skills** tab, set the following configuration:

   - Expand Attach Cognitive Services, and select your Cognitive Services account.
   - Expand Add enrichments:
     - **Skillset name**: Enter **policy-docs-skillset**.
     - **Text cognitive skills**: Check this box to select all the skills.

   ![The configuration specified above is entered into the Add cognitive search tab.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/add-azure-search-add-cognitive-skills.png?raw=true "Add Azure Search")

7. Select **Next: Customize target index**.

8. On the **Customize target index tab**, do the following:

   - **Index name**: Enter **policy-docs-index**.
   - Check the top Retrievable box, to check all items underneath it.
   - Check the top Searchable box, to check all items underneath it.

   ![The Customize target index tab is displayed with the Index name, Retrievable checkbox and Searchable checkbox highlighted.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/add-azure-search-customize-target-index.png?raw=true "Add Azure Search")

9. Select **Next: Create an indexer**.

10. On the **Create an indexer** tab, enter **policy-docs-indexer** as the name, select **Once** for the schedule, and then select **Submit**.

    ![The name field and submit button are highlighted on the Create an indexer tab.](media/add-azure-search-create-an-indexer.png "Add Azure Search")

    > **Note**: For this hands-on lab, we are only running the indexer once, at the time of creation. In a production application, you would probably choose a schedule such as hourly or daily to run the indexer. This would allow you to bring in any new data that arrives in the target blob storage account.

11. Within a few seconds, you receive a notification in the Azure portal that the import was successfully configured.

### Task 2: Review search results

In this task, you run a query against your search index to review the enrichments added by cognitive search to policy documents.

1. In the [Azure portal](https://portal.azure.com), navigate to your **Search service** resource by selecting **Resource groups** from Azure services list, selecting the **hands-on-lab-SUFFIX** resource group, and then selecting the **contoso-search-UniqueId** Search service resource from the list of resources.

   ![The Search service resource is highlighted in the list of resources.](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/fix/Hands-on%20lab/local/azure-resources-search.png?raw=true "Search service")

2. On the Search service overview blade, scroll down and select **Indexers**.

   ![In Contoso Insurance search service, Indexers is highlighted and selected.](media/azure-search-indexers.png "Search Service")

   > **Note**: If you see a message that the indexer was stopped because the free skillset execution quota has been reached, you will need to return to Exercise 8, Task 1, Step 6, and select your cognitive services account.

3. Note the status of the policy-docs-indexer. Once the indexer has run, it should display a status of **Success**. If the status is **In progress**, select **Refresh** every 20-30 seconds until it changes to **Success**.

   > If you see a status of **No history**, select the policy-docs-indexer, and select **Run** on the Indexer blade.

4. Now select **Search explorer** in the Search service blade toolbar.

   ![Search explorer is highlighted on the Search service toolbar.](media/search-service-explorer.png "Search service")

5. On the **Search explorer** blade, select **Search**.

6. In the search results, inspect the returned documents, paying special attention to the fields added by the cognitive skills you added when creating the search index. These fields are `People`, `Organizations`, `Locations`, `Keyphrases`, `Language`, and `Translated_Text`.

   ```json
   {
     "@search.score": 1,
     "content": "\nContoso Insurance - Your Platinum Policy\n\nPolicy Holder: Igor Cooke\nPolicy #: COO13CE2ZLOKD\nEffective Coverage Dates: 22 July 2008 - 13 August 2041\nAddress: P.O. Box 442, 802 Pellentesque AveTaupo, NI 240\nPolicy Amount: $48,247.00\nDeductible: $250.00\nOut of Pocket Max: $1,000.00\n\nDEPENDENTS\nFirst Name Date of Birth\n\nIma 21 January 2002\nEcho 12 August 2003\n\nPage Summary\nDependents\n\n1 / 0 22 July 2008\n\n\nworksheet1\n\n\t\tFirst Name\t\tDate of Birth\n\n\t\tIma\t\t21 January 2002\n\n\t\tEcho\t\t12 August 2003\n\n\n\n\n\n\n",
     "metadata_storage_content_type": "application/octet-stream",
     "metadata_storage_size": 142754,
     "metadata_storage_last_modified": "2019-10-23T21:42:23Z",
     "metadata_storage_content_md5": "ksk3JZT5QPkHfAR0F17ZEw==",
     "metadata_storage_name": "Cooke-COO13CE2ZLOKD.pdf",
     "metadata_storage_path": "aHR0cHM6Ly9ob2xzdG9yYWdlYWNjb3VudC5ibG9iLmNvcmUud2luZG93cy5uZXQvcG9saWNpZXMvQ29va2UtQ09PMTNDRTJaTE9LRC5wZGY1",
     "metadata_content_type": "application/pdf",
     "metadata_language": "en",
     "metadata_author": "Contoso Insurance",
     "metadata_title": "Your Policy",
     "People": ["Igor Cooke", "Cooke", "Max"],
     "Organizations": [
       "Contoso Insurance - Your Platinum Policy",
       "NI",
       "DEPENDENTS\nFirst",
       "Ima",
       "Page Summary\nDependents",
       "Echo"
     ],
     "Locations": [],
     "Keyphrases": [
       "Platinum Policy",
       "Policy Holder",
       "Date of Birth",
       "Echo",
       "DEPENDENTS",
       "Ima",
       "Box",
       "Pellentesque AveTaupo",
       "Address",
       "NI",
       "Contoso Insurance",
       "Igor Cooke",
       "Effective Coverage Dates",
       "Pocket Max",
       "Page Summary",
       "COO13CE2ZLOKD",
       "worksheet1"
     ],
     "Language": "en",
     "Translated_Text": "\nContoso Insurance - Your Platinum Policy\n\nPolicy Holder: Igor Cooke\nPolicy #: COO13CE2ZLOKD\nEffective Coverage Dates: 22 July 2008 - 13 August 2041\nAddress: P.O. Box 442, 802 Pellentesque AveTaupo, NI 240\nPolicy Amount: $48,247.00\nDeductible: $250.00\nOut of Pocket Max: $1,000.00\n\nDEPENDENTS\nFirst Name Date of Birth\n\nIma 21 January 2002\nEcho 12 August 2003\n\nPage Summary\nDependents\n\n1 / 0 22 July 2008\n\nworksheet1\n\nFirst Name\t\tDate of Birth\n\nIma\t\t21 January 2002\n\nEcho\t\t12 August 2003\n\n"
   }
   ```

7. For comparison, the same document without cognitive search skills enabled would look similar to the following:

   ```json
   {
     "@search.score": 1,
     "content": "\nContoso Insurance - Your Platinum Policy\n\nPolicy Holder: Igor Cooke\nPolicy #: COO13CE2ZLOKD\nEffective Coverage Dates: 22 July 2008 - 13 August 2041\nAddress: P.O. Box 442, 802 Pellentesque AveTaupo, NI 240\nPolicy Amount: $48,247.00\nDeductible: $250.00\nOut of Pocket Max: $1,000.00\n\nDEPENDENTS\nFirst Name Date of Birth\n\nIma 21 January 2002\nEcho 12 August 2003\n\nPage Summary\nDependents\n\n1 / 0 22 July 2008\n\n\nworksheet1\n\n\t\tFirst Name\t\tDate of Birth\n\n\t\tIma\t\t21 January 2002\n\n\t\tEcho\t\t12 August 2003\n\n\n\n\n\n\n",
     "metadata_storage_content_type": "application/octet-stream",
     "metadata_storage_size": 142754,
     "metadata_storage_last_modified": "2019-10-23T21:42:23Z",
     "metadata_storage_content_md5": "ksk3JZT5QPkHfAR0F17ZEw==",
     "metadata_storage_name": "Cooke-COO13CE2ZLOKD.pdf",
     "metadata_storage_path": "aHR0cHM6Ly9ob2xzdG9yYWdlYWNjb3VudC5ibG9iLmNvcmUud2luZG93cy5uZXQvcG9saWNpZXMvQ29va2UtQ09PMTNDRTJaTE9LRC5wZGY1",
     "metadata_content_type": "application/pdf",
     "metadata_language": "en",
     "metadata_author": "Contoso Insurance",
     "metadata_title": "Your Policy"
   }
   ```

8. As you can see from the search results, the addition of cognitive skills adds valuable metadata to your search index, and helps to make documents and their contents more usable by Contoso.

