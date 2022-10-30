#!/usr/bin/env bash

_cp() {
  (set -x ; cp -p $*)
}

_cp reverse-cookie.sh /usr/local/bin
