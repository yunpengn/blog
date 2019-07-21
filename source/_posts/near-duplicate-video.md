---
title: Thoughts on Near-Duplicate Video Detection
date: 2019-07-21 14:47:11
categories: [Technical, Algorithms]
---

In this post, I will share some of my thoughts on a few approaches to an interesting research topic, **near-duplicate video detection**. Apart from the algorithms themselves, we are also going to discuss the scalability issues.

{% img /images/duplicate-videos.jpg 500 "Possible near-duplicate videos" %}

## Why "Near-Duplicate"?

**Near-duplicate video detection** is a branch of a broader topic, near-duplicate detection. There are a lot of problems under this topic, which can be classified into the following categories:

<!-- more -->

- Near-duplicate document detection, such as plagiarism checkers;
- Near-duplicate image detection, such as image search engines;
- Near-duplicate audio detection, such as the music finder app _Shazam_;
- Near-duplicate video detection _(our topic today)_.

It is obvious that **near-duplicate video detection** would probably be the most difficult branch of this topic. The complexity would go beyond the others.

So why are we talking about "near-duplicate" rather than "duplicate"? This is an important point to clarify. We are trying to filter out those similar objects rather than identical objects. For "duplicate" detection, we can probably calculate MD5 of all inputs and then get the duplicates. For "near-duplicate" detection, it is not that simple.

## Perceptual Hash

Normal cryptographic hash functions have a property called **avalanche effect**: _a slight change in input will cause a significant change in its output_. This is the reason why normal hash functions such as MD5 will not work for near-duplicate detection. Even if two files are the same except for 1 bit flip, the hashed value of them will be drastically different.

That is the inverse of what we want. When two inputs are similar, we hope the algorithm should generate similar outputs as well. Fortunately, there is a class of algorithms called **perceptual Hash** which could help us on this. A famous implementation is [pHash](https://www.phash.org). A Python library called [ImageHash](https://pypi.org/project/ImageHash/) is also available.

## K-Means Clustering

We can also learn from a technique from data mining, **k-means clustering**. This algorithm tries to partition the inputs into `k` different clusters. Items in the same cluster are deemded to be similar. However, this approach does not scale well since it will suffer when `k` becomes larger (i.e., curse of dimensionality).

## References

- [Perceptual hashing - Wikipedia](https://en.wikipedia.org/wiki/Perceptual_hashing)
- [Multiple feature hashing for real-time large scale near-duplicate video retrieval](https://dl.acm.org/citation.cfm?id=2072354)
- [Near-duplicate video retrieval: Current research and future trend](https://dl.acm.org/ft_gateway.cfm?id=2501658)
- [CC_WEB_VIDEO: Near-Duplicate Web Video Dataset](http://vireo.cs.cityu.edu.hk/webvideo/)
