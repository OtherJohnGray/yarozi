#!/bin/bash
less "log/$(ls -ltr log | grep Thread | tr -s ' ' | cut -f9,10 -d' ' | tail -$([ -n "$1" ] && echo "$1" || echo "1") | head -n1 )"