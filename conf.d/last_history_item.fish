#!/usr/bin/env fish

set -g __last_history_item_abbr_version 0.0.1

abbr -a !! --position anywhere --function last_history_item
