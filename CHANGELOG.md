# Changelog

## v0.0.20 [2013-08-03]

* 修复base\_url对首页和列表页面不起作用

## v0.0.0 - v.0.019

* 检测已经存在的目录, 更新theme
* 删除came样式中在主页和列表页面显示disqus插件
* 增加mac, windows平台支持
* 优化命令行提示输出
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
* 增加图片等其他资源文件支持(注意, 不合理的permalink\_style定义可能导致资源覆盖)
* 增加文档
* 为async增加conditional函数(已comment到issue)
* 思考如何消除大量回调([solution for javascript callback chain](http://blog.cattail.me/Tech/2013/06/18/solution-for-javascript-async-callback-chain/index.html))
