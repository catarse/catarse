# -*- coding: utf-8 -*-
# This module handles with default state validation
module Project::AllOrNothingStateValidator
  extend ActiveSupport::Concern

  included do

    # All valid states for projects in_analysis to end of publication
    ON_ANALYSIS_TO_END_STATES = %w(in_analysis approved online successful waiting_funds failed).freeze

    # All valid states for projects approved to end of publication
    ON_ONLINE_TO_END_STATES = %w(online successful waiting_funds failed).freeze

    # Validation for in_analysis? only state
    with_options if: :in_analysis? do |wo|
      wo.validates_presence_of :city
      wo.validates_length_of :name, maximum: Project::NAME_MAXLENGTH
    end

    # Start validations when project state
    # is included on ON_ANALYSIS_TO_END_STATE
    with_options if: -> (x) { ON_ANALYSIS_TO_END_STATES.include? x.state } do |wo| 
      wo.validates_presence_of :about_html,
        :headline, :goal, :online_days, :budget

      wo.validates_presence_of :uploaded_image,
        if: ->(project) { project.video_thumbnail.blank? }

      wo.validate do
        [:uploaded_image, :about_html, :name].each do |attr|
          self.user.errors.add_on_blank(attr)
        end

        self.user.errors.each do |error, error_message|
          self.errors.add('user.' + error.to_s, error_message)
        end

        if self.account && (self.account.agency.try(:size) || 0) < 4
          self.errors['account.agency_size'] << "Agência deve ter pelo menos 4 dígitos"
        end
      end
    end

    # Start validations when project state
    # is included on ON_ONLINE_TO_END_STATE
    with_options if: -> (x) { ON_ONLINE_TO_END_STATES.include? x.state } do |wo| 
      wo.validates_presence_of :account,
        message: 'Dados Bancários não podem ficar em branco'

      wo.validate do
        # NOTE: maybe this validations can be on ProjectAccount
        [
          :email, :address_street, :address_number, :address_city,
          :address_state, :address_zip_code, :phone_number, :bank,
          :agency, :account, :account_digit, :owner_name, :owner_document
        ].each do |attr|
          self.account.errors.add_on_blank(attr) if self.account.present?
        end

        # only add account errors to project when account already
        # created, if not no validate (legacy projects).
        self.account.errors.each do |error, error_message|
          self.errors.add('project_account.' + error.to_s, error_message)
        end if self.account.present?
      end
    end
  end
end
