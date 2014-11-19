=begin
6.  Install shorewall instead of the doc's suggested 'iptables' method:

    http://blog.jeff-owens.com/shorewall-firewall-on-ubuntu-feisty-vps-part-3/

    EDIT: the example docs have moved to:

    /usr/share/doc/shorewall/examples/one-interface/

    deploy@api-sc-01:/etc/shorewall$ ll /usr/share/doc/shorewall/examples/one-interface/
    total 80
    drwxr-xr-x 2 root root  4096 May 12 22:03 ./
    drwxr-xr-x 6 root root  4096 May 12 22:03 ../
    -rw-r--r-- 1 root root   860 Jan 30 21:18 interfaces
    -rw-r--r-- 1 root root  6199 Jan 30 23:17 interfaces.annotated.gz
    -rw-r--r-- 1 root root   806 Jan 30 21:18 policy
    -rw-r--r-- 1 root root  2974 Jan 30 23:17 policy.annotated.gz
    -rw-r--r-- 1 root root  1126 Jan 30 21:18 README.txt
    -rw-r--r-- 1 root root  1322 Jan 30 21:18 rules
    -rw-r--r-- 1 root root 12043 Jan 30 23:17 rules.annotated.gz
    -rw-r--r-- 1 root root 20013 Jan 30 23:17 shorewall.conf.annotated.gz
    -rw-r--r-- 1 root root  1798 Jan 30 21:18 shorewall.conf.gz
    -rw-r--r-- 1 root root   737 Jan 30 21:18 zones
    -rw-r--r-- 1 root root  3234 Jan 30 23:17 zones.annotated.gz
    deploy@api-sc-01:/etc/shorewall$ ll /usr/share/doc/shorewall/examples/one-interface/interfaces
    -rw-r--r-- 1 root root 860 Jan 30 21:18 /usr/share/doc/shorewall/examples/one-interface/interfaces

    A.  Copy the files from a different server - they now reside on apisc01 so get them from there /etc/shorewall/

        $ cd /etc/shorewall

        $ cp -v /usr/share/doc/shorewall/examples/one-interface/interfaces .
        $ cp -v /usr/share/doc/shorewall/examples/one-interface/policy .
        $ cp -v /usr/share/doc/shorewall/examples/one-interface/rules .
        $ cp -v /usr/share/doc/shorewall/examples/one-interface/zones .

    B.  edit the interfaces file

        $ nano /etc/shorewall/interfaces


    C.  edit the zones file

        $ nano /etc/shorewall/zones

    D.  edit the policy file

        $ nano /etc/shorewall/policy


    E.  edit the rules file

        $ nano /etc/shorewall/rules
        NOTE: don't forget to add the line for postgres access on the db_sc_01 server
        ACCEPT          net             fw              tcp     5432

    F.  edit the shorewall file

        $ nano /etc/default/shorewall.conf

    G. restart shorewall

        $ invoke-rc.d shorewall start
=end

unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

  namespace :shorewall do

    desc <<-DESC
      Creates and updates the shorewall config files on the server and starts the shorewall firewall.
    DESC
    task :setup, except: { no_release: true } do
      base_loc, spec_loc = '/home/deploy/shorewall', '/home/deploy/shorewall-etc'
      locations = {}
      locations["#{base_loc}/rules"]          = fetch(:template_dir, "config/deploy/file_templates") + '/shorewall-rules.erb'
      locations["#{base_loc}/zones"]          = fetch(:template_dir, "config/deploy/file_templates") + '/shorewall-zones.erb'
      locations["#{base_loc}/policy"]         = fetch(:template_dir, "config/deploy/file_templates") + '/shorewall-policy.erb'
      locations["#{base_loc}/interfaces"]     = fetch(:template_dir, "config/deploy/file_templates") + '/shorewall-interfaces.erb'
      locations["#{base_loc}/shorewall.conf"] = fetch(:template_dir, "config/deploy/file_templates") + '/shorewall.conf.erb'
      locations["#{spec_loc}/shorewall"]      = fetch(:template_dir, "config/deploy/file_templates") + '/shorewall-default.erb'

      run "mkdir -p /home/deploy/shorewall"
      run "mkdir -p /home/deploy/shorewall-etc"

      locations.each_pair do | serv_loc, loc |
        template = File.file?(loc) ? File.read(loc) : (raise "Capistrano:Deploy:ShorewallTemplateNotFound")

        config = ERB.new(template)

        puts "Writing #{app_name} shorewall initialization script (#{loc}) to /home/deploy/shorewall"

        put config.result(binding), serv_loc
      end
    end

    desc <<-DESC
      [internal] Moves config files in /home/deploy/shorewall to /etc/shorewall and /etc/default.
    DESC
    task :move_config_files, except: { no_release: true } do
      run "cd /home/deploy/shorewall && #{sudo} mv -f * /etc/shorewall"
      run "cd /home/deploy/shorewall-etc && #{sudo} mv -f * /etc/default"
    end

    desc "Start shorewall"
    task :start_shorewall do
      run "#{sudo} service shorewall start || #{sudo} service shorewall restart"
    end
  end

  puts "shorewall_config_generator.rb running..."
  after "deploy:setup",    "shorewall:setup"    unless fetch(:skip_shorewall_setup, false)
  after "shorewall:setup", "shorewall:move_config_files"
  after "shorewall:move_config_files", 'shorewall:start_shorewall'
end