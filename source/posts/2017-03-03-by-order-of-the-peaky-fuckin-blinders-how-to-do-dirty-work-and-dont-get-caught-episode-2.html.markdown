---
title: "\"By order of the Peaky fuckin' Blinders\" - how to do dirty work and don’t get caught - episode 2"
author: piotr
cover_photo: cover.png
tags: development, entrepreneurship
---

> "Intelligence is a very valuable thing, innit, my friend? And usually it comes far too fucking late."

_Alfie Solomons_

This time is different. Intelligence comes in the right time. In [the previous episode](/2017/02/14/by-order-of-the-peaky-fuckin-blinders-how-to-do-dirty-work-and-dont-get-caught-episode-1.html), we learned how is “our” API working. It is time to code the scraper that will use this API to get the data we want. Unfortunately, the API provider probably doesn't want us to get this data. He will ban us as soon as he will notice our unwelcome activities. Good news is that we will be smart from the beginning and prevent being noticed and banned :)

READMORE

What are the factors that can give us away?

* A lot of traffic from specific IP address
* A lot of traffic from countries where the app is not in use
* Invalid / inconsistent requests headers
* Increase in traffic load at specific time

Let’s solve them one by one.

## Use proxies to not increase traffic from one specific IP address
The IP address check is the easiest way to notice suspect traffic in API logs. IP ban is also the easiest way to avoid this kind of activities. You can avoid this situation in two ways:

* Write your scraper in master/slaves architecture
* Use external proxy providers to make API requests

In the first case, you need to write a few apps (slaves) that are sending requests to the API. The data from parsed responses is sent to one central app (master) which is responsible for data storage. Each slave has his own unique IP address which limits the number of requests made from one IP address.

In the second case, you have only one app that is responsible both for sending requests to the API and for the storage of parsed responses in our database. The app is configured to use a proxy. The app is sending a request to the proxy, the proxy in making this request to the API and then return the response to our app. If you choose good proxy it will use a wide range of IPs to make requests. So the number of requests made from one IP address is very limited.

We decided to use the second approach. It looks less time consuming, cheaper and giving better results.

It is less time consuming because you write a single app and configure it in a few lines of code to use proxy service. In another case, you have to write two apps (master and slave) and implement communication layer between them. You also have to setup up and maintain infrastructure for them.

The developer working time is one of the most important costs. If he will spend significantly less time on development, than the cost also will be smaller. Even if we have to pay for an external proxy service. You can use this kind of services in a subscription model. You can get a solution for the monthly price of 1 or 2 developer working hours. In the case of master/slaves architecture, you will probably have to invest more money in the infrastructure (hosting and IP addresses).

In master/slaves architecture, the efficiency of the system depends on the number of slave apps. You can increase the number of slaves to reduce the amount of request made from single IP address. With a few slaves, the number of request from one IP address can still be quite significant and can be noticed by APIs admin and banned. Every ban has to be discovered and solved by our own.

If you use proxy service provider he will provide you dozens, hundreds or even thousands of IP address that will be randomly (or as they usually say: by smart algorithms) assigned to your requests. None of them will make a significant amount of requests so they should be not banned. But even if some IPs are banned for some reason you still have a lot of other to use and you don’t have to take any action. Most of the providers recognize bans on themselves. They retry banned request on another IP address and blacklist the IP to not be used for your request in the future. The cool thing is that the developer and the product owner don’t have to even know about it. From outside perspective, it just works.

### Crawlera
In this article, we will use proxy service called Crawlera. Which I prefer, because it offers good quality and all required options by reasonable price. By required options I mean:
* Large monthly limit of request (150k in the cheapest plan, millions in other plans)
* Wide range of IP addresses
* Concurrent requests
* Customization of user agent
* You can limit IP address you want to use to selected countries
* Sessions support (you can pass many related requests via the same IP address)

To make a request via Crawlera you just have to use it as a proxy and provide your API KEY. With curl it will look like this:

```
   curl -U API_KEY -x proxy.crawlera.com:8010 http://blog.ragnarson.com
```


It works the same in the app code. You just have to specify a proxy for your request.

We have a rails app that uses Typhoeus gem to make HTTP requests to the API. To make a standard GET request you have to call:

```
Typhoeus.get(“http://blog.ragnarson.com")
```

To use Crawlera you have to also specify proxy and proxyuserpwd options:

```
Typhoeus.get(“http://blog.ragnarson.com", { proxy: ‘proxy.crawlera.com:8010’, proxyuserpwd: ‘API_KEY’ })
```

You can specify proxy options globally (for example in an initializer) by setting:

```
Typhoeus::Config.proxy = ‘proxy.crawlera.com:8010’
```

Unfortunately, we can not do the same with proxyuserpwd. It has to be added to each request.

### Be country specific if necessary
If we want to scrape API that is in use by an app that works only on specific markets (countries). In that cases, you should use only IP addresses from those countries. You should consider it during research which proxy provider you would like to use.
In Crawlera you can specify countries list during the app creation in its web interface.

## Use proper headers
In the previous episode, you get to know how APIs request should look like. Which headers should be attached to them. It is time to use this knowledge.

Again your requests should not look like send from one device. You should store at least a few user agent headers and pick one of them for each request. If the API requires also a header with API key or sth like that you also should use at least a few of them. The best option is to pair them with user agent header. As a result, you will always use the same user agent header with the same API key. It looks normal, not suspicious.

It is a good practice to change the user header and api_key from time to time. Especially when a new version of the API's app is released. It is a good time to use the tools from the previous episode and see what has been changed.

If you use Crawlera you should use X-Crawlera-UA header. It allows you set the user agent:
* The one you set in the header
* Random mobile user agent
* Random desktop user agent

[See more in their docs](https://doc.scrapinghub.com/crawlera.html#x-crawlera-ua)

## Use the same IP address for requests connected with each other.
If requests are related to each other, for example, one has to be done before the second, you should send them with the same IP address (and headers). We have many cases like this. For example, you need to get a token that allows you to perform any API action. Or you need to get search results to be able to see any search details.

With Crawlera we just can to use their sessions feature. To start a new session you just have to send a `POST` request to `proxy.crawlera.com:8010/sessions`. As a response you will receive a session id, that has to be attached to request headers:

```
X-Crawlera-Session: SESSION_ID
```

All requests with the same `SESSION_ID` will be sent from the same IP address.
You can read more about [crawlers sessions in their docs](https://doc.scrapinghub.com/crawlera.html#sessions)

## Divide your work and schedule it in a smart way
Another risk factor is that the API provider will notice in the log a huge traffic every single night at 2.a.m. Because you decided it will be better to schedule background job as usually in the night. When there is no traffic and we have free resources that can be used to process the background jobs. So you scrape entire data from the API at 2 a.m. Wrong! It is not a smart move.

You should divide your task into as small chunks as possible. It depends on the API you scrape and your business needs and can be sometimes hard. But let’s take a quite popular case. We use the API that allows to search for something in the cities. You pass a keyword and city to receive a list of something match to the keyword in the city. To handle it well you should create a search model with keyword, city and next scraping time. Each record is scheduled for background job. As soon as it is scraped it schedule next scraping time. It will be a random time tomorrow. You can limit the time range to the hours while the biggest traffic in the API’s app.

## What’s more?
I have no idea. If you have some tips for dirty scraping work, please leave them in the comments below.
