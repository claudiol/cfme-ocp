#
# Description: <Method description here>
#
require 'kubeclient'
$evm.log("info","===== BEGIN GETTING BUILD CONFIGS =====")

dialog_field = $evm.object
user = $evm.root['user']

project_id = $evm.root['dialog_option_0_source_project']
$evm.log("info","===> The project ID is #{project_id}")
project = $evm.vmdb('container_project').find_by_id(project_id)
project_name = project.name

client = project.ext_management_system.connect
unless client.discovered
  client.discover
end

build_configs = client.get_build_configs(namespace: project_name)
$evm.log("info", "Retrieved #{build_configs.length} build configs for project #{project_name}")

hash = {}
build_configs.each { |bc| 
  
  bc_name = bc.metadata.name
  hash[bc_name] = bc_name
  
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

$evm.log("info","===== END GETTING BUILD CONFIGS =====")
