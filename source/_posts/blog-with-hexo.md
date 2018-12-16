---
title: Blogging with Hexo.js
date: 2018-04-11 13:00:17
categories: Technical
---

As you may already know, this blog is built using [Hexo.js](https://hexo.io) with theme [Next](https://github.com/theme-next/hexo-theme-next). In this post, I will discuss the reasons why I select this static site generator and this theme.

## Why do I select Hexo.js?

- I want a blog website that only consists of static webpages. Thus, I cannot use any content management system (CMS) with dynamic pages, like [WordPress](https://wordpress.org/) and [Drupal](https://www.drupal.org/).
	- This provides me with more options to host it. For instance, [GitHub Pages](https://pages.github.com/) only supports static webpages.
	- Static webpages are generally faster. They do not need any server-side pre-rendering.
- It may be a waste of time to write raw HTML, CSS & JavaScript code for every page of the blog. Much of the code can be reused. Thus, I need a framework to help me generate the static webpages.
- I want to develop in both Windows and Linux-based environment. This means some programming languages like Ruby may be troublesome. Thus, I will not choose engines like [Jekyll](https://jekyllrb.com/).
- The body of my blog posts should not be in plain text. I need basic styling of the text. Also, I may insert code snippets to technical posts sometimes.
	- Therefore, the framework had better support [Markdown](https://en.wikipedia.org/wiki/Markdown) and/or [AsciiDoc](http://www.methods.co.nz/asciidoc/).
	- I know how to use [LaTeX](https://www.latex-project.org). My slides for my CS1101S classes are all typed in Latex with [Beamer](https://ctan.org/pkg/beamer) package. However, although LaTeX is very powerful, I have to say its syntax is way too complex.
		- In fact, the [Next](https://github.com/theme-next/hexo-theme-next) theme also supports math equation rendering by either [MathJax](https://www.mathjax.org) or [Katex](https://katex.org).

Given all the factors mentioned above, I choose [Hexo.js](https://hexo.io/) in the end.

## Why am I using theme Next?

- I have tried other themes before. They are just not _nice enough_. I do not like the styling.
- I am not a front-end guy or an expert in design, CSS & JavaScript. I do not and cannot create my own theme. I do not have time to do so as well.
- I need to integrate some common 3rd-party services, such as [Disqus](https://disqus.com) for comments and [Google Analytics](https://analytics.google.com/) for traffic monitoring. It would be great if the theme provides native support for those services.

Taken all into consideration, I choose theme [Next](https://github.com/theme-next/hexo-theme-next) finally.
