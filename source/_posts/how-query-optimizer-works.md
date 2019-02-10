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

If we represent a query as a tree, we need to estimate, there are two factors to consider when estimating the cost: the cost of performing the corresponding operation at each node, the size of the operation result at each node and whether the result need to be sorted. Here, we focus on how the query optimizer could estimate the result size of an operation (using system catalog).

## References

- [Database Management Systems (3rd edition)](http://pages.cs.wisc.edu/~dbbook/)
