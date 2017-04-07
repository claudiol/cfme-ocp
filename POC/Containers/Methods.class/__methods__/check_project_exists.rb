require 'kubeclient'

$evm.log("info", "Listing Root Object Attributes:")
$evm.root.attributes.sort.each { |k, v| $evm.log("info", "\t#{k}: #{v}") }
$evm.log("info", "===========================================")

def project_exists?(project_name, project_list)
  project_list.each do |key|
    $evm.log("info", "Checking requested project #{project_name} against #{key['metadata']['name']}")
    if project_name == key['metadata']['name']
      return true
    end
  end
  return false
end

dialog_options = $evm.root["service_template_provision_task"].dialog_options
project_name = dialog_options['dialog_option_0_service_name']

$evm.log("info", "========= BEGIN CHECKING IF PROJECT #{project_name} EXISTS =========")

debug = $evm.object['debug']
pretty = $evm.object['pretty']

ems = $evm.vmdb(:ext_management_system).find_by_name(dialog_options['dialog_option_0_target_cluster'])
client = ems.connect
client.discover


project_list = client.get_projects

if project_exists?(project_name, project_list)
  $evm.root['ae_result'] = 'ok'
  $evm.log("info","Project #{project_name} has been created.")
else
  $evm.root['ae_result']         = 'retry'
  $evm.root['ae_retry_interval'] = '30.seconds'
  $evm.log("info","Project #{project_name} not yet created.  Retrying in 30 seconds.")
end

$evm.log("info", "====== END CHECKING IF PROJECT #{project_name} EXISTS ======")
