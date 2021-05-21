#!/usr/bin/env tarantool

-- configure path so that you can run application
-- from outside the root directory
if package.setsearchroot ~= nil then
    package.setsearchroot()
else
    -- Workaround for rocks loading in tarantool 1.10
    -- It can be removed in tarantool > 2.2
    -- By default, when you do require('mymodule'), tarantool looks into
    -- the current working directory and whatever is specified in
    -- package.path and package.cpath. If you run your app while in the
    -- root directory of that app, everything goes fine, but if you try to
    -- start your app with "tarantool myapp/init.lua", it will fail to load
    -- its modules, and modules from myapp/.rocks.
    local fio = require("fio")
    local app_dir = fio.abspath(fio.dirname(arg[0]))
    package.path = app_dir .. "/?.lua;" .. package.path
    package.path = app_dir .. "/?/init.lua;" .. package.path
    package.path = app_dir .. "/.rocks/share/tarantool/?.lua;" .. package.path
    package.path = app_dir .. "/.rocks/share/tarantool/?/init.lua;" .. package.path
    package.cpath = app_dir .. "/?.so;" .. package.cpath
    package.cpath = app_dir .. "/?.dylib;" .. package.cpath
    package.cpath = app_dir .. "/.rocks/lib/tarantool/?.so;" .. package.cpath
    package.cpath = app_dir .. "/.rocks/lib/tarantool/?.dylib;" .. package.cpath
end

local log = require("log")
local cartridge = require("cartridge")
local argparse = require("cartridge.argparse")
local membership = require("membership")

-- Configure and run Cartridge on node.
local _, err =
    cartridge.cfg(
    {
        workdir = "tmp/",
        roles = {
            "centrifuge"
        }
    }
)
if err ~= nil then
    log.info(err)
    os.exit(1)
end

local opts, err =
    argparse.get_opts(
    {
        bootstrap = "boolean"
    }
)

if err ~= nil then
    log.error("%s", tostring(err))
    os.exit(1)
end

if opts.bootstrap then
    log.info("Bootstrapping in %s", workdir)
    require("membership.options").ACK_TIMEOUT_SECONDS = 0.5
    local all = {
        ["centrifuge"] = true
    }

    local _, err =
        cartridge.admin_join_server(
        {
            uri = membership.myself().uri,
            roles = all
        }
    )

    if err ~= nil then
        log.warn("%s", tostring(err))
    end
end
