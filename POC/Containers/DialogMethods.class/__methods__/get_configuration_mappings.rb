#
# Description: <Method description here>
#
require 'kubeclient'
$evm.log("info","===== BEGIN GETTING DAEMON SETS =====")

dialog_field = $evm.object
user = $evm.root['user']

project_id = $evm.root['dialog_option_0_source_project']
project = $evm.vmdb('container_project').find_by_id(project_id)
project_name = project.name

client = project.ext_management_system.connect
unless client.discovered
  client.discover
end

daemon_sets = client.get_daemon_sets(namespace: project_name)
$evm.log("info", "Retrieved #{daemon_sets.length} daemon_sets project #{project_name}")

hash = {}
daemon_sets.each { |ds| 
  
  ds_name = ds.metadata.name
  hash[ds_name] = ds_name
  
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

$evm.log("info","===== END GETTING DAEMON SETS =====")
