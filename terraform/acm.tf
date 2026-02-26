###########################
# AWS Certificate Manager
###########################
# Generate Private Key for WikiJS
resource "tls_private_key" "wikijs_lb_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create Self-Signed Certificate
resource "tls_self_signed_cert" "wikijs_lb_cert" {
  private_key_pem = tls_private_key.wikijs_lb_key.private_key_pem

  subject {
    common_name  = "wikijs.internal"
    organization = "Internal Infrastructure"
  }

  validity_period_hours = 87600 # 10 years

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# Import to ACM with a clear reference
resource "aws_acm_certificate" "wikijs_alb_cert" {
  private_key      = tls_private_key.wikijs_lb_key.private_key_pem
  certificate_body = tls_self_signed_cert.wikijs_lb_cert.cert_pem

  tags = {
    Name = "wikijs-self-signed-cert"
  }
}
