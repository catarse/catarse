class AddCodeToCountries < ActiveRecord::Migration
  def up
    add_column :countries, :code, :string, limit: 2

    Country.all.each do |country|
      next if ignore_list.include?(country.name_en)

      if country.name_en == 'Netherlands Antilles'
        country.update!(code: 'AN')
      elsif country.name_en == 'The Bahamas'
        country.update!(code: 'BS', name_en: 'Bahamas', name: 'Bahamas')
      elsif country.name_en == 'North Korea'
        country.update!(code: 'KP', name_en: 'Korea (Democratic People\'s Republic of)')
      elsif country.name_en == 'The Gambia'
        country.update!(code: 'GM', name_en: 'Gambia')
      elsif country.name_en == 'Cocos Islands'
        country.update!(code: 'CC', name_en: 'Cocos (Keeling) Islands')
      elsif country.name_en == 'US Virgin Islands'
        country.update!(code: 'VI', name_en: 'Virgin Islands (U.S.)')
      elsif country.name_en == 'Jan Mayen'
        country.update!(code: 'SJ', name_en: 'Svalbard and Jan Mayen', name: 'Svalbard e Jan Mayen')
      elsif country.name_en == 'Man,Isle of'
        country.update!(code: 'IM', name_en: 'Isle of Man', name: 'Ilha de Man')
      elsif country.name_en == 'Monserrate'
        country.update!(code: 'MS', name_en: 'Montserrat', name: 'Monserrate')
      elsif country.name_en == 'St. Helena'
        country.update!(code: 'SH', name_en: 'Saint Helena, Ascension and Tristan da Cunha', name: 'Santa Helena, Ascensão e Tristão da Cunha')
      elsif country.name_en == 'São Cristóvão e Neves'
        country.update!(code: 'KN', name_en: 'Saint Kitts and Nevis')
      elsif country.name == 'Brasil'
        country.update!(code: 'BR', name_en: 'Brazil')
      elsif country.name_en.blank?
        # do nothing
      else
        c = ISO3166::Country.find_country_by_name(country.name_en)
        if c.present?
          country.update(code: c.alpha2)
        else
          raise country.inspect
        end
      end
    end
  end

  def down
    remove_column :countries, :code
  end

  def ignore_list
    [
      'Arctic Ocean',
      'Ashmore and Cartier Islands',
      'Atlantic Ocean',
      'Clipperton Island',
      'Congo-Brazzaville',
      'Congo-Kinshasa',
      'Coral Sea Islands',
      'Dhekelia',
      'Gaza Strip',
      'Granada',
      'Cocos Islands',
      'Indian Ocean',
      'Akrotiri',
      'World',
      'Navassa Island',
      'Pacific Ocean',
      'Paracel Islands',
      'Southern Ocean',
      'Spratly Islands',
      'The European Union',
      'Vatican',
      'Wake Island',
      'West Bank'
    ]
  end
end
