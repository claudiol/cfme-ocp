#
# Description: Adds a user to the cluster.
#
require 'kubeclient'
$evm.log("info","===== BEGIN ADDING USER TO CLUSTER =====")

project_name = ""
project_display_name = ""
project_description = ""
cluster_name = ""
project = nil
container_manager = nil

task = $evm.root["service_template_provision_task"]
dialog_options = task.dialog_options

unless dialog_options['dialog_option_0_service_name'].nil?
  project_name = dialog_options['dialog_option_0_service_name']
  cluster_name = dialog_options['dialog_option_0_target_cluster']
  target_cluster = $evm.vmdb(:ext_management_system).find_by_name(cluster_name)
  cluster_id = target_cluster.id
  project = $evm.vmdb(:container_project).where("name = ? AND ems_id = ? AND deleted_on IS ?", project_name, cluster_id, nil)
else
  project_id = dialog_options['dialog_option_0_source_project']
  project = $evm.vmdb(:container_project).find_by_id(project_id)
  $evm.log("info", "==> Found project #{project.inspect}")
end

begin
  container_manager = project.ext_management_system
rescue NoMethodError
  container_manager = project[0].ext_management_system
end

client = container_manager.connect

unless client.discovered
  client.discover
end

#Get the requester from the provision object
user = task.miq_request.requester
raise "User not specified" if user.nil?

$evm.log("info","==> Detected requester is #{user.userid}")

new_user = Kubeclient::User.new
new_user.metadata = {}
new_user.metadata.name = user.userid
new_user.identities = {}
new_user.groups = {}

begin
  client.create_user(new_user)
rescue KubeException => e
  unless e.message.include? "already exists"
    raise e
  else
    $evm.log("info","==> User #{user.name} already exists in cluster #{container_manager.name}.  No action taken")
  end
end

$evm.log("info","===== END ADDING USER TO CLUSTER =====")
