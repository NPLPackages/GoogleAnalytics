--[[
title: google analytics client
author: chenqh
date: 2018/10/25
desc: a simple google analytics client for npl, support both website and mobile app

-------------------------------------------------------------------------------------------
useage:
-------------------------------------------------------------------------------------------

GoogleAnalytics = NPL.load("GoogleAnalytics")

UA = 'UA-127983943-1' -- your ua number

client = GoogleAnalytics:new():init(UA)

options = {
    location = 'www.keepwork.com/lesson',
    language = 'zh-CN',
    category = 'test',
    action = 'create',
    label = 'keepwork',
    value = 123
}

client:send_event(options)

options = {
    location = 'www.keepwork.com/lesson',
    title = 'keepwork',
    page = '/'
}

client:send_page(options)

options = {
    app_version = 'v1.0.0',
    title = 'keepwork',
    screen = 'home'
}

client:send_screen(options)

]]

local _M = commonlib.inherit(nil, NPL.export())

local table_concat = table.concat
local rand = math.random
local http_get = System.os.GetUrl

local GA_URL = 'www.google-analytics.com/r/collect'

local function encode_params(params)
    local arr = {}
    for k, v in pairs(params) do
        if v ~= nil then
            arr[#arr+1] = k .. '=' .. v
        end
    end
    return table_concat(arr, '&')
end

local function create_req_url(params)
    return tostring(GA_URL .. '?' .. encode_params(params))
end

function _M:ctor()
end

function _M:init(ua)
    self.ua = ua
    self.latest_updated = os.time()
    self:reset()

    return self
end

function _M:reset()
    self.client_id = rand(1000000000, 9999999999) .. '.' .. rand(1000000000, 9999999999)
end

function _M:update_clock()
    local now = os.time()
    -- client id will be changed if there's no new update in 30 mins
    if (now - self.latest_updated > 60 * 30) then
        self:reset()
    end
    self.latest_updated = now
end

function _M:new_params(options)
    -- https://www.cheatography.com/dmpg-tom/cheat-sheets/google-universal-analytics-url-collect-parameters/
    return {
        v = 1,
        cid = self.client_id, -- client id number
        tid = self.ua, -- tracking id (your ua number)
        a = rand(1000000000, 2147483647), -- a random number
        de = 'utf-8', -- document encode type
        t = options.type, -- the type of tracking call this (eg pageview, event)
        dl = options.location, -- the document location
        cd = options.screen, -- screen name, mainly used in app tracking
        dp = options.page, -- document path
        ul = options.language, -- language
        dt = options.title, -- document title
        ec = options.category, -- event category
        ea = options.action, --- event action
        el = options.label, -- event label
        ev = options.value, -- event value
        aid = options.app_id, -- Applic­ation ID
        aiid = options.app_installer_id, -- Applic­ation Installer ID
        an = options.app_name, -- Applic­ation Name
        av = options.app_version, -- Applic­ation Version
        uip = options.ip, -- user ip
        exd = options.exception, -- EXception Descri­ption
    }
end

function _M:send(options)
    local params = self:new_params(options)
    local tracking_url = create_req_url(params)
    print(tracking_url)
    return http_get({
        url = tracking_url,
        headers = {
            ['User-Agent'] = options.user_agent or 'npl analytics/1.0',
            ['Referer'] = options.location or ''
        }
    })
end

-- use for website
function _M:send_page(options)
    if (not options or not options.page) then return end
    options.type = 'pageview'

    self:send(options)
end

-- use for app
function _M:send_screen(options)
    if (not options or not options.screen or not options.app_version) then return end
    options.type = 'screenview'

    self:send(options)
end

function _M:send_event(options)
    if (not options or not options.category or not options.action) then return end
    options.type = 'event'

    self:send(options)
end
