# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|


  # The OS that will run our code
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # Customizing memory. The VM will need at least 512MB
  config.vm.customize ["modifyvm", :id, "--memory", 512] 

  # In case the Rails app runs on port 3000, make it available on the host
  config.vm.forward_port 3000, 3000
  config.vm.forward_port 5432, 5432
  #config.vm.forward_port 80, 8080

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "cookbooks"

    chef.add_recipe "apt"


    # Include GCC and other utilities (compilation,etc)
    chef.add_recipe "build-essential"
    chef.add_recipe "git"
    chef.add_recipe "curl"
    chef.add_recipe "curl::devel"
    chef.add_recipe "locale::default"

    # Virtual server X Frame Buffer
    chef.add_recipe "xvfb"
    chef.add_recipe "firefox"

    # Image handling
    chef.add_recipe "imagemagick"
    chef.add_recipe "imagemagick::devel"
    chef.add_recipe "imagemagick::rmagick"

    # This recipe is necessary if you're working with Rails & needs a JS runtime
    chef.add_recipe "nodejs"

    # Make my terminal looks good
    chef.add_recipe "oh_my_zsh"

    # RVM for rubies management
    chef.add_recipe "rvm::vagrant"
    chef.add_recipe "rvm::system"

    # PostgreSQL Because we Love it
    chef.add_recipe "postgresql"
    chef.add_recipe "postgresql::client"
    chef.add_recipe "postgresql::libpq"
    chef.add_recipe "postgresql::server"
    chef.add_recipe "postgresql::contrib"


    #  Configuration: 
    #  The JSON below is where we configure or modify our recipes attributes
    #  Every recipe has an 'attributes' folder, and these are accessible using the hash format

    chef.json = {
      # Installing The latest ruby version
      rvm: {
        ruby: {
          implementation: :ruby, version: "1.9.3"
        },
        global_gems: [
          { name: :thin }, 
          { name: :bundler },
        ],
        # This is needed because of Vagrant & Chef Solo
        vagrant: {
          system_chef_solo: '/opt/vagrant_ruby/bin/chef-solo'
        }

      },

      # Configuring postgreSQL
      # WARNING: 
      # If you're going to deploy using Chef, please Change all these configurations!
      postgresql: {
        listen_addresses: "*",
        pg_hba: [
            "host all all 0.0.0.0/0 md5",
            "host all all ::1/0 md5",
        ],
        users: [
          {
            username: "postgres",
            password: "password",
            superuser: true,
            createdb: true,
            login: true
          }
        ],
       databases: [
          { name: :catarse_development, owner: :postgres, template: "template0", encoding: "utf-8", locale: "en_US.UTF8" },
          { name: :catarse_test, owner: :postgres, template: "template0", encoding: "utf-8", locale: "en_US.UTF8" },
          { name: :catarse_production, owner: :postgres, template: "template0", encoding: "utf-8", locale: "en_US.UTF8" },
        ],
      },
      # Making the terminal looks good with theming and assigning to the vagrant user
      oh_my_zsh: {
        users: [{ 
          login: :vagrant,
          plugins: %w{git bundler ruby vi rails}
        }]
      }
    }
  

  end

  
  # Run the Rails project right on vagrant up 
  config.vm.provision :shell, inline: %q{cd /vagrant && export DISPLAY=:99}
  config.vm.provision :shell, inline: %q{cp /vagrant/config/database.sample.yml /vagrant/config/database.yml}
  config.vm.provision :shell, inline: %q{update-locale LANG=en_US.utf8}
  config.vm.provision :shell, inline: %q{cd /vagrant && bundle install}
  config.vm.provision :shell, inline: %q{cd /vagrant && rake db:migrate && rake catarse:config:load_defaults && rake db:seed}
  config.vm.provision :shell, inline: %q{cd /vagrant && bundle exec rails s -d}
end

