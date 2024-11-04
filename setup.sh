#!/bin/bash

chmod u+x server-setup.sh deploy-app.sh traefik-dashboard.sh prometheus.sh

sudo ./server-setup.sh

sudo ./deploy-app.sh

. prometheus.sh

./traefik-dashboard.sh
