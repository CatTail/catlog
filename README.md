## TODO
* 增加图片支持
* 允许在项目目录(即存在settings.json的任意子目录)运行catlog命令

## Done
* 增加已存在markdown文件的迁移
* 寻求分类目录下index文件位置确定的解决方案.暂时为category固定路径
* 通过创建全局scope而不是通过scope继承的方式解决单个post和post分类之间的冲突耦合
* 将分类信息集中在目录结构中, 并且统一将makrdown文件命名为index.md
* 将meta信息和markdown分离
* 将项目作为binary服务启动, 测试非同级目录下的生成情况
