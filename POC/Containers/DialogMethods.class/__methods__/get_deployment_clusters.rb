$evm.log("info","===== BEGIN GET DEPLOYMENT CLUSTERS =====")
dialog_field = $evm.object
hash = {}
user = $evm.root['user']
#Get the user's current group
group = user.current_group
$evm.log("info","==> User is #{user.name} and group is #{group.description}")

allowed_deployment_tags = group.tags("ocp_cluster_step")
allowed_deployment_tags.each { |allowed_tag|
  tag = "/managed/ocp_cluster_step/" + allowed_tag
  emses = $evm.vmdb(:ext_management_system).find_tagged_with(:all => tag, :ns => "*")
  emses.each { |ems| hash[ems.name] = ems.name}
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

$evm.log("info","===== END GET DEPLOYMENT CLUSTERS =====")
