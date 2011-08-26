package :deploy, :provides => :deployer do
  description 'Create deploy user'
  
  requires :create_deploy_user, :add_deploy_ssh_keys
end

package :create_deploy_user do
  description "Create the deploy user"
  
  runner "useradd --create-home --shell /bin/bash --user-group --groups users,sudo #{DEPLOY_USER}"
  runner "echo '#{DEPLOY_USER}:#{DEPLOY_USER_PASSWORD}' | chpasswd"
  
  verify do
    has_directory "/home/#{DEPLOY_USER}"
  end
end

package :add_deploy_ssh_keys do
  description "Add deployer public key to authorized ones"
  requires :create_deploy_user
  
  id_rsa_pub = `cat ~/.ssh/id_rsa.pub`
  authorized_keys_file = "/home/#{DEPLOY_USER}/.ssh/authorized_keys"
  
  push_text id_rsa_pub, authorized_keys_file do
    # Ensure there is a .ssh folder.
    pre :install, "mkdir -p /home/#{DEPLOY_USER}/.ssh"
    
    # Set correct permissons and ownership.
    pre :install, "chmod 0700 /home/#{DEPLOY_USER}/.ssh"
    pre :install, "chown -R #{DEPLOY_USER}:#{DEPLOY_USER} /home/#{DEPLOY_USER}/.ssh"
    
    post :install, "chmod 0700 /home/#{DEPLOY_USER}/.ssh/authorized_keys"
  end
  
  verify do
    file_contains authorized_keys_file, id_rsa_pub
  end
end