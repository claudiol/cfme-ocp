#
# Description: <Method description here>
#
require 'kubeclient'
$evm.log("info","===== BEGIN GETTING IMAGE STREAMS =====")

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

image_streams = client.get_image_streams(namespace: project_name)
$evm.log("info", "Retrieved #{image_streams.length} image streams for project #{project_name}")

hash = {}
image_streams.each { |is| 
  
  is_name = is.metadata.name
  hash[is_name] = is_name
  
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

$evm.log("info","===== END GETTING IMAGE STREAMS =====")
