# Development environment with docker

### building dev.Dockerfile

Inside project root run:
`docker build -t catarse -f dev.Dockerfile .`
This will build the docker image for catarse project.


### Setting up database

Catarse uses PostgreSQL 9.4:
`docker run -p 5432:5432 --name catarse_pg -d postgres:9.4`
This will download and run a container with the postgres 9.4 image (for more Postgres configurations take a look at https://hub.docker.com/_/postgres/).

Creating database:
`docker run -it --rm --link catarse_pg:postgres postgres:9.4 createdb catarse_development -h postgres -U postgres`
If you want to run tests create a catarse_test using same command.

Creating database rules:
`docker run -it --rm --link catarse_pg:postgres postgres:9.4  createuser --no-login web_user -h postgres -U postgres> /dev/null 2>&1`

`docker run -it --rm --link catarse_pg:postgres postgres:9.4  createuser --no-login admin -h postgres -U postgres > /dev/null 2>&1`

`docker run -it --rm --link catarse_pg:postgres postgres:9.4  createuser --no-login anonymous -h postgres -U postgres > /dev/null 2>&1`

`docker run -it --rm --link catarse_pg:postgres postgres:9.4  createuser catarse -s -h postgres -U postgres> /dev/null 2>&1`

`docker run -it --rm --link catarse_pg:postgres postgres:9.4 createuser postgrest -g admin -g web_user -g anonymous -h postgres -U postgres > /dev/null 2>&1`

All these commands will create the necessary database roles to running Rails and PostgREST services.

You can run this local instead use docker, just grab the IP (`docker inspect container_id | grep IPAddress`) of the current docker machine and change on you config/database.yml  sabe for psql, pg_restore, pg_dump, -h use the IP of docker machine

Running migrations:
`docker run -i --rm -v ~/Code/catarse/:/usr/app/ -e "RAILS_ENV=development" -e "DATABASE_URL=postgres://postgres@postgres:5432/catarse_development" -p 3000:3000 --link catarse_pg:postgres catarse bundle exec rake db:migrate`

Mount the current project path to get new migrations (no need to rebuild when developing)


### Running PostgREST server


```
cat > postgrest.conf <<EOL  
db-uri = "postgres://postgrest@postgres:5432/catarse_development"
db-schema    = "1" 
db-anon-role = "anonymous"
db-pool = 10
server-port = 3004
server-host = "0.0.0.0"
jwt-secret = "gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C"
EOL
docker run -it -v $PWD/postgrest.conf:/postgrest.conf -p 3004:3004 --link catarse_pg:postgres  --name api_server -d  begriffs/postgrest:v0.4.1.0 postgrest /postgrest.conf 
```

This create a postgrest.conf on current path and link via mount on container, new version of postgrest use a configuration file instead arg vars.


### Running the server

`docker run -i -d --rm  -v ~/Code/catarse/:/usr/app/ -v ~/Code/catarse.js:/usr/app/vendor/assets/components/catarse.js -e "RAILS_ENV=development" -e "DATABASE_URL=postgres://postgres@postgres:5432/catarse_development" -p 3000:3000 --link catarse_pg:postgres catarse bundle exec rails server -p 3000 -b 0.0.0.0`

This will start rails server on port 3000 and mount the current project code and catarse.js lib on container (this is so you don’t need to rebuild the image when changing files)

Sometimes this error can occur: `A server is already running. Check /usr/app/tmp/pids/server.pid.` this is because we are getting the tmp directory so we need to remove on your project folder `rm -rf tmp/pids/server.pid`


### TODO (next)

- [ ] Conditional on RAILS_ENV to run rake assets compilation on container when for production
