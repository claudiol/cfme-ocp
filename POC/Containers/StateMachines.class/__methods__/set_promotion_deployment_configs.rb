#
# Description: Set Promotion Objects
#
require 'kubeclient'

$evm.log("info","=== BEGIN SET PROMOTION DEPLOYMENT CONFIGS ===")

def remove_image_change_trigger(triggers)
  triggers.each { |trigger|
    if trigger[:type] == "ImageChange"
      triggers.delete(trigger)
    end
    }
  triggers
end

#def get_route_name(project)
#  ems_id = project.ext_management_system.id
#  routes = $evm.vmdb(:container_route).where(:name => 'docker-registry', :ems_id => ems_id)
#  route_name = routes[0].host_name
#  route_name
#end


def update_container_image_repo(containers)
	containers.each { |container|  
      if match = container[:image].match(/172\.30\.\d{1,3}\.\d{1,3}:5000\/\S*\/(\S*)@/i)
        image_name = match.captures
        $evm.root['isdc-'+image_name[0]] = image_name[0]
      end
      container[:image].gsub!(/172\.30\.\d{1,3}\.\d{1,3}:5000\/\S*\//, '')
      $evm.log("info","===> Container image repo is now #{container[:image]}")

      }
  containers
  
end

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
        
        dc_hash[:spec][:triggers] = remove_image_change_trigger(dc_hash[:spec][:triggers])
        dc_hash[:spec][:template][:spec][:containers] = update_container_image_repo(dc_hash[:spec][:template][:spec][:containers])
      	$evm.root['dcreplica-'+dc_name] = dc_hash[:spec][:replicas]
        #Initially we will set this to zero and scale up at the end of the promotion statemachine
        #dc_hash[:spec][:replicas] = '0'    
      
        dc_hash.delete(:status)
        
        containers = dc_hash[:spec][:template][:spec][:containers]
		$evm.root["dc-"+dc_name] = dc_hash
      end

      }
    }
end


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
#route_name = get_route_name(project)

client = project.ext_management_system.connect
unless client.discovered
  client.discover
end

parse_deployment_configs(client, project_name, dc_selected_configs)

$evm.log("info","=== END SET PROMOTION DEPLOYMENT CONFIGS ===")
