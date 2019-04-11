namespace :dev_seed do
  desc 'states'
  task input_states: :environment do
    ['Acre|AC',
    'Alagoas|AL',
    'Amapá|AP',
    'Amazonas|AM',
    'Bahia|BA',
    'Ceará|CE',
    'Distrito Federal|DF',
    'Espírito Santo|ES',
    'Goiás|GO',
    'Maranhão|MA',
    'Mato Grosso|MT',
    'Mato Grosso do Sul|MS',
    'Minas Gerais|MG',
    'Pará|PA',
    'Paraíba|PB',
    'Paraná|PR',
    'Pernambuco|PE',
    'Piauí|PI',
    'Rio de Janeiro|RJ',
    'Rio Grande do Norte|RN',
    'Rio Grande do Sul|RS',
    'Rondônia|RO',
    'Roraima|RR',
    'Santa Catarina|SC',
    'São Paulo|SP',
    'Sergipe|SE',
    'Tocantins|TO'].each do |state_str|
      name, acronym = state_str.split('|')
      state = State.find_or_initialize_by acronym: acronym
      state.name = name
      state.save!
    end
  end

  desc 'setup demo configurations'
  task demo_settings: :environment do |t, args|
    raise 'only run in development' unless Rails.env.development?
    rewrite = ENV['REWRITE_ALL'].present? && ENV['REWRITE_ALL'] == 'true'

    puts "===== demo settings to working with docker-compose  ====="

    puts "rewriting all settings" if rewrite

    puts "===== setting demo settings ====="
    catarse = {
      company_name: 'Demo Catarse',
      company_logo: 'http://catarse.me/assets/catarse_bootstrap/logo_icon_catarse.png',
      host: 'localhost:3000',
      base_url: "http://localhost:3000",

      email_contact: 'contato@example.email',
      email_payments: 'financeiro@example.email',
      email_projects: 'projetos@example.email',
      email_system: 'system@example.email',
      email_no_reply: 'no-reply@example.email',
      facebook_url: "http://facebook.com/dtcatarse.me",
      facebook_app_id: '173747042661491',
      twitter_url: 'http://twitter.com/catarse',
      twitter_username: "catarse",
      mailchimp_url: "http://catarse.us5.list-manage.com/subscribe/post?u=ebfcd0d16dbb0001a0bea3639&amp;id=149c39709e",
      catarse_fee: '0.13',
      support_forum: 'http://localhost:3000',
      base_domain: 'localhost:3000',
      faq_url: 'http://localhost:3000/',
      feedback_url: 'http://localhost:3000/',
      terms_url: 'http://localhost:3000/',
      privacy_url: 'http://localhost:3000/',
      about_channel_url: 'http://localhost:3000/',
      instagram_url: 'http://localhost:3000/',
      blog_url: "http://localhost:3000/",
      github_url: 'http://localhost:3000/',
      contato_url: 'http://localhost:3000/',
      api_moments_host: 'http://catarse_moment_service_api:3000',
      api_host: 'http://catarse_api:3000',
      front_api_moments_host: 'http://localhost:3010',
      front_api_host: 'http://localhost:3008'
      #api_moments_host: 'http://localhost:3008'
    }

    common = {
			jwt_secret: 'bUH75katNm6Yj0iPSchcgUuTwYAzZr7C',
      front_common_notification_service_api: 'http://localhost:3007',
			front_common_recommender_service_api: 'http://localhost:3009',
      front_common_community_service_api: 'http://localhost:3003',
      front_common_project_service_api: 'http://localhost:3002',
      front_common_analytics_service_api: 'http://localhost:3005',
      front_common_payment_service_api: 'http://localhost:3001',
			front_common_proxy_service_api: 'http://localhost:3013',

      common_notification_service_api: 'http://notification_service_api:30000',
			common_recommender_service_api: 'http://recommender_service_api:3000',
      common_community_service_api: 'http://community_service_api:3000',
      common_project_service_api: 'http://project_service_api:3000',
      common_analytics_service_api: 'http://analytics_service_api:3000',
      common_payment_service_api: 'http://payment_service_api:3000',
			common_proxy_service_api: 'http://proxy',
      common_platform_token: 'a28be766-bb36-4821-82ec-768d2634d78b',
      common_platform_id: '8187a11e-6fa5-4561-a5e5-83329236fbd6',
      common_db_host: 'service_core_db',
      common_db_name: 'service_core',
      common_db_port: '5432',
			common_db_password: 'example',
			common_db_user: 'catarse_fdw',
			fdw_user: 'catarse_fdw',
      common_api_key: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoicGxhdGZvcm1fdXNlciIsInBsYXRmb3JtX3Rva2VuIjoiYTI4YmU3NjYtYmIzNi00ODIxLTgyZWMtNzY4ZDI2MzRkNzhiIiwiZ2VuX2F0IjoxNTA0MTMzNDQwfQ.kDTJb9HVmCMf8PIX0ZSwWr2CtJ0QjZgaNgk2qTJttjg',
			common_proxy_api_key: 'platform_api_key_fc975e84cd927457f023bdc06d9bdf6209cf4d2dfbfae2702286f86ec1f8941b350a7a8ab3c52e8adda04c6441fd95a94b4bcfd9dbc7457c059e232ec8649dd9'
    }


    [catarse,common].each do |setting_hash|
      setting_hash.each do |name, value|
        conf = CatarseSettings.find_or_initialize_by(name: name)
        if conf.new_record? || rewrite
          puts "setting value for CatarseSettings[:#{name}]"
          conf.update_attributes({
            value: value
          })
        end
      end
    end


    OauthProvider.find_or_create_by!(name: 'facebook') do |o|
      o.key = 'your_facebook_app_key'
      o.secret = 'your_facebook_app_secret'
      o.path = 'facebook'
    end

  end
end
