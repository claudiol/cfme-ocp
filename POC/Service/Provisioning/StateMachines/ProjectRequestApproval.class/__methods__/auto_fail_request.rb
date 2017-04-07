#
# Description: This method is executed when the provisioning request is auto-approved
#


$evm.log("info", "AUTO-DENIED")
$evm.root["miq_request"].deny("admin", "AUTO-DENIED - Project with name already exists.")
