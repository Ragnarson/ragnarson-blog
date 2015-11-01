---
title: Be aware about the out-of-memory killer
author: smefju
---

One of the most important things for applications is stability. There are various hosting platforms that give you virtual servers, where you can run multiple services. There is no limit to the number of processes so it is up to you how much of their resources will be used. However, exceeding all available RAM memory can result in poor stability or even a server crash. This article gives you some basic knowledge about the *out-of-memory* system state.

*OOM* is a state where there is no memory available for the system. In such a situation, Kernel will invoke *oom-killer* to choose and sacrifice some processes, to free up the memory. It may force-kill your puma webservers, sidekiq workers or database.

<figure>
  ![New Reilc](2015-06-29-be-aware-about-the-out-of-memory-killer/newrelic.png)
</figure>

The server stopped reporting stats to NewRelic at around 11:41. Memory usage (RAM and SWAP) exceeded all server resources and *oom-killer* killed NewRelic daemon, and other processes, to free up the memory.

```bash
root@i-10-255-3-105[staging]:~# grep -i kill /var/log/syslog
Jun 17 11:41:37 i-10-255-3-105 kernel: [54493.290148] ruby invoked oom-killer: gfp_mask=0x201da, order=0, oom_score_adj=0
[...]
Jun 17 11:41:41 i-10-255-3-105 kernel: [54498.831237] Out of memory: Kill process 32236 (ruby) score 912 or sacrifice child
Jun 17 11:41:41 i-10-255-3-105 kernel: [54498.831894] Killed process 32236 (ruby) total-vm:209732kB, anon-rss:921340kB, file-rss:0kB
[...]
```

## OOM Score

There are various factors taken into consideration for calculating the priority for killing a given process. One of them is *oom score adjustment*. The user can adjust the priority by using a special file placed in [process information pseudo-filesystem][proc] called `/proc`

```bash
# set the highest priority
echo 1000 > /proc/[PID]/oom_score_adj

# set the lowest priority
echo -1000 > /proc/[PID]/oom_score_adj
```

The highest priority means that the particular process will always be marked for killing in the case of an *out-of-memory* state. However, the process with the lowest priority will only be killed if there are no other processes with a higher score. `oom_score_adj` can be used as one factor for calculating the `oom_score`, which is used by *oom-killer* as a final score.

Shelly Cloud sets the lowest priority for critical services such as sshd, monitoring or databases and the highest priority for application services.

## Monitoring

Monitoring is a key factor in such situations. If a process was killed by kernel there should be a service that will bring it back to action. Otherwise the server may become unresponsive and only a complete restart will help.

Each virtual server on Shelly Cloud has its own monitoring.

## Conclusion

You should always keep an eye on the available resources to avoid dangerous situations. We recommend [NewRelic][NewRelic] and their free plan for monitoring server resources. It allows you to set up an alert if RAM usage is too high. Graphs can help recognize if there is a memory leak, or if your application needs more resources.

[proc]:     http://man7.org/linux/man-pages/man5/proc.5.html
[newrelic]: https://shellycloud.com/documentation/faq#new_relic
