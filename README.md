# Catarse
[![Circle CI](https://circleci.com/gh/catarse/catarse/tree/master.svg?style=svg)](https://circleci.com/gh/catarse/catarse/tree/master)
[![Coverage Status](https://coveralls.io/repos/catarse/catarse/badge.svg?branch=master)](https://coveralls.io/r/catarse/catarse?branch=master)
[![Code Climate](https://codeclimate.com/github/catarse/catarse/badges/gpa.svg)](https://codeclimate.com/github/catarse/catarse)

The first crowdfunding platform from Brazil

## An open-source crowdfunding platform for creative projects

Welcome to Catarse's source code repository.
Our goal with opening the source code is to stimulate the creation of a community of developers around a high-quality crowdfunding platform.

You can see the software in action in http://catarse.me.
The official repo is https://github.com/catarse/catarse

## Getting started

### Dependencies

To run this project you need to have:

* Ruby 2.2.3

* Rails 4.1

* [postgREST 0.3](https://github.com/begriffs/postgrest/releases/tag/v0.3.0.3)

* [PostgreSQL 9.4](http://www.postgresql.org/)
  * OSX - [Postgres.app](http://postgresapp.com/)
  * Linux - `$ sudo apt-get install postgresql`
  * Windows - [PostgreSQL for Windows](http://www.postgresql.org/download/windows/)

  **IMPORTANT**: Make sure you have postgresql-contrib ([Aditional Modules](http://www.postgresql.org/docs/9.3/static/contrib.html)) installed on your system.

### Setup the project

* Clone the project

        $ git clone https://github.com/catarse/catarse.git

* Enter project folder

        $ cd catarse

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

	After downloading PostgREST 0.3.x you can unpack and run the executable as bellow.

		$ ./postgrest postgres://postgrest@localhost/catarse_development -a anonymous --jwt-secret gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C -p 8080 -s 1 -p 3004

* Run Rails server
```bash
$ rails server
```

Open [http://localhost:3000](http://localhost:3000)

### Translations

We hope to support a lot of languages in the future, so we are willing to accept pull requests with translations to other languages.

Thanks a lot to Daniel Walmsley, from http://purpose.com, for starting the internationalization and beginning the English translation.

## Payment gateways

Currently, we support pagarme through our payment engines. Payment engines are extensions to Catarse that implement a specific payment gateway logic.

If you have created a different payment engine to Catarse, please contact us so we can link your engine here.
If you want to create a payment engine, please join our mailing list at http://groups.google.com/group/catarse-dev

## How to contribute with code

Discuss your plans in our mailing list (http://groups.google.com/group/catarse-dev).

After that, just fork the project, change what you want, and send us a pull request.

### Best practices (or how to get your pull request accepted faster)

* Follow this style guide: https://github.com/bbatsov/ruby-style-guide
* Create one acceptance tests for each scenario of the feature you are trying to implement.
* Create model and controller tests to keep 100% of code coverage in the new parts you are writing.
* Feel free to add specs to committed code that lacks coverage ;)
* Let our tests serve as a style guide: we try to use implicit spec subjects and lazy evaluation wherever we can.

## Credits

Author: Daniel Weinmann

Contributors: You know who you are ;) The commit history can help, but the list was getting bigger and pointless to keep in the README.

## License

Copyright (c) 2016 Softa

Licensed under the MIT license (see MIT-LICENSE file)
