#
# Description: <Method description here>
#
require 'kubeclient'
$evm.log("info","===== BEGIN GETTING DEPLOYMENT CONFIGS =====")

dialog_field = $evm.object

project_id = $evm.root['dialog_option_0_source_project']
$evm.log("info","===> The project ID is #{project_id}")
project = $evm.vmdb('container_project').find_by_id(project_id)
project_name = project.name

client = project.ext_management_system.connect
unless client.discovered
  client.discover
end

deployment_configs = client.get_deployment_configs(namespace: project_name)
$evm.log("info", "Retrieved #{deployment_configs.length} deployment configs for project #{project_name}")

hash = {}
deployment_configs.each { |dc| 
  
  dc_name = dc.metadata.name
  hash[dc_name] = dc_name
  
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

$evm.log("info","===== END GETTING DEPLOYMENT CONFIGS =====")
