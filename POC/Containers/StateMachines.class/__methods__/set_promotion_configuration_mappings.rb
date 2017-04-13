#
# Description: Set Promotion Objects
#
require 'kubeclient'
require 'json'

def parse_configuration_mappings(client, project_name, selected_configs)
  services = client.get_configuration_mappings(namespace: project_name)
  #If only one config was selected, this won't be an array.  So we will make it one.
  unless selected_configs.kind_of?(Array)
    if selected_configs.include? ","
      selected_configs = selected_configs.split(",")
    else
      selected_configs = [selected_configs]
    end
  end
  
  selected_configs.each { |config|
    services.each { |cm| 

      cm_name = cm.metadata.name
      if config.eql? service_name
        cm_name = cm.metadata.name
        cm_name = cm.to_h
        cm_name[:metadata].delete(:selfLink)
        cm_name[:metadata].delete(:uid)
        cm_name[:metadata].delete(:resourceVersion)
        cm_name[:metadata].delete(:creationTimestamp)
        cm_name[:metadata].delete(:generation)
        cm_name.delete(:status)
        cm_name[:spec].delete(:clusterIP)
        $evm.log("info", "===> Cleaned up hash #{cm_name}")
        $evm.log("info", "--------------")
        $evm.root["cm-"+cm_name] = cm_name
      end

      }
    }
end

$evm.log("info","=== BEGIN SET PROMOTION SERVICES ===")
project_id = 0
services_selected_configs = []
unless $evm.root["service_template_provision_task"].nil?
  dialog_options = $evm.root["service_template_provision_task"].dialog_options
  project_id = dialog_options['dialog_option_0_source_project']
  services_selected_configs = dialog_options['Array::dialog_option_0_services']
else
  dialog_options = $evm.root["service_template_provision_request"].options[:dialog]
  project_id = dialog_options['dialog_option_0_source_project']
  services_selected_configs = dialog_options['Array::dialog_option_0_services']
end

$evm.log("info","===> The project ID is #{project_id}")
$evm.log("info","===> The selected services are #{services_selected_configs.inspect}")
project = $evm.vmdb('container_project').find_by_id(project_id)
project_name = project.name

client_options = {}
client_options[:service] = 'kubernetes'
client = project.ext_management_system.connect(client_options)
unless client.discovered
  client.discover
end

parse_services(client, project_name, services_selected_configs)

$evm.log("info","=== END SET PROMOTION SERVICES ===")
