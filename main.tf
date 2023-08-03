provider "kubernetes" {
  config_path = "/home/tal/.kube/config"  # Path to your kubeconfig file
}

resource "kubernetes_namespace" "flask" {
  metadata {
    name = "flask"
  }
}

resource "kubernetes_deployment" "flask_deployment" {
  metadata {
    name = "flask-deployment"
    namespace = kubernetes_namespace.flask.metadata[0].name
    labels = {
      app = "flask-app"
    }
  }

  spec {
    replicas = 1  # Adjust the number of replicas as needed
    selector {
      match_labels = {
        app = "flask-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "flask-app"
        }
      }

      spec {
	host_network = true
        container {
          name  = "flask-container"
          image = "berko431/flask"
          port {
            container_port = 5000  # Replace with the port your Flask app listens on
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "flask_service" {
  metadata {
    name      = "flask-service"
    namespace = kubernetes_namespace.flask.metadata[0].name
  }

  spec {
    selector = {
      app = "flask-app"
    }

    # Use "NodePort" type for local clusters or "LoadBalancer" for cloud clusters
    type = "ClusterIP"

    # Replace with the port your Flask app listens on inside the container
    port {
      protocol = "TCP"
      port     = 5000 # Replace with the desired external port
      target_port = 5000  # Replace with the port your Flask app listens on inside the container
    }
  }
}


resource "kubernetes_deployment" "activemq_deployment" {
  metadata {
    name = "activemq-deployment"
    namespace = kubernetes_namespace.flask.metadata[0].name
    labels = {
      app = "activemq"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "activemq"
      }
    }

    template {
      metadata {
        labels = {
          app = "activemq"
        }
      }

      spec {
        container {
          name  = "activemq"
          image = "berko431/activemq"
          port {
            container_port = 61613
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "activemq_service" {
  metadata {
    name = "activemq-service"
    namespace = kubernetes_namespace.flask.metadata[0].name

  }

  spec {
    selector = {
      app = "activemq"
    }

    port {
      protocol    = "TCP"
      port        = 61613
      target_port = 61613
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_service" "activemq_service_external" {
  metadata {
    name = "activemq-service-external"
    namespace = kubernetes_namespace.flask.metadata[0].name
  }

  spec {
    selector = {
      app = "activemq"
    }

    port {
      name         = "activemq-port"
      protocol     = "TCP"
      port         = 8161
      target_port  = 8161
    }

    type = "LoadBalancer"
  }
}


resource "kubernetes_ingress_v1" "flask-ingress" {
   metadata {
      name        = "flask-ingress"
      namespace   = "flask"
   }
   spec {
      rule {
	host = "flask.local"
        http {
         path {
           path = "/"
           backend {
             service {
               name = "flask-service"
               port {
                 number = 5000
               }
             }
           }
        }
      }
    }
  }
}

