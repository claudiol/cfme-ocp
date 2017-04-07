

miq_request = $evm.root["miq_request"]
raise "MiqRequest Not Found" if miq_request.nil?

description = miq_request.description[(miq_request.description.index('[')+1)..(miq_request.description.index(']')-1)]
description.gsub!(' ','')
$evm.log("info","==== The description is #{description} ====")
unless description.nil?
  $evm.object['request_type'] = description
  $evm.root['request_type'] = description
else
  $evm.object['request_type'] = miq_request.resource_type
  $evm.root['request_type'] = miq_request.resource_type
end
$evm.root['user'] ||= $evm.root['miq_request'].requester
$evm.log("info", "Request Type:<#{$evm.object['request_type']}>")
