#!/bin/sh

set -e

ansible-playbook -i 127.0.0.1 jenkins.yml
