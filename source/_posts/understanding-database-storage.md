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

In the hierarchy diagram above, the devices in the lower part of the diagram tends to have a larger storage capacity, slower transfer rate but cheaper price.

## References

- [Database Management Systems (3rd edition)](http://pages.cs.wisc.edu/~dbbook/)
