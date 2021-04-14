#!/usr/bin/env tarantool

local log = require('log')


--[[
    Set current dir as a starting
    path for module loading.
--]]
package.setsearchroot()

local cartridge = require('cartridge')
local argparse = require('cartridge.argparse')
local membership = require('membership')

--[[
    Configure and run Cartridge on node.
]]
local _, err = cartridge.cfg({
        workdir = 'one', -- default

        roles = {
            'centrifuge',
        },
})
if err ~= nil then
    log.info(err)
    os.exit(1)
end

local opts, err = argparse.get_opts({
        bootstrap = 'boolean'})

if err ~= nil then
    log.error('%s', tostring(err))
    os.exit(1)
end

if opts.bootstrap then
    log.info('Bootstrapping in %s', workdir)
    require("membership.options").ACK_TIMEOUT_SECONDS = 0.5
    local all = {
        ['centrifuge'] = true,
    }

    local _, err = cartridge.admin_join_server({
            uri = membership.myself().uri,
            roles = all,
    })

    if err ~= nil then
        log.warn('%s', tostring(err))
    end
end
