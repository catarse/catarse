# coding: utf-8
require 'sexy_pg_constraints'
class CreateStates < ActiveRecord::Migration
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
    execute "INSERT INTO states (name, acronym, created_at, updated_at) VALUES
      ('Acre', 'AC', current_timestamp, current_timestamp),
      ('Alagoas', 'AL', current_timestamp, current_timestamp),
      ('Amapá', 'AP', current_timestamp, current_timestamp),
      ('Amazonas', 'AM', current_timestamp, current_timestamp),
      ('Bahia', 'BA', current_timestamp, current_timestamp),
      ('Ceará', 'CE', current_timestamp, current_timestamp),
      ('Distrito Federal', 'DF', current_timestamp, current_timestamp),
      ('Espírito Santo', 'ES', current_timestamp, current_timestamp),
      ('Goiás', 'GO', current_timestamp, current_timestamp),
      ('Maranhão', 'MA', current_timestamp, current_timestamp),
      ('Mato Grosso', 'MT', current_timestamp, current_timestamp),
      ('Mato Grosso do Sul', 'MS', current_timestamp, current_timestamp),
      ('Minas Gerais', 'MG', current_timestamp, current_timestamp),
      ('Pará', 'PA', current_timestamp, current_timestamp),
      ('Paraíba', 'PB', current_timestamp, current_timestamp),
      ('Paraná', 'PR', current_timestamp, current_timestamp),
      ('Pernambuco', 'PE', current_timestamp, current_timestamp),
      ('Piauí', 'PI', current_timestamp, current_timestamp),
      ('Rio de Janeiro', 'RJ', current_timestamp, current_timestamp),
      ('Rio Grande do Norte', 'RN', current_timestamp, current_timestamp),
      ('Rio Grande do Sul', 'RS', current_timestamp, current_timestamp),
      ('Rondônia', 'RO', current_timestamp, current_timestamp),
      ('Roraima', 'RR', current_timestamp, current_timestamp),
      ('Santa Catarina', 'SC', current_timestamp, current_timestamp),
      ('São Paulo', 'SP', current_timestamp, current_timestamp),
      ('Sergipe', 'SE', current_timestamp, current_timestamp),
      ('Tocantins', 'TO', current_timestamp, current_timestamp);"
  end

  def self.down
    drop_table :states
  end
end
