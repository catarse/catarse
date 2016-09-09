# Run Catarse using Docker

This guide will help you get started to setup the project using Docker, and keep using it as part of your development process.

## Table of contents
- [Installing Docker](#installing-docker)
- [Setup Catarse](#setup-catarse)
- [Running Catarse](#running-catarse)
- [Stop Catarse](#stop-catarse)
- [Seeding DB](#seeding-db)
- [Running tests](#running-tests)
- [Debugging](#debugging)

## Installing Docker

The first thing you need to do before start is to install `Docker` and `docker-compose`. 

For Mac/Windows users:

* [https://docs.docker.com/docker-for-mac/](https://docs.docker.com/docker-for-mac/) 

For Linux users:

* [Docker](https://docs.docker.com/engine/installation/linux/)
* [docker-compose](https://github.com/docker/compose/releases)

If Docker was successfully installed, you should be good to go.

## Setup Catarse

To setup Catarse you just need to run the following commands:

```
% docker-compose run --rm web bash
```

It may take some time the first time you run this, but once you are done, you will be logged into the container, with something like:

```
root@77b21b498430:/usr/src/app
```

There you can just run the creation & migration tasks for the database:

```
% rake db:create
% rake db:migrate
```

## Running Catarse

Tu run catarse you can just simply run the up command with `docker-compose`:

```
% docker-compose up -d
```

That command will lift every service Catarse needs, such as the `rails server`, `sidekiq` and `redis`.

It may take a while before you see anything, you can follow the logs of the containers with:

```
% docker-compose logs
```

Once you see an output like this:

```
web_1   | => Booting Thin
web_1   | => Rails 4.2.5.2 application starting in development on http://0.0.0.0:3000
web_1   | => Run `rails server -h` for more startup options
web_1   | => Ctrl-C to shutdown server
web_1   | Thin web server (v1.6.3 codename Protein Powder)
web_1   | Maximum connections set to 1024
web_1   | Listening on 0.0.0.0:3000, CTRL+C to stop
```

## Stop Catarse

In order to stop Catarse as a whole you can run:

```
% docker-compose stop
```

This will stop every container, but if you need to stop one in particular, you can specify it like:

```
% docker-compose stop web
```

`web` is the service name located on the `docker-compose.yml` file, there you can see the services name and stop each of them if you need to.

## Seeding DB

You probably won't be working with a blank database, so once you are able to run Catarse you can seed the database, to do it, just run:

```
% docker-compose run --rm web rake db:seed
```

## Running tests

In order to run the tests you have to first setup the test database, and then execute the rspec command:

```
% docker-compose run --rm test bash
```

Create and migrate the database:

```
% rake db:create rake db:migrate
```

Run the tests:

```
% bundle exec rspec --colour --format d spec
```

## Debugging

We know you love to use `debugger` or `binding.pry`, and who doesn't, that's why we put together a script to attach the `web` container service into your terminal session. 

What we mean by this, is that if you add a `debugger` or `binding.pry` on a part of the code, you can run:

```
% bin/attach web
```

This will display the logs from the rails app, as well as give you access to stop the execution on the debugging point as you would expect.

**Take note that if you kill this process you will kill the web service, and you will probably need to lift it up again.**
