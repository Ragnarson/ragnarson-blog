---
title: "\"by order of the peaky fuckin' blinders\" - how to do dirty work and don’t get caught - episode 1"
author: piotr
cover_photo: cover.png
---

> “Everyone's a whore, Grace. We just sell different parts of ourselves”

_Thomas Shelby_

Life is not always nice, simple and easy. Sometimes is more complex. Sometimes you are its lawful citizen. Sometimes you break the rules and do some dirty, shady things. Sometimes you are a copper. Sometimes you are a scoundrel. One day you are writing an API and taking care of its protection. Another day you are receiving the task to use someone else API without permission. It is not a thing you should do, but in startups game sometimes you have to do whatever it takes.  It is possible to do that if the API is protected by basic auth. I will help you to do it right and won’t be caught.

READMORE

## Draw the map to the princes' bedroom
> "Do you have a map? Because I'm not going to be able to find my way in the dark. You see, at midnight, I'm going to leave my wing and I'm going to come find you. And I'm going to turn the handle of your bedroom door without making a sound and none of the maids will know."

_Thomas Shelby_

Every single day hundreds or even thousands of new mobile apps are released. The majority of them are using APIs to get some data. Like information about events nearby or trains timetables. Let’s assume that we really need such data. And there is no free nor even paid sources of the data. But thank God, there is an app for that (that is using this data). Let use its API.

The first thing we have to do is to figure out how the API works. How requests and responses look like. To achieve this goal we have to see how the app is communicating with the API. The things will be required:

- To establish a proxy on our machine that will allow us to see communication between the app and the API
- To configure our iPhone to use this proxy

### Establish the proxy
There are many ready to use proxy solutions on the market. Like [Burp Suite](https://portswigger.net/burp/) or [mitmproxy](https://mitmproxy.org/). We will use the second one because it works from a console. It will make this article to look more geeky and professional.

Mitmproxy is written in Python, so we will install it via Python’s package manager PIP:

```
pip install mitmproxy
```

If you don’t have Python installed on your machine you can [download it from here](https://www.python.org/downloads/). It doesn’t matter if you install Python-2.7 or Python-3.5. Just pick one of them.

If you need more info or you have any problems during mitmproxy installation then, please follow the [installation guide](http://docs.mitmproxy.org/en/stable/install.html).

After installation, you can call mitmproxy from the console
```
mitmproxy
```
As you can see in the left bottom corner the proxy is available at port 8080. Now it is time to…

### Configure your iPhone to use our proxy
Let’s start with the Captain Obvious: connect your iPhone to the same wi-fi network as your computer.

The second thing is to check your computer's internal network IP. You can find it in your network preferences.
![MacOS network preferences](2017-02-14-by-order-of-the-peaky-fuckin-blinders-how-to-do-dirty-work-and-dont-get-caught-episode-1/network.png)


Now you have to set up your iPhone to use this proxy. Go to `Settings -> Wi-Fi` then go to `current network details`. And the bottom there are `proxy settings`. Click the manual tab and provide proxy server IP you got in the previous step and its port which is 8080.

And it works! Now you can go to the iPhone browser and visit any page. Then you will see the request in mitmproxy. Use arrows to navigate on requests list. Press enter to see the request details. Press q to go back to the list.

![Mitmproxy in action](2017-02-14-by-order-of-the-peaky-fuckin-blinders-how-to-do-dirty-work-and-dont-get-caught-episode-1/mitmproxy.png)

### The SSL traffic
You can see some cases when the proxy it not working. Some websites or apps are not working. The data is not loaded for them and you can’t see their request in proxy logs.

The reason is simple. The SSL clients don’t trust our proxy. To solve that issue we have to install mitmproxy CA certificates on the phone. To do this open web browser in your iPhone and visit special mitmproxy page: [http://mitm.it](http://mitm.it). Then click the icon of your platform, you will be asked to confirm certificate installation. And it is done. Now all https traffic is working and you can see it on the proxy.

## What we can see here
It is time to use the app that is using the API that we are interested in. Make some requests and see their details in mitmproxy.

The most important parts are:

 - Which URLs are requested for each action
 - How does each request look like?
 - which HTTP method is in use
 - how the params look like
 - how the body looks like
 - which headers are sent with the request? What are their values? You would like to send the same headers with your requests. Special interesting will be headers with API key or user ID. If you find them and the API use only basic authentication you are at home. You can save them and use in your future requests. If API is protected with a more sophisticated protocol like OAuth then I’m not able to help you. Find another API or article :)

You can also see how the response looks like. Which format is in use? How is data organized? Etc. This knowledge will be useful to write good parsers on your site.

Now we have all required info: how the requests should look like? Which headers are sent?
You are ready to write your own scraper of this API. In the next episode, we will talk about things you need to focus on to do it right and won’t be caught.
