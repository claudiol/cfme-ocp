#
# Description: <Method description here>
#
require 'kubeclient'

$evm.log("info","===== BEGIN CREATE IMAGE STREAMS FROM DC =====")

def get_route_name(project)
  ems_id = project.ext_management_system.id
  routes = $evm.vmdb(:container_route).where(:name => 'docker-registry', :ems_id => ems_id)
  route_name = routes[0].host_name
  route_name
end


dialog_options = $evm.root["service_template_provision_task"].dialog_options
cluster_name = dialog_options['dialog_option_0_target_cluster']
source_project_id = dialog_options['dialog_option_0_source_project']
source_project = $evm.vmdb('container_project').find_by_id(source_project_id)
project_name = source_project.name
route_name = get_route_name(source_project)

ems = $evm.vmdb(:ext_management_system).find_by_name(cluster_name)
client = ems.connect
unless client.discovered
  client.discover
end

$evm.root.attributes.sort.each { |k, v| 
  if k.start_with? "isdc-"
    name = k.gsub("isdc-","")
    $evm.log("info","====> Found image stream #{name}")
    image_stream = Kubeclient::ImageStream.new
    
    image_stream.metadata = {}
    image_stream.metadata.name = v
    image_stream.metadata.namespace = project_name
    image_stream.metadata.annotations = {}
    image_stream.metadata.annotations['openshift.io/image.insecureRepository'] = 'true'
    
    image_stream.spec = {}
    image_stream.spec.dockerImageRepository = route_name + '/' + project_name + '/' + name
    
    begin
    	client.create_image_stream(image_stream)
    rescue KubeException => e
      if e.message.include? "already exists"
        client.patch_image_stream(name, image_stream, project_name)
      else
        raise e
      end
    end
  end
  }
$evm.log("info","===== END CREATE IMAGE STREAMS FROM DC =====")

