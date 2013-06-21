阅读本文你至少应该了解异步调用的基本概念.

由于javascript单线程(exclude webworkers)的情况, 对于诸如网络请求等延时操作, 
采用了事件和异步的方式解决阻塞的发生.

对于阻塞式的代码执行, 如
```js
var data = fetchData();
calculate(data);
```

对于异步调用的代码
```js
fetchData(function (data) {
  calculate(data);
});
```

然而, 对于大量的异步操作, 会产生嵌套的异步调用
```js
fetchData1(function (data1) {
  fetchData2(function (data2) {
    fetchData3(function (data3) {
      calculate(data1, data2, data3);
    });
  });
});
```

大量异步调用产生的挑战包括

* 代码可读性: 代码中参杂了异步程序结构和正常的阻塞式程序结构
* 程序逻辑结构: 如何进行异步的循环, 如何控制异步代码的执行顺序, 如何将大量异步
代码执行结果提供给一个终止函数

下面围绕这两个问题, 讲述async库提供的功能, jquery提供的deferred, 以及在语言层面寻求改进的elm.

## async
async库主要提供了两类工具函数

* 单个异步调用对于数组的遍历操作
* 大量异步调用的执行顺序

async很好解决了正常程序逻辑结构面临异步调用时产生关于返回值和调用时机的问题.

然而, 它仍存在代码可读性上面的问题.

## jquery defer
jquery deferred通过链式调用(function chain)和deferred object来完成本质上异步调用
的'同步'假象, 比如下面的异步函数
```js
function createItem(item, successCallback, errorCallback) {
  $.post("/api/item", item, successCallback, errorCallback);
}
```
将被改造为
```js
function createItem(item, successCallback, errorCallback) {
  var req = $.post("/api/item", item);
  req.success(successCallback);
  req.error(errorCallback);
}
```
极像一个同步调用.
而$.post实现机制类似于
```js
function doIt() {
  var dfd = $.Deferred();

  setTimeout(function() {
    dfd.resolve('hello world');
  }, 5000);

  return dfd.promise();
}
```
事实上, async和deferred都使用了相同的方式来控制异步调用的执行---回调.

然而, 却使用了不同的理念来解决问题, async更像是提供了一套解决具体问题的工具箱,
而jquery仅提供了deferred object, 倾向于使用阻塞式代码的方式来表现异步代码, 
你可以使用deferred对象来解决某个具体的问题.

## elm
这里引用&lt;黑客于画家&gt;中的一段话
> 如果你想解决一个困难的问题，关键不是你使用的语言是否强大,而是好几个因素同时发挥作用 
> 
> 1. 使用一种强大的语言,
> 2. 为这个难题写一个事实上的解释器
> 3. 或者, 你自己变成这个难题的人肉编译器

面对异步调用的各种hack, 这句话也同样试用.

elm使用了所谓的Functional Reactive Programming来解决问题, 事实上, 这是一个语言
层面上的signal(or event), 当时间或变量值发生变更时, 来自动调用响应函数.

## 参考资料
* [async github](https://github.com/caolan/async)
* [jquery deferred object](http://api.jquery.com/category/deferred-object/)
* [escape from callback hell-the jquery way](http://ianbishop.github.io/blog/2013/01/13/escape-from-callback-hell/)
* [Escape from Callback hell-the elm way](http://elm-lang.org/learn/Escape-from-Callback-Hell.elm)
