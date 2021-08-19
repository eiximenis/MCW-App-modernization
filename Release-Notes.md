# Release Notes

### 24 July 2021
  - Minor update
  - As per the recent update in Azure, Log Analytics Workspace needs to be selected along with resource name and location while enabling Application Insights for Function App in [Exercise 5, Task 4](https://github.com/CloudLabs-MCW/MCW-App-modernization/blob/stage/Hands-on%20lab/HOL%20step-by-step%20-%20App%20modernization_09.md). So we added code in ARM template for precreating the Log Analytics workspace, which will allow the users to directly select the loganalytics workspace instead for creating by themselves. Screenshot and instruction has been changed accordingly. 
