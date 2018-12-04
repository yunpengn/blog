# Yunpeng's Blog

This repository is meant for [Yunpeng](https://yunpengn.github.io/)'s personal blog website. It is proudly powered by [Hexo.js](https://hexo.io/).

## Why I choose Hexo.js

- I want a blog website that only consists of static webpages. Thus, I cannot use any content management system (CMS) with dynamic pages, like [WordPress](https://wordpress.org/) and [Drupal](https://www.drupal.org/).
	- This provides me with more options to host it. For instance, [GitHub Pages](https://pages.github.com/) only supports static webpages.
	- Static webpages are generally faster. They do not need any server-side pre-rendering.
- It may be a waste of time to write raw HTML, CSS & JavaScript code for every page of the blog. Much of the code can be reused. Thus, I need a framework to help me generate the static webpages.
- I want to develop in both Windows and Linux-based environment. This means some programming languages like Ruby may be troublesome. Thus, I will not choose engines like [Jekyll](https://jekyllrb.com/).
- The body of my blog posts should not be in plain text. I need basic styling of the text. Also, I may insert code snippets to technical posts sometimes.
	- Therefore, the framework had better support [Markdown](https://en.wikipedia.org/wiki/Markdown) and/or [AsciiDoc](http://www.methods.co.nz/asciidoc/).

Given all the factors mentioned above, I choose [Hexo.js](https://hexo.io/) in the end.

## Development

- Make sure you have installed the latest version of [Node.js](https://nodejs.org/), [Npm](https://www.npmjs.com) and [Git](https://git-scm.com/) on your development machine. Npm should come with Node.js.
	- You chould check them by `git --version`, `node -v` and `npm -v`.
- Install the command line interface of [Hexo.js](https://hexo.io/).
```bash
npm install hexo-cli -g
```
- Fork and clone this repository to your computer.
```bash
git clone --recurse-submodules git@github.com:yunpengn/blog.git
```
- Navigate to this directory.
```bash
cd blog
```
- Install all the dependencies stated in `package.json` (or `package-lock.json`).
```bash
npm install
```
- Run the Hexo server to host the website locally.
```bash
hexo server
```
- Now, you can visit the website at `http://localhost:4000/blog/`
- Hexo will watch for file changes and update automatically, so it’s not necessary to manually restart the server.
	- Use `hexo server -s` to serve from `public` folder and disable file watching.

## Writing

- Run the following command to create a new post
	- Surround `<title>` with quotation marks if there exists whitespaces.
```bash
hexo new <title>
```
- Run the following command to create a draft
```bash
hexo new draft <title>
```
- Run the following command to transform a draft into a post
```bash
hexo publish <title>
```
- If you have customize layout under the `scaffolds` folder, you can apply it by
```bash
hexo new <layout> <title>
```

## Deployment

_Notice: [Hexo.js](https://hexo.io/) supports many different deployment approaches. We are using [GitHub Pages](https://pages.github.com/) currently. For other deployment approaches, see the official [documentation](https://hexo.io/docs/deployment.html) for more information._

- Make sure you have declared the required dependency in `package.json`. For instance, if you need to deploy to a Git repository, run the following command
```bash
npm install hexo-deployer-git --save
```
- Check the settings in `_config.yml` is correct:
```yaml
deploy:
  type: git
  repo: <The URL to your Git repository>
  branch: <The branch for deployment>
  message: <The commit message>
```
- Deploy the website by running the following commands:
```bash
# Clean the database and the public folder
hexo clean
# Generate all the static webpages
hexo generate
# Deploy the website
hexo deploy
```
- _Notice: You should have access to the Git repository for deployment._

## Acknowledgements

- [Hexo.js](https://hexo.io/)
- [Hexo theme - Next](https://github.com/theme-next/hexo-theme-next)

## Copyright

Copyright &copy; 2017 - 2018 by [Niu Yunpeng](https://www.github.com/yunpengn/)

This project ([Yunpeng's Blog](https://yunpengn.github.io/blog/)) is licensed under a [Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License](http://creativecommons.org/licenses/by-nc-nd/4.0/) (_"the licence"_). Based on a work at [this repository](https://github.com/yunpengn/blog).

The licence generally grants you the freedom that
- You are free to share, copy and redistribute the material in any medium or format

under the following terms:
- You must give appropriate credit, provide a link to the license, and indicate if changes were made; and
- You may not use the material for commercial purposes; and
- If you remix, transform, or build upon the material, you may not distribute the modified material; and
- You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.

A copy of the licence has been attached to this repository, and can be found [here](LICENSE.md). You may seek permissions beyond the scope of this license by contacting the author at [neilniuyunpeng@gmail.com](mailto:neilniuyunpeng@gmail.com).<br>

<a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/4.0/">
	<img src="https://i.creativecommons.org/l/by-nc-nd/4.0/88x31.png" alt="Creative Commons License" style="border-width:0">
</a>
