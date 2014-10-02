# Catarse [![Build Status](https://secure.travis-ci.org/catarse/catarse.png?branch=master)](https://travis-ci.org/catarse/catarse) [![Coverage Status](https://coveralls.io/repos/catarse/catarse/badge.png?branch=channels)](https://coveralls.io/r/catarse/catarse) [![Dependency Status](https://gemnasium.com/catarse/catarse.png)](https://gemnasium.com/catarse/catarse) [![Code Climate](https://codeclimate.com/github/catarse/catarse.png)](https://codeclimate.com/github/catarse/catarse)

The first crowdfunding platform from Brazil

## An open source crowdfunding platform for creative projects

Welcome to Catarse's source code repository.
Our goal with opening the source code is to stimulate the creation of a community of developers around a high-quality crowdfunding platform.

You can see the software in action in http://catarse.me.
The official repo is https://github.com/catarse/catarse

## Getting started

### Dependencies

To run this project you need to have:

* Ruby 2.1.2
* [PostgreSQL](http://www.postgresql.org/)
  * OSX - [Postgress.app](http://postgresapp.com/)
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

    Add your datbase credentials

* Install the gems

        $ bundle install

* Create the database

        $ rake db:create db:migrate db:seed

If everything goes OK, you can now run the project!

### Running the project

```bash
$ rails server
```

Open [http://localhost:3000](http://localhost:3000)

### Translations

We hope to support a lot of languages in the future.
So we are willing to accept pull requests with translations to other languages.

Thanks a lot to Daniel Walmsley, from http://purpose.com, for starting the internationalization and beginning the english translation.

## Payment gateways

Currently, we support MoIP, PayPal and WePay through our payment engines. Payment engines are extensions to Catarse that implement a specific payment gateway logic.
The current working engines are:
* MoIP
* PayPal
* WePay

If you have created a different payment engine to Catarse please contact us so we can link your engine here.
If you want to create a payment engine please join our mailing list at http://groups.google.com/group/catarse-dev

## How to contribute with code

Before contributing, take a look at our Roadmap (https://www.pivotaltracker.com/projects/427075) and discuss your plans in our mailing list (http://groups.google.com/group/catarse-dev).

Our pivotal is concerned with user visible features using user stories. But we do have some features not visible to users that are planned such as:
* Turn Catarse into a Rails Engine with customizable views.
* Make a installer script to guide users through initial Catarse configuration.

After that, just fork the project, change what you want, and send us a pull request.

### Best practices (or how to get your pull request accepted faster)

* Follow this style guide: https://github.com/bbatsov/ruby-style-guide
* Create one acceptance tests for each scenario of the feature you are trying to implement.
* Create model and controller tests to keep 100% of code coverage at least in the new parts that you are writing.
* Feel free to add specs to the code that is already in the repository without the proper coverage ;)
* Regard the existing tests for a style guide, we try to use implicit spec subjects and lazy evaluation as often as we can.

## Credits

Author: Daniel Weinmann

Contributors: You know who you are ;) The commit history can help, but the list was getting bigger and pointless to keep in the README.


## License

Copyright (c) 2011 Softa

Licensed under the MIT license (see MIT-LICENSE file)
