job "demo-webapp" {
  datacenters = ["dc1"]

  # Run only on nodes with "targeted" in the 
  # instance metadata name
  // constraint {
  //   attribute = "${meta.node-name}"
  //   operator = "regexp"
  //   value = "targeted"
  // }

  constraint {
    distinct_hosts = true
  }

  group "demo" {
    count = 5
    network {
      port "http" {
        to = -1
      }
    }

    service {
      name = "demo-webapp"
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
