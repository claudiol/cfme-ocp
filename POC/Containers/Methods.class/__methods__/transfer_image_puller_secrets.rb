#
# Description: <Method description here>
#
require 'kubeclient'
require 'base64'

$evm.log("info","===== BEGIN TRANSFER IMAGE PULLER SECRETS =====")

def get_route_name(project)
  ems_id = project.ext_management_system.id
  routes = $evm.vmdb(:container_route).where(:name => 'docker-registry', :ems_id => ems_id)
  route_name = routes[0].host_name
  route_name
end

def extract_secret(secrets, secret_type)
  secrets.each { |secret|
    if secret.metadata.name.start_with? secret_type
      return secret.data.to_h
    end
    }
end

def replace_registry_host_in_secret(registry_host, datas)
  datas_value = datas[:".dockercfg"]
  datas_value_dec = Base64.decode64(datas_value)
  datas_value_dec.gsub!(/172\.30\.\d{1,3}\.\d{1,3}:5000/, registry_host)
  datas[:".dockercfg"] = Base64.encode64(datas_value_dec)
  datas
end

def create_secret(client, project_name, source_cluster_pretty_name, secret_type, data)
  
  secret_name = secret_type+source_cluster_pretty_name
  
  secret = Kubeclient::Secret.new
  secret.metadata = {}
  secret.metadata.name = secret_name
  secret.metadata.namespace = project_name
  secret.data = data
  secret.type = "kubernetes.io/dockercfg"

  begin
    client.create_secret(secret)
    return secret
  rescue KubeException => e
    if e.message.include? "already exists"
      client.patch_secret(secret_name, secret, project_name)
    else
      raise e
    end
  end
end

def assign_secret(client, project_name, sa_type, secret_name)
  sas = client.get_service_accounts(:namespace => project_name)
  sas.each { |sa|
    
    if sa.metadata.name.eql? sa_type
      sa_reference = Kubeclient::ServiceAccount.new
      sa_reference.name = secret_name
      #Oddly there is sometimes a race condition where the association between an
      #image pull secret and SA lingers, even after a project is destroyed.  This
      #should clean it up.
      image_pull_secrets = sa.imagePullSecrets.reject {|ips| ips == sa_reference}
      image_pull_secrets.push(sa_reference)
      sa.imagePullSecrets = image_pull_secrets
      client.patch_service_account(sa_type, sa, project_name)
      
    end
    }
  
end

task = $evm.root["service_template_provision_task"]
dialog_options = task.dialog_options

dialog_options = $evm.root["service_template_provision_task"].dialog_options
target_cluster_name = dialog_options['dialog_option_0_target_cluster']
target_ems = $evm.vmdb(:ext_management_system).find_by_name(target_cluster_name)

project_id = dialog_options['dialog_option_0_source_project']
project = $evm.vmdb(:container_project).find_by_id(project_id)
project_name = project.name

source_ems = project.ext_management_system
source_cluster_pretty_name = source_ems.name.downcase.gsub(/[^a-z0-9]/i, '')

route_name = get_route_name(project)

client_options = {}
client_options[:service] = 'kubernetes'
client = source_ems.connect(client_options)

secrets = client.get_secrets(:namespace => project_name)
default_dockercfg_secret = extract_secret(secrets, "default-dockercfg-")

deployer_dockercfg_secret = extract_secret(secrets, "deployer-dockercfg-")

client = target_ems.connect(client_options)
default_dockercfg_secret = replace_registry_host_in_secret(route_name, default_dockercfg_secret)

default_secret = create_secret(client, project_name, source_cluster_pretty_name, "default-dockercfg-", default_dockercfg_secret)
assign_secret(client, project_name, "default", "default-dockercfg-"+source_cluster_pretty_name)

deployer_secret = create_secret(client, project_name, source_cluster_pretty_name, "deployer-dockercfg-", deployer_dockercfg_secret)
assign_secret(client, project_name, "deployer", "deployer-dockercfg-"+source_cluster_pretty_name)

$evm.log("info","===== END TRANSFER IMAGE PULLER SECRETS =====")
