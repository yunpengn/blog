# Yunpeng's Blog

This repository is meant for [Yunpeng](https://yunpengn.github.io/)'s personal blog website. It is proudly powered by [Hexo.js](https://hexo.io/).

## Why I choose Hexo.js

- The front-end styling should be reasonably consistent and polished. For a developer like me who is better at backend programming, it is difficult to start front-end design from scratch. Thus, I have to choose a framework, or a website generator.
- I want a blog website that only consists of static webpages. This provides me with more options to host it. For instance, [GitHub Pages](https://pages.github.com/) certainly only supports static webpages. Thus, I cannot use any content management system (CMS) with dynamic pages, like [WordPress](https://wordpress.org/) and [Drupal](https://www.drupal.org/).
- I want to use a Windows-based development machine. This means some programming languages like Ruby may be troublesome. Thus, I will not choose engines like [Jekyll](https://jekyllrb.com/).

Given all the factors mentioned above, I choose [Hexo.js](https://hexo.io/) in the end.

## Deployment

_Notice: we are using [GitHub Pages](https://pages.github.com/) to deploy the website. For other deployment approaches, see the Hexo.js official [documentation](https://hexo.io/docs/deployment.html) for more information._

If you have not deployed a Hexo.js project via a Git repository before, you need to install the following package:
```shell
npm install hexo-deployer-git --save
```

After that, change the settings in `_config.yml` as follows:
```yaml
deploy:
  type: git
  repo: <The URL to your Git repository>
  branch: <The branch for deployment>
  message: <The commit message>
```

In the end, run the following commands and Hexo.js will help you deploy the website automatically:
```shell
# Clean the database and the public folder
hexo clean
# Generate all the static webpages
hexo generate
# Deploy the website
hexo deploy
```

## Licence

[GNU General Public Licence 3.0](LICENSE)
