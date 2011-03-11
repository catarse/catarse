# coding: utf-8
class CreateStates < ActiveRecord::Migration
  require 'sexy_pg_constraints'
  def self.up
    create_table :states do |t|
      t.string :name, :null => false
      t.string :acronym, :null => false
      t.timestamps
    end
    constrain :states do |t|
      t.name :not_blank => true, :unique => true
      t.acronym :not_blank => true, :unique => true
    end
    execute "INSERT INTO states (name, acronym) VALUES
      ('Acre', 'AC'),
      ('Alagoas', 'AL'),
      ('Amapá', 'AP'),
      ('Amazonas', 'AM'),
      ('Bahia', 'BA'),
      ('Ceará', 'CE'),
      ('Distrito Federal', 'DF'),
      ('Espírito Santo', 'ES'),
      ('Goiás', 'GO'),
      ('Maranhão', 'MA'),
      ('Mato Grosso', 'MT'),
      ('Mato Grosso do Sul', 'MS'),
      ('Minas Gerais', 'MG'),
      ('Pará', 'PA'),
      ('Paraíba', 'PB'),
      ('Paraná', 'PR'),
      ('Pernambuco', 'PE'),
      ('Piauí', 'PI'),
      ('Rio de Janeiro', 'RJ'),
      ('Rio Grande do Norte', 'RN'),
      ('Rio Grande do Sul', 'RS'),
      ('Rondônia', 'RO'),
      ('Roraima', 'RR'),
      ('Santa Catarina', 'SC'),
      ('São Paulo', 'SP'),
      ('Sergipe', 'SE'),
      ('Tocantins', 'TO');"
  end

  def self.down
    drop_table :states
  end
end
