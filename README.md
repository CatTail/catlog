# Catlog

## Introduction
Catlog is a static site generator. It allow user to use markdown syntax to write post and publish it with html format. Catlog has a inner test server to allow you see post result after write it. It also support for self theme and plugin definition.

## Installation
Simply type `npm install -g catlogjs` in console.

## Usage
Type `catlog -h` in console, it will tell you how to use catlog.
```
Usage: catlog.coffee [options] [command]

Commands:

  init                   initialize project
  migrate <path>         migrate already exist markdown file into catlog accepted directory construct
  post                   generate post
  generate               generate assets and html files

Options:

  -h, --help          output usage information
  -V, --version       output the version number
  -s --server [port]  start local server on port
  -a --auto           watch for file change and auto update
```

### init
Go to directory you want to create the blog, type `catlog init`, it will create  such directory structure `plugins  post  _post  settings.json  themes`. Change settings.json as you wish.

### migrate
If you already have a lot of markdown post files and want to migrate them into catlog blog structure, using `catlog migrate <path>`. It will prompt lost meta information needed for every markdown files.

### post
Want to create an new post? Fine, using `catlog post`. For the reason that catlog blog structure contain the meta info of posts, do not change the directory structure without knowning what it means. `post` command will handle this properly for you.

### generate
When you finish writing post and want to see the result, using `catlog generate` to generate html files.

### options
If you need local server add `--server` options, with `--auto` option added, change made in markdown file will auto re-generated into html.

## theme
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

## plugin

## ChangeLog
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

## TODO
* 增加示例
* 编写测试
* 思考如何消除大量回调
* 增加about等特殊页面的支持(当前使用了http://about.me)
* 完善came样式(完善设计, 样式, 时间等)
