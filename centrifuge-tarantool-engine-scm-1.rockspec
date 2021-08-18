package = "centrifuge-tarantool-engine"
version = "scm-1"
source = {
   url = "https://github.com/centrifugal/tarantool-engine"
}
description = {
   summary = "Centrifugal Tarantool Engine for Tarantool Cartridge",
   detailed = "Integration of Centrifugo stack with [Tarantool](https://www.tarantool.io/en/) database/platform. The integration provides efficient PUB/SUB, ephemeral history streams and channel presence functionality.",
   license = "MIT"
}

dependencies = {
   'tarantool',
   'cartridge == 2.6.0'
}

build = {
   type = "builtin",
   modules = {
      app = "app.lua",
      init = "init.lua"
   }
}
