$evm.log("info","===== BEGIN GET PROMOTION CLUSTERS =====")

dialog_field = $evm.object

hash = {}

project_id = $evm.root['dialog_option_0_source_project']
project = $evm.vmdb('container_project').find_by_id(project_id)
ems = project.ext_management_system

step_tags = ems.tags("ocp_cluster_step")

step_tags.each { |step_tag|
    next_tag = step_tag.to_i + 1
    tag = "/managed/ocp_cluster_step/"+next_tag.to_s
  	emses = $evm.vmdb(:ext_management_system).find_tagged_with(:all => tag, :ns => "*")
	emses.each { |ems| hash[ems.name] = ems.name } 
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

$evm.log("info","===== END GET PROMOTION CLUSTER =====")
