#
# Description: Set Promotion Objects
#
require 'kubeclient'
require 'json'

def parse_secrets(client, project_name, selected_configs)
  secrets = client.get_secrets(namespace: project_name)
  #If only one config was selected, this won't be an array.  So we will make it one.
  unless selected_configs.kind_of?(Array)
    if selected_configs.include? ","
      selected_configs = selected_configs.split(",")
    else
      selected_configs = [selected_configs]
    end
  end
  
  selected_configs.each { |config|  
    secrets.each { |secret| 

      secret_name = secret.metadata.name
      if config.eql? secret_name
        secret_metadata = secret.metadata.to_json
        secret_spec = secret.spec.to_json

        $evm.root["secret_"+secret_name+"_metadata"] = secret_metadata
        $evm.root["secret_"+secret_name+"_spec"] = secret_spec
      end
      }
    }
end

$evm.log("info","=== BEGIN SET PROMOTION SECRETS ===")
project_id = 0

secrets_selected_configs = []
unless $evm.root["service_template_provision_task"].nil?
  dialog_options = $evm.root["service_template_provision_task"].dialog_options
  project_id = dialog_options['dialog_option_0_source_project']
  secrets_selected_configs = dialog_options['Array::dialog_option_0_secrets']
else
  dialog_options = $evm.root["service_template_provision_request"].options[:dialog]
  project_id = dialog_options['dialog_option_0_source_project']
  secrets_selected_configs = dialog_options['Array::dialog_option_0_secrets']
end

$evm.log("info","===> The project ID is #{project_id}")
$evm.log("info","===> The selected services are #{secrets_selected_configs}")
project = $evm.vmdb('container_project').find_by_id(project_id)
project_name = project.name

client_options = {}
client_options[:service] = 'kubernetes'
client = project.ext_management_system.connect(client_options)
unless client.discovered
  client.discover
end

parse_secrets(client, project_name, secrets_selected_configs)

$evm.log("info","=== END SET PROMOTION SECRETS ===")
