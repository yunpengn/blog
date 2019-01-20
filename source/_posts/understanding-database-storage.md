---
title: Understanding How is Data Stored in RDBMS
date: 2019-01-20 21:16:19
categories: Technical
---

We all know that DBMS _(database management system)_ is used to store (a massive amount of) data. However, have you ever wondered how is data stored in DBMS? In this post, we will focus on data storage in RDBMS, the most traditional relational database systems.

## Physical Storage

Data can be stored in many different kinds of medium or devices, from the fastest but costy registers to the slow but cheap hard drives, or even magnetic tapes. Nowadays, [IaaS](https://en.wikipedia.org/wiki/Infrastructure_as_a_service) providers such as [AWS](https://aws.amazon.com) even provides services such as [S3 Glacier](https://aws.amazon.com/glacier/) as a low-cost archiving storage solution. The diagram below shows the memory hierarchy of common devices.

{% img /images/memory_hierarchy.jpg 500 "Memory hierarchy" %}

<!-- more -->

In the hierarchy diagram above, the devices in the lower part of the diagram tends to have a larger storage capacity, slower transfer rate but cheaper price. However, this seems contradictory to the requirements for almost any system: to lower the cost, as well as to improve the performance. To solve such dilemma, most RDBMS (and many other software as well) would try to: store data that are more frequently accessed in a faster memory device (such as main memory and even higher level cache) but store less frequently accesses data in a slower medium (such as hard drive). Specifically, RDMS uses hard drive as the persistent layer while use main memory to store that is currently being processed.

Apart from that, we should also consider how to organize files to enable more efficient retrieval of information. Due to such two-way transfer between hard drive and main memory, the cost of page I/O dominates the cost of almost all relational database operations. Usually, a page is around 4KB or 8KB. When we calculate the time complexity of a certain query, we would directly use the I/O time to estimate the overall time (i.e., we would omit the CPU cost). Also, later we would use a term rid _(record id)_ which could uniquely identify a record's disk address. For ease of optimization, all transfer between hard drive and main memory would be managed by the buffer manager. At a slightly lower layer, disk space manager would control the usage of disk pages.

## File & Index

In RDBMS, a collection of records becomes a file, which could in turn be stored in one or more pages on the hard disk. A file is implemented by the files and access methods layer, and support the scan operation. The file layer keeps track of those records being inserted or deleted, so that it knows whether to request for new pages or how much free space is available in the file. There are a few different file structures. The simplest file structure is a _heap file_, unordered. It stores all records in random order acroos all pages allocated to the file.

To optimize retrieval performance, we could use **index**, a data structure to allow efficient retrieval of records satisfying certain conditions on the _search key_ fields of that index. Usually, an index could be a better alternative of storing sorted file when the predicate is an equality check. Notice that index itself is also stored as a file (i.e., the index consists of a collection of records). These records of an index are called **data entries**, while the actual underlying records are called **data records**. However, there are actually some alternatives. Three of them are listed below:

- _Alternative 1:_ a data entry contains the actual data record;
- _Alternative 2:_ a data entry is a `<k, rid>` pair, where `k` is the search key value and `rid` is the record id of the data record;
- _Alternative 3:_ a data entry is a `<k, rid-list>` pair, where `rid-list` is a list of record ids satisfying the search key value `k`.

Notice that the later two alternatives could be thought of, effectively contains a pointer to the actual data record. If we want to build multiple indexes on the same relation, at most one of them could use _alternative 1_.

When a file is organized so that the ordering of data records is the same as or similar to that of data entries for an index, we say it is a clustered index; otherwise, it is an unclustered index. An index using _alternative 1_ is by default clustered. For _alternative 2_ or _alternative 3_, the index is only clustered if the data records are sorted on the search key field(s). In practice, files are rarely kept sorted because it is really hard to maintain such ordering. Thus, clustered indexes are mostly using _alternative 1_. Notice that the cost to answer a range search query could increase a lot if the index is unclustered.

## Errata

- On Page 277, `otherwise, it clustered is an unclustered index` should be changed to `otherwise, it is an unclustered index`.

## References

- [Database Management Systems (3rd edition)](http://pages.cs.wisc.edu/~dbbook/)
