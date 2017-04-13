#
# Description: <Method description here>
#
require 'kubeclient'

$evm.log("info","===== BEGIN PROMOTING PVCS =====")
dialog_options = $evm.root["service_template_provision_task"].dialog_options
cluster_name = dialog_options['dialog_option_0_target_cluster']

ems = $evm.vmdb(:ext_management_system).find_by_name(cluster_name)
client = ems.connect
unless client.discovered
  client.discover
end

$evm.root.attributes.sort.each { |k, v| 
  if k.start_with? "pvc-"
    name = k.gsub("pvc-","")
    $evm.log("info","====> Found PVC #{name}")
    pvc = $evm.root[k]
    
    begin
    client.create_persistent_volume_claim(pvc)
    rescue KubeException => e
      if e.message.include? "already exists"
        project_id = dialog_options['dialog_option_0_source_project']
        project = $evm.vmdb(:container_project).find_by_id(project_id)
        project_name = project.name
        client.patch_persistent_volume_claim(name, pvc, project_name)
      else
        raise e
      end
    end
  end
  }
$evm.log("info","===== END PROMOTING PVCS =====")

