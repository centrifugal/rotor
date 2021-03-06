local fio = require('fio')
local log = require('log')
local t = require('luatest')

local g = t.group('centrifuge')

local helpers = require('cartridge.test-helpers')

g.before_all(function()
        local tempdir = fio.tempdir()

        local cluster = helpers.Cluster:new({
                datadir = tempdir,
                server_command = 'init_cartridge.lua',
                use_vshard = false,
                replicasets = {{
                        roles = {'centrifuge'},
                        servers = {{
                                alias = 'storage1',
                               }}},
                    {
                        roles = {'centrifuge'},
                        servers = {{
                                alias = 'storage2',
                                   },{
                                alias = 'storage2',
                    }}},
                },
        })
        cluster:start()
        g.cluster = cluster
end)

g.after_all(function()
        g.cluster:stop()
end)

function g.test_starwars_storage()
    local cluster = g.cluster
    local server = cluster:server('storage1')

    local rc, err = server.net_box:call('centrifuge.add_presence', {'hellochannel', 160, 'clientid',
                                                                    'userid', 'info', 'chaninfo'})

    t.assert_equals(err, nil, err)
    local rc, err = server.net_box:call('centrifuge.presence', {'hellochannel'})
    t.assert_equals(err, nil, err)
end
