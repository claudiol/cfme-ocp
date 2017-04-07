# Description: This method deletes the project
require 'kubeclient'

dialog_options = $evm.root["service_template_provision_task"].dialog_options
project_name = dialog_options['dialog_option_0_service_name']
project_display_name = dialog_options['dialog_option_0_display_name']
project_description = dialog_options['dialog_option_0_project_description']

$evm.log("info", "========= DELETE PROJECT =========")

debug = $evm.object['debug']
pretty = $evm.object['pretty']

ems = $evm.vmdb(:ext_management_system).find_by_name(dialog_options['dialog_option_0_target_cluster'])
client = ems.connect
client.discover

resp = client.delete_project project_name

$evm.log("info", "======= END DELETING PROJECT =======")
