#
# Description: This will tag project roles.  Container projects must be tagged with "cfme_managed/true"
#
require 'kubeclient'
require 'json'

$evm.log("info","===== Begin Tagging Project Roles =====")

def create_tags_if_not_exist(role, user)
  unless $evm.execute('category_exists?', 'ocp_role_' + role)
    $evm.execute('category_create',
                        :name => 'ocp_role_' + role,
                        :single_value => true,
                        :perf_by_tag => false,
                        :description => "OCP Role " + role)
  end

  unless $evm.execute('tag_exists?', 'ocp_role_' + role, 'true')
    $evm.execute('tag_create', 
                        'ocp_role_' + role,
                        :name => user,
                        :description => user)
  end
end

def tag_project_user_role(project, roleref, role)
  $evm.log("info","Project #{role}s are #{roleref.userNames}")
  users = roleref.userNames
  users.each { |user| create_tags_if_not_exist(role, user)
    project.tag_assign('ocp_role_' + role + '/' + user)
    }
end

def get_project_role_bindings(project)
  $evm.log("info","==> Looking at project #{project.name}")
  ems = project.ext_management_system
  $evm.log("info","==> Project is in cluster #{ems.inspect}")
  client = ems.connect
  unless client.discovered
    client.discover
  end
  bindings = client.get_role_bindings(namespace: project.name)
  bindings
end

roles = ['admin','edit','view']

tag = "/managed/cfme_managed/true"
projects = $evm.vmdb('container_project').find_tagged_with(:all => tag, :ns => "*")

projects.each { |project|
  $evm.log("info","==> Project #{project.inspect}")
  unless not project.deleted_on.nil?
    bindings = get_project_role_bindings(project)
    roles.each { |role| 
      bindings.each { |roleref|
        if roleref.metadata.name == role
          tag_project_user_role(project, roleref, role)
        end
        }
      }
  end
  }

$evm.log("info","===== End Tagging Project Admins =====")
