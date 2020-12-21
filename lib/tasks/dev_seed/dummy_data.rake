if ENV['RAILS_ENV'] == 'development'
  require 'faker'
  require 'net/http'
  require 'json'

  namespace :dev_seed do

    desc 'generate projects'
    task :generate_projects, [:project_base_name, :user_id, :city_id, :mode, :number_of_projects] => [:environment] do |task, args|

      number_of_projects_to_generate = args[:number_of_projects].to_i

      def getFromIdOrRandom(model, id)
        if id.present?
          model.find_by_id(id)
        else
          model.offset(rand(model.count)).first
        end
      end

      for i in 0..(number_of_projects_to_generate - 1) do
        name = "#{args[:project_base_name]} #{i}"
        category = getFromIdOrRandom(Category, nil)
        city = getFromIdOrRandom(City, args[:city_id])
        user = getFromIdOrRandom(User, args[:user_id])
        mode = args.fetch(:mode, 'flex')

        _project = user.projects.new
        _project.name = name
        _project.category = category
        _project.city = city
        _project.about_html = '<p>about</p>'
        _project.headline = 'headline'
        _project.mode = 'flex'
        _project.goal = rand(2000..100000)
        _project.online_days = rand(30..59)
        _project.video_url = 'http://vimeo.com/17298435'
        _project.budget = '10000'
        _project.content_rating = 1
        _project.save!
      end

      Project.where(state: 'draft').each do |pr|
        pr.about_html = '<p>about</p>'
        pr.headline = 'headline'
        pr.content_rating = 1
        pr.state_machine.transition_to!(:online)
        puts "#{pr.mode} project #{pr.id} is online"
      end

      puts ':generate_projects', task, args
    end

    desc 'fill cities from states'
    task fill_cities_from_state: :environment do
      State.all.each do |state|
        uri_string = "http://educacao.dadosabertosbr.com/api/cidades/#{state.acronym.downcase}"
        uri = URI(uri_string)
        response = Net::HTTP.get(uri)
        cities = JSON.parse(response)

        puts "Creating cities from state #{state.name}"

        cities.each do |ibge_number_city_name|
          city_name = ibge_number_city_name.split(':')[1]
          city = City.find_or_initialize_by(name: city_name.titleize, state: state)
          city.save!
        end
      end
    end

    desc 'add some users projects and contributions'
    task dummy_data: :environment do
      Faker::Config.locale = :"pt-BR"
      raise 'only run in development' unless Rails.env.development?

      country_br = Country.where(name: 'Brasil').first
      raise 'missing br in country tables' unless country_br.present?

      10.times do |i|
        _email = "fakeuser#{i}@email.com"
        next if User.where(email: _email).exists?

        _user = User.create!(
          public_name: Faker::Name.first_name,
          name: Faker::Name.name,
          email: _email,
          password: '12345678',
          cpf: Faker::IDNumber.brazilian_citizen_number,
          birth_date: Faker::Date.birthday(18, 55),
          account_type: 'pf'
        )

        _s = Faker::Address.state_abbr
        _state =State.find_or_initialize_by(acronym: _s, name: _s)
        _state.save!

        _cname = Faker::Address.city
        _city = City.create!(state_id: _state.id, name: _cname)

        address = _user.address || _user.build_address
        address.update!(
          country_id: country_br.id,
          state_id: _state.id,
          address_street: Faker::Address.street_name,
          address_number: Faker::Address.building_number,
          address_neighbourhood: Faker::Address.state,
          address_zip_code: Faker::Address.postcode_by_state(_s),
          address_city: _city.name,
          address_state: _s,
          phone_number: Faker::PhoneNumber.cell_phone
        )
        _user.save!

        puts "created user #{_user.email}"
      end

      # add aon projects
      3.times do |i|
        _user = User.order('random()').first
        next unless _user.address.present?

        _project = _user.projects.new
        _project.name = Faker::Commerce.product_name
        _project.category = Category.order('random()').first
        _project.city = City.order('random()').first
        _project.about_html = Faker::Lorem.paragraph
        _project.headline = Faker::Lorem.sentence
        _project.mode = 'aon'
        _project.goal = rand(2000..100000)
        _project.online_days = rand(30..59)
        _project.video_url = 'http://vimeo.com/17298435'
        _project.budget = '10000'
        _project.rewards.build(
          deliver_at: 1.year.from_now,
          minimum_value: rand(10..100),
          description: Faker::Lorem.sentence,
          shipping_options: 'free'
        )
        _project.save!
        puts "AON Project #{_project.id} created"
      end

      # add sub projects
      3.times do |i|
        _user = User.order('random()').first
        next unless _user.address.present?

        _project = _user.projects.new
        _project.name = Faker::Commerce.product_name
        _project.category = Category.order('random()').first
        _project.city = City.order('random()').first
        _project.about_html = Faker::Lorem.paragraph
        _project.headline = Faker::Lorem.sentence
        _project.mode = 'sub'
        _project.goal = rand(2000..100000)
        _project.video_url = 'http://vimeo.com/17298435'
        _project.budget = '10000'
        _project.rewards.build(
          deliver_at: 1.year.from_now,
          minimum_value: rand(10..100),
          description: Faker::Lorem.sentence,
          shipping_options: 'free'
        )
        _project.save!
        puts "Sub Project #{_project.id} created"
      end

      Project.where(state: 'draft').each do |pr|
        pr.state_machine.transition_to!(:online)
        puts "#{pr.mode} project #{pr.id} is online"
      end

    end
  end
end
