# catarse.js [![Circle CI](https://circleci.com/gh/catarse/catarse.js/tree/master.svg?style=svg)](https://circleci.com/gh/catarse/catarse.js/tree/master) [![Code Climate](https://codeclimate.com/github/catarse/catarse.js/badges/gpa.svg)](https://codeclimate.com/github/catarse/catarse.js)

# Mithril components for the Catarse world

A set of mithril components to use accross [catarse](https://github.com/catarse/catarse).

## Development

Install project dependencies ```npm install```.

Catarse.js uses webpack as build tool. 

To trigger a build, run:
```npm run build```

If you are deploying the built code to production, then run:
```npm run build:prod```

When developing, you need to link catarse.js as an npm dependency for the main catarse project. You can do so by:

Running `npm link` in the root folder of the catarse.js project and then `npm link catarse.js` in the root folder of the main catarse project

You can use webpack-dev-server to provide your assets locally by running `npm build:dev` and running the rails application with `webpack_dev_server` configuration set to true in config/application.rb

## Project Architecture

Webpack compiles the code found inside the /src directory and outputs into the /dist folder as catarse.js
There are 3 different folders: /c, /root and /vm.

/c

Small UI components: self-contained javascript modules that contain specific UI and behavior
root - Root components are bigger then regular components. They are the main component and the ones that are mounted (directly or by mithril's router). They also own their data, which should flow in one direction to it's children components (kind of like a Flux implementation). In our projects, they are related to endpoints (e.g.: when you hit a /project-permalink endpoint the JS will mount the projectsShow root component)

/root

Core components [need fuller description here...]

/vm

View-models. Component controllers ideally should not deal with nothing more then the ocmponent's user interface behavior. All other type of data manipulation should be handled by a view-model

/c.js

The entry point we use to expose the root components to the application

/app.js

Where we do the application bootstraping

/api.js

The module that handles setup for all the different apis we currently communicate with

/h.js

Module containing helper methods used across components. stuff like datetime formatting and other types of tasks that are common to all components

/error.js

Module that implements an error interface to be used across components
