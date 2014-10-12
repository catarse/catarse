class CreateCountries < ActiveRecord::Migration
  def up
    create_table :countries do |t|
      t.text :name, null: false
      t.timestamps
    end
    execute <<-SQL
      INSERT INTO countries (name) VALUES
      ('Afeganistão'), ('África do Sul'), ('Akrotiri'), ('Albânia'), ('Alemanha'), 
      ('Andorra'), ('Angola'), ('Anguila'), ('Antárctida'), ('Antígua e Barbuda'), 
      ('Antilhas Neerlandesas'), ('Arábia Saudita'), ('Arctic Ocean'), ('Argélia'), 
      ('Argentina'), ('Arménia'), ('Aruba'), ('Ashmore and Cartier Islands'), 
      ('Atlantic Ocean'), ('Austrália'), ('Áustria'), ('Azerbaijão'), 
      ('Baamas'), ('Bangladeche'), ('Barbados'), ('Barém'), ('Bélgica'), ('Belize'), 
      ('Benim'), ('Bermudas'), ('Bielorrússia'), ('Birmânia'), ('Bolívia'), 
      ('Bósnia e Herzegovina'), ('Botsuana'), ('Brasil'), ('Brunei'), ('Bulgária'), 
      ('Burquina Faso'), ('Burúndi'), ('Butão'), ('Cabo Verde'), ('Camarões'), 
      ('Camboja'), ('Canadá'), ('Catar'), ('Cazaquistão'), ('Chade'), ('Chile'), 
      ('China'), ('Chipre'), ('Clipperton Island'), ('Colômbia'), ('Comores'), 
      ('Congo-Brazzaville'), ('Congo-Kinshasa'), ('Coral Sea Islands'), 
      ('Coreia do Norte'), ('Coreia do Sul'), ('Costa do Marfim'), ('Costa Rica'), 
      ('Croácia'), ('Cuba'), ('Dhekelia'), ('Dinamarca'), ('Domínica'), ('Egipto'), 
      ('Emiratos Árabes Unidos'), ('Equador'), ('Eritreia'), ('Eslováquia'), 
      ('Eslovénia'), ('Espanha'), ('Estados Unidos'), ('Estónia'), ('Etiópia'), 
      ('Faroé'), ('Fiji'), ('Filipinas'), ('Finlândia'), ('França'), ('Gabão'), 
      ('Gâmbia'), ('Gana'), ('Gaza Strip'), ('Geórgia'), 
      ('Geórgia do Sul e Sandwich do Sul'), ('Gibraltar'), ('Granada'), ('Grécia'), 
      ('Gronelândia'), ('Guame'), ('Guatemala'), ('Guernsey'), ('Guiana'), ('Guiné'), 
      ('Guiné Equatorial'), ('Guiné-Bissau'), ('Haiti'), ('Honduras'), ('Hong Kong'), 
      ('Hungria'), ('Iémen'), ('Ilha Bouvet'), ('Ilha do Natal'), ('Ilha Norfolk'), 
      ('Ilhas Caimão'), ('Ilhas Cook'), ('Ilhas dos Cocos'), ('Ilhas Falkland'), 
      ('Ilhas Heard e McDonald'), ('Ilhas Marshall'), ('Ilhas Salomão'), 
      ('Ilhas Turcas e Caicos'), ('Ilhas Virgens Americanas'), ('Ilhas Virgens Britânicas'), 
      ('Índia'), ('Indian Ocean'), ('Indonésia'), ('Irão'), ('Iraque'), ('Irlanda'), 
      ('Islândia'), ('Israel'), ('Itália'), ('Jamaica'), ('Jan Mayen'), ('Japão'), 
      ('Jersey'), ('Jibuti'), ('Jordânia'), ('Kuwait'), ('Laos'), ('Lesoto'), 
      ('Letónia'), ('Líbano'), ('Libéria'), ('Líbia'), ('Listenstaine'), ('Lituânia'), 
      ('Luxemburgo'), ('Macau'), ('Macedónia'), ('Madagáscar'), ('Malásia'), ('Malávi'), 
      ('Maldivas'), ('Mali'), ('Malta'), ('Man, Isle of'), ('Marianas do Norte'), 
      ('Marrocos'), ('Maurícia'), ('Mauritânia'), ('Mayotte'), ('México'), 
      ('Micronésia'), ('Moçambique'), ('Moldávia'), ('Mónaco'), ('Mongólia'), 
      ('Monserrate'), ('Montenegro'), ('Mundo'), ('Namíbia'), ('Nauru'), ('Navassa Island'), 
      ('Nepal'), ('Nicarágua'), ('Níger'), ('Nigéria'), ('Niue'), ('Noruega'), 
      ('Nova Caledónia'), ('Nova Zelândia'), ('Omã'), ('Pacific Ocean'), 
      ('Países Baixos'), ('Palau'), ('Panamá'), ('Papua-Nova Guiné'), ('Paquistão'), 
      ('Paracel Islands'), ('Paraguai'), ('Peru'), ('Pitcairn'), ('Polinésia Francesa'), 
      ('Polónia'), ('Porto Rico'), ('Portugal'), ('Quénia'), ('Quirguizistão'), 
      ('Quiribáti'), ('Reino Unido'), ('República Centro-Africana'), ('República Checa'), 
      ('República Dominicana'), ('Roménia'), ('Ruanda'), ('Rússia'), ('Salvador'), ('Samoa'), 
      ('Samoa Americana'), ('Santa Helena'), ('Santa Lúcia'), ('São Cristóvão e Neves'), 
      ('São Marinho'), ('São Pedro e Miquelon'), ('São Tomé e Príncipe'), 
      ('São Vicente e Granadinas'), ('Sara Ocidental'), ('Seicheles'), ('Senegal'), 
      ('Serra Leoa'), ('Sérvia'), ('Singapura'), ('Síria'), ('Somália'), ('Southern Ocean'), 
      ('Spratly Islands'), ('Sri Lanca'), ('Suazilândia'), ('Sudão'), ('Suécia'), ('Suíça'), 
      ('Suriname'), ('Svalbard e Jan Mayen'), ('Tailândia'), ('Taiwan'), ('Tajiquistão'), 
      ('Tanzânia'), ('Território Britânico do Oceano Índico'), ('Territórios Austrais Franceses'), 
      ('Timor Leste'), ('Togo'), ('Tokelau'), ('Tonga'), ('Trindade e Tobago'), ('Tunísia'), 
      ('Turquemenistão'), ('Turquia'), ('Tuvalu'), ('Ucrânia'), ('Uganda'), ('União Europeia'), 
      ('Uruguai'), ('Usbequistão'), ('Vanuatu'), ('Vaticano'), ('Venezuela'), ('Vietname'), 
      ('Wake Island'), ('Wallis e Futuna'), ('West Bank'), ('Zâmbia'), ('Zimbabué');
      UPDATE countries SET created_at = now(), updated_at = now();
    SQL
  end

  def down
    drop_table :countries
  end
end
