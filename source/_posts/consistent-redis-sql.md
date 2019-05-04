---
title: Consistency between Redis Cache and SQL Database
date: 2019-05-04 17:02:18
categories: [Technical, Database, Redis]
---

Nowadays, Redis has become one of the most popular cache solution in the Internet industry. Although relational database systems (SQL) bring many awesome properties such as ACID, the performance of the database would degrade under high load in order to maintain these properties.

In order to fix this problem, many companies & websites have decided to add a cache layer between the application layer (i.e., the backend code which handles the business logic) and the storage layer (i.e., the SQL database). This cache layer is usually implemented using an in-memory cache. This is because, as stated in many textbooks, the performance bottleneck of traditional SQL databases is usually I/O to secondary storage (i.e., the hard disk). As the price of main memory (RAM) has gone down in the past decade, it is now feasible to store (at least part of) the data in main memory to improve performance. One popular choice is Redis.

{% img /images/ram_cost.png 370 "The cost of RAM in the past decades" %}

<!-- more -->

Certainly, most systems would only store the _so-called_ "hot data" in the cache layer (i.e., main memory). This is according to the **Pareto Principle** (also known as **80/20 rule**), _for many events, roughly 80% of the effects come from 20% of the causes_. To be cost-efficient, we just need to store that _20%_ in the cache layer. To identify the "hot data", we could specify an _eviction policy_ (such as LFU or LRU) to determine which data to expire.

## Background

As mentioned earlier, part of the data from the SQL database would be stored in in-memory cache such as Redis. Even though the performance is improved, this approach brings a huge headache that we do not have a _single source of truth_ anymore. Now, the same peace of data would be stored in two places. How can we ensure the consistency between the data stored in Redis and the data stored in SQL database?

Below, we present a few common mistakes and point out what could go wrong. We also present a few solutions to this tricky problem.

_Notice:_ to ease our discussion here, we take the example of Redis and traditional SQL database. However, please be aware the solutions presented in this post could be extended to other databases, or even the consistency between any two layers in the memory hierarchy.

## Common Mistakes
