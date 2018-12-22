---
title: Literature Review on Join Reorderability
date: 2018-12-22 16:24:11
categories: Technical
---

Recently, I was looking at some research papers on the join reorderability. To start with, let's understand what do we mean by "_join reorderability_" and why it is important.

## Background Knowledge

Here, we are looking at a query optimization problem, specifically join optimization. As mentioned by [Benjamin Nevarez](http://www.benjaminnevarez.com/2010/06/optimizing-join-orders/), there are two factors in join optimization: **selection of a join order** and **choice of a join algorithm**.

As stated by Tan Kian Lee's [lecture notes](https://www.comp.nus.edu.sg/~tankl/cs3223/slides/opr.pdf), common join algorithms include iteration-based nested loop join _(tuple-based, page-based, block-based)_, sort-based merge join and partition-based hash join. We should consider a few factors when deciding which algorithm to use: 1) types of the join predicate (equality predicate v.s. non-equality predicate); 2) sizes of the left v.s. right join operand; 3) available buffer space & access methods.

For a query attempting to join `n` tables together, we need `n - 1` individual joins. Apart from the join algorithm applied to each join, we have to decide in which order these `n` tables should be joined. We could represent such join queries on multiple tables as a tree. The tree could have different shapes, such as left-deep tree, right-deep tree and bushy tree. The 3 types of trees are compared below on an example of joining 4 tables together.

{% img /images/join_order_tree.jpg 450 "3 types of join trees" %}

For a join on `n` tables, there could be `n!` left-deep trees and `n!` right-deep trees respectively. There could be even more bushy trees, etc. Given so many different join orders, it is important to find an optimal one among them. There are many different algorithms to find the optimal join order: exhaustive, greedy, randomized, transformation, dynamic programming (with pruning).

## Join Reorderability

As illustrated in the last section, we have developed algorithms to find the optimal join order of queries. However, we could meet problems when we try to apply such algorithms on outer joins & anti-joins. This is because such joins do not have the same nice properties of commutativity and assocativitity associativity as inner joins.

Further, this means our algorithms cannot safely search on the entire space to find an optimal order _(i.e. a significant subset of the search space is invalid)_. Such dilemma puts us into two questions: 1) which part of hte search space is valid? 2) what can we do with the invalid part of the search space?

Up to now, hopefully the topic has become much clearer to you. In _join reorderability_, we are trying to figure out "the ability to manipulate the join query to a certain join order".

## Recent Researches

As follows, I summarize some recent researches on this topic and give my _naive_ literature reviews.

## References

- [NUS CS3223 Lecture Notes - Relational Operators](https://www.comp.nus.edu.sg/~tankl/cs3223/slides/opr.pdf)
- [NUS CS3223 Lecture Notes - Query Optimizer](https://www.comp.nus.edu.sg/~tankl/cs3223/slides/opt.pdf)
- [Optimizing Join Orders](http://www.benjaminnevarez.com/2010/06/optimizing-join-orders/)
