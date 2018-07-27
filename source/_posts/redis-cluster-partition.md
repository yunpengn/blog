---
title: Redis Cluster & Common Partition Techniques in Distributed Cache
date: 2018-07-27 13:09:53
categories: Technical
---

In this post, I will discuss a few common partition techniques in distributed cache. Especially, I will elaborate on my understanding on the use of [Redis Cluster](https://redis.io/topics/cluster-tutorial).

## Common Partition Techniques

Here, we refer to horizontal partitioning, which is also known as data sharding. Traditionally, there are 3 approaches to achieve data partitioning, namely, server-side partitioning, cluster proxy, and client-side partitioning.

### Server-side partitioning

The datastore nodes take full control of the partitioning. In other words, the client does not know how the partitioning is done. Thus, it has to blindly send a request to a random master node. If this node is not the correct node, a redirect must be done. The redirect can be in the form of either:

- Return an error code to the client and tell the IP address & port of the correct node to the client; or
- The incorrect node will become a client and re-send the request to the correct node.

This approach has a major drawback that the traffic is doubled (because a redirect is triggered with a high possibility).

### Cluster proxy

There is a proxy or some middleware similar in front of all the nodes. All requests will be sent to the proxy first. Then, the proxy will send the requests to the correct node. For instance, Twemproxy developed by Twitter uses this approach. A disadvantage is that the proxy itself becomes a single-point-of-failure.

### Client-side partitioning

The clients decide how to partition the data. There is no extra traffic in this way. However, all clients must agree on a certain partitioning scheme. This approach could be error prone (since the partitioning scheme used may have differences).

## Partitioning in Redis Cluster

Redis uses a “hash-slot” approach, which can be considered as a mix of server-side partitioning and client-side partitioning. It achieves certain advantages over the 3 traditional approaches.

The whole range of possible hash codes of keys are divided into 16384 slots. These slots are automatically assigned to different master nodes. The client could get the allocation information easily by using “CLUSTER SLOTS” command (Redis Labs). This command should be done when the client starts. Each time when the client wants to insert a new key, it will pre-compute the CRC16 value of the key. Using its CRC16 value, it could easily detect which hash slot this key belongs to, thus knowing which master node this key should go to. In this way, all the clients must follow the partitioning determined by the server.

The “hash-slot” approach is also helpful for data re-sharding, i.e., adding or deleting nodes. It is again different from the traditional approach, **consistent hashing**.
