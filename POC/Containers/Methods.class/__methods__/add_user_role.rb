# Description: This method adds a user to the project in the role of admin

require 'kubeclient'

user_name = ""
user_role = "admin"

task = $evm.root["service_template_provision_task"]
dialog_options = task.dialog_options
project_name = dialog_options['dialog_option_0_service_name']

$evm.log("info", "========= ADDING USER TO PROJECT #{project_name} =========")

#Get the requester from the provision object
user = task.miq_request.requester
raise "User not specified" if user.nil?

$evm.log("info"," Detected requester is #{user}")

#Get the user's current group
group = user.current_group
user_role = group.tags("ocp_project_role")[0]

user_name = user.userid

ems = $evm.vmdb(:ext_management_system).find_by_name(dialog_options['dialog_option_0_target_cluster'])
client = ems.connect
client.discover

$evm.log("info","--- The user role being added is: #{user_role} ---")
client.patch_role_binding user_role, {:userNames => [user_name]}, project_name

$evm.log("info", "====== END USER #{user_name} TO PROJECT #{project_name} ======")
