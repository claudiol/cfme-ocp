#
# Description: <Method description here>
#
require 'kubeclient'
$evm.log("info","===== BEGIN GETTING PVCS =====")

dialog_field = $evm.object
user = $evm.root['user']

project_id = $evm.root['dialog_option_0_source_project']
$evm.log("info","===> The project ID is #{project_id}")
project = $evm.vmdb('container_project').find_by_id(project_id)
project_name = project.name

client_options = {}
client_options[:service] = 'kubernetes'
client = project.ext_management_system.connect(client_options)
unless client.discovered
  client.discover
end

pvcs = client.get_persistent_volume_claims(namespace: project_name)
$evm.log("info", "Retrieved #{pvcs.length} pvcs for project #{project_name}")

hash = {}
pvcs.each { |pvc| 
  
  pvc_name = pvc.metadata.name
  hash[pvc_name] = pvc_name
  
  }

# sort_by: value / description / none
dialog_field["sort_by"] = "value"

# sort_order: ascending / descending
dialog_field["sort_order"] = "ascending"

# data_type: string / integer
dialog_field["data_type"] = "string"

# required: true / false
dialog_field["required"] = "true"

dialog_field["values"] = hash

$evm.log("info","===== END GETTING PVCS =====")
