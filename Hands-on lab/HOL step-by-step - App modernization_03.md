# Solution architecture

Below is a high-level architecture diagram of the solution you implement in this hands-on lab. Please review this carefully, so you understand the whole of the solution as you are working on the various components.

![This solution diagram includes a high-level overview of the architecture implemented within this hands-on lab.](media/architecture-diagram.png "Solution architecture diagram")

> **Note:** The solution provided is only one of many possible, viable approaches.

The solution begins with setting up Azure Migrate as the central assessment and migration hub for Parts Unlimited's E-Commerce web site. Using the App Service Migration Assistant tool from Azure Migrate, Parts Unlimited found that their web site is fully compatible with Azure App Service. As a next step, they use App Service Migration Assistant to provision an Azure App Service environment and deploy their application to Azure. Following the success in moving the web application, Parts Unlimited uses the Data Migration Assistant (DMA) assessment to determine that they can migrate into a fully-managed SQL Database service in Azure. The assessment reveals no compatibility issues or unsupported features that would prevent them from using Azure SQL Database.

Next, Parts Unlimited sets up a private GitHub repository and pushes their codebase to GitHub. They set up deployment slots to have a staging environment to test functionality before releasing to production. As a CI/CD solution, they decide to use GitHub Actions and Workflows.

Finally, Parts Unlimited decides to decouple its order processing system and move to an event-driven serverless compute platform. Following a [web-queue-worker architecture](https://docs.microsoft.com/en-us/azure/architecture/guide/architecture-styles/web-queue-worker), they build an Azure Function and use Azure Storage Queue to process orders and create invoices asynchronously. When new orders come in, the web front end adds jobs into the queue consumed by Azure Functions. The Functions App scales independently based on the number of jobs in the queue, helping Parts Unlimited elastically handle a variable amount of orders.
