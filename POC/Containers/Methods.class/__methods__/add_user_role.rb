#Authorization: Bearer
# Description: This method launches the service provisioning job
require 'rest-client'
require 'json'
require 'kubeclient'

user_name = ""
user_role = "admin"

task = $evm.root["service_template_provision_task"]
dialog_options = task.dialog_options
project_name = dialog_options['dialog_option_0_service_name']

$evm.log("info", "========= ADDING USER TO PROJECT #{project_name} =========")

#Get the requester from the provision object
user = task.miq_request.requester
raise "User not specified" if user.nil?

$evm.log("info"," Detected requester is #{user}")

#Get the user's current group
group = user.current_group

#Pull the user name out of the LDAP by attribute, else use the username in the CFME DB
#ldap_username_attr = group.tags("ldap_username_attribute")[0]

#unless ldap_username_attr.nil?
#	user_name = user.get_ldap_attribute(ldap_username_attr)
#else
#  user_name = user.name
#  $evm.log("info","Unable to get username by attribute.  Procceding with user_name as #{user_name}")
#end

user_name = user.userid
token = $evm.object['token']
cluster_url = $evm.object['cluster_url']
cluster_api_port = $evm.object['cluster_api_port']
no_verify_ssl = $evm.object['no_verify_ssl']

debug = $evm.object['debug']
pretty = $evm.object['pretty']

client_cert_location = $evm.object['client_cert_location']
client_key_location = $evm.object['client_key_location']
client_ca_cert_location = $evm.object['client_ca_cert_location']

cluster_master = cluster_url + ":" + cluster_api_port.to_s + "/oapi"

ssl_options = {
  client_cert: OpenSSL::X509::Certificate.new(File.read(client_cert_location)),
  client_key:  OpenSSL::PKey::RSA.new(File.read(client_key_location)),
  ca_file:     client_ca_cert_location,
  verify_ssl: OpenSSL::SSL::VERIFY_NONE }

client = Kubeclient::Client.new cluster_master, "v1", ssl_options: ssl_options

$evm.log("info","--- The user role being added is: #{user_role} ---")
client.patch_role_binding user_role, {:userNames => [user_name]}, project_name

$evm.log("info", "====== END USER #{user_name} TO PROJECT #{project_name} ======")
