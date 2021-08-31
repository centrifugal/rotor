package = "rotor"
version = "scm-1"
source = {
   url = "https://github.com/centrifugal/rotor"
}
description = {
   summary = "Centrifugo/Centrifuge Tarantool Engine for Tarantool Cartridge",
   detailed = "Integration of Centrifugo stack with Tarantool database/platform. The integration provides efficient PUB/SUB, ephemeral history streams and channel presence functionality.",
   license = "MIT"
}

dependencies = {
   'tarantool',
   'cartridge == 2.7.1'
}

build = {
   type = "builtin",
   modules = {
      app = "app.lua",
      init = "init.lua"
   }
}
