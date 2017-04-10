# This method is essentially the same as project_request_validation.  The difference
# being that this method won't fail the workflow, but rather sets a flag to indicate
# this is a patch.
require 'kubeclient'

project_name = ""
cluster_name = ""

unless $evm.root["service_template_provision_task"].nil?
	dialog_options = $evm.root["service_template_provision_task"].dialog_options
    project_id = dialog_options['dialog_option_0_source_project']
    project = $evm.vmdb('container_project').find_by_id(project_id)
    project_name = project.name
    cluster_name = dialog_options['dialog_option_0_target_cluster']
else
	dialog_options = $evm.root["service_template_provision_request"].options[:dialog]
	project_id = dialog_options['dialog_option_0_source_project']
    project = $evm.vmdb('container_project').find_by_id(project_id)
    project_name = project.name
    cluster_name = dialog_options['dialog_option_0_target_cluster']
end

# Get a connection to the target cluster
container_manager = $evm.vmdb('ext_management_system').find_by_name(cluster_name)
client = container_manager.connect
unless client.discovered
  client.discover
end
# Check if a project with the source project's name exists in target cluster
begin
  target_project = client.get_project(project_name)
  $evm.log("info","Project #{project_name} exists in #{cluster_name}.  Setting patch flag.")
  $evm.root['promotion_patch'] = true
rescue KubeException => e
  $evm.log("info","Project #{project_name} doesn't exist in #{cluster_name}.  Proceeding.")
  $evm.root['promotion_patch'] = false
end

$evm.log("info","Setting the flag to #{$evm.root['promotion_patch']}")

$evm.log("info", "====== END CHECKING IF PROJECT #{project_name} EXISTS ======")
