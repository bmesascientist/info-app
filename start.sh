#!/bin/bash

chmod u+x server-setup.sh deploy-app.sh traefik-dashboard.sh

sudo ./server-setup.sh

sudo ./deploy-app.sh

. traefik-dashboard.sh
