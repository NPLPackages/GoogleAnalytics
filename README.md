# Google Analytics
A simple google analytics client for npl. only support event type for now.


## useage


``` lua
-- load mod
GoogleAnalytics = NPL.load("GoogleAnalytics")

-- define parameters

-- ua number from google
-- this is the only one that's mandatory
UA = 'UA-127983943-1'
-- a account that represent a user, such as keepwork username or etc
-- default: 'anonymous'
user_id = 'dreamanddead'
-- an id that marks a client, such as an uuid of a machine with paracraft installed
-- default: a rand number
client_id = '215150-24a97f-23'
-- which app that is running. paracraft, haqi, haqi2 or etc
-- default: 'npl analytics'
app_name = 'paracraft'
-- which version of current app. 0.7.14, 0.7.0, or etc
-- default: '0.0'
app_version = '0.7.14'
-- how many api requests per second you limit
-- default: 2
api_rate = 4

-- init ga client
gaClient = GoogleAnalytics:new():init(UA, user_id, client_id, app_name, app_version, api_rate)

-------------------------------------------------------------------------------------------
-- Send Event
-------------------------------------------------------------------------------------------

-- category key and action key are mandatory
-- ATTENTION options.value should be number type. it'll be converted to number if it's not.
-- you'd better follow the 'number type' rule because the parameter converted is possibly not what you want.
options = {
  category = 'block',
  action = 'create',
  label = 'paracraft',
  value = 62, -- a block id
}

gaClient:SendEvent(options)

-------------------------------------------------------------------------------------------
-- Session control
-------------------------------------------------------------------------------------------

-- force starting a new session
gaClient:StartSession()
-- force ending the current session
gaClient:EndSession()

```

