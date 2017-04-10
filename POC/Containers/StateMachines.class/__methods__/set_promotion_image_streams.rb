#
# Description: Set Promotion Objects
#
require 'kubeclient'
require 'json'

def parse_image_streams(client, project_name,selected_configs)
  image_streams = client.get_image_streams(namespace: project_name)
  
  unless selected_configs.kind_of?(Array)
    if selected_configs.include? ","
      selected_configs = selected_configs.split(",")
    else
      selected_configs = [selected_configs]
    end
  end
  
  selected_configs.each { |config|
    image_streams.each { |is| 

      is_name = is.metadata.name
      if config.eql? is_name
        is_hash = is.to_h
        is_hash[:metadata].delete(:selfLink)
        is_hash[:metadata].delete(:uid)
        is_hash[:metadata].delete(:resourceVersion)
        is_hash[:metadata].delete(:creationTimestamp)
        is_hash[:metadata].delete(:generation)
        is_hash.delete(:status)
        $evm.log("info", "===> Cleaned up hash #{is_hash}")
        $evm.root["is-"+is_name] = is_hash
      end

      }
    }
end

$evm.log("info","=== BEGIN SET PROMOTION IMAGE STREAMS ===")
project_id = 0
selected_configs = []
unless $evm.root["service_template_provision_task"].nil?
  dialog_options = $evm.root["service_template_provision_task"].dialog_options
  project_id = dialog_options['dialog_option_0_source_project']
  selected_configs = dialog_options['Array::dialog_option_0_container_image_streams']
else
  dialog_options = $evm.root["service_template_provision_request"].options[:dialog]
  project_id = dialog_options['dialog_option_0_source_project']
  selected_configs = dialog_options['Array::dialog_option_0_container_image_streams']
end

$evm.log("info","===> The project ID is #{project_id}")
project = $evm.vmdb('container_project').find_by_id(project_id)
project_name = project.name

client = project.ext_management_system.connect
unless client.discovered
  client.discover
end

parse_image_streams(client, project_name, selected_configs)

$evm.log("info","=== END SET PROMOTION IMAGE STREAMS ===")
