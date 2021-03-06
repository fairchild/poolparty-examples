# NOTE: many of the virtual resources below still need to be written
pool(:washington) do
  cloud(:app) do

    # if you want to use ec2 do this:

    # keypair "poolparty-examples"
    # using :ec2

    # if you want to use vmware, try this:
    # replace this with the IP address of your vmware instance
    vmware_ip = "192.168.133.128"

    using :vmrun do
      vmx_hash({
        "/Users/nmurray/Documents/VMware/Ubuntu-jaunty.vmwarevm/Ubuntu-jaunty.vmx" => vmware_ip
      })
    end

    instances 1
    expand_when "cpu > 3.5" 
    contract_when "cpu < 0.50"

    enable :haproxy

    has_package("tree")
    has_package("vim-nox")
    has_package("xfsprogs")
    has_package("screen")

    apache do
      present_apache_module("status")

      enable_php5 do
        extras :cli, :pspell
      end

      has_file :name => "/var/www/index.html" do
        content "<h1>Welcome to your new poolparty instance</h1>"
        mode 0644
        owner "www-data"
      end
    end

    chef do
      include_recipes "~/.poolparty/chef/cookbooks/*"
    # recipe "#{File.dirname(__FILE__)}/recipes/example_recipe.rb"
    end

    verify do
      ping
      http_status "http://#{vmware_ip}/index.html", 200
      http_status "http://#{vmware_ip}/index.html", :success
      http_status "http://#{vmware_ip}/asdfasdfads.html", 404
      http_match  "http://#{vmware_ip}/index.html", /Welcome to your/
      http_match  "http://#{vmware_ip}/index.html", /new poolparty instance/
    end


    # -- Nothing below this line works yet --

    # s3fs do 
    #   bucket "pprb-testing"
    # end

    # below is the eventual apache config
    
    # apache do
      # installed_as_standard

      # enable_php5 do
      #   extras :cli, :pspell, :mysql
      # end

      # config("store", ::File.join(File.dirname(__FILE__), "templates/apache", "store.conf.erb"))

      # has_custom_store do
      #   name "my_store.com"
      # end

      # has_file({:name => "/etc/apache2/htpasswd", 
      #         :template => File.dirname(__FILE__) + "/templates/apache/htpasswd",
      #         :owner => "www-data",
      #         :group => "www-data",
      #         :mode => 660})

      # present_apache_module("speling")
      # has_file({:name => "/etc/apache2/mods-enabled/speling.conf", 
      #             :content => "CheckSpelling On",
      #             :owner => "www-data",
      #             :group => "www-data",
      #             :mode => 660})

    # end

    # mysql do
    #   install_on_volume("/data")
    #   install_client
    # end

    # mrtg do
    #   monitor :cpu, :uptime, :memory, :open_files, :processes, :apache, :network_interfaces
    # end

    # master_takeover_hacks

    # has_file({:name => "/usr/bin/setlock.sh", 
    #           :template => File.dirname(__FILE__) + "/templates/bin/setlock.sh",
    #           :mode => 755})

    

  end # cloud :app
end # pool

# vim: ft=ruby
