#!/usr/bin/env bash
set -eux
./retrieve_batsim_messages_from_log.bash $@
./check_kill_progress_presence.py $@

