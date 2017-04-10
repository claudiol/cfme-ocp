#
# Description: <Method description here>
#

projects = $evm.vmdb("container_project").where(:name => 'default', :ems_id => '2')
$evm.log("info","Projects #{projects.inspect}")
