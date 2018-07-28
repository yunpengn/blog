---
title: Redis Cluster & Common Partition Techniques in Distributed Cache
date: 2018-07-27 13:09:53
categories: Technical
---

In this post, I will discuss a few common partition techniques in distributed cache. Especially, I will elaborate on my understanding on the use of [Redis Cluster](https://redis.io/topics/cluster-tutorial).

Please understand that at the time of writing, the latest version of Redis is [4.0.10](http://download.redis.io/releases/redis-4.0.10.tar.gz). Many articles on the same topic have a different idea from this post. This is mainly because, those articles are probably outdated. In particular, they may refer to the Redis Cluster implementation in Redis 3. Redis Cluster has been improved a lot since Redis 4.

_(This article was based on part of my project report. You may want to take a look at the full report [here](https://dl.comp.nus.edu.sg/handle/1900.100/7123). You may need a valid account to gain access to NUS SoC Digital Library.)_

## Common Partition Techniques

Here, we refer to **horizontal partitioning**, which is also known as **data sharding**. Traditionally, there are 3 approaches to achieve data partitioning, namely, server-side partitioning, cluster proxy, and client-side partitioning.

### Server-side partitioning

The datastore nodes take full control of the partitioning. In other words, the client does not know how the partitioning is done. Thus, it has to blindly send a request to a random master node. If this node is not the correct node, a redirect must be done. The redirect can be in the form of either:

- Return an error code to the client and tell the IP address & port of the correct node to the client; or
- The incorrect node will become a client and re-send the request to the correct node.

This approach has a major drawback that the traffic is doubled (because a redirect is triggered with a high possibility).

### Cluster proxy

There is a proxy or some middleware similar in front of all the nodes. All requests will be sent to the proxy first. Then, the proxy will send the requests to the correct node. For instance, [Twemproxy](https://github.com/twitter/twemproxy) developed by [Twitter](https://twitter.com/) and [Codis](https://github.com/CodisLabs/codis) developed by [Wandoujia](http://www.wandoujia.com) uses this approach. A disadvantage is that the proxy itself becomes a single-point-of-failure.

### Client-side partitioning

The clients decide how to partition the data. There is no extra traffic in this way. However, all clients must agree on a certain partitioning scheme. This approach could be error prone (since the partitioning scheme used may have differences).

## Partitioning in Redis Cluster

Redis uses a “hash-slot” approach, which can be considered as a mix of server-side partitioning and client-side partitioning. It achieves certain advantages over the 3 traditional approaches.

The whole range of possible hash codes of keys are divided into 16384 slots. These slots are automatically assigned to different master nodes. The client could get the allocation information easily by using “CLUSTER SLOTS” command (Redis Labs). This command should be done when the client starts. Each time when the client wants to insert a new key, it will pre-compute the [CRC16](https://en.wikipedia.org/wiki/Cyclic_redundancy_check) value of the key. Using its CRC16 value, it could easily detect which hash slot this key belongs to, thus knowing which master node this key should go to. In this way, all the clients must follow the partitioning determined by the server.

## Data Re-sharding

In the sections above, we have discussed how data sharding is usually done. However, a common scenario is that, your business will grow (_hopefully, the growth is because you have read this article_ 😂). One day, you may find that you need to add more nodes into your distributed cache, the Redis Cluster. Typically, the process of adding new nodes or removing existing nodes is called **data re-sharding**.

Let's say you have 4000 keys in your key-value store (_certainly, 4000 is a too small number since this is just a demo_). Previously, you have 4 master nodes and each node will approximatley contain 1000 keys. Now, you want to add a new master node. Thus, there will be 5 master nodes in total and each node will have about 800 keys.

Now, the problem comes. The new node is empty. How should we move some data into the new node? Ideally, we want to remap only `K/n` keys on average, where `K` is the total number of keys and `n` is the number of nodes. This is where [consistent hashing](https://en.wikipedia.org/wiki/Consistent_hashing) comes into play.

However, the “hash-slot” approach is again different from the traditional **consistent hashing** approach.
