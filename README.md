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
git clone git@github.com:yunpengn/blog.git
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

The theme used by this blog website benefits from [Aath](https://github.com/lewis-geek/hexo-theme-Aath). I would personally appreciate [Lewis](http://lewis.suclub.cn/)'s awesome work. 

## Licence

[GNU General Public Licence 3.0](LICENSE)
