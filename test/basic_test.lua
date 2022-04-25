local fio = require("fio")
local log = require("log")
local netbox = require("net.box")
local t = require("luatest")

local g = t.group("centrifuge")

local helpers = require("cartridge.test-helpers")

g.before_all(
    function()
        local tempdir = fio.tempdir()

        local cluster =
            helpers.Cluster:new(
            {
                datadir = tempdir,
                server_command = "init.lua",
                use_vshard = false,
                replicasets = {
                    {
                        roles = {"rotor"},
                        servers = {
                            {
                                alias = "storage1"
                            }
                        }
                    },
                    {
                        roles = {"rotor"},
                        servers = {
                            {
                                alias = "storage2"
                            },
                            {
                                alias = "storage2"
                            }
                        }
                    }
                }
            }
        )
        cluster:start()
        g.cluster = cluster
    end
)

g.after_all(
    function()
        g.cluster:stop()
    end
)

function g.test_centrifuge()
    local cluster = g.cluster
    local server = cluster:server("storage1")

    -- subscribe(id, channels)
    local rc, err = server.net_box:call("centrifuge.subscribe", {1, {"hellochannel"}})
    t.assert_equals(err, nil, err)

    local rc, err = server.net_box:call("centrifuge.subscribe", {1, {"hellochannelasdfasdf"}})
    t.assert_equals(err, nil, err)

    local rc, err = server.net_box:call("centrifuge.get_messages", {1, true, 1})
    t.assert_equals(err, nil, err)
    t.assert_equals(rc, nil)

    local offset, epoch, err =
        server.net_box:call(
        "centrifuge.publish",
        {"msgtype", "hellochannel", "Data for message 1", 10, 10, 10}
    )
    t.assert_equals(err, nil, err)
    t.assert_equals(offset, 1)
    t.assert_not_equals(epoch, "")

    local pubs, err = server.net_box:call("centrifuge.get_messages", {1, true, 1})
    t.assert_equals(err, nil, err)
    t.assert_equals(pubs[1][5], "Data for message 1")

    local offset, epoch2, err =
        server.net_box:call(
        "centrifuge.publish",
        {"msgtype", "hellochannel", "Data for message 2", 10, 10, 10}
    )
    t.assert_equals(err, nil, err)
    t.assert_equals(offset, 2)
    t.assert_equals(epoch, epoch2)

    local offset, epoch, pubs, err = server.net_box:call("centrifuge.history", {"hellochannel", 0, 10, false, true, 10})
    log.warn(offset)
    log.warn(epoch)
    log.warn(pubs)
    t.assert_equals(err, nil, err)
    t.assert_equals(offset, 2)
    t.assert_not_equals(epoch, nil)
    t.assert_not_equals(pubs, nil)
    t.assert_equals(pubs[1][1] < pubs[2][1], true)

    local offset, epoch, pubs, err = server.net_box:call("centrifuge.history", {"hellochannel", 0, 10, true, true, 10})
    log.warn(offset)
    log.warn(epoch)
    log.warn(pubs)
    t.assert_equals(err, nil, err)
    t.assert_equals(offset, 2)
    t.assert_not_equals(epoch, nil)
    t.assert_not_equals(pubs, nil)
    t.assert_equals(pubs[1][1] > pubs[2][1], true)

    local rc, err = server.net_box:call("centrifuge.remove_history", {"hellochannel"})
    t.assert_equals(rc, nil, rc)
    t.assert_equals(err, nil, err)

    local rc, err = server.net_box:call("centrifuge.unsubscribe", {1, {"hellochannel"}})
    t.assert_equals(err, nil, err)

    local rc, err = server.net_box:call("centrifuge.unsubscribe", {1, {"hellochannelasdfasdf"}})
    t.assert_equals(err, nil, err)

    local rc, err =
        server.net_box:call(
        "centrifuge.add_presence",
        {
            "hellochannel",
            160,
            "clientid",
            "userid",
            "data",
        }
    )
    t.assert_equals(err, nil, err)

    local rc, err = server.net_box:call("centrifuge.presence", {"hellochannel"})
    t.assert_equals(err, nil, err)
    t.assert_equals(rc[1][1], "hellochannel")
    t.assert_equals(rc[1][2], "clientid")
    t.assert_equals(rc[1][3], "userid")
    t.assert_equals(rc[1][4], "data")
    t.assert_equals(rc[1][5] > 0, true)

    local rc, err = server.net_box:call("centrifuge.remove_presence", {"hellochannel", "clientid"})
    t.assert_equals(rc, nil, rc)
    t.assert_equals(err, nil, err)

    local rc, err = server.net_box:call("centrifuge.presence", {"hellochannel"})
    t.assert_equals(err, nil, err)
    t.assert_equals(rc, {})
end
