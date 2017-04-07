#
# Description: Placeholder for service request validation
#
req = $evm.root['service_template_provision_request']
desc = req.description
desc_name = desc[desc.index('[')..desc.index(']')]

$evm.root['validation_method'] = "#{desc_name.gsub!('[','').gsub!(']','').gsub!(' ','')}"
$evm.log("info","-----  The filtered validation method is #{$evm.root['validation_method']} ------")
