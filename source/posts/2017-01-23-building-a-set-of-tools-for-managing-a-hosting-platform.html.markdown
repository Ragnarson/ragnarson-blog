---
title: Building a set of tools for managing a hosting platform
author: smefju
cover_photo: cover.png
tags: development
---

At Ragnarson we have unique experience in building Platform as a Service infrastructures for applications. For more than one year, I have worked on a private solution for a big player from Asia. We made a platform using several tools and services. Here is the list of some of them:

 * Workflow (previously Deis) for managing applications,
 * Amazon Web Services as instances provider and file storage,
 * Kubernetes as the scheduler for Workflow,
 * PostgreSQL, Redis and ElasticSearch for storing and caching data,
 * Cloudflare as a DNS provider,
 * Chef to make an infrastructure configuration repeatable and testable,
 * DataDog for metrics,
 * Kibana and Logstash as a logs aggregator,
 * Jabber for exchanging messages

READMORE

The project has a few very specific requirements:

 * It has to be vendor-free. We started with Amazon Web Services, but it should be easy to migrate to another provider (all clusters or only some of them).
 * It needs to scale well to handle big traffic.
 * It needs to be easy to manage multiple clusters in different regions.
 * We had to bootstrap fast and grow together with applications.
 * There are different teams that builds applications in each region. They have to be able to read only their data (including a single, shared staging cluster)

As the result, we’ve decided to have Workflow (previously Deis) running alone on some instances and other services on separate servers. This way we could manage each part of infrastructure independently. For example upgrading all Deis-related components (including OS) doesn’t require touching database servers.

We had to face the non-obvious problem of management. It is hard when you have different information in different tools for multiple clusters especially, when you aim for a vendor-free infrastructure. For example when an instance gets a new IP address and you have to update its DNS record. It becomes even more complicated when people that develop applications do not have access to "internal" tools. Those are the cases with flushing HTTP cache or database backup that needs to be restored on another application.

At the very beginning we’ve decided to create a tool that will synchronize data from external services and allow to make interactions between them using a single abstraction. This is a point where the Admin Panel project was born. Its name is really obvious and says everything - a tool that is used mainly for administrators to handle the internals. Later it got another role: API for developers and for internal tools (Chef that uses API to generate configurations on servers).

In the article, I will make an overview of the main features of the application to show you that sometimes there is a better tool than custom scripts combined with command line interfaces.

# Data synchronization

The main - and the most useful - role is presenting information about the current state of the Platform. It requires data synchronization from different sources with building relations between them. For example an instance and its DNS records or an application and its database with backups. The Admin Panel performs that process periodically using a background worker and automatically on changing the state from the web interface (for example after updating a DNS record). It ensures that all information are up-to-date.

The first service that provides important data is Deis. It is responsible for running applications. We synchronize application's metadata, domains, limits, configuration and SSL certificates. Having all of them on a single view per application is helpful when developers ask for assistance.

Another tool is Amazon Web Services that is used as instances provider at the moment. Under the hood, there are servers not only for Deis itself, but also for databases, Chef server, monitoring, etc. At this point, it stores information about instances, their maintenance events and load balancers. You can easily recognize which server of PostgreSQL replica set is a master or which instance does not have a DNS record yet.

The Platform uses Cloudflare as a DNS provider. The Admin Panel synchronizes all records. It also builds relations between records and instances.

# Solving "in our use case"

The Admin Panel helps us to solve things that are specific to our use case. For example in the past, we had an incident when Amazon Web Service restarted one of our instance due to the maintenance event. We were not aware about this, because an email has been sent to a person from management team and not to the people that took care about the servers. We decided to add a monitoring that will send us an alert when an instance have a maintenance event added. This way we can take an action immediately.

Another thing is with Deis and the way it manages SSL certificates. When one administrator creates a certificate, no one else can read it using the command line interface. This is a problem for us, because we need to be able to manage it even if someone will take a few days off. We have solved the problem by moving certificates under a single user that is used by the Admin Panel. This way we have a view with all certificates and their expiry date.

# Monitoring

A complex hosting requires a well designed and adjustable monitoring system. We are using several tools here. One of them is monit service running on the separate server. It covers applications statuses, certificates expiry date, internal web tools statuses, etc. The configuration is generated by Chef (that is running periodically!) which takes data from the Admin Panel. This way, an administrator is able to make very basic things without messing with Chef's data bags. For example it is possible to enable or disable monitoring for an application with a single click. It also exposes all certificates to make sure that they don’t have to be renewed.

There are multiple, independent regions and for each production environment, an administrator sets another cluster that performs additional monitoring. This way we check availability not only from the cluster itself, but also from the outside.

# Complex DNS interactions

Sometimes, an administrator needs to perform complicated procedures and it would not be so easy without the Admin Panel. Relations between records and instances allow us to avoid switching between two dashboards or command line interfaces just to make an update of the data.

For example in the past, we made Deis upgrades by creating a new cluster and switching DNS records at the end. It allows to make a hot rollback in case of any issues in the production. Every cluster has its own load balancer on the Amazon Web Services side. The switch is performed by taking instances IP addresses associated with a given load balancer and recreating DNS records.

Another common situation is a simple update to a DNS record for an instance when it has been replaced (and its IP address had changed).

# Databases and their backups

Most of the backend applications require database to operate. Deis does not provide any way to make management easy for the developer. You need to provide a `DATABASE_URL` in configuration but database setup is on your side. We didn't want to open PostgreSQL servers for developers so we decided to automate the procedure using the Admin Panel. Every cluster has its own replica set and it is possible to build database url using DNS records. The only problem is that we didn’t want to interact with a database server directly from a Deis application (the Admin Panel). It could result in potential problems with security and stability (for example disk space).

We made a web application that manages databases and backups and it is running on the separate server. The Admin Panel communicates with this API using HTTP requests. Almost all actions are asynchronous with a callback-based communication (each process might be very time consuming). As the result the Admin Panel can create a new database and manage its backups. When database is created for a given application, it updates the configuration to set a proper `DATABASE_URL`.

The interesting approach is that the Admin Panel stores only the metadata of each backup. It does not know how to download it or how to decrypt a file from storage. Those sensitive data and procedures are stored on the Databases API side. It makes it easy to replace the storage or clone the backup object to another database on the Admin Panel side (to make it available for another application).

We made a Plugin for Deis command line tool to bring the whole feature to developers. They are connecting to the Admin Panel's API using their Deis token. The Admin Panel authenticates them in Deis controller and performs a proper action. The only cases when a user connects to the Databases API directly, is when backup needs to be uploaded or downloaded. In such situation the Admin Panel negotiates a time-limited token for a given resource and sends it back to developer. Token has to be used by a user to make a request to the Databases API. When download is requested, the file will be decrypted and unpacked on the fly on the Databases API side.

# Keep it in the limit

Deis allows to set resource limits for a given application. It is very useful on clusters where there are multiple applications because of the stability requirement. We have put that functionality to the Admin Panel and made it responsible for ensuring that limits are up-to-date. An administrator can create a set of limits for a given cluster and application type.

# Recurring tasks

The Admin Panel is also responsible for running periodic tasks. One of the most important one are databases backups. All database systems on the Platform are redundant (using replication with failover), but regular backups make your sleep better. The Admin Panel performs that action early in the morning in every region (using region’s local time). It also takes care about the rotation so a storage will not run out of disk space because of old dump files.

Other tasks include keeping applications limits up-to-date, monitoring if there are no “in-progress” actions for databases and if there are no long running jobs in the queue. The last one is to make sure that a background worker from the Admin Panel didn't get stuck on something.

# Summary

This was only a part of the system that we made to make our daily work easier. We believe that building tools that automates tasks is much more efficient in a long-term view. We started with the first version of Deis that used CoreOS. Now it uses Kubernetes under the hood and some of the tasks can be achieved in different ways. The Admin Panel is still a powerful tool for us. It allows the team to focus on solving problems instead of switching between management tools to perform simple tasks.
