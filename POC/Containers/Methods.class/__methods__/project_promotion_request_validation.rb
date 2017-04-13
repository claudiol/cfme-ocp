$evm.log("info", "====== BEGIN PROJECT PROMOTION REQUEST VALIDATION ======")
cluster_name = ""

unless $evm.root["service_template_provision_task"].nil?
	dialog_options = $evm.root["service_template_provision_task"].dialog_options
    cluster_name = dialog_options['dialog_option_0_target_cluster']
else
	dialog_options = $evm.root["service_template_provision_request"].options[:dialog]
    cluster_name = dialog_options['dialog_option_0_target_cluster']
end

if cluster_name.nil? or cluster_name.length == 0
  raise "Target cluster was not specified in request."
end

$evm.log("info", "====== BEGIN PROJECT PROMOTION REQUEST VALIDATION ======")
