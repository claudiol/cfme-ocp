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

client = ems.connect
unless client.discovered
  client.discover
end

users = client.get_users
users.each { |user| $evm.log("info","User ==> #{user.to_h}") }
