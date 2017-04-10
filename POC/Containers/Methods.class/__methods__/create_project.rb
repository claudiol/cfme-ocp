# Description: This method creates a container project
require 'kubeclient'

project_name = ""
project_display_name = ""
project_description = ""
cluster_name = ""

dialog_options = $evm.root["service_template_provision_task"].dialog_options

promotion_patch = $evm.root['promotion_patch']

unless dialog_options['dialog_option_0_service_name'].nil?
	project_name = dialog_options['dialog_option_0_service_name']
    project_display_name = dialog_options['dialog_option_0_display_name']
    project_description = dialog_options['dialog_option_0_project_description']
else
    project_id = dialog_options['dialog_option_0_source_project']
	project = $evm.vmdb(:container_project).find_by_id(project_id)
    project_name = project.name
    project_display_mame = project.display_name
end

cluster_name = dialog_options['dialog_option_0_target_cluster']

$evm.log("info", "========= CREATING PROJECT #{project_name} IN CLUSTER #{cluster_name} =========")

unless promotion_patch.nil? or promotion_patch
    ems = $evm.vmdb(:ext_management_system).find_by_name(cluster_name)
    client = ems.connect
    client.discover

    project = Kubeclient::ProjectRequest.new
    project.metadata = {}
    project.metadata.name = project_name
    project.displayName = project_display_name
    project.description = project_description 

    response = client.create_project_request project
else
	$evm.log("info", "Project #{project_name} exists in target cluster #{cluster_name}.")
end
$evm.log("info", "======= END CREATING PROJECT #{project_name} IN CLUSTER #{cluster_name} =======")

$evm.root["service_template_provision_task"].execute
