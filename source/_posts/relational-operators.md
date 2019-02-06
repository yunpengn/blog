---
title: Evaluation & Implementation of Relational Operators
date: 2019-01-05 22:10:55
categories: [Technical, Database, SQL]
---

This post talks about some basic implementation of relational operators in traditional RDBMS (relational database management systems). It was based on Chapter 14 of the [textbook](http://pages.cs.wisc.edu/~dbbook/) by [Raghu Ramakrishnan](http://pages.cs.wisc.edu/~raghu) and [Johannes Gehrke](http://www.cs.cornell.edu/johannes).

Below we will talk about the classical evaluation & implementation of relational operators one-by-one, namely:

- [Selection](#Selection)
- [Projection](#Projection)
- [Join](#Join), cross product
- [Set operations](#Set-Operations) (intersection, union, difference)
- [Grouping & aggregation](#Aggregation)

<!-- more -->

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

Since join could be the most expensive operator in relational algebra, it also becomes significantly necessary for us to figure out how to optimize it. Although we can say join is a cross product followed by a selection & projection. We really want to avoid executing the cross product in the actual implementation because that's going to be expensive. Here, we will discuss the following approaches to implement join:

- _Simple nested loop:_ contains execution of cross product, would result in a time complexity of `O(M * N)`, where `M` and `N` are the number of pages for the two relations respectively. Depending on the position of the loop variable, one relation `R` would be called the _outer relation_, while the other relation `S` would be called the _inner relation_.
- _Block-based nested loop:_ still contains execution of cross product, but utilize the buffer pages better. This would work when we could hold one smaller relation in the buffer. If we cannot fit the whole relation into buffer, we could split it into blocks.
- _Index-based nest loop:_ no execution of cross product. However, this could only be possible when there is an index on one of the join attributes. The relation with indexed attribute would be the inner relation. In this way, we compare the outer tuple with the inner tuples in the matching partition only. Certainly, this approach would bring a nice performance when the index is clustered. In general, it would be better than the previous two approaches.
- _Sort-merge join:_ no execution of croos product. This method would first do an external sorting to sort two relations on the joined attributes. Then, it would do a merging on the two relations since they are already sorted. Notice that the sorting step essentially enables the possibility of finding partitions. Then, similar to index-based nest loop, we could only search for tuples in the targeted partition. Sometimes, the relation could have already been sorted on the joined attribute. This would make sort-merge join even better. To make sure we do not miss any tuple, we have to be careful to implement the algorithm correctly so that two pointers (for two relations) are advancing in turn. If at least one relation involved can guarantee no duplicates on the join attribute (such as a key-foreign key join), the I/O costs for the merge step would be `O(M + N)` since we essentially just scan both relations once. This method can be further enhanced by blocked access and double buffering.
- _Hash join:_ no execution of cross product. This method has two phases: first _partitioning phase_ to use hashing function to separate the relation into hash slots, second _probing phase_ similar to merging but using hash function to identify the corrsponding partition instead. It is necessary to use the same hash function `h` to hash both relations. In the probing phase, we would practically build an in-memory hash table for the targeted partition to speed up the process. The hash function for this in-memory hash table must be different from `h`. The I/O costs would therefore be around `3 * (M + N)`, or `O(M + N)`. If the partition overflow problem happens, one solution would be to apply the hash join technique recursively.
	- _Hybrid hash join:_ a variant of hash join when more memory is available. In this enhanced method, we basically hold one partition of the outer relation `R` in memory rather than write it back to disk. When partitioning `S`, we would also perform the probing with the in-memory `R` directly.

Now, we discuss join predicates of more general forms, such as inequality conditions or equality conditions over multiple attributes.

- _Inequality conditions:_ requires a B+ tree index for index-based nested loop, hash join & sort-merge join will become inapplicable since we essentailly cannot find the corrsponding partition.
- _Equality conditinos involving multiple attributes:_ build an index of multiple attributes for index-based nested loop, sort on multiple attributes for sort-merge join.

## Set Operations

Now, we discuss the following 4 set operations on two relations:

- _Cross product:_ similar to join with no predicate(s), can use the algorithms mentioned in the last section.
- _Intersection:_ similar to join with a large equality predicate on all attributes.
- _Union:_ simply put two relations together and then eliminate duplicates, similar to the projection operation.
- _Difference:_ implemented using a variant of union.

In general, for union and difference, sort-merge and hash would still be two major approaches.

## Aggregation

In SQL standard, aggregated functions include `AVG`, `MIN`, `MAX`, `SUM` & `COUNT`. Obviously, the basic algorithm would be to scan through the entire relation and maintain some running information along the way.

Usually, they would be used with the `GROUP BY` clause. Without relying on existing indexes, we could derive algorithms based on sorting or hashing _(again, similar to what we do in the last section & last second section)_. For the sorting approach, we would simply sort the relation on the grouping attribute and iterate the sorted relatin to compute the aggregate operation for each group. If we canc do the iteration step together with the sorting step, this approach would be as fast as (or as slow as) the time for the external sorting. For the hashing approach, we build a hashmap on the grouping attribute (with the grouped attribute value as the key and the running information of each group as the value). Hopefully, we could store this hashmap in memory to speed up the process. The cost for this approach would be `O(M)`, where `M` is the size of the relation (i.e., the number of pages). If the hashmap mentioned cannot fit into the memory, we could use a double-hashing approach (i.e., partition the relation using a hashing function on the grouping attribute first, and then do the normal hashing approach on each partition).

Also, we could utilize the existing index(es) to accelerate aggregation. If all attributes needed for the aggregation calculation are present in the index(es), we could avoid actually fetching the data records. For a tree index (i.e., we could retrieve data in a sorted manner), if the attributes in the `GROUP BY` list forms a **prefix** on the index search key of the tree index, we could effectively avoid the sorting step.

## The Use of Buffering

In many algorithms mentioned above, we rely heavily on the buffer pages. If there are multiple operations running concurrently, the size of available buffer pool reduces. Also, if tuples are accessed via an unclustered inxex, mostly it would not be in the buffer pool (although this depends on the size of the buffer pool and the replacement policy). This is because in this context, each tuple retrieved would probably bring in a new page and the buffer pool would be full very soon. When observing a repeated pattern of accessing certain page(s), we probably need to think about carefully on the selection of appropriate replacement policy. Below we list a few pitfalls regarding the selection of replacement policy:

- _Sequentially flooding_ problem: let's say we are executing a simple nested loop join, and we want to buffer the outer relation but cannot hold the whole outer relation. Then, if we use LRU as the replacement policy, the buffer pool effectively becomes a so-called "sliding window" but is never useful (i.e., we always have to do a disk I/O when retrieving a new page).
- For an index-based nested loop join, we could sort the outer relations so that there are a few tuples of the inner relation who would often appear (because the neighboring outer relation tuples probably belong to the same partition of the index and thus those few inner relation tuples often appear). Therefore, it is easier to manage the buffer pool in this way.

## Errata

- On Page 462, `combining the merging phase of sorting with the merging phase of the join` should be changed to `combining the sorting phase of the join with the merging phase of the join`.

## References

- [Database Management Systems (3rd edition)](http://pages.cs.wisc.edu/~dbbook/)
