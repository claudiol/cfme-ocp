#
# Description: <Method description here>
#
require 'kubeclient'
require 'yaml'

$evm.log("info","=== copy image streams ===")
project_name = ''
service = $evm.root['service']

project = $evm.vmdb('container_project').find_by_name(service.name)
ems = project.ext_management_system

$evm.log("info","Project Info ==> #{project.inspect}")

client = ems.connect
unless client.discovered
  client.discover
end

image_streams = client.get_image_streams(namespace: service.name)
image_streams.each { |image_stream| $evm.log("info","Image Stream ==> #{YAML.dump(image_stream.inspect)}") }
