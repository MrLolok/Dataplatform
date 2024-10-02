#!/bin/bash
set -e

./bin/livy-server start
tail -f /dev/null