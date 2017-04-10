#
# Description: Set Promotion Objects
#
require 'kubeclient'
require 'json'

def parse_deployment_configs(client, project_name,selected_configs)
  deployment_configs = client.get_deployment_configs(namespace: project_name)
  #If only one config was selected, this won't be an array.  So we will make it one.
  unless selected_configs.kind_of?(Array)
    if selected_configs.include? ","
      selected_configs = selected_configs.split(",")
    else
      selected_configs = [selected_configs]
    end
  end
  
  selected_configs.each { |config|
    deployment_configs.each { |dc| 

      dc_name = dc.metadata.name
      if config.eql? dc_name
        dc_hash = dc.to_h
        dc_hash[:metadata].delete(:selfLink)
        dc_hash[:metadata].delete(:uid)
        dc_hash[:metadata].delete(:resourceVersion)
        dc_hash[:metadata].delete(:creationTimestamp)
        dc_hash[:metadata].delete(:generation)
        dc_hash.delete(:status)
        $evm.log("info", "===> Cleaned up hash #{dc_hash}")
        $evm.root["dc-"+dc_name] = dc_hash
      end

      }
    }
end

$evm.log("info","=== BEGIN SET PROMOTION DEPLOYMENT CONFIGS ===")
project_id = 0
dc_selected_configs = []
unless $evm.root["service_template_provision_task"].nil?
  dialog_options = $evm.root["service_template_provision_task"].dialog_options
  project_id = dialog_options['dialog_option_0_source_project']
  dc_selected_configs = dialog_options['Array::dialog_option_0_deployment_configs']
else
  dialog_options = $evm.root["service_template_provision_request"].options[:dialog]
  project_id = dialog_options['dialog_option_0_source_project']
  dc_selected_configs = dialog_options['Array::dialog_option_0_deployment_configs']
end

$evm.log("info","===> The project ID is #{project_id}")
$evm.log("info","===> The selected deployment configs are #{dc_selected_configs.inspect}")
project = $evm.vmdb('container_project').find_by_id(project_id)
project_name = project.name

client = project.ext_management_system.connect
unless client.discovered
  client.discover
end

parse_deployment_configs(client, project_name, dc_selected_configs)

$evm.log("info","=== END SET PROMOTION DEPLOYMENT CONFIGS ===")
