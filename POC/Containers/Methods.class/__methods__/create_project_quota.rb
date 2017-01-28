#
# Description: create_project_quota
#
require 'rest-client'
require 'json'
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

token = $evm.object['token']
cluster_url = $evm.object['cluster_url']
cluster_api_port = $evm.object['cluster_api_port']
no_verify_ssl = $evm.object['no_verify_ssl']

debug = $evm.object['debug']
pretty = $evm.object['pretty']

client_cert_location = $evm.object['client_cert_location']
client_key_location = $evm.object['client_key_location']
client_ca_cert_location = $evm.object['client_ca_cert_location']

cluster_master = cluster_url + ":" + cluster_api_port.to_s + "/api"
ssl_options = {
  client_cert: OpenSSL::X509::Certificate.new(File.read(client_cert_location)),
  client_key:  OpenSSL::PKey::RSA.new(File.read(client_key_location)),
  ca_file:     client_ca_cert_location,
  verify_ssl: OpenSSL::SSL::VERIFY_NONE }


client = Kubeclient::Client.new cluster_master, "v1", ssl_options: ssl_options
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
