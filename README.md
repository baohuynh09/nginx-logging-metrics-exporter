# NGINX-EXPORTER

+ Using /var/log/nginx/nginx_exporter.log for parsing => creates metrics from these log
+ These metrics then will be published at http://<ip_nginx>:4040/metrics
+ More details: https://github.com/martin-helmich/prometheus-nginxlog-exporter
+ Nginx Logging & monitoring: https://www.nginx.com/resources/admin-guide/logging-and-monitoring/

## HOW-TO-RUN
Step1: config for metrics exposure & log scrapping: config.yml

NOTE: format logs scrapping MUST be the SAME as format logs in nginx.conf
```bash
listen:
  port: 4040
  address: "0.0.0.0"

namespaces:
  - name: nginx
    format: "$remote_addr - $remote_user [$time_local] \"$request\" $status $body_bytes_sent \"$http_referer\" \"$http_user_agent\" \"$http_x_forwarded_for\" rt=$request_time uct=\"$upstream_connect_time\" uht=\"$upstream_header_time\" urt=\"$upstream_response_time\" us=\"$upstream_status\""
    source_files:
      - "/var/log/nginx/nginx_exporter.log"
```

Step2: enable logs format (nginx) in /etc/nginx/nginx.conf:
```bash
http {
   log_format  nginx_exporter '$remote_addr - $remote_user [$time_local] "$request" '
                         '$status $body_bytes_sent "$http_referer" '
                         '"$http_user_agent" "$http_x_forwarded_for" '
                         'rt=$request_time uct="$upstream_connect_time" uht="$upstream_header_time" urt="$upstream_response_time"';
   ..............
   ..............
   access_log /var/log/nginx/nginx_exporter.log nginx_exporter;
}
```


Step3: Run logs collector & export metrics:
```bash
docker run --rm -d --name nginx-exporter \
           -p 4040:4040 \
           -v /var/log/nginx:/var/log/nginx \
           -v /root/nginx_exporter/config.yml:/etc/prometheus-nginxlog-exporter.yml \
           quay.io/martinhelmich/prometheus-nginxlog-exporter:v1.3.0 \
           -config-file /etc/prometheus-nginxlog-exporter.yml
```


## FAQ
--------------------------------------------------
NOTE: if see below errors in nginx-exporter docker:
```bash
2019/08/17 06:10:35 Seeked /var/log/nginx/nginx_exporter.log - &{Offset:0 Whence:2}
```

=> Reason: 
+ Nginx process touch & hold /var/log/nginx_exporter.logs first. Then there's no permission for nginx-exporter to read it & create metrics.


=> Fix as below:
+ Start docker nginx-exporter first
+ Reload nginx (nginx -s reload) after then.
+ Tailf logs nginx-exporter. Below logs should be presented:
```bash
2019/08/17 13:42:06 Re-opening moved/deleted file /var/log/nginx/nginx_exporter.log ...
2019/08/17 13:42:06 Successfully reopened /var/log/nginx/nginx_exporter.log
```

