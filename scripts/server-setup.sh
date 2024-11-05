#!/bin/bash

sudo apt update && sudo apt upgrade -y

sudo ufw disable

sudo apt install docker.io -y

sudo usermod -aG docker $USER

# newgrp docker
