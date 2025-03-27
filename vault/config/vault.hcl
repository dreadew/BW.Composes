storage "consul" {
  address = "http://consul:8500"
  path    = "vault/"
}

listener "tcp" {
  address       = "0.0.0.0:8525"
  tls_disable   = 1  # Отключаем TLS (для тестов, в продакшене нужен HTTPS)
}

api_addr = "http://0.0.0.0:8525"
ui       = true
