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

* Ruby 2.1.2
* [PostgreSQL](http://www.postgresql.org/)
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

If everything goes OK, you can now run the project!

### Running the project

```bash
$ rails server
```

Open [http://localhost:3000](http://localhost:3000)

### Translations

We hope to support a lot of languages in the future, so we are willing to accept pull requests with translations to other languages.

Thanks a lot to Daniel Walmsley, from http://purpose.com, for starting the internationalization and beginning the English translation.

## Payment gateways

Currently, we support MoIP, PayPal and WePay through our payment engines. Payment engines are extensions to Catarse that implement a specific payment gateway logic.
The current working engines are:
* MoIP
* PayPal
* WePay

If you have created a different payment engine to Catarse, please contact us so we can link your engine here.
If you want to create a payment engine, please join our mailing list at http://groups.google.com/group/catarse-dev

## How to contribute with code

Before contributing, take a look at our Roadmap (https://www.pivotaltracker.com/projects/427075) and discuss your plans in our mailing list (http://groups.google.com/group/catarse-dev).

Our Pivotal is concerned with user visible features using user stories. But we do have some features not visible to users that are planned such as:
* Turn Catarse into a Rails Engine with customizable views.
* Make an installer script to guide users through initial Catarse configuration.

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

Copyright (c) 2011 Softa

Licensed under the MIT license (see MIT-LICENSE file)
