require 'kubeclient'

dialog_options = $evm.root["service_template_provision_task"].dialog_options
target_cluster_name = dialog_options['dialog_option_0_target_cluster']

unless dialog_options['dialog_option_0_service_name'].nil?
	project_name = dialog_options['dialog_option_0_service_name']
else
    project_id = dialog_options['dialog_option_0_source_project']
	project = $evm.vmdb(:container_project).find_by_id(project_id)
    project_name = project.name
end

$evm.log("info", "========= BEGIN CHECKING IF PROJECT #{project_name} EXISTS =========")
target_cluster = $evm.vmdb(:ext_management_system).find_by_name(target_cluster_name)
project = $evm.vmdb(:container_project).where(:name => project_name, :ems_id => target_cluster.id)

unless project.nil?
  $evm.root['ae_result'] = 'ok'
  $evm.log("info","Project #{project_name} has been created.")
else
  retries = $evm.root['ae_state_retries']
  if retries.to_i % 10 == 0
    $evm.log("info", "=== Refreshing the provider every ten ten retries. ===")
    target_cluster.refresh
  end
  
  $evm.root['ae_result']         = 'retry'
  $evm.root['ae_retry_interval'] = '30.seconds'
  $evm.log("info","Project #{project_name} not yet created.  Retrying in 30 seconds.  Retry count is #{retries}")
end

$evm.log("info", "====== END CHECKING IF PROJECT #{project_name} EXISTS ======")
