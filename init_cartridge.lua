#!/usr/bin/env tarantool

local log = require('log')


--[[
    Устаналвиваем текущую директорию,
    как начальный путь загрузки всех модулей
--]]
package.setsearchroot()

local cartridge = require('cartridge')
local argparse = require('cartridge.argparse')
local membership = require('membership')

--[[
    Конфигурируем и запускаем cartridge на узле
    Указываем какие роли мы будем использовать в кластере
    Указываем рабочую директорию для хранения снапов, икслогов
    и конфигурации приложения `one`
]]
local _, err = cartridge.cfg({
        workdir = 'one', -- default

        roles = {
            --<<< Добавляем роль - указываем путь к модулю
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
