# Google Analytics
A simple google analytics client for npl

## useage

``` lua
GoogleAnalytics = NPL.load("GoogleAnalytics")

UA = 'UA-127983943-1' -- your ua number
user_id = 123

client = GoogleAnalytics:new():init(UA, user_id)

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
```