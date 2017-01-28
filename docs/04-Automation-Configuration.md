# Automation Configuration
## Creating the Custom Service Dialog
The dialog being created will resemble the web form presented when one provisions a new project through the OpenShift web interface.
* Automate --> Customization --> Service Dialogs

From the **Configuration** dropdown choose **Add a new Dialog**

Name this the *project-request-dialog*.  Give it a *Submit* and *Cancel* button.

1. Add a tab named *Basic Info*
2. Add a box named *General*
3. Add the following elements.

| Label | Name | Description | Type | Required |  Validator Rule |
| ----- | ---- | ----------- | ---- | -------- | -------------- |
| Project Name | option_0_service_name | Project name may only container lowercase letters and numbers | Text Box | Yes | ^([a-z0-9]+-)*[a-z0-9]+$ |
| Project Display Name | option_0_display_name  | | Text Box | No | |
| Project Description | option_0_project_description | | Text Area Box | No |  |

Save

## Importing the Automate model
### Download the Model

1. Navigate to https://github.com/kevensen/cfme-ocp
2. Clone the repository

### ZIP the Repository

1. In your file system, navigate to you cloned folder
2. Use your favorite archive utility to zip the POC folder as a **ZIP** archive

### Import the Model

1. In CFME, navigate to *Automate --> Import / Export*
2. In the *Import Datastore Classes* dialog, click *Choose File*
3. In the file choose, find and select the ZIP file you created
4. Click *Upload*
5. On the next screen, the only option to change is the *Toggle All/None* to ensure that all components are selected.  Leave defaults for the other options.
6. Click *Commit*

### Enable the Model

1. Navigate to *Automate --> Explorer*
2. In the tree select *POC*
3. Click on *Configuration* in the button bar
4. Click *Edit this Domain*
5. Check the *Enabled Box* if it is not enabled

### Configure the Model

1. In CFME, navigate to *Automate --> Explorer*
2. Under *Datastore*, navigate to the *POC/Containers/Methods* class
3. For each of the following instances, update the instance fields by navigating to *Configuration* and *Edit the Instnance* in the button bar.
 * AddUserRole
 * CheckProjectExists
 * CreateProject
 * CreateProjectQuota
 * DeleteProject
 * ProjectRequestValidation
4. Under *Datastore*, navigate to the *POC/Service/Provisioning/Email* class
5. For each of the following instances, update the instance fields by navigating to *Configuration* and *Edit the Instance* in the button bar.
 * .missing
 * ProjectRequest_Pending_Approver
 * ProjectRequest_Pending_User
 * ServiceProvision_Complete
 * ServiceTemplateProvisionRequest_Approved
 * ServiceTemplateProvisionRequest_Denied
 * ServiceTemplateProvisionRequest_Pending

### Create a Service Catalog

These steps are optional and are only required if you do not have a catalog you wish to use.

1. Navigate to *Services --> Catalogs*
2. With the *Catalogs* accordion open, click *Configuration --> Add a New Catalog"* in the button bar
3. Provide a name and description

### Create a Catalog Item

1. Navigate to *Services --> Catalogs*
2. With the *Catalog Items* accordion open, choose the desired catalog
3. Click *Configuration --> Add a New Catalog Item"* in the button bar
4. With the catalog item type, choose *Generic*
5. The name will be *Project Request*
6. The description will be *Project Request*
7. In *Catalog*, choose your desired catalog
8. In *Dialog*, choose the dialog you created earlier
9. For *Provisioning Entry Point State Machine (NS/Cls/Inst)* choose /POC/Service/Provisioning/StateMachines/ServiceProvision_Template/ProjectRequestItemInitialization
