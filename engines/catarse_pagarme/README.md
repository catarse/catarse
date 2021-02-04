# CatarsePagarme [![Code Climate](https://codeclimate.com/github/catarse/catarse_pagarme/badges/gpa.svg)](https://codeclimate.com/github/catarse/catarse_pagarme)

A [Pagar.me](http://pagar.me) payment engine for [Catarse](http://github.com/catarse/catarse)

## Installation

For now we are under development, but you can install directly via git on Gemfile

```
gem 'catarse_pagarme', github: 'catarse/catarse_pagarme'
```

## Usage

Configure the routes for your Catarse application. Add the following lines in the routes file (config/routes.rb):

```
mount CatarsePagarme::Engine => "/", :as => "catarse_moip"
```

create an (config/initializers/pagarme.rb) and configure with:


```
CatarsePagarme.configure do |config|
  config.api_key = "API_KEY"
  config.ecr_key = "ENCRYPTION KEY"
  config.slip_tax = "Slip payment tax"
  config.credit_card_tax = "Credit card transaction tax don't need to define the 0.39"
  config.interest_rate = "Interest rate for installments"
end
```



This project rocks and uses MIT-LICENSE.
