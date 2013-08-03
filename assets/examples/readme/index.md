# Catlog

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
