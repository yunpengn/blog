---
title: To Select the Correct Technical Stack for Web
date: 2018-04-29 22:04:05
categories: Technical
---

When I planned to upgrade the [CS1101S DG Website](https://github.com/yunpengn/CS1101S-DG-Website) project, selection of the technical stack became a big headache. The current decision is
- Backend: [Spring Boot 2.x](https://spring.io/projects/spring-boot)
- Frontend: [Vue.js 2.x](https://vuejs.org) + [Bootstrap 4.x](http://getbootstrap.com) (integrated with Vue.js using [Bootstrap Vue](https://bootstrap-vue.js.org))

In this post, I would like to present the decision-making process.

## What are the possible languages, frameworks?

ertainly, there are many different choices. Let's compare them as follows.

To select a backend framework, it is essentially to select a server-side programming language.
- **Java _(current choice)_**: good for scalability and maintainability, used in many enterprise applications. As a relatively _old_ language, its robustness is no doubt.
- **PHP**: also a traditional choice. However, its performance is not as good as Java (since Java is a fully compiled language, PHP is parsed into opcode and sent to [Zend Engine](http://www.zend.com/en/resources/php-7)).
- **Ruby**: a dynamic-typed language, which becomes famous due to Ruby on Rails. You can write less code to achieve more functionalities. However, its performance is even worse and its development environment is also not trivial to set up.
- **Node.js**: a newer technology than others. It provides a unified language for both frontend and backend development. It is fast since it leverages JavaScript event loop to create non-blocking I/O.
- **Python**: clear and compact syntax that is helpful to developers. Similar to Ruby, it has potential performance issues.

Aligned with the above description, the languages provide the following frameworks:
- **Java**: [Spring](https://spring.io), [Spring Boot](https://spring.io/projects/spring-boot), [Spring Cloud](http://projects.spring.io/spring-cloud/).
- **PHP**: [Laravel](https://laravel.com), [CakePHP](https://cakephp.org).
- **Ruby**: [Ruby on Rails](https://rubyonrails.org).
- **Node.js**: [Express](http://expressjs.com), [Sails](https://sailsjs.com).
- **Python**: [Django](https://www.djangoproject.com).

To select a frontend framework, there are usually two steps:
- _Select an interface-design framework_: whether to use raw HTML+CSS+JavaScript or newer MVVM techniques such as [Vue.js](https://vuejs.org). In other words, you need to decide whether to build a single-page application (SPA) or multi-page application (MPA).
- _Select a UI element library_: whether to use Twitter's [Bootstrap](https://getbootstrap.com) or Alibaba's [Ant Design](https://ant.design/).

Let's first decide which interface-design approach to select:
- **Raw HTML5+CSS3+JavaScript**: easier to learn and straightforward for beginners. It is a more classical approach that you can find a lot of resources online.
- **[React.js](https://reactjs.org)**: declarative component-based library. It is developed by Facebook.
- **[Angular.js](https://angular.io)**: especially useful for building responsive interfaces. It is maintained by Google.
- **[Vue.js](https://vuejs.org) _(current choice)_**: a progressive frontend framework. It is contributed by the open-source community.

Then, we will decide the UI element library to build beautiful interfaces:
- **[Bootstrap](https://getbootstrap.com) _(current choice)_**: the most popular CSS+JavaScript mobile-first library in the world. It can also be taken to the next level by using themes, such as those provided by [Bootswatch](https://bootswatch.com). To integrate it with [Vue.js](https://vuejs.org), we can use [Bootstrap Vue](https://bootstrap-vue.js.org).
- **[Ant Design](https://ant.design/)**: many polished and usable components. It is maintained by [Alibaba Group](https://www.alibabagroup.com/), a Chinese multinational technology corporation.
- **[Element UI](http://element.eleme.io/)**: tuned for Vue.js by [Eleme](https://www.ele.me), a Chinese technial company, whose primary service is online food delivery. Its documentation is not as nice as others.
