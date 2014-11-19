unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

  namespace :puma do

    desc <<-DESC
      Creates the puma config files on the server.
    DESC
    task :setup, roles: :app, except: { no_release: true } do
      locations = {}
      locations["#{app_name}.conf"]  = fetch(:template_dir, "config/deploy/file_templates") + '/puma.conf.erb'
      locations["puma-manager.conf"] = fetch(:template_dir, "config/deploy/file_templates") + '/puma-manager.conf.erb'

      locations.each_pair do |name, loc|
        template = File.file?(loc) ? File.read(loc) : (raise "Capistrano:Deploy:PumaTemplateNotFound")

        config = ERB.new(template)

        puts "Writing #{app_name} daemon script (#{loc}) to /home/deploy/upstart"

        run "mkdir -p /home/deploy/upstart"

        put config.result(binding), "/home/deploy/upstart/#{name}"
      end
    end

    desc <<-DESC
      [internal] Moves config files in /home/deploy/upstart to /etc/init for daemonization.
    DESC
    task :move_config_files, roles: :app, except: { no_release: true } do
      run "cd /home/deploy/upstart && #{sudo} mv -f * /etc/init"
    end
  end

  puts "puma_config_generator.rb running..."
  after "deploy:setup", "puma:setup"    unless fetch(:skip_puma_setup, false)
  after "puma:setup",   "puma:move_config_files"
end