# frozen_string_literal: true

require 'net/http'

module Transfeera
  class BankAccountValidator < Transfeera::BaseRequest
    def self.validate(catarse_user_bank_account)
      BankAccountValidator.new(HttpRequest.new).validate_account catarse_user_bank_account
    end

    def validate_account(catarse_user_bank_account)
      begin
        account_to_validate = map_to_transfeera_account_from catarse_user_bank_account
        validation_response = request_validation account_to_validate
        validation = validation_response["_validation"]
        map_to_catarse_bank_account_model validation
      rescue StandardError => e
        Sentry.capture_exception(e)
        Rails.logger.info("VALIDATE ERROR #{e.inspect}")
        {
          valid: false,
          errors: [
            {
              field: :validation_error,
              message: I18n.t("bank_accounts.edit.validation_error"),
            },
          ],
        }
      end
    end

    private

    def map_to_transfeera_account_from(catarse_user_bank_account)
      account_type = if catarse_user_bank_account.account_type.include?('conta_facil')
        'CONTA_FACIL'
      elsif catarse_user_bank_account.account_type.include?("conta_corrente")
        "CONTA_CORRENTE"
      elsif catarse_user_bank_account.account_type.include?("conta_poupanca")
        "CONTA_POUPANCA"
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
        integration_id: "",
      }
    end

    def request_validation(account_to_validate)
      contacerta_url = CatarseSettings.get_without_cache(:transfeera_contacerta_url)
      validate_url = "#{contacerta_url}/validate?type=BASICA"
      with_config = {
        :method => 'POST',
        :url => validate_url,
        :data => account_to_validate,
      }

      authorized_request with_config
    end

    def map_to_catarse_bank_account_model(validation)
      {
        valid: validation["valid"],
        errors: validation["errors"].map do |error|
          if error["field"] == "name"
            {
              field: :user_name,
              message: error["message"],
            }
          elsif error["field"] == "cpf_cnpj"
            {
              field: :cpf,
              message: error["message"],
            }
          else
            {
              field: error["field"].to_sym,
              message: error["message"],
            }
          end
        end,
      }
    end
  end
end
