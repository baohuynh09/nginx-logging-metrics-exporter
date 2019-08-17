#!/bin/bash

docker run --rm -d --name nginx-exporter \
	   -p 4040:4040 \
	   -v /var/log/nginx:/var/log/nginx \
	   -v /root/nginx_exporter/config.yml:/etc/prometheus-nginxlog-exporter.yml \
	   quay.io/martinhelmich/prometheus-nginxlog-exporter:v1.3.0 \
	   -config-file /etc/prometheus-nginxlog-exporter.yml
