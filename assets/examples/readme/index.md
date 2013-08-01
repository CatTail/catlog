# Catlog
[![Build Status](https://travis-ci.org/CatTail/catlog.png?branch=develop)](https://travis-ci.org/CatTail/catlog)

## Introduction
Catlog is a static site generator. It allow users to use markdown syntax to write blog article and publish it with html format. Catlog has a inner test server to allow you see your blog after write it. It also support for self theme and plugin definition.

Live demo [blog.cattail.me](http://blog.cattail.me)

## Quick-start
First install catlog with npm:

```bash
$ npm install -g catlogjs
```

This will install catlog globally on your system so that you can access the catlog command from anywhere. Once that you can view help:

```bash
$ catlog -h
```
	
it will tell you how to use catlog.

Create a directory for your website, get inside of it, and initialize an empty catlog project:
	
```bash
$ mkdir my-website
$ cd my-website
$ catlog init
```

This creates a skeleton site with a basic set of templates.


Want to create an new blog? 

```bash
$ catlog publish
```
	
then you will need to provide some info for it.

```bash
write your article name: 文章名称
choose article category: 选择已创建类别，或者创建新的类别（这会给你在网站上添加一个新的导航项)
input new permalink title: 固定链接，为了美观，请尽量使用英文
input author name: 文章作者名
```
		
when done, you will have a subdirectory in contents folder: contents/category_name/permalink_title.There will be a index.md and a meta.json file. The index.md is where you write your article, and the meta.json file holds some info of your article.
	
The catlog blog structure contain the meta info of articles, do not change the directory structure without knowning what it means. `publish` command will handle this properly for you.

If you already have a lot of markdown article files and want to migrate them into catlog blog structure, run:

```bash
$ catlog migrate <path> 
```

It will prompt lost meta information needed for every markdown files.

When you finish writing article and want to preview it on local server, you should run:

```bash
$ catlog preview [-s] [-a] 
	
options:
	
	-s [port]: start local server on port,the default port is 8080.
	-a: watch for file change and auto update
	--server [port]: the same effect as -s [port]
	--auto: the same effect as -a
```

Then you can build your site.

```bash
$ catlog build 
```

This generates your site and places it in the build/ directory - all ready to be copied to your web server!

## Theme
### environment
#### site
* source
* destination
* theme_path
* plugin_path
* permalink_style
* base_url
* port
* author
* site_title
* site_url
* destination
* theme
* plugins
* categories
* posts

#### post
* src
* title
* category
* date
* time
* author
* year
* month
* day
* permalink
* heading
* content
could have self-defined variables

## Plugin
Catlog itself bring with three plugins:

* [Google Analytics](http://www.google.com/analytics/)
* [Disqus](http://disqus.com/)
* [Qudian](http://qudian.so/)

In your website root directory, change settings.json `plugins` field.  Following is a example configuration file 

```json
{
  "source": ".contents",
  "destination": "build",
  "permalink_style": "date",
  "base_url": "/",
  "about_url": "http://about.me/cattail",
  "port": "8081",
  "author": "CatTail",
  "site_title": "Catblog",
  "site_url": "http://blog.cattail.me",
  "description": "",
  "theme": "came",
  "plugins": {
    "ga": {
      "trackingID": "UA-41494270-1",
      "domain": "cattail.me"
    },
    "disqus": {
      "disqus_shortname": "cattail"
    },
    "qudian": {
      "auth_key_id": "1362799309",
      "auth_key_secret": "44fc9ea58e1697c85506d305a20dbfea"
    }
  }
}
```

## ChangeLog
* 增加静态html文件的直接发布
* 将项目作为binary服务启动, 测试非同级目录下的生成情况
* 将meta信息和markdown分离
* 将分类信息集中在目录结构中, 并且统一将makrdown文件命名为index.md
* 通过创建全局scope而不是通过scope继承的方式解决单个post和post分类之间的冲突耦合
* 寻求分类目录下index文件位置确定的解决方案.暂时为category固定路径
* 增加已存在markdown文件的迁移
* RSS
* 分离post title和name
* 增加自定义插件支持(disqus, qudian etc)
* 确定特定类型页面的渲染变量
* 针对不同页面, 使用不同的插件
* 增加markdown文件中变量的渲染功能
* 允许在项目目录(即存在settings.json的任意子目录)运行catlog命令
* 增加图片等其他资源文件支持(注意, 不合理的permalink_style定义可能导致资源覆盖)
* 增加文档
* 为async增加conditional函数(已comment到issue)
* 思考如何消除大量回调([solution for javascript callback chain](http://blog.cattail.me/Tech/2013/06/18/solution-for-javascript-async-callback-chain/index.html))

## TODO
* 编写测试
* 增加示例
* 增加about等特殊页面的支持
* 完善came样式(完善设计, 样式, 时间等)
* 相册
* 支持其他类型文件(除了md, 包括html, add lab)的转换



