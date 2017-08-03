---
title: Life of an HTTP Request
author: michalkw
shelly: true
tags: development
---

When working on web applications we take a lot of supporting technology for
granted. We build our code on top of a multi-layered network stack with HTTP as
the glue. Each user interaction with our app may cause several HTTP requests
that are routed and handled separately, often in parallel. Most of the time
developers don't have to care how exactly this magic works. Sometimes though,
performance requirements force them to dig deeper. We at Shelly Cloud want to
empower our users, that's why we decided to share details of our internal
architecture.

Today we're going to describe what route an HTTP requests takes, from the moment
it leaves the browser up to the moment a response gets back from the server.

Second part of this article builds upon this knowledge and describes multiple
failure scenarios. READMORE

## From a browser to the application

**User clicks a link** or enters the URL directly into the browser's address
bar. Something like [https://shellycloud.com/](https://shellycloud.com/). After
that the browser **resolves the host name** (some browsers even do it before you
click). DNS request is made and it returns 46.4.70.228: IP of Shelly Cloud's
front end server.

Since the request goes over HTTPS, **front end server is contacted** on port
443. At Shelly Cloud this **traffic is handled by [Nginx](http://nginx.org/)**
which is also responsible for terminating SSL and SPDY. Behind it, the rest of
the stack talks pure HTTP.

After that a request is passed to [Varnish](https://www.varnish-cache.org/) to
handle **caching**. Each application on Shelly Cloud has a dedicated Varnish
process. If the requested document is already in the cache, it is immediately
returned, otherwise the request is passed further.

Next in the request chain is the **load balancer**. In Shelly Cloud we use
[HAProxy](http://haproxy.1wt.eu/) to load balance each application's traffic
over all of its available backends. HAProxy does periodic health checks and
automatically removes dead backends from the pool. The load balancing algorithm
first assigns requests to unoccupied backends. If none are immediately
available, round robin scheme is used to select a backend to use. Thin web
servers are assigned at most one connection, while pumas up to 16.

**Backend server**, be it thin or puma, upon receiving the request **invokes the
application** allowing it to handle it. In Ruby, [rack
interface](http://rack.github.io/) mediates between the application and the web
server. From the point of view of the application, those two interfaces matter
the most: rack as a programming interface and HTTP as the network interface.

After being processed, the request generates a **response that goes all the way
back**, via backend servers through load balancer and cache server back to the
front end that passes it to the client. Along the way, Varnish stores the
response if [the cache headers were properly set by the
application](https://shellycloud.com/documentation/caching#caching_on_front_end).

Just to recap, here's a short list of all the steps described above:

1. Browser resolves server's host name.
2. Browser sends the request to the server.
3. Nginx gets the request and terminates HTTPS/SPDY.
4. Varnish handles HTTP caching.
5. HAProxy load balances the traffic.
6. Web server (thin/puma) receives the request and passes control to application code.
7. Application prepares a response.
8. Response goes through web server through HAProxy, Varnish and Nginx back to the browser.

## Failure scenarios

Request-response cycle works as described above, but only when everything is
running smoothly. Unfortunately, failures are common and any robust architecture
should be prepared to handle them gracefully. Detailed failure scenarios are
listed below, but most of them boil down to avoiding a single point of
failure. In other words, redundancy is the key.

**Q: What happens if a process of the application server dies?**<br>
A: First, HAProxy health check will fail for this backend and it will be removed
from the pool, so no more traffic is routed there. Second, local monitoring will
restart the missing process. Once it is back up and ready to serve requests,
load balancer will detect that and put it back into the active pool.

**Q: What happens when all application servers are dead?**<br>
A: After marking all backends as unavailable, HAProxy will start to return
*503 Service Unavailable* error code to Nginx that will show maintenance page to
users. This may happen in a number of situations. When application code has a
fatal error (e.g. exception raised at loading time) none of the backends will
start after deployment. If only one backend has been configured in
[Cloudfile](https://shellycloud.com/documentation/cloudfile), any failure at the
process level will again trigger the problem. Similarly, if only one virtual
server is used, problem at OS or hardware level may also cause the same symptoms
until faulty server is replaced. With only a single virtual server this
situation may also be triggered during [restart phase of
deployment](https://shellycloud.com/blog/2013/06/how-code-is-deployed-on-shelly-cloud).

**Q: What happens in the case of a traffic spike, when there are more incoming
connections than available end points?**<br>
A: Connections will wait in a queue until backends can handle them. If a request
stays in queue longer than **2 minutes** it will be dropped. The client will get
*504 Gateway Timeout* HTTP error code.

**Q: What happens when application servers are being restarted during deployment?**<br>
A: When thin or puma is being restarted, it stops accepting new connections and
it exits once all active connections has been handled. All backends on a given
virtual server are restarted at once, so this may manifest the problem of all
application servers being down (see two questions above), but only if a single
virtual server is available. Even with more than one virtual server the symptoms
may be the same as for a traffic spike, because number of active backends is
temporarily lowered during deployment (see question above).

**Q: What happens when the application doesn't respond in time?**<br>
A: We have a hard **50 seconds** limit on backend reply, so if the application
doesn't respond in that time, front end server sends back *504 Gateway Timeout*
to the client.

**Q: What happens when a front end server on a shard fails?**<br>
A: In addition to all front end processes (Nginx, Varnish and HAProxy) being
monitored locally, in case of an OS or hardware failure we have a failover
mechanism through a floating IP that switches to a backup front end server. The
backup server is always on stand by and ready to immediately process
requests. Any active and incoming connections made between time of the failure
and failover switch will be lost.
