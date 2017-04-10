#
# Description: <Method description here>
#

dialog_options = $evm.root["service_template_provision_task"].dialog_options
project_name = ""

unless dialog_options['dialog_option_0_service_name'].nil?
	project_name = dialog_options['dialog_option_0_service_name']
else
    project_id = dialog_options['dialog_option_0_source_project']
	project = $evm.vmdb(:container_project).find_by_id(project_id)
    project_name = project.name
end

$evm.log("info","===== BEGIN NAME SERVICE =====")
task = $evm.root['service_template_provision_task']
service = task.destination
service.name = project_name
$evm.log("info","===== END NAME SERVICE =====")
