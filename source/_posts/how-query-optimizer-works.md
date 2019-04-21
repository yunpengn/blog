---
title: How Query Optimizer Works in RDBMS
date: 2019-02-07 00:09:39
categories: [Technical, Database, SQL]
---

In a previous {% post_link relational-operators 'post' %}, we discussed how the various relational operators are implemented in relational database systems. If you have read that post, you probably still remember that there are a few alternative implementations for every operator. Thus, how should RDBMS determine which algorithm (or implementation) to use?

Obviously, to optimize the performance for any query, RDBMS has to select the correct the algorithm based on the query. It would not be desirable to always use the same algorithm. Also, SQL is a declarative language _(i.e., as a programmer we only declare what we want to do with the language, not tell how the language should accomplish the task)_. Therefore, it would be an anti-pattern if the user of the database system needs to specify which algorithm to use when writing the query. Instead, the correct approach would be that the user would treat the entire system as a blackbox. The end-user should not care about which algorithm is picked but expect the performance optimization is guaranteed. 

<!-- more -->

## Introduction

One tricky issue is about response time. Let's say given a SQL query, you know all possible approaches to evaluate it. How should we find the optimal one? Without hesitation, you may answer that we can simply emuerate all of them and compare to see which one takes the shortest time. However, that is a terrible mistake. Let's say there are 100 possible approaches, the best one takes 100ms while the worst one takes 1h. If you iterate through all of them, that probably already takes a few hours. Even after a few hours, you are still trying to find out which one is the optimal plan (i.e., the engine has not started the actual execution yet)! That would be even worse than randomly picking one of the approaches (i.e., in the worst case it would take 1h which is still better than iterating all plans).

In other words, you have to predict which approach is the best without actually executing and comparing them. Emm, that's hard. But probably, we can look at the input data to predict which one works for the current input? That may not always work as well. If you have read a previous {% post_link understanding-database-storage 'post' %}, you may know that database stores index as well. Thus, probably we should read the indexes rather than the actual data records. I/Os in database systems are considered to be even more expensive than CPU costs. Thus, we have to make the prediction probably without seeing the data at all.

In this post, we would discuss an important component in RDBMS, **query optimizer**. Basically, it would _run some algorithms to determine which algorithm for the considered relational operator is optimal_. Strange? 🤔

## From Query to Relational Algebra

The input from SQL programmers are SQL queries. However, the SQL engine is more concerned with the format of relational algebra. Certainly, here we probably should call it "extend relational algebra" as the classical algebra may not be enough.

To translate the SQL query into an equivalent relational algebra expression, we would decompose the query into smaller units called _"blocks"_. Then, the query optimizer would optimize on each _"block"_ basis. A single _"block"_ does not contain nesting parts and should have exactly one `SELECT` clause, exactly one `FROM` clause, at most one `WHERE` clause, at most one `GROUP BY` clause, and at most one `HAVING` clause. The `WHERE` clause should be in **conjuctive normal form (CNF)**, that is, a collection of _conjuncts_ connected by `AND` logical operator. A **conjunct** contains one or more terms connected by `OR` logical operator.

It would be relatively trivial to convert each query block to relational algebra. Each `SELECT` clause would be mapping to projection, `WHERE` clause will be mapped to selection, `FROM` clause will be mapped to cross-product. And we assume `GROUP BY` and `HAVING` clauses as the extended operators in relational algebra.

## Estimating the Cost of a Plan

If we represent a query as a tree, there are two factors to consider when estimating the cost:

- The cost of performing the corresponding operation at each node;
- The size of the operation result at each node;
- Whether the result at a certain node is sorted (so that no need to sort again later).

### The Result Size of an Operation

In this section, we first focus on how the query optimizer could estimate the result size of an operation (using _system catalogs_). We have to understand this first because the other components of the overall cost depends on this. For instance, the cost of performing an operation usually depends on the input size. However, the input of an operator is probably the output of its _base operator_. Thus, we have to estimate the result size of its base operation at first.

To estimate the size of a given operation, we need to have some assumptions:

- **Uniformity**: for each attribute, its values are distributed uniformly;
- **Independence**: for different attributes, the distribution is independent to each other;
- **Inclusion**: for convenience, if attribute `A` has fewer number of distinct values than `B`, we assume the distinct values of `A` form a subset of the distinct values of `B`.
- **Preservation**: due to **independence**, the result preserves all distinct values for attributes not in the selection and/or join predicates.

We need the help of system catalogs to estimate result sizes. The system catalogs should contain information, including but not limited to:

- The number of tuples for each relation;
- The size of per tuple for each relation;
- The number of tuples per page for each relation;
- The number of distinct values for each attribute;
	- And probably the range of these distinct values if they are continuous.
- The height for each B+ tree index.

We estimate the result size of an operation using the rules as follows:

- _For an equality selection predicate:_ the output size will be `1 / n` of the input size, where `n` is the number of distinct values on the selection attribute;
- _For a non-equality selection predicate:_
	- If we know the range of the values of the selection attribute, the output size will be `m / n` of the input size, where `m` is the number of distinct values left and `n` is the total number of distinct values;
	- If we are unaware of range of the values of the selection attribute, the output size will be `1 / 2` of the input size. This is a best-effort estimation.
- _For an equality join predicate:_
	- Let's say the number of tuples from the left relation `R1`  is `p`, and the number of tuples from the right relation `R2` is `q`;
	- If the join predicate is `R1.A = R2.B`, the number of distinct values of attribute `A` is `m`, and the number of distinct values of attribute `B` is `n`;
	- Due to the **inclusion** assumption, we assume all `m` values of `A` form a subset of all `n` values of `B`;
	- The result size of this inner join would be `p * q / max(m, n)`;
	- For _key & foreign key join_, let's say `A` is the key column while `B` is the foreign key column, then the result size would be `q`.

The information stored in system catalogs would only guarantee _eventual consistency_. In other words, it would only be updated periodically (rather than being updated whenever there is a mutable operation on the database). This means the information is inaccurate. Anyway, we are just doing an estimation here. Due to the 3 assumptions above, the calculation is far from accuracy. The error would be more significant when propagating to higher level of the query plan tree.

To deal with the errors and the make the estimation more accurate, we can either:

- Maintain more detailed statistics (like using histogram, etc.);
	- To capture correlation between 2 columns, we can use 2-dimensional histograms.
- Sample statistics of the intermediate query results at runtime (to reduce the effect of error propagation).

### The Cost of an Operation

In this section, we discuss the cost of a single operation without considering the correlation between its parent & child operations. Thus, the cost we computer here could be very different from its actual value in a complete query plan tree. This is primaily due to 2 reasons:

- The output of its base operator may have produced sorted result. Thus, if the current operation is sort-based, like sort-merge join, we can simply ignore the cost of the sort step;
- The SQL engine is using a pipelined execution model (such as the Volcano iterator model mentioned later). In this case, some operations may be performed "on-the-fly" (i.e., combined with its base operator) and does not incur any cost at all.

Below, we first consider the cost of external sorting. Here, the implementation of external sorting is based on k-way merge algorithm. We assume the input has `n` pages and we have `r` buffer pages. Recall external sort needs two steps:

- _Generate sorted runs:_ we need to read all `n` pages and generate `n / r` sorted runs. Then, these sorted runs have to be written back to the hard disk. In total, we need `2n` page I/Os.
- _Merge sorted runs:_ in each iteration, we can at most merge `r - 1` sorted runs into 1 run (i.e., use `r - 1` pages as input buffer and `1` page as output buffer). Thus, we need `log_(r - 1)^(n / r)` iterations and each iteration would need `2n` page I/Os.

The cost calculation for external sorting is helpful since many other operations would involve the sorting step. Next, we compute the cost of other operations:

- _Selection:_ normally would need to scan the whole table, which means `n` page I/Os. However, it could usually be done "on-the-fly" for pipelined evaluation. It can also be accelerated if the selection attribute has an index available.
- _Projection:_ similar to selection. Need `n` page I/Os by right, but would be faster with pipelined evaluation or index.
- _Join:_ depends on the join algorithm used. Let's say left relation has `m` pages, right relation has `n` pages and we have `r` buffer pages. We use left table as the outer relation.
	- _Tuple-based nested loop join:_ naive algorithm, should always use page-based instead;
	- _Page-based nested loop join:_  need `m + m * n` page I/Os;
	- _Block-based nested loop join:_ need `m + m * n / (r - 2)` page I/Os;
		- We use `r - 2` because 1 page is used as inner relation buffer and 1 page is used as output buffer.
	- _Index-based nested loop join:_ need `m * k` page I/Os, where `k` is the cost of index access path;
	- _Sort-merge join_: sort step needs the same cost as external sorting (could ignore if the output of base operator is already sorted), merge step needs _at least_ `m + n` page I/Os';
	- _Grace hash join_: partition step needs to read all pages and then write back to hard disk thus needs `2m + 2n` page I/Os, and join step needs `m + n` I/Os;
- _Order by:_ obviously, need to do external sorting;
- _Group by:_ need to do sorting first which requires the same cost as external sorting, and produce the grouping "on-the-fly" when writing back the sorted result; 
- _Distinct:_ similar to group by, do sorting first but only write one value from each group back to hard disk;
- _Set (intersection, union, difference):_ sort-based approach (similar to sort-merge join) or hash-based approach (similar to Grace hash join).

### Volcano Iterator Model

Volcano Iterator Model is a popular implementation of SQL pipelined evaluation. To understand this model better, we can think of it as the `Iterator` interface in Java (i.e., see `java.util.Iterator`). It has 2 methods:

- `hasNext`: to check whether we have finished the operation at this node. For example, it returns `false` when we have fully scanned the table;
- `next`: to produce the next page as the output of this node.

Certainly, it should also have `open` and `close` methods to open & close the resources needed for this operator (like file & stream operations). Not all operations can be implemented with this iterator model (such as operators which require external sorting). Such operators are called "blocking operators".

This model brings one huge advantage: better response time. Let's say there is a query plan tree with no blocking operators. The end user could get the 1st output page in `O(1)` time even if the overall cost may be `O(n)` or even higher. Further, this has 2 applicable scenarios:

- Let's say the query contains a `LIMIT BY` clause. Using the iterator model means we only need to "pay as you need". If the query only wants the result of first 5 pages, we do not need to process the whole relation. In production systems, we suggest to "protect" all queries with `LIMIT BY` clause due to this reason;
	- Note such "protection" will be invalidated if there exists blocking operators in the execution plan;
	- The use of `LIMIT BY` usually aligns with the business requirement as well since mostly the frontend would perform pagination anyway.
- The SQL server & client could potentially establish a communication model similar to stream processing or message queue. Whenever the iterator model produces a new output page, the client would consume this new page. In this way, the overall latency of the system would be reduced.

## Search Space

Next, we discuss the search space of a query optimizer. Recall a query optimizer essentially attempts to find the fastest execution plan amont many potential plans. All these plans which are considered by the query optimizer form the _search space_ of this optimizer.

Note a given query may have many possible execution plans, however, not all of them belong to the "search space". This is simply because there are way too many plans to consider. Thus, the search space is usually a subset of them. As shared in the previous {% post_link literature-review-join-reorder 'post' %}, this "subset" may consist of left deep trees, right deep trees or bushy trees.

How shall we generate these possible execution plans given an initial plan? Let's visualize the execution plan as a tree, we can either:

- Change the order of the execution plan (i.e., swap the nodes in the tree);
- Change the implementation method of a node in the tree.

## Enumeration Algorithm

Now, we already obtain the execution plans we need to consider and also know how to calculate the cost for each of them. It is time to enumerate through all of them and find our choice. Again, since there are too many plans to consider, it is nearly impossible to iterate through every one of them. In fact, query optimization is an NP-hard problem.

Similar to other NP-hard problems, there are a few categories of algorithms that can help us solve the challenge here:

- Exhaustive search
	- only possible for queries with small number of relations (i.e., joins).
- Greedy algorithms
	- apply some greedy heuristics, fast but could get bad results.
- Randomized algorithms
	- such as iterative improvement (II) & simulated annealing (SA).
- Dynamic programming
	- most commercial systems apply this approach.

## Conclusion

To conclude, a query optimizer works based on 3 components: **cost model**, **search space**, **enumeration algorithm**. With careful design, the optimizer could hopefully avoid bad plans, although most likely the result would be sub-optimal. Without exhaustive search, it is not always possible to get the optimal plan.

The design of query optimizer is still an ongoing research topic. With the efforts of database researchers around the world, more and more innovations have been developed to improve the performance of SQL query optimizer.

## References

- [Database Management Systems (3rd edition)](http://pages.cs.wisc.edu/~dbbook/)
- [Volcano - An Extensible and Parallel Query Evaluation System](https://paperhub.s3.amazonaws.com/dace52a42c07f7f8348b08dc2b186061.pdf)
- [Randomized Algorithms for Optimizing Large Join Queries](https://dl.acm.org/citation.cfm?id=98740)
