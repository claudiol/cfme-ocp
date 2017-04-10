#
# Description: Set Promotion Objects
#
require 'kubeclient'
require 'json'

def parse_services(client, project_name, selected_configs)
  services = client.get_services(namespace: project_name)
  #If only one config was selected, this won't be an array.  So we will make it one.
  unless selected_configs.kind_of?(Array)
    if selected_configs.include? ","
      selected_configs = selected_configs.split(",")
    else
      selected_configs = [selected_configs]
    end
  end
  
  selected_configs.each { |config|
    services.each { |svc| 

      service_name = svc.metadata.name
      if config.eql? service_name
        svc_name = svc.metadata.name
        svc_hash = svc.to_h
        svc_hash[:metadata].delete(:selfLink)
        svc_hash[:metadata].delete(:uid)
        svc_hash[:metadata].delete(:resourceVersion)
        svc_hash[:metadata].delete(:creationTimestamp)
        svc_hash[:metadata].delete(:generation)
        svc_hash.delete(:status)
        svc_hash[:spec].delete(:clusterIP)
        $evm.log("info", "===> Cleaned up hash #{svc_hash}")
        $evm.log("info", "--------------")
        $evm.root["svc-"+svc_name] = svc_hash
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
