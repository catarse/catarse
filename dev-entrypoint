#! /bin/bash

# The Docker App Container's development entrypoint.
# This is a script used by the project's Docker development environment to
# setup the app containers and databases upon runnning.
set -e

: ${APP_PATH:="/usr/src/app"}
: ${APP_TEMP_PATH:="$APP_PATH/tmp"}
: ${APP_SETUP_LOCK:="$APP_TEMP_PATH/setup.lock"}
: ${APP_SETUP_WAIT:="5"}

# 1: Define the functions lock and unlock our app containers setup processes:
function lock_setup { mkdir -p $APP_TEMP_PATH && touch $APP_SETUP_LOCK; }
function unlock_setup { rm -rf $APP_SETUP_LOCK; }
function wait_setup { echo "Waiting for app setup to finish..."; sleep $APP_SETUP_WAIT; }

# 2: 'Unlock' the setup process if the script exits prematurely:
trap unlock_setup HUP INT QUIT KILL TERM EXIT

# 3: Wait until the setup 'lock' file no longer exists:
while [ -f $APP_SETUP_LOCK ]; do wait_setup; done

# 4: 'Lock' the setup process, to prevent a race condition when the project's
# app containers will try to install gems and setup the database concurrently:
lock_setup

# 5: Check or install the app dependencies via Bundler:
bundle check || bundle

# 6: Check if the database exists, or setup the database if it doesn't, as it is
# the case when the project runs for the first time.
#
# We'll use a custom script `check-or-setup-db` (inside our app's `bin` folder),
# instead of running `rake db:version  || rake db:setup`, as running that command
# (at least on rails 4.2.4) will leave a couple of small ruby zombie processes
# running in the container:
check_or_setup_db

# 7: 'Unlock' the setup process:
unlock_setup

# 8: Specify a default command, in case it wasn't issued:
if [ -z "$1" ]; then set -- rails server -p 3000 -b 0.0.0.0 "$@"; fi

# 9: If the command to execute is 'rails server', then force it to write the
# pid file into a non-shared container directory. Suddenly killing and removing
# app containers without this would leave a pidfile in the project's tmp dir,
# preventing the app container from starting up on further attempts:
if [[ "$1" = "rails" && ("$2" = "s" || "$2" = "server") ]]; then set -- "$@" -P /tmp/server.pid; fi

# 10: Execute the given or default command:
exec "$@"
