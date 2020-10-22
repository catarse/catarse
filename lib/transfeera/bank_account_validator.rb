# frozen_string_literal: true
require 'net/http'

module Transfeera
    class BankAccountValidator

        def self.validate(catarse_user_bank_account)
            authorization_data = Transfeera::Authorization.request()
            account_to_validate = map_to_transfeera_account_from catarse_user_bank_account
        
            email_contact = CatarseSettings[:email_contact]
            access_token = authorization_data['access_token']

            begin
                validation_response = request_validation(email_contact, access_token, account_to_validate)
                validation = validation_response['_validation']
                
                map_to_catarse_bank_account_model validation
            rescue StandardError => e
                Raven.capture_exception(e, level: 'fatal')
                {
                    valid: false,
                    errors: [
                        {
                            field: :validation_error,
                            message: I18n.t('bank_accounts.edit.validation_error')
                        }
                    ]
                }
            end
        end

        private

        def self.map_to_transfeera_account_from(catarse_user_bank_account)
            account_type = if catarse_user_bank_account.account_type.include?('conta_corrente')
                'CONTA_CORRENTE'
            elsif catarse_user_bank_account.account_type.include?('conta_poupanca')
                'CONTA_POUPANCA'
            end
            {
                name: catarse_user_bank_account.user.name,
                cpf_cnpj: catarse_user_bank_account.user.cpf,
                bank_code: catarse_user_bank_account.bank_code,
                agency: catarse_user_bank_account.agency,
                agency_digit: catarse_user_bank_account.agency_digit,
                account: catarse_user_bank_account.account,
                account_digit: catarse_user_bank_account.account_digit,
                account_type: account_type,
                integration_id: ''
            }
        end

        def self.request_validation(email_contact, access_token, account_to_validate)
            contacerta_url = CatarseSettings[:transfeera_contacerta_url]
            validate_url = "#{contacerta_url}/validate?type=BASICA"
            headers = {
                'Authorization' => access_token,
                'User-Agent' => "Company (#{email_contact})",
                'Content-Type' => 'application/json'
            }
            JSON.parse(Net::HTTP.post(URI(validate_url), account_to_validate.to_json, headers).body).to_h
        end
        
        def self.map_to_catarse_bank_account_model(validation)
            {
                valid: validation['valid'],
                errors: validation['errors'].map do |error| 
                    if error['field'] == 'name'
                        {
                            field: :user_name,
                            message: error['message']
                        }
                    elsif error['field'] == 'cpf_cnpj'
                        {
                            field: :cpf,
                            message: error['message']
                        }
                    else
                        {
                            field: error['field'].to_sym,
                            message: error['message']
                        }
                    end
                end
            }
        end

    end
end
