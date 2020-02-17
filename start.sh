#!/bin/bash

# turn on bash's job control
set -m

# Start the primary process (http server) and put it in the background
./start-http.sh &

# Start the helper process (ESS pull service)
./pull-ESS.sh


# the my_helper_process might need to know how to wait on the
# primary process to start before it does its work and returns

# now we bring the primary process (http server) back into the foreground
# and leave it there
fg %1

# Details at:
# https://docs.docker.com/config/containers/multi-service_container/
