#!/bin/bash
export COUNTER_SERVER_DEBUG=0                        # mainly from server-counter.pl
export COUNTER_SERVER_SOCKET=./counter.socket
export COUNTER_IMAGE_TIMEOUT=3                       # how long to wait before creating another image
export COUNTER_NUMBER_LENGTH=6                       # how many numbers to show up, 6 -> 123456;   4 -> 1234; etc
export COUNTER_NUMBER_FILE=./counter.numb
export COUNTER_NUMBER_SAVE_FREQUENCY=60              # generally, how much time should pass before the count gets saved (*during* accept(), no alarm() or anything fancy)
export CONTENT_SECURITY_POLICY=artemis.venus.place
export COUNTER_TEMP_DIR=./tmp/                       # note ending '/'
export COUNTER_IMAGE_FILE=counter.png
export COUNTER_ASSET_DIR=./asset/                    # note ending '/'

(trap 'kill 0' SIGINT; ./counter-server.pl & hypnotoad -f ./myapp.pl & wait)
