# Joint Venture Nepal (JVN)

######A hyper local Nepali crowdfunding platform.

Welcome to JVN code repo.JVN is a forked project of a popular crowdfunding project called [Catarse](https://github.com/catarse/catarse). Our goal with opening the source code is to stimulate the creation of a community of developers around a high-quality crowdfunding platform.

You can see the software in action in [http://myjvn.com](http://myjvn.com). The official repo is [https://github.com/sushant12/jvn](https://github.com/sushant12/jvn)

## Getting started

### Dependencies

To run this project you need to have:

* Ruby 2.3.1

* Rails 4.2

* [postgREST 0.3](https://github.com/begriffs/postgrest/releases/tag/v0.3.0.3)

* [PostgreSQL 9.4](http://www.postgresql.org/)
  * OSX - [Postgres.app](http://postgresapp.com/)
  * Linux - `$ sudo apt-get install postgresql`
  * Windows - [PostgreSQL for Windows](http://www.postgresql.org/download/windows/)

  **IMPORTANT**: Make sure you have postgresql-contrib ([Additional Modules](http://www.postgresql.org/docs/9.3/static/contrib.html)) installed on your system.

### Setup the project

* Clone the project

        $ git clone https://github.com/sushant12/jvn.git

* Enter project folder

        $ cd jvn

* Create the `database.yml`

        $ cp config/database.sample.yml config/database.yml

    You must do this to configure your local database!
    Add your database username and password (unless you don't have any).

* Install the gems

        $ bundle install

* Install the front-end dependencies

        $ bower install

    Requires [bower](http://bower.io/#install-bower), which requires [Node.js](https://nodejs.org/download/) and its package manager, *npm*. Follow the instructions on the bower.io website.

* Create and seed the database

        $ rake db:create db:migrate db:seed

* Configure the API server

	We provide authentication through JWT ([JSON Web Tokens](http://jwt.io/)) and it can be configured by `CatarseSettings` into rails console.

		$ bundle exec rails console
		> CatarseSettings[:api_host] = "http://localhost:3004" # postgREST server url
		> CatarseSettings[:jwt_secret] = "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C" # this token is just a valid example

If everything goes OK, you can now run the project!

### Running the project

* Run API server

	After downloading PostgREST 0.3.x you can unpack and run the executable as below.

		$ ./postgrest postgres://user@localhost/db_name -a anonymous --jwt-secret gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C -s 1 -p 3004

* Run Rails server
```bash
$ rails server
```

Open [http://localhost:3000](http://localhost:3000)

### Translations

We hope to support Nepali languages in the future, so we are willing to accept pull requests with translations in Nepali.

## Payment gateways

We have plans to integrate eSewa, Stripe, Everest Bank Payment System and NIBL Bank Payment System.

  List of payment enginees that are being developed or need to be developed further

    https://github.com/catarse/catarse_pagarme (payment engine used by Catarse.me)
    https://github.com/devton/catarse_paypal_express (currently out of date and not maintained)
    https://github.com/sushant12/CatarseStripe (just starting to be developed and needs extra hands -- please pitch in...)

## How to contribute with code

Discuss your plans in our mailing list (http://groups.google.com/group/joint-venture-nepal).

After that, just fork the project, change what you want, and send us a pull request.

### Best practices (or how to get your pull request accepted faster)

* Follow this style guide: https://github.com/bbatsov/ruby-style-guide
* Create one acceptance tests for each scenario of the feature you are trying to implement.
* Create model and controller tests to keep 100% of code coverage in the new parts you are writing.
* Feel free to add specs to committed code that lacks coverage ;)
* Let our tests serve as a style guide: we try to use implicit spec subjects and lazy evaluation wherever we can.

## License

Licensed under the MIT license (see MIT-LICENSE file)