#
# Description: <Method description here>
#
require 'kubeclient'

$evm.log("info","===== BEGIN PROMOTING DEPLOYMENT CONFIGS =====")
dialog_options = $evm.root["service_template_provision_task"].dialog_options
cluster_name = dialog_options['dialog_option_0_target_cluster']

ems = $evm.vmdb(:ext_management_system).find_by_name(cluster_name)
client = ems.connect
unless client.discovered
  client.discover
end

$evm.root.attributes.sort.each { |k, v| 
  if k.start_with? "dc-"
    name = k.gsub("dc-","")
    $evm.log("info","====> Found Deployment Config #{name}")
    deployment_config = $evm.root[k]
    
    begin
    client.create_deployment_config(deployment_config)
    rescue KubeException => e
      if e.message.include? "already exists"
        project_id = dialog_options['dialog_option_0_source_project']
        project = $evm.vmdb(:container_project).find_by_id(project_id)
        project_name = project.name
        client.patch_deployment_config(name, deployment_config, project_name)
      else
        raise e
      end
    end
  end
  }
$evm.log("info","===== END PROMOTING DEPLOYMENT CONFIGS =====")

