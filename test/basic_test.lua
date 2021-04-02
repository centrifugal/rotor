local fio = require('fio')
local log = require('log')
local netbox = require('net.box')
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

function g.test_centrifuge()
    local cluster = g.cluster
    local server = cluster:server('storage1')

    local rc, err = server.net_box:call('centrifuge.add_presence', {'hellochannel', 160, 'clientid',
                                                                    'userid', 'info', 'chaninfo'})
    t.assert_equals(err, nil, err)

    local rc, err = server.net_box:call('centrifuge.presence', {'hellochannel'})
    t.assert_not_equals(rc, nil, err)
    t.assert_equals(err, nil, err)

    -- subscribe(id, channels)
    local rc, err = server.net_box:call('centrifuge.subscribe', {1, {'hellochannel'}})
    t.assert_equals(err, nil, err)

    local rc, err = server.net_box:call('centrifuge.subscribe', {1, {'hellochannelasdfasdf'}})
    t.assert_equals(err, nil, err)

    local rc, tm = t.assert_error(server.net_box.call, server.net_box, 'centrifuge.publish', {'msgtype', 'hellochannel', 'Data for message', 'some info', 10, 10, 10})

    local rc, err = server.net_box:call('centrifuge.get_messages', {1, true, 1})
    t.assert_equals(err, nil, err)

    local rc, tm = server.net_box:call('centrifuge.publish', {'msgtype', 'hellochannel', 'Data for message', 'some info', 10, 10, 10})
    t.assert_not_equals(rc, nil)
    t.assert_not_equals(tm, nil)

    local rc, err = server.net_box:call('centrifuge.get_messages', {1, true, 1})
    t.assert_not_equals(rc, nil, err)
    t.assert_equals(err, nil, err)


    local rc, tm = server.net_box:call('centrifuge.publish', {'msgtype', 'hellochannel', 'Data2 for message', 'some info', 10, 10, 10})
    t.assert_not_equals(rc, nil)
    t.assert_not_equals(tm, nil)

    local rc, tm = server.net_box:call('centrifuge.history', {'hellochannel', 0, 10, true, 10})
    t.assert_not_equals(rc, nil, rc)
    t.assert_not_equals(tm, nil, tm)

    local rc, err = server.net_box:call('centrifuge.history', {'hellochannel', 0, 10, true, 10})
    t.assert_not_equals(rc, nil, rc)
    t.assert_not_equals(tm, nil, tm)

    local rc, err = server.net_box:call('centrifuge.remove_history', {'hellochannel'})
    t.assert_equals(rc, nil, rc)
    t.assert_equals(err, nil, err)

    local rc, err = server.net_box:call('centrifuge.unsubscribe', {1, {'hellochannel'}})
    t.assert_equals(err, nil, err)

    local rc, err = server.net_box:call('centrifuge.unsubscribe', {1, {'hellochannelasdfasdf'}})
    t.assert_equals(err, nil, err)

    local rc, err = server.net_box:call('centrifuge.add_presence', {'hellochannel', 10, 'client id', 'user id', 'connection info', 'channel info'})
    t.assert_equals(rc, nil, rc)
    t.assert_equals(err, nil, err)

    local rc, err = server.net_box:call('centrifuge.presence', {'hellochannel'})
    t.assert_not_equals(rc, nil, rc)
    t.assert_equals(err, nil, err)

    local rc, err = server.net_box:call('centrifuge.remove_presence', {'hellochannel', 'client id'})
    t.assert_equals(rc, nil, rc)
    t.assert_equals(err, nil, err)
    
    -- history
    -- remove history
end
