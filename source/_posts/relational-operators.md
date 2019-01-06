---
title: Evaluation & Implementation of Relational Operators
date: 2019-01-05 22:10:55
categories: Technical
---

This post talks about some basic implementation of relational operators in traditional RDBMS (relational database management systems). It was based on Chapter 14 of the [textbook](http://pages.cs.wisc.edu/~dbbook/) by [Raghu Ramakrishnan](http://pages.cs.wisc.edu/~raghu) and [Johannes Gehrke](http://www.cs.cornell.edu/johannes).

Below we will talk about the classical evaluation & implementation of relational operators one-by-one, namely:

- [Selection](#Selection)
- [Projection](#Projection)
- [Join](#Join), cross product
- Set operations (intersection, union, difference)
- Grouping & aggregation

## Selection

The selection operation is discussed in Section 14.1 of the [textbook](http://pages.cs.wisc.edu/~dbbook/). Based on the availability of indexes and sorting, we discuss the following scenarios:

- No index and unsorted data: if there is no index on the concerned column and also the table is not sorted on that column, the only access path would be a whole file scan. This is very slow but we have to live with that.
- No index but sorted data: do a binary search on the physical file organization, i.e. a sorted file scan. This would be faster than the first scenario. However, one pratical problem is that we usually could not keep a relation sorted for a long term. A better idea would be to use a B+ tree index. Why not, isn't it?
- B+ tree index: for a non-equality selection predicate, using this clustered B+ tree index would be the best strategy. For equality selection predicate, hash index would be a little bit better. Notice that if the index is not clustered, the cost of retrieving qualifying tuples would be higher (because they are not neraby physically thus incur more I/O costs). However, we probably could sort the tuples based on that field for unclustered B+ tree index. Or, we may simply use a file scan.
- Hash index: the best strategy for equality selection predicate. Thus, the cost includes: a few I/Os to retrieve bucket pages from the index + I/Os to retrieve qualifying tuples (again, depends on whether the index is clustered).

To process generic selection, we could express the predicate(s) as a **conjunctive normal form** (CNF), i.e. a collection of conjuncts connected by the `AND` operator and each conjunct containing one or more terms connected by the `OR` operator. Conjuncts that contain `OR` operator(s) are said to contain **disjunction**. Let's discuss the following 2 scenarios:

- _Without disjunction:_ retrieve tuples using a file scan or index that could be the most selective access path. For the rest (non-primary) conjuncts, apply them along the way for each retrieved tuple. Alternatively, we could utilize multiple indexes. We can use these indexes to compute the intersecting rid sets of candidate tuples. In the end, we retrieve those remaining tuples. Notice that this method would only be applicable for Alternative 2 or 3 (since in Alternative 1, we would have already retrieved the tuples which are stored along with the index anyway).
- _With disjunction:_ due to the existence of disjunction, we have to do a file scan as long as there is no index available on at least one of the term(s). On the opposite, if every term mentioned has an index available, we can simply take a union of candidate tuples (or a union of rid sets).

## Projection

In relational algebra, projection requires us to remove unwanted attributes and eliminate duplicate tuples. Although it is relatively easy to remove unwanted attributes, we require some work to eliminate duplication (by either sorting or hashing).

- _Projection based on sorting:_ sort first and do a sequential scan on the sorted output to eliminate duplicates. The time complexity would be `O(M * logM)`, where `M` is the number of pages. The bottleneck is the sorting step.
- _Projection based on hashing:_ worthy if we have faily large number of buffer pages `B`. We would use 1 page as the input buffer and `B - 1` pages as the output buffer. The hash function `f` would be desired to partition the tuples equally to `B - 1` output pages. This is similar to the idea of Bloom filter in the sense that two tuples belonging to different partitions are guaranteed to be not duplicates of each other. In other words, we could only possibly find duplicates within the same partition. Then, for each partition produced in the first phase, we process one page at a time. For the page being processed, read all entried into an in-memory hashtable to eliminate duplicates. Notice that the hash function used here should be different from the previous one `f`. This hashing strategy will not work when the size of a hashtable for a partition is greater than the number of available buffer pages `B` (the _partition overflow_ problem). Though, we could divide the overflowing partition into sub-partitions and apply hashing recursively.

Comparing the two approaches above, sorting-based approach would be better when there are many duplicates or the distribution of (hash) values is very non-uniform. A useful side effect of sorting-based approach is that the result would be sorted. Thus, sorting could be the standard implementation for projection in many systems.

## Join

## References

- [Database Management Systems (3rd edition)](http://pages.cs.wisc.edu/~dbbook/)
