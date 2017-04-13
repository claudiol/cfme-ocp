#
# Description: Set Promotion Objects
#
require 'kubeclient'
require 'json'

def parse_pvcs(client, project_name, selected_configs)
  pvcs = client.get_secrets(namespace: project_name)
  #If only one config was selected, this won't be an array.  So we will make it one.
  unless selected_configs.kind_of?(Array)
    if selected_configs.include? ","
      selected_configs = selected_configs.split(",")
    else
      selected_configs = [selected_configs]
    end
  end
  
  selected_configs.each { |config|  
    pvcs.each { |pvc| 
      pvc_name = pvc.metadata.name
      if config.eql? pvc_name
        $evm.root["pvc-"+pvc_name] = pvc
      end
      }
    }
end

$evm.log("info","=== BEGIN SET PROMOTION PVCS ===")
project_id = 0

selected_configs = []
dialog_options = []
unless $evm.root["service_template_provision_task"].nil?
  dialog_options = $evm.root["service_template_provision_task"].dialog_options
else
  dialog_options = $evm.root["service_template_provision_request"].options[:dialog]
end

project_id = dialog_options['dialog_option_0_source_project']
selected_configs = dialog_options['Array::dialog_option_0_pvcs']

$evm.log("debug","===> The project ID is #{project_id}")
$evm.log("info","===> The selected pvcs are #{selected_configs}")
project = $evm.vmdb('container_project').find_by_id(project_id)
project_name = project.name

client_options = {}
client_options[:service] = 'kubernetes'
client = project.ext_management_system.connect(client_options)
unless client.discovered
  client.discover
end

parse_pvcs(client, project_name, selected_configs)

$evm.log("info","=== END SET PROMOTION PVCS ===")
