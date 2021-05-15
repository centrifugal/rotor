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
    local fio = require('fio')
    local app_dir = fio.abspath(fio.dirname(arg[0]))
    package.path = app_dir .. '/?.lua;' .. package.path
    package.path = app_dir .. '/?/init.lua;' .. package.path
    package.path = app_dir .. '/.rocks/share/tarantool/?.lua;' .. package.path
    package.path = app_dir .. '/.rocks/share/tarantool/?/init.lua;' .. package.path
    package.cpath = app_dir .. '/?.so;' .. package.cpath
    package.cpath = app_dir .. '/?.dylib;' .. package.cpath
    package.cpath = app_dir .. '/.rocks/lib/tarantool/?.so;' .. package.cpath
    package.cpath = app_dir .. '/.rocks/lib/tarantool/?.dylib;' .. package.cpath
end

require 'strict'.on()
local log = require('log')
fiber = require 'fiber'

local address = os.getenv("TARANTOOL_ADDRESS")
if address == nil then
    address = '0.0.0.0'
end

local port = os.getenv("TARANTOOL_PORT")
if port == nil then
    port = 3301
end

local workdir = os.getenv("TARANTOOL_WORKDIR")
if workdir == nil then
    workdir = "tmp/standalone_"..port
end

local fio = require('fio')
fio.mkdir(workdir)

box.cfg{
    listen = address..':'..port,
    wal_mode = 'none',
    wal_dir = workdir, -- though WAL used here by default, see above
    memtx_dir = workdir,
    readahead = 10 * 1024 * 1024, -- to keep up with benchmark load
    net_msg_max = 1024, -- to keep up with benchmark load
}
box.schema.user.grant('guest', 'super', nil, nil, { if_not_exists = true })

local centrifuge = require 'centrifuge'

centrifuge.init({is_master=true})

if not fiber.self().storage.console then
    require'console'.start()
    os.exit()
end
