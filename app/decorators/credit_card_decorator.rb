class CreditCardDecorator < Draper::Decorator
  decorates :credit_card
  include Draper::LazyHelpers

  def display_digits
    "XXXX-XXXX-XXXX-#{source.last_digits}"
  end
end
