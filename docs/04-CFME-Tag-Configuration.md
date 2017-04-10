# Tags
We need to add some tags to affect how OCP projects are provisioned.
* Settings --> Configuration
In the pane on the left, choose the appropriate **CFME Region: Region N [N]**.  There may be only one.  

When creating tags, we must first create some categories.

| Name  | Description | Long Description | Show in Console | Single Value | Capture C&U Data by Tag |
| ----- | ----------- | ---------------- | --------------- | ------------ | ----------------------- |
| quota_ocp_pods | Quota OCP Pods | Quota OCP Pods | On | On | Off |
| quota_ocp_pvc | Quota OCP Persistent Volume Claims | Quota OCP Persistent Volume Claims | On | On | Off |
| quota_ocp_rc | Quota OCP Replication Controller Count | Quota OCP Replication Controller Count | On | On | Off |
| quota_ocp_secrets | Quota OCP Secrets | Quota OCP Secrets | On | On | Off |
| quota_ocp_services | Quota OCP Services | Quota OCP Services | On | On | Off |
| ocp_project_role | Default Requester Project Role | Default Requester Project Role | On | On | Off |
| ocp_cluster_type | OCP Cluster Type | OCP Cluster Type | On | On | Off |

Now we can add values to the tags.  For each of the categories above, create the following **recommended** values.

## Quota OCP Pods

| Name | Description |
| ---- | ----------- |
| 100 | 100 |
| 25 | 25 |
| 50 | 50 |

## Quota OCP Persistent Volume Claims

| Name | Description |
| ---- | ----------- |
| 1 | 1 |
| 10 | 10 |
| 5 | 5 |

## Quota OCP Replication Controller Count

| Name | Description |
| ---- | ----------- |
| 10 | 10 |
| 20 | 20 |
| 50 | 50 |

## Quota OCP Secrets

| Name | Description |
| ---- | ----------- |
| 10 | 10 |
| 20 | 20 |
| 5 | 5 |

## Quota OCP Services

| Name | Description |
| ---- | ----------- |
| 100 | 100 |
| 25 | 25 |
| 50 | 50 |

## LDAP Manager Attribute

| Name | Description |
| ---- | ----------- |
| manager | Manager |

## LDAP User Name Attribute

| Name | Description |
| ---- | ----------- |
| uid | UID |

## Default Requester Project Role

| Name | Description |
| ---- | ----------- |
| admin | Administrator |
| edit | Editor |
| view | Viewer |

## OCP Cluster Type

| Name | Description |
| ---- | ----------- |
| dev | Development |
| test | Test |
| prod | Production |

## Applying the tags
Each of the above tags get applied to a group (except the OCP Cluster Type).  Groups are configured under **Access Control**.
* Settings --> Configuration --> Access Control

Under **Groups** select the group to which to apply the tags.  Then go to **Policy** at the top and select the *Edit <Company> Tags for this Group*.

The **OCP Cluster Type** gets applied to a particular Container Manager Provider: OpenShift.
