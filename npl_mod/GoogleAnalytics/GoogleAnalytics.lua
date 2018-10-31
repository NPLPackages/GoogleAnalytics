--[[
	title: google analytics client
	author: chenqh
	date: 2018/10/25
	desc: a simple google analytics client for npl, support both website and mobile app.
	only support event type for now.

	-------------------------------------------------------------------------------------------
	useage:
	-------------------------------------------------------------------------------------------

	GoogleAnalytics = NPL.load("GoogleAnalytics")

	UA = 'UA-127983943-1' -- your ua number

	client = GoogleAnalytics:new():init(UA, uid, cid)

	options = {
	category = 'test',
	action = 'create',
	label = 'keepwork',
	value = 123
	}

	client:SendEvent(options)
]]

local GoogleAnalytics = commonlib.inherit(nil, NPL.export())

local table_concat = table.concat
local rand = math.random
local http_post = System.os.GetUrl

local GA_URL = 'https://www.google-analytics.com/collect'
-- debug api address
-- local GA_URL = 'https://www.google-analytics.com/debug/collect'
local GA_BATCH_URL = 'https://www.google-analytics.com/batch'


function GoogleAnalytics:ctor()
end

function GoogleAnalytics:init(ua, user_id, client_id)
	if not ua then
		LOG.std(nil, "error", "GoogleAnalytics->Init", "ua parameter is a must");
	end

	self.ua = ua
	self.user_id = user_id or 'anonymous'
	self.client_id = client_id or (rand(1000000000, 9999999999) .. '.' .. rand(1000000000, 9999999999))

	return self
end

function GoogleAnalytics:MergeOptions(options)
	-- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters
	-- there're too many parameters to use. we will extend it later.
	return {


		v = options.version or 1, -- ga api version
		tid = self.ua, -- tracking id (your ua number)
		uid = self.user_id, -- User ID, e.g. a login user name
		cid = self.client_id, -- client id number, e.g. the device UUID number
		z = options.z or rand(1000000000, 2147483647), -- a random number to avoid http cache

		-- the type of tracking.
		-- event, transaction, pageview, screenview,
		-- item, social, exception, timing
		t = options.type,
		ec = options.category, -- event category
		ea = options.action, --- event action
		el = options.label, -- event label
		ev = options.value, -- event value

		sc = options.session_control, -- session control, 'start' or 'end'
		aip = options.anonymous_ip,  -- don't track my ip
		uip = options.user_ip, -- user machine ip address
		geoid = options.geo_id, -- geo id, e.g. US

		ds = options.data_source, -- data source, like 'web', 'app' or others
		ua = options.user_agent, -- browser user agent
		an = options.app_name, -- Application Name
		aid = options.app_id, -- Application ID
		av = options.app_version, -- Application Version
		aiid = options.app_installer_id, -- Application Installer ID
	}
end

function GoogleAnalytics:_HttpPost(url, payload, headers)
	return http_post(
		{
			url = url,
			headers = {
				['User-Agent'] = headers.user_agent or 'npl analytics/1.0',
				['Content-Type'] = 'application/x-www-form-urlencoded',
			},
			postfields = payload,
		},
		function (err, msg, data)
		end
	)
end

function GoogleAnalytics:_Collect(options)
	local merged_options = self:MergeOptions(options)
	local payload = self:GetPayload(merged_options)
	local url = GA_URL

	LOG.std(nil, "debug", "GoogleAnalytics->collect", payload)
	return self:_HttpPost(url, payload, {user_agent=options.user_agent})
end

function GoogleAnalytics:_Batch(batch_options)
	-- FIXME
	-- I did everything the guide told me,
	-- https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide
	-- but it doesn't work. I can't figure out why.
	LOG.std(nil, "error", "GoogleAnalytics->_Batch", "This api is not accomplished.");

	local url = GA_BATCH_URL
	-- TODO most 20 options can be sent once
	local batch_merged_options = {}
	for i, o in pairs(batch_options) do
		batch_merged_options[#batch_merged_options+1] = self:MergeOptions(o)
	end

	local payloads = {}
	for i, o in pairs(batch_merged_options) do
		payloads[#payloads+1] = self:GetPayload(o)
	end

	local payload = table_concat(payloads, '\n')

	LOG.std(nil, "debug", "GoogleAnalytics->batch", payload)
	return self:_HttpPost(url, payload, {user_agent=batch_options[1].user_agent})
end


-- https://github.com/stuartpb/tvtropes-lua/blob/master/urlencode.lua
local function encode(str)
	--Ensure all newlines are in CRLF form
	str = string.gsub (str, "\r?\n", "\r\n")

	--Percent-encode all non-unreserved characters
	--as per RFC 3986, Section 2.3
	--(except for space, which gets plus-encoded)
	str = string.gsub (str, "([^%w%-%.%_%~ ])",
					   function (c) return string.format ("%%%02X", string.byte(c)) end)

	--Convert spaces to plus signs
	str = string.gsub (str, " ", "+")

	return str
end

local function urlencode(options)
	local arr = {}
	for k, v in pairs(options) do
		if v ~= nil then
			arr[#arr+1] = encode(k) .. '=' .. encode(v)
		end
	end
	return table_concat(arr, '&')
end

function GoogleAnalytics:GetPayload(options)
	-- transform options from dict to x-www-url-encode form
	return urlencode(options)
end


function GoogleAnalytics:_CheckEvent(event)
	if next(event) == nil then
		return false
	end
	if (not event.category or not event.action) then
		return false
	end
	return true
end

function GoogleAnalytics:SendEvent(event)
	if not self:_CheckEvent(event) then
		LOG.std(nil, "error", "GoogleAnalytics->SendEvent, event object is illegal: ", event)
		return
	end
	event.type = 'event'

	self:_Collect(event)
end

function GoogleAnalytics:SendEvents(events)
	if next(events) == nil then
		return
	end
	for i, e in pairs(events) do
		if not self:_CheckEvent(e) then
			LOG.std(nil, "error", "GoogleAnalytics->SendEvents, event object is illegal: ", e)
			return
		end
	end
	-- self:_Batch(events)
end
