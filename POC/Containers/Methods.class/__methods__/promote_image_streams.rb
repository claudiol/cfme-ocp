#
# Description: <Method description here>
#
require 'kubeclient'

$evm.log("info","===== BEGIN PROMOTING IMAGE STREAMS =====")
dialog_options = $evm.root["service_template_provision_task"].dialog_options
cluster_name = dialog_options['dialog_option_0_target_cluster']

ems = $evm.vmdb(:ext_management_system).find_by_name(cluster_name)
client = ems.connect
unless client.discovered
  client.discover
end

$evm.root.attributes.sort.each { |k, v| 
  if k.start_with? "is-"
    name = k.gsub("is-","")
    $evm.log("info","====> Found image stream #{name}")
    image_stream = $evm.root[k]
    
    begin
    client.create_image_stream(image_stream)
    rescue KubeException => e
      if e.message.include? "already exists"
        project_id = dialog_options['dialog_option_0_source_project']
        project = $evm.vmdb(:container_project).find_by_id(project_id)
        project_name = project.name
        client.patch_image_stream(name, image_stream, project_name)
      end
    end
  end
  }
$evm.log("info","===== END PROMOTING IMAGE STREAMS =====")

