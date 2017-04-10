#
# Description: <Method description here>
#
require 'kubeclient'

$evm.log("info","===== BEGIN PROMOTING SERVICES =====")
dialog_options = $evm.root["service_template_provision_task"].dialog_options
cluster_name = dialog_options['dialog_option_0_target_cluster']

ems = $evm.vmdb(:ext_management_system).find_by_name(cluster_name)
client_options = {}
client_options[:service] = 'kubernetes'
client = ems.connect(client_options)
unless client.discovered
  client.discover
end

$evm.root.attributes.sort.each { |k, v| 
  if k.start_with? "svc-"
    name = k.gsub("svc-","")
    $evm.log("info","====> Found service #{name}")
    service = $evm.root[k]
    
    begin
    client.create_service(service)
    rescue KubeException => e
      if e.message.include? "already exists"
        project_id = dialog_options['dialog_option_0_source_project']
        project = $evm.vmdb(:container_project).find_by_id(project_id)
        project_name = project.name
        client.patch_service(name, service, project_name)
      end
    end
  end
  }
$evm.log("info","===== END PROMOTING SERVICES =====")

