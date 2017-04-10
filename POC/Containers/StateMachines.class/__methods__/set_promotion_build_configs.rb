#
# Description: Set Promotion Objects
#
require 'kubeclient'
require 'json'

def parse_build_configs(client, project_name, selected_configs)
  build_configs = client.get_build_configs(namespace: project_name)
  #If only one config was selected, this won't be an array.  So we will make it one.
  unless selected_configs.kind_of?(Array)
    if selected_configs.include? ","
      selected_configs = selected_configs.split(",")
    else
      selected_configs = [selected_configs]
    end
  end
  
  selected_configs.each { |config| 
  	build_configs.each { |bc| 

      bc_name = bc.metadata.name
      
      if config.eql? bc_name
        bc_metadata = bc.metadata.to_json
        bc_spec = bc.spec.to_json

        $evm.root["bc_"+bc_name+"_metadata"] = bc_metadata
        $evm.root["bc_"+bc_name+"_spec"] = bc_spec
       end

      }
    }
end

$evm.log("info","=== BEGIN SET PROMOTION BUILD CONFIGS ===")
project_id = 0
bc_selected_configs = []
unless $evm.root["service_template_provision_task"].nil?
	dialog_options = $evm.root["service_template_provision_task"].dialog_options
	project_id = dialog_options['dialog_option_0_source_project']
    bc_selected_configs = dialog_options['Array::dialog_option_0_build_configs']
else
	dialog_options = $evm.root["service_template_provision_request"].options[:dialog]
	project_id = dialog_options['dialog_option_0_source_project']
    bc_selected_configs = dialog_options['Array::dialog_option_0_build_configs']
end

$evm.log("info","===> The project ID is #{project_id}")
$evm.log("info","===> The selected build configs are #{bc_selected_configs.inspect}")
project = $evm.vmdb('container_project').find_by_id(project_id)
project_name = project.name

client = project.ext_management_system.connect
unless client.discovered
  client.discover
end

parse_build_configs(client, project_name, bc_selected_configs)

$evm.log("info","=== END SET PROMOTION BUILD CONFIGS ===")
