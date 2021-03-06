local clock = require "clock"
local fiber = require "fiber"
local log = require "log"
local ffi = require "ffi"
local json = require "json".new()
local centrifuge = require "centrifuge"

--=======================================================================================
-- Rotor: Tarantool Engine for Centrifugo/Centrifuge based on Tarantool Cartridge.
-- Provides PUB/SUB broker, ephemeral history streams and channel presence functionality.
--=======================================================================================

local app = {}

app.init = function(opts)
    if not opts then
        opts = {}
    end
    if opts.is_master == true then
        centrifuge.init_spaces()
    end
    centrifuge.start()
    rawset(_G, "centrifuge", centrifuge)
end

function app.stop()
    centrifuge.stop()
    rawset(_G, "centrifuge", nil)
end

function app.validate_config(_, _) --(conf, old)
    return true
end

function app.apply_config(_, _) --(conf, opts)
    return true
end

app.role_name = "rotor"

return app
