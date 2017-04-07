# Prerequisites
1. Install the [OpenShift Container Platform](https://docs.openshift.com/enterprise/3.2/install_config/install/index.html)
  * Though not necessary, if you wish to disable the self-service provisioner capability, see the [administration documentation](https://docs.openshift.com/enterprise/3.2/admin_guide/managing_projects.html)
2. The **system:serviceaccount:management-infra:management-admin** must be given the cluster-admin role.
```terminal
oadm policy add-cluster-role-to-user cluster-admin system:serviceaccount:management-infra:management-admin
```
3. Deploy CloudForms 5.7.2 (or ManageIQ).  I recommend one appliance configured for database management and two for doing the actual work.  The following sections provide a recommended configuration.
4. The [Kubeclient Ruby Gem](https://github.com/abonas/kubeclient.git) is required on each worker appliance.  Version 2.3.0 is the minimum version and should be the default in 5.7.2 or euwe of ManageIQ.
