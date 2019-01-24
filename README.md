[![Build Status](https://travis-ci.com/yunpengn/blog.svg?branch=master)](https://travis-ci.com/yunpengn/blog)
[![Dependabot Status](https://api.dependabot.com/badges/status?host=github&repo=yunpengn/blog)](https://dependabot.com)

# Yunpeng's Blog

This repository is meant for [Yunpeng](https://yunpengn.github.io/)'s personal blog website. It is proudly powered by [Hexo.js](https://hexo.io/). In a previous [blog](https://yunpengn.github.io/blog/2018/04/11/blog-with-hexo/), I shared the reasons why I chose to blog with Hexo.js.

- Production Site: [https://yunpengn.github.io/blog/](https://yunpengn.github.io/blog/)
- Staging Site: [https://yunpengn-blog.netlify.com/](https://yunpengn-blog.netlify.com/)

## Development

- Make sure you have installed the latest version of [Node.js](https://nodejs.org/), [Npm](https://www.npmjs.com) and [Git](https://git-scm.com/) on your development machine. Npm should come with Node.js.
	- You chould check them by `git --version`, `node -v` and `npm -v`.
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
npm start
```
- Now, you can visit the website at `http://localhost:4000/blog/`.

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

Currently, this blog is being deployed to two environments concurrently, [production site](https://yunpengn.github.io/blog/) on [GitHub Pages](https://pages.github.com/), as well as [staging site](https://yunpengn-blog.netlify.com/) on [Netlify](https://www.netlify.com). The details for these two environments are described as follows respectively.

### Production deployment

We use the [Git deployer plugin](https://github.com/hexojs/hexo-deployer-git) for Hexo to deploy the site to the [`gh-pages` branch](https://github.com/yunpengn/blog/tree/gh-pages), which is then picked up by GitHub Pages automatically.

- You should have followed the [section above](#development) to set up the local development environment.
- Check the settings in `_config.yml` is correct (see Hexo's [documentation](https://hexo.io/docs/deployment#Git) for more details):
```yaml
deploy:
  type: git
  repo: <The URL to your Git repository>
  branch: <The branch for deployment>
  message: <The commit message>
```
- Deploy the website by running `npm run deploy`. _Prior to doing this, check that you have access to the Git repository._

### Staging deployment

We are also using [Netlify](https://www.netlify.com) as a CI/CD service to host the staging site. The relevant configuration for Netlify can be found in the file [netlify.toml](netlify.toml). The staging pipeline would run whenever you push the changes to this GitHub repository and there is no manual step involved.

You should take special note that the Hexo.js configuration [file](_config_netlify.yml) for the staging environment is different. This is due to the differences in base URL and root path between the two environments. When running the Hexo commannds, make sure you suffix them with `--config _config_netlify.yml`.

## Acknowledgements

- [Hexo.js](https://hexo.io/)
- [Hexo theme - Next](https://github.com/theme-next/hexo-theme-next)

## Copyright

Copyright &copy; 2017 - Present by [Niu Yunpeng](https://www.github.com/yunpengn/)

This project ([Yunpeng's Blog](https://yunpengn.github.io/blog/)) is licensed under a [Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License](http://creativecommons.org/licenses/by-nc-nd/4.0/) (_"the licence"_). Based on a work at [this repository](https://github.com/yunpengn/blog).

The licence generally grants you the freedom that
- You are free to share, copy and redistribute the material in any medium or format

under the following terms:
- You must give appropriate credit, provide a link to the license, and indicate if changes were made; and
- You may not use the material for commercial purposes; and
- If you remix, transform, or build upon the material, you may not distribute the modified material; and
- You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.

> In summary, the licence mentioned above allows you to view and share this work in its original form via any meidum. However, you are **NOT** allowed to modify it for other uses (_such as to create your own website_).

A copy of the licence has been attached to this repository, and can be found [here](LICENSE.md). You may seek permissions beyond the scope of this license by contacting the author at [neilniuyunpeng@gmail.com](mailto:neilniuyunpeng@gmail.com).<br>

<a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/4.0/">
	<img src="https://i.creativecommons.org/l/by-nc-nd/4.0/88x31.png" alt="Creative Commons License" style="border-width:0">
</a>
