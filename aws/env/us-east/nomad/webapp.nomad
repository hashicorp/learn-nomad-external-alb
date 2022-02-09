job "demo-webapp" {
  datacenters = ["dc1","dc2"]

  group "dc1-demo" {
    constraint {
      attribute = "${node.datacenter}"
      operator  = "="
      value     = "dc1"
    }
    count = 3
    network {
      port "http" {
        to = -1
      }
    }

    service {
      name = "demo-webapp-dc1"
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
  group "dc2-demo" {
    constraint {
      attribute = "${node.datacenter}"
      operator  = "="
      value     = "dc2"
    }
    count = 2
    network {
      port "http" {
        to = -1
      }
    }

    service {
      name = "demo-webapp-dc2"
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
