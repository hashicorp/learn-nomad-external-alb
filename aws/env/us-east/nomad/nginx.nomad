job "nginx" {
  datacenters = ["dc1", "dc2"]

  group "nginx-dc1" {
    constraint {
      attribute = "${node.datacenter}"
      operator  = "="
      value     = "dc1"
    }
    count = 1

    network {
      port "http" {
        static = 8080
      }
    }

    service {
      name = "nginx-dc1"
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
{{ range service "demo-webapp-dc1" }}
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
  group "nginx-dc2" {
    constraint {
      attribute = "${node.datacenter}"
      operator  = "="
      value     = "dc2"
    }
    count = 1

    network {
      port "http" {
        static = 8080
      }
    }

    service {
      name = "nginx-dc2"
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
{{ range service "demo-webapp-dc2" }}
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
