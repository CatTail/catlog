本文侧重描述brower side javascript library，在阅读了一些库的文档和源码后作出的总结。这些库包括kissy，tangme，jx，seajs(国内)，underscore，backbone，async，dojo，moto，ender，closure(国外)

## 现状
从功能上来讲，主要有两类库
* 功能全面 
* 功能专一 
功能全面的库，如jx，dojo，jquery(更多的是dom操作)提供了一整套的解决方案，包括模块载入，核心对象功能拓展，浏览器兼容性，dom操作，网络访问等等。这类库的优点是提供了完整的解决方案，缺点则是学习成本高，维护成本更大。
功能专一的库，用于解决特定需求。如seajs解决模块问题，async侧重于解决异步调用，underscore拓展核心对象以及增加了一些编程范式。通过组织不同的专一库，可以完成使用功能全面库所能完成的功能。因此出现了如ender这样的no library library用于将库组织起来。

## 权衡
相比较extjs这样功能全面而又臃肿的库，我更青睐于使用功能专一的库来完成需求，原因有

### 谁的功能更强大
通过组织各种专一库，可以完成全面库所不具有的功能，prototype并不提供异步方面的解决方案。

### 谁做的更好
我认为专一库能够在性能，bug解决以及contribute上有更大的优势。

虽然专一库拥有很多优势，更好的使用他们也面对一些问题：
* 模块依赖
* 命名空间
* 代码规范
* 编译压缩
面对这些问题，也有相应的专一库或工具（包括其他语言编写的工具）来解决问题
* seajs, requirejs
* google closure的依赖, 模块, 编译等整套工具
* ender

## 未来
引用一句ender的一句话In the browser - small, loosely coupled modules are the future and large, tightly-bound monolithic libraries are the past!
