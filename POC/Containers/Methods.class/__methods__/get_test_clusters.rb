require 'kubeclient'

dialog_field = $evm.object


hash = {}

tag = "/managed/ocp_cluster_type/test"
test_emses = $evm.vmdb(:ext_management_system).find_tagged_with(:all => tag, :ns => "*")
test_emses.each { |ems| hash[ems.name] = ems.name } 

# sort_by: value / description / none
dialog_field["sort_by"] = "value"

# sort_order: ascending / descending
dialog_field["sort_order"] = "ascending"

# data_type: string / integer
dialog_field["data_type"] = "string"

# required: true / false
dialog_field["required"] = "true"

dialog_field["values"] = hash
