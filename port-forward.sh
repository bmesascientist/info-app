#!/bin/bash

kubectl port-forward --address 0.0.0.0 service/prometheus-server-ext 9090:80 &
