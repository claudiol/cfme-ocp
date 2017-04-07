# Description: This method creates a container project
require 'kubeclient'

dialog_options = $evm.root["service_template_provision_task"].dialog_options
$evm.log("info", "========= CREATING PROJECT =========")
debug = $evm.object['debug']
pretty = $evm.object['pretty']

ems = $evm.vmdb(:ext_management_system).find_by_name(dialog_options['dialog_option_0_target_cluster'])
client = ems.connect
client.discover

project = Kubeclient::ProjectRequest.new
project.metadata = {}
project.metadata.name = dialog_options['dialog_option_0_service_name']
project.displayName = dialog_options['dialog_option_0_display_name']
project.description = project_description = dialog_options['dialog_option_0_project_description']

response = client.create_project_request project
$evm.log("info", "======= END CREATING PROJECT =======")

$evm.root["service_template_provision_task"].execute


