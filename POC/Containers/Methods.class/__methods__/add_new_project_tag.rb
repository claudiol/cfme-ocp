task = $evm.root["service_template_provision_task"]
dialog_options = task.dialog_options

dialog_options = $evm.root["service_template_provision_task"].dialog_options
target_cluster_name = dialog_options['dialog_option_0_target_cluster']
project_name = ""

unless dialog_options['dialog_option_0_service_name'].nil?
	project_name = dialog_options['dialog_option_0_service_name']
else
    project_id = dialog_options['dialog_option_0_source_project']
	project = $evm.vmdb(:container_project).find_by_id(project_id)
    project_name = project.name
end

$evm.log("info", "========= ADDING TAG TO PROJECT #{project_name} =========")

unless $evm.execute('category_exists?', 'cfme_managed')
  $evm.execute('category_create',
                      :name => 'cfme_managed',
                      :single_value => true,
                      :perf_by_tag => false,
                      :description => "CFME Managed")
end

unless $evm.execute('tag_exists?', 'cfme_managed', 'true')
  $evm.execute('tag_create', 
                      'cfme_managed',
                      :name => 'true',
                      :description => 'True')
end


target_cluster = $evm.vmdb(:ext_management_system).find_by_name(target_cluster_name)
#projects = $evm.vmdb(:container_project).where(:name => project_name, :ems_id => target_cluster.id)
projects = $evm.vmdb(:container_project).where("name = ? AND ems_id = ? AND deleted_on IS ?", project_name, target_cluster.id, nil)

projects.each { |project|
  $evm.log("info","==> Tagging Project #{project.name}")
  unless project.tagged_with?("cfme_managed","true")
      project.tag_assign("cfme_managed/true")
  end
  }

$evm.log("info", "========= DONE ADDING TAG TO PROJECT #{project_name} =========")
