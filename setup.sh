#!/bin/bash

chmod u+x scripts/*.sh

sudo ./scripts/server-setup.sh

sudo ./scripts/deploy-app.sh

. ./scripts/prometheus.sh

./scripts/traefik-dashboard.sh
