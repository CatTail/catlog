## TODO
* 增加about等特殊页面的支持
* 完善came样式(增加样式, 时间等)
* 使用event system来解决大量回调问题
* 完善文档和测试

## Done
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

## 环境
### site
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

### post
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
