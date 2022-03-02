job "demo-webapp" {
  datacenters = ["dc1","dc2"]

  group "api-demo" {
    constraint {
      attribute = "${meta.service-client}"
      operator  = "="
      value     = "api"
    }
    count = 3
    network {
      port "http" {
        to = -1
      }
    }

    service {
      name = "api-service"
      port = "http"

      check {
        type     = "http"
        path     = "/"
        interval = "2s"
        timeout  = "2s"
      }
    }

    task "server" {
      env {
        PORT    = "${NOMAD_PORT_http}"
        NODE_IP = "${NOMAD_IP_http}"
      }

      driver = "docker"

      config {
        image = "hashicorp/demo-webapp-lb-guide"
        ports = ["http"]
      }
    }
  }
  group "payments-demo" {
    constraint {
      attribute = "${meta.service-client}"
      operator  = "="
      value     = "payments"
    }
    count = 2
    network {
      port "http" {
        to = -1
      }
    }

    service {
      name = "payments-service"
      port = "http"

      check {
        type     = "http"
        path     = "/"
        interval = "2s"
        timeout  = "2s"
      }
    }

    task "server" {
      env {
        PORT    = "${NOMAD_PORT_http}"
        NODE_IP = "${NOMAD_IP_http}"
      }

      driver = "docker"

      config {
        image = "hashicorp/demo-webapp-lb-guide"
        ports = ["http"]
      }
    }
  }
}
