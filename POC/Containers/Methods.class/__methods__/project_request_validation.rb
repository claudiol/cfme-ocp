require 'json'

project_name = ""
cluster_name = ""

unless $evm.root["service_template_provision_task"].nil?
	dialog_options = $evm.root["service_template_provision_task"].dialog_options
	project_name = dialog_options['dialog_option_0_service_name']
    cluster_name = dialog_options['dialog_option_0_target_cluster']
else
	dialog_options = $evm.root["service_template_provision_request"].options[:dialog]
	project_name = dialog_options['dialog_option_0_service_name']
    cluster_name = dialog_options['dialog_option_0_target_cluster']
end

container_manager = $evm.vmdb('ext_management_system').find_by_name(cluster_name)
project = $evm.vmdb(:container_project).where("name = ? AND deleted_on IS ?", project_name, nil)
$evm.log("info","==> #{project_name} #{project.inspect}")

if project.nil? or project == []
  $evm.root['ae_result'] = 'ok'
  $evm.log("info","Project #{project_name} doesn't exist.  Proceeding.")
else
  $evm.root['ae_result'] = 'error'
  $evm.log("info","Project #{project_name} already exists.")
  exit MIQ_ERROR
end

$evm.log("info", "====== END CHECKING IF PROJECT #{project_name} EXISTS ======")
