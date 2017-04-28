# QE Testing
These tests will employ buttons for some simple testing of this functionality.

## Pre-Requistes
1. Configure your development environment per ManageIQ the [developer documentation](https://github.com/ManageiQ/guides).
2. Clone the **container-resource-work** branch of kevensen's [ManageIQ](https://github.com/kevensen/manageiq.git) repo.
```terminal
# git clone https://github.com/kevensen/manageiq.git -b container-resource-work
```
3. Some of this work is now in the *manageiq-providers-openshift* plugin. Clone the **master** branch of kevensen's [manageiq-providers-openshift](https://github.com/kevensen/manageiq-providers-openshift.git) plugin.
```terminal
# git clone https://github.com/kevensen/manageiq-providers-openshift.git
```
4. Now [configure](https://github.com/ManageIQ/guides/blob/master/developer_setup/plugins.md) manageiq to use this plugin that you cloned.
  1. This involves adding the following to your ./manageiq/Gemfile.dev.rb file.
  ```terminal
  # Gemfile.dev.rb:
override_gem 'manageiq-providers-openshift', :path => File.expand_path("/path/to/provider/manageiq-providers-openshift")
  ```
5. Start ManageIQ per the same developer docs as in step one.
6. Clone the **euwe-rework** branch in this repository.  You may wish to do this on a machine that contains your desktop since the files you will upload will be done through the Web UI.
```terminal
# git clone https://github.com/kevensen/cfme-ocp.git -b euwe-rework
```
7. Add an OCP cluster to ManageIQ
## Configure the OCP Service Account
1. Open a terminal session (e.g. SSH) to an OCP master in your cluster.
2. The **system:serviceaccount:management-infra:management-admin** must be given the cluster-admin role.
```terminal
oadm policy add-cluster-role-to-user cluster-admin system:serviceaccount:management-infra:management-admin
```
3. You can log out of the OCP master.

## Configure ManageIQ
1. Log in to the ManageIQ WebUI.
12 Add a user to ManageIQ.  This user can belong to any group.  For ease, EvmGroup-super_administrator will be fine.

### Import the Automate Model
1. Navigate to Automation --> Automate --> Import/Export
2. In the **Import Datastore Classes (*.zip)** dialog click **Choose file**
3. The cfme-ocp repository contains a **datastore_2017_04_28.zip** file.  Choose this file.
4. Click **Upload**
5. On the next screen:
  1. Select existing domain to import into: <Same as import from>
  2. Select domain you wish to import from: POC
  3. Select namespaces you wish to import: Toggle All
6. Click Commit
**NOTE:** There may appear to be some UI errors.  I believe these can be safely ignored.

### Import the Service Dialogs
1. Navigate to Automation --> Automate --> Customization
2. Click the Import/Export accordion
3. Click **Choose file**
4. The cfme-ocp repository contains the service dialog configuration: dialog_export_20170414_151512.yml.  Choose this file.
5. Click **Upload**
6. On the next sreen, only choose the *project-request-dialog* and click **Commit**

### Import Tags
1. kevensen's cfme-ocp repository contains a YAML file with the tags necessary to support the automate model.  Copy the **cfme-ocp-tags.yml** file to the ManageIQ host.
2. Import the tags with the following command.
```terminal
# cd manageiq
# rails runner tools/import_tags.rb cfme-ocp-tags.yml
```

### Tag the Appropriate Entities
#### Tag the User's Group
1. Navigate to Configuration --> Access Control --> Groups.
2. Select the User's group.
3. Click the **Policy** button and **Edit 'something' Tags for this Group**.
4. The following tags must be assigned to the group.
  1. Default Requester Project Role -- Administrator
  2. OCP Cluster Promotion Step -- 1
  3. Quota OCP Persistent Volume Claims -- 10
  4. Quota OCP Pods -- 100
  5. Quota OCP Replication Controller Count -- 50
  6. Quota OCP Secrets -- 20
  7. Quota OCP Services -- 100

#### Tag the Provider
1. Navigate to Compute --> Containers --> Providers
2. Click the **Policy** and **Edit tags for this Provider**
3. The following tags must be assigned to this provider.
  1. CFME Managed: True
  2. OCP Cluster Promotion Step: 1

#### Configure a Service Catalog Item
1. Navigate to Services --> Catalogs
2. Click the Catalogs accordion
3. Click the **Configuration** Button and **Add New Catalog**
4. Create a name for your catalog and click **Ok**
5. Click the Catalog Items accordion and select the catalog defined in the previous step
6. Click the **Configuration** Button and **Add New Catalog Item**
  1. Catalog Item Type -- Generic
  2. Name / Description -- Project Provision Request / Project Provision Request
  3. Display in Catalog -- Check
  4. Catalog -- << The catalog you defined in the previous step >>
  5. Dialog -- project-request-dialog
  6. Provisioning Entry Point -- POC/Service/Provisioning/StateMachines/ServiceProvisioin_Template/ProjectRequestItemInitialization
  7. Reconfigure Entry Point -- << Empty >>
  8. Retirement Entry Point -- << Empty >>

## Provision a Project
I'm sorry that was kind of a drag getting setup.  It was worth it, I promise.
1. Navigate to Service --> Catalogs
2. Click the Service Catalogs accordion
3. Next to Project Request click **Order**
4. Enter a Project Name
5. Click **Submit**

**NOTE:** If your user is in the EvmGroup-super_administrator group, the request will auto-approve.
