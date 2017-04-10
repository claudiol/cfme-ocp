# Description: This method adds a user to the project in the role of admin

require 'kubeclient'

user_name = ""
user_role = "view"
project_name = ""
target_cluster = ""

task = $evm.root["service_template_provision_task"]
dialog_options = task.dialog_options

unless dialog_options['dialog_option_0_service_name'].nil?
	project_name = dialog_options['dialog_option_0_service_name']
else
    project_id = dialog_options['dialog_option_0_source_project']
	project = $evm.vmdb(:container_project).find_by_id(project_id)
    project_name = project.name
end

target_cluster = dialog_options['dialog_option_0_target_cluster']

$evm.log("info", "========= ADDING USER TO PROJECT #{project_name} IN CLUSTER #{target_cluster} =========")

#Get the requester from the provision object
user = task.miq_request.requester
raise "User not specified" if user.nil?
user_name = user.userid

ems = $evm.vmdb(:ext_management_system).find_by_name(target_cluster)
client = ems.connect
client.discover

begin
  role_binding = Kubeclient::RoleBinding.new
  role_binding.metadata = {}
  role_binding.metadata.namespace = project_name
  role_binding.metadata.name = user_role
  role_binding.roleRef = {}
  role_binding.roleRef.name = user_role
  role_binding.userNames = [user_name]
  client.create_role_binding(role_binding)

rescue KubeException => e
  if e.message.include? "already exists"
    $evm.log("info","Role Binding #{user_role} exists for project #{project_name}.  Updating instead." )
    client.patch_role_binding user_role, {:userNames => [user_name]}, project_name
  end
end

$evm.log("info", "====== END USER #{user_name} TO PROJECT #{project_name} IN CLUSTER #{target_cluster} ======")
