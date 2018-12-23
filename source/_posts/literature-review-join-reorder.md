---
title: Literature Review on Join Reorderability
date: 2018-12-22 16:24:11
categories: Technical
---

Recently, I was looking at some research papers on the join reorderability. To start with, let's understand what do we mean by _"join reorderability"_ and why it is important.

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

As follows, I summarize some recent researches on this topic and give my _naive_ literature reviews on them.

### Moerkotte, G., Fender, P., & Eich, M. (2013). On the correct and complete enumeration of the core search space. doi:10.1145/2463676.2465314

This paper begins by pointing out two major approaches (bottom-up dynamic programming & top-down memoization) to find optimal join order requires the considered search space to be valid. In other words, this probably only works when we consider inner joins only. Such algorithms could not work on outerjoins, antijoins, semijoins, groupjoins, etc.

To (partially) solve this problem, this paper presents 3 _conflict detectors_, `CD-A`, `CD-B` & `CD-C` (all correct, but only `CD-C` is also complete). It also shows 2 approaches (NEL/EEL & SES/TES) proposed in previous researches are buggy. The authors also propose a desired conflict detector to have the following properties:

- correct: no invalid plans will be included;
- complete: all valid plans will be generated;
- easy to understand and implement;
- flexible:
	- _null-tolerant:_ the predicates are not required to reject nulls (opposite to _null-intolerant_);
	- _complex:_ the predicates could reference more than 2 relations;
- extensible: extend the set of binary operators considered _(by a table-driven approach)_.

Then, the paper introduces the **"core search space"**, all valid ordering defined by a set of transformation rules. Notice that based on commutativity and assocativitity, the left & right asscom property is also proposed. A "conflict" means application of such transformations _(4 kinds of transformations based on 4 properties: commutativity, associativity, l-asscom & r-asscom)_ will result in an invalid plan. "Conflict detector" basically tries to find out such "conflict"s.

If a predicate contained in binary operators do not reference tables from both operands, it is called a _degenerate predicate_. It is observed that for _non-degenerate predicate_:

- For left nesting tree: can apply either associativity or l-asscom (but not both); and
- For right nesting tree: can apply either associativity or r-asscom (but not both).

This observation in fact makes our life much easier. For either left or right nesting tree, we only need to consider one kind of transformation (rather than two kinds). We can further observe we usually at most need to apply commutativity _once_ to each operator. We probably only need to apply associativity, l-asscom, or r-asscom less than once per operator as well. From this, we can infer that it is possible to create an algorithm to iterate through the whole search space in finite steps. Thereafter, the authors proposed an algorithm that extends the classical dynamic programming algorithm, as shown below.

{% img /images/join_order_dp_algo.png 360 "Pseudocode for DP algorithm" %}

Notice that the procedure above calls a sub-procedure `Applicable`, which tests whether a certain operator is applicable. Talking about "reorderability", the rest would discuss how to implement this sub-procedure `Applicable`.

### Rao, J., Pirahesh, H., & Zuzarte, C. (2004). Canonical abstraction for outerjoin optimization. doi:10.1145/1007568.1007643

something here

## References

- [Cost Based Transformation](https://slideplayer.com/slide/7520334/)
- [NUS CS3223 Lecture Notes - Relational Operators](https://www.comp.nus.edu.sg/~tankl/cs3223/slides/opr.pdf)
- [NUS CS3223 Lecture Notes - Query Optimizer](https://www.comp.nus.edu.sg/~tankl/cs3223/slides/opt.pdf)
- [Optimizing Join Orders](http://www.benjaminnevarez.com/2010/06/optimizing-join-orders/)
