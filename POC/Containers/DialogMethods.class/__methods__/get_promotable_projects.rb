require 'kubeclient'

dialog_field = $evm.object
user = $evm.root['user']


hash = {}
tag = "/managed/ocp_role_admin/"+user.name
projects = $evm.vmdb(:container_project).find_tagged_with(:all => tag, :ns => "*")

projects.each { |project| 
  unless not project.deleted_on.nil?
  	hash[project.id] = project.ext_management_system.name + " - " + project.name 
  end
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
