#
# Description: This will refresh the relationships with OCP.  OCP providers must be tagged with "cfme_managed/true"
#
$evm.log("info","===== Begin Refreshing Container Providers =====")

tag = "/managed/cfme_managed/true"
cps = $evm.vmdb('ext_management_system').find_tagged_with(:all => tag, :ns => "*")

cps.each { |cp| 
  $evm.log("info","==> Refreshing Container Provider #{cp.name}")
  cp.refresh
  $evm.log("info","==> Finished Refreshing Container Provider #{cp.name}")
  }

$evm.log("info","===== End Refreshing Container Providers =====")
