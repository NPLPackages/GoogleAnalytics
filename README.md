# Google Analytics
A simple google analytics client for npl. only support event type for now.


## useage

``` lua
GoogleAnalytics = NPL.load("GoogleAnalytics")

UA = 'UA-127983943-1' -- your ua number
user_id = 123
client_id = uuid

client = GoogleAnalytics:new():init(UA, user_id, client_id)

options = {
    category = 'test',
    action = 'create',
    label = 'keepwork',
    value = 123,
}

client:SendEvent(options)

```

