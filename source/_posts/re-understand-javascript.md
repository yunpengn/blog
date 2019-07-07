---
title: Re-understand JavaScript
date: 2019-06-18 13:56:39
categories: [Technical, Web]
---

In this post, we will be looking at a few interesting (but could be challenging) JavaScript questions.

Most of them are actually testing the so-called "down-side" of JavaScript. You certainly should not write such code in a real-world codebase. As I have repeated many times, code should be clear, precise and concise, in that order of importantce. Nevertheless, they are indeed good questions to test your competency in JavaScript.

## 9 or 10?

You are given a function called `magic_length`, which is defined as follows:
```javascript
function magic_length(input) {
    return input.length == 10 && input == ",,,,,,,,,";
}
```

Please give one possible value of `input` such that `magic_length(input)` will return `true`. _Notice: `input` should be of basic data type provided by built-in libraries._

### Solution

One possible value of `input` is `[undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined]` (an array of 10 items, each of which is `undefined`).

### Analysis

Let's first think about what shall be the data type of `input`. `input` must be of such a data type that it comes with the `length` attribute. Therefore, `input` can only be of type `string` or `array`.

We also notice that the statement on Line 2 is using the abstract equality comparison (`==`) rather than strict equality comparison (`===`). This "double equal" will only check for loose equality and will perform a type conversion when the two items are not of the same type. See [here](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Equality_comparisons_and_sameness) for official documentation.

- If `input` is a `string`:
	- Let's look at the 2nd comparision first. When comparing two strings, no type conversion is done. Thus, `input` has to be `,,,,,,,,,`. Then, it is impossible for its length to be 10.
- If `input` is an `array`:
	- When comparing an array with a string, `input` will be converted to string by `ToPrimitive(input)`. Inferring from the first part, this `array` would have 10 items. Thus, now the problem becomes: given an array with 10 items, what would be the value when applying `ToPrimitive` on it would result in `,,,,,,,,,`.

According to [ECMAScript 2015 Language Specification](https://www.ecma-international.org/ecma-262/6.0/#sec-toprimitive), the [`toString` method](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/toString) of `array` will be called. `toString` joins the array and returns one string containing each array element separated by commas. Hence, `,,,,,,,,,` actually comes from the commas used to separate the elements. Since there are 10 items in `input`, there shall be 9 commas to separate them.

Further, that means when 10 items in `input` are converted to string format, they become empty string. A simple guess would be either `null` or `undefined`. When `null` is converted to string format, it will become `"null"`; when `undefined` is converted to string format, it will become `""`.

Therefore, we can conclude that `input` is an array containing 10 `undefined` inside.
