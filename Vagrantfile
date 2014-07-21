# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|


  # The OS that will run our code
  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  # Customizing memory. The VM will need at least 512MB
  config.vm.customize ["modifyvm", :id, "--memory", 512]
  config.vm.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]

  # In case the Rails app runs on port 3000, make it available on the host
  config.vm.forward_port 3000, 3000
  config.vm.forward_port 5432, 5432
  #config.vm.forward_port 80, 8080

  config.vm.provision :chef_solo do |chef|
    # NOTE:
    # This path should be created. Why? Because we want to enforce cookbooks repositories
    # Just `mkdir cookbooks` inside the Catarse repository
    # Install vagrant gem install librarian-chef
    # Only this and cookbooks will be automatically installed
    chef.cookbooks_path = "cookbooks"

    chef.add_recipe "apt"


    # Include GCC and other utilities (compilation,etc)
    chef.add_recipe "build-essential"
    chef.add_recipe "git"
    chef.add_recipe "curl"
    chef.add_recipe "curl::devel"
    chef.add_recipe "locale"

    # Avoiding uft-8 problem
    chef.add_recipe "set_locale"

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
    chef.add_recipe "set_locale::postgres"


    #  Configuration:
    #  The JSON below is where we configure or modify our recipes attributes
    #  Every recipe has an 'attributes' folder, and these are accessible using the hash format

    chef.json = {
      # Installing The latest ruby version
      rvm: {
        default_ruby: 'ruby-2.1.2',

        # Installing multiple ruby versions
        rubies: ['2.0.0-p0'],
        upgrade: :latest,

        # Gems that will be accessed globally
        global_gems: [
          { name: :thin },
          { name: :bundler },

          # Add heroku to make deployment easier
          { name: :heroku },
        ],

        # Somehow needed for Vagrant
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
  config.vm.provision :shell, inline: %q{sudo /etc/init.d/xvfb start}
  config.vm.provision :shell, inline: %q{sudo bash -c "echo 'UseDNS no' >> /etc/ssh/sshd_config"}
  config.vm.provision :shell, inline: %q{cp /vagrant/config/database.sample.yml /vagrant/config/database.yml}
  config.vm.provision :shell, inline: %q{cd /vagrant && bundle install}
  config.vm.provision :shell, inline: %q{cd /vagrant && rake db:create db:migrate db:test:prepare db:seed}
  config.vm.provision :shell, inline: %q{cd /vagrant && rails s -d}
end

