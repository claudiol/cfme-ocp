#
# Description: create_project_quota

require 'kubeclient'

task = $evm.root["service_template_provision_task"]
dialog_options = task.dialog_options
project_name = dialog_options['dialog_option_0_service_name']

$evm.log("info","==== CREATING QUOTA FOR PROJECT #{project_name} ====")

#Get the requester from the provision object
user = task.miq_request.requester
raise "User not specified" if user.nil?

$evm.log("info"," Detected requester is #{user.name}")

#Get the user's current group
group = user.current_group

$evm.log("info"," Detected requester's group is #{group.inspect}")

debug = $evm.object['debug']
pretty = $evm.object['pretty']


#client = Kubeclient::Client.new cluster_master, "v1", ssl_options: ssl_options
ems = $evm.vmdb(:ext_management_system).find_by_name(dialog_options['dialog_option_0_target_cluster'])
client_options = {}
client_options[:service] = 'kubernetes'
client = ems.connect(client_options)
client.discover

resource_quota = Kubeclient::ResourceQuota.new
resource_quota.metadata = {}
#resource_quota.metadata.name = group.description.gsub!(/[^0-9A-Za-z]/, '') + "quota"
resource_quota.metadata.name = "ocpquota"
resource_quota.metadata.namespace = project_name
resource_quota.spec = {}
resource_quota.spec.hard = {}
resource_quota.spec.hard.pods = group.tags("quota_ocp_pods")[0]
resource_quota.spec.hard.replicationcontrollers = group.tags("quota_ocp_rc")[0]
resource_quota.spec.hard.services = group.tags("quota_ocp_services")[0]
resource_quota.spec.hard.persistentvolumeclaims = group.tags("quota_ocp_pvc")[0]
resource_quota.spec.hard.secrets = group.tags("quota_ocp_secrets")[0]
resp = client.create_resource_quota resource_quota

$evm.log("info","Response => #{resp}")

$evm.log("info","======= END PROJECT QUOTA FOR PROJECT =======")
