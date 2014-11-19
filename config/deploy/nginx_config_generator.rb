unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

  namespace :apache do 
    desc "Create VHost Apache"
    task :create_vhost_apache, roles: :app, except: { no_release: true } do

      if exists?( :create_vhost_apache )


        puts "***********************"
        puts "***********************"
        puts "***********************"
        puts "INSIDE task :create_vhost_apache   exists?( :create_vhost_apache ): #{exists?( :create_vhost_apache )}"
        puts "***********************"
        puts "***********************"
        puts "***********************"

        vhost = <<-EOF
        <VirtualHost *:80>

          # written via deploy.rb

          ServerAlias #{app_uri}
          DocumentRoot #{deploy_to}/current/public
          <Directory #{deploy_to}/current/public>
             AllowOverride all
             Options -MultiViews
          </Directory>

          RailsEnv #{rails_env}

        </VirtualHost>
        EOF

        put vhost, "#{shared_path}/config/vhost"

        if rails_env == 'staging'
          sudo "mv #{shared_path}/config/vhost /etc/apache2/sites-available/000-default.conf"
          sudo "a2ensite 000-default.conf"
        else
          sudo "mv #{shared_path}/config/vhost /etc/apache2/sites-available/#{app_uri}"
          sudo "a2ensite #{app_uri}"
        end

        #sudo "/etc/init.d/apache2 reload"
      end
    end
  end

  namespace :nginx do

    desc "Setup nginx config"
    task :setup, roles: :app, except: { no_release: true } do
      config_file = ERB.new( File.read( fetch( :template_dir, "config/deploy/file_templates" ) + '/nginx.conf.erb' ) )

      run "mkdir -p /home/deploy/nginx"

      put config_file.result(binding), "/home/deploy/nginx/nginx.conf"

      run "cd /home/deploy/nginx && #{sudo} mv -f * /etc/nginx"
    end

    desc "Create VHost Nginx"
    task :create_vhost_nginx, roles: :app, except: { no_release: true } do
      config_file = ERB.new( File.read( fetch( :template_dir, "config/deploy/file_templates" ) + '/nginx_vhost.erb' ) )

      put config_file.result(binding), "#{shared_path}/config/vhost"

      puts "***********************"
      puts "INSIDE task :create_vhost_nginx"
      puts config_file.result(binding)
      puts "***********************"

      # sudo "rm /opt/nginx/sites-available/#{app_uri} /opt/nginx/sites-enabled/#{app_uri}"
      # We create the vhost file as the 'default' server as we will never be assigning separate FQDN's to every server; of we need to access them separately we just hit them with their respective ip address that then serves the default site
      run "#{sudo} mv -f #{shared_path}/config/vhost /etc/nginx/sites-available/#{app_uri}"
      # if rails_env == 'staging'
      #   run "#{sudo} ln -f -s /etc/nginx/sites-available/#{app_uri} /etc/nginx/sites-enabled/default"
      # else
      #   run "#{sudo} ln -f -s /etc/nginx/sites-available/#{app_uri} /etc/nginx/sites-enabled/#{app_uri}"
      # end
      run "#{sudo} ln -f -s /etc/nginx/sites-available/#{app_uri} /etc/nginx/sites-enabled/default"

    end
  end

  puts "nginx_config_generator: AFTER setup"
  after "deploy:setup", "nginx:setup"
  after "nginx:setup", "nginx:create_vhost_nginx"
  #after "deploy:setup", "apache:create_vhost_apache"
end