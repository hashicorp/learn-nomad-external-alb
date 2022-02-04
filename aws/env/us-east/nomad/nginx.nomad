job "nginx" {
  datacenters = ["dc1"]

  group "nginx" {
    count = 1

    network {
      port "http" {
        static = 8080
      }
    }

    service {
      name = "nginx"
      port = "http"
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx"

        ports = ["http"]

        volumes = [
          "local:/etc/nginx/conf.d",
        ]
      }

      template {
        data = <<EOF
upstream backend {
{{ range service "demo-webapp" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}server 127.0.0.1:65535; # force a 502
{{ end }}
}

server {
   listen 8080;

   location / {
      proxy_pass http://backend;
   }
}
EOF

        destination   = "local/load-balancer.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
    }
  }
}
