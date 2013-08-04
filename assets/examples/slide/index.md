title: Introduction to Javascript

* preface
* basic
* environment(closure, this)
* asynchronous
* paradigm
* framework, library and tool
* Q & A

---

title: 1. preface
class: segue dark nobackground

---

本讲座围绕编程语言Javascript来展开, 讲座中的内容源自日常编码中的总结.

然而讲座并不只局限于JS程序员, 对于不同类型的听者, 下面是我给出的一些建议.

* 非技术人员(如设计师): 我并不期望你们能从讲座中学到多少技术知识, 但是希望你们能从一些编程思维中有所启发. 虽然如此, 我还是增加了关于数据类型的基础知识, 你们只需要有所了解即可. 回调部分提到了一些你们将有所收获的地方.
* 使用其他编程语言的技术人员: 你们应该忽略掉语言细节, 而在编程思想上集中注意. 相信在闭包, 回调和范式的内容中你们将有所收获.
* Javascript程序员: 这里我假设你们已经对本讲座的内容非常熟悉, 你们可以比较对于这门编程语言我们不同的观察角度.

---

title: 2. basic
class: segue dark nobackground

---

title: number, string

<pre class="prettyprint" data-lang="javascript">
// don't distinguish integer with float
var num1 = 123;
var num2 = 23.4;
// unmutable
var str1 = 'aabb';
str1.replace('bb', 'aa'); // aaaa
str1 === 'aabb'; // true
</pre>

---

title: {}, []
content_class: smaller

<pre class="prettyprint" data-lang="javascript">
// hash, dict or map
var obj = {};
obj.prop = 'this is a property';
obj.meth = function (x) { return x*x; };
obj.meth(2); // 4

var arr = [];
arr.push(1, 2, 3);
arr.length === 3;
arr.pop();
arr.length === 2;
</pre>

search by {}

<pre class="prettyprint" data-lang="javascript">
var dict = {};
dict.zcy = 'zhongchiyu@gmail.com';
dict.hjh = 'callblueday@gmail.com';
dict.zgxb = 'zhugexiaobo@gmail.com';
dict.nyj = 'niexiaoxiao98@gmail.com';
dict.xpf = 'shinepengfei@gmail.com'; // ...
</pre>

<input type="text" id="search-input" />
<button id="search-btn">search</button>
<span id="search-output"></span>

<script type="text/javascript">
var dict = {};
dict.zcy = 'zhongchiyu@gmail.com';
dict.zm = 'cucnzhangmin@gmail.com';
dict.byh = 'baiyunhe0205@gmail.com';
dict.nyj = 'niexiaoxiao98@gmail.com';
dict.xpf = 'shinepengfei@gmail.com';
dict.ty = 'crystalyue0704@gmail.com';
dict.hjh = 'callblueday@gmail.com';
dict.zgxb = 'zhugexiaobo@gmail.com';
dict.lxl = 'lilydjwg@gmail.com';
dict.hjl = 'hhlak47@gmail.com';
dict.wtj = 'wutaojun@gmail.com';
document.getElementById('search-btn').onclick = function () {
  document.getElementById('search-output').textContent =
   dict[document.getElementById('search-input').value];
};
</script>

---

title: JSON(BSON)

<iframe data-src="http://www.json.org/"></iframe>

---

title: Function 
content_class: smaller

<pre class="prettyprint" data-lang="javascript">
// statement
function func_stat (arg) {
  // do some work
}
// expression, note the trailing semicolon
var func_expr = function (arg) {
  // do some work
};
// nested
function level1 () {
  function level2 () {
    // stuff
  }
}
// immediate function
var tmp = function(){ /* do stuff */ };
tmp();
(function(){ /* do stuff */ })();
</pre>

function is object

function are first class

assignment, argument, returned

---

title: core concept

object, mutable objects! everything being an object.

Array is object, only magic in array is the length property.

<pre class="prettyprint" data-lang="javascript">
typeof [] === 'object';
</pre>

---

title: 3. environment
subtitle: closure, this
class: segue dark nobackground

---

title: 3.1 closure
class: segue dark nobackground

---

content_class: smaller

The only way to create a new scope is to invoke a function. if, while... statement don't.

<pre class="prettyprint" data-lang="javascript">
function condition () {
  if (true) {
    var variable = 0;
  }
  console.log(variable); // 0
}
function level1 () {
  function level2 () {
    var variable = 0;
  }
  console.log(variable); // undefined
}
</pre>

closure(lexical closure) provide two important function

* extend variable life circle
* provide privacy

---

content_class: smaller

extend variable life circle by global variable

<pre class="prettyprint" data-lang="javascript">
var dream = function () {
  var secret = 'Love X';
};
dream(); // secret destroyed after invocation
</pre>
<pre class="prettyprint" data-lang="javascript">
// extend variable life circle by global variable
var secret;
var dream = function () {
  secret = 'Love X';
  console.log(secret);
};
dream(); // 'Love X'
// another people
console.log(secret); // 'Love X'
</pre>

---

content_class: smaller

extend life circle and providing privacy

<pre class="prettyprint" data-lang="javascript">
var dream = (function () {
  var secret;
  return function () {
    secret = 'Love X';
    console.log(secret);
  };
})();
dream(); // 'Love X'
// another people
console.log(secret); // undefined
</pre>

---

title: how to break
content_class: smaller

<pre class="prettyprint" data-lang="javascript">
var thief = {};
var dream = (function () {
  var secret;
  return function dream () {
    // people 1
    secret = 'Love X';
    // thief
    thief.steal = function () {
      console.log(secret);
    };
    thief.inception = function (secret) {
      secret = secret;
    };
  };
})();
dream(); // 'Love X'
thief.steal(); // 'Love X'
thief.inception('Love Y');
thief.steal(); // 'Love Y'
</pre>

---

title: behaviour carry data

closure is behaviour carry data rather than data carry behaviour.

closure is the other side of class.

<pre class="prettyprint" data-lang="java">
class Car {
  int speed = 100;
  int spend (int distance) {
    return distance / this.speed;
  }
}
</pre>

<pre class="prettyprint" data-lang="javascript">
var spend = (function () {
  var speed = 100;
  return function (distance) {
    return distance / speed;
  };
})();
</pre>

---

title: example

uuid

<pre class="prettyprint" data-lang="javascript">
var uuid = (function(){
  var id = 0;
  return function () {
    return id++;
  };
}());
</pre>

<button id="uuid-btn">uuid</button>
<span id="uuid-output"></span>

<script type="text/javascript">
var uuid = (function(){
  var id = 0;
  return function () {
    return id++;
  };
}());
document.getElementById('uuid-btn').onclick = function () {
  document.getElementById('uuid-output').textContent = uuid();
};
</script>

---

closure to create closure

<pre class="prettyprint" data-lang="javascript">
var closure = function (func) {
  var scope = {};
  return function () {
    var args = Array.prototype.slice.call(arguments);
    args.unshift(scope);
    return func.apply(this, args);
  };
};
var uuid2 = closure(function (scope) {
  scope.uuid = scope.uuid || 0;
  return scope.uuid++;
});
</pre>

<button id="uuid2-btn">uuid2</button>
<span id="uuid2-output"></span>

<script type="text/javascript">
var closure = function (func) {
  var scope = {};
  return function () {
    var args = Array.prototype.slice.call(arguments);
    args.unshift(scope);
    return func.apply(this, args);
  };
};
var uuid2 = closure(function (scope) {
  scope.uuid = scope.uuid || 0;
  return scope.uuid++;
});
document.getElementById('uuid2-btn').onclick = function () {
  document.getElementById('uuid2-output').textContent = uuid2();
};
</script>

---

title: 3.2 this
class: segue dark nobackground

---

title: dynamic scope

same code, different result

<pre class="prettyprint" data-lang="javascript">
var func = function () { console.log(this.prop); };
var obj1 = { prop: 'obj1'};
var obj2 = {prop: 'obj2'};
obj1.meth = func;
obj2.meth = func;
obj1.meth(); // 'obj1'
obj2.meth(); // 'obj2'
</pre>

---

title: call, apply
content_class: smaller

Providing a way to dynamic call function.

`()` operator VS `Function.prototype.call` and `Function.prototype.call`
<pre class="prettyprint" data-lang="javascript">
var add = function (x, y) { return x+y; };
add(1, 2);
// equals
add.call(null, 1, 2);
// OR
add.apply(null, [1, 2]);
// think about add.call.call ...
</pre>

<pre class="prettyprint" data-lang="javascript">
var obj1 = {prop: 'obj1'};
var obj2 = {prop: 'obj2'};
var dynamic = function () {
  console.log(this.prop);
};
dynamic.call(obj1); // 'obj1'
dynamic.call(obj2); // 'obj2'
</pre>

---

title: trap

<pre class="prettyprint" data-lang="javascript">
var listener = function () {
  console.log(this);
};
// window object 
document.onclick = listener;
// empty {} object
document.onclick = function () {
  listener.apply('string', arguments);
};
</pre>

<button id="trap-start-btn">start</button>
<button id="trap-switch-btn">switch</button>
<button id="trap-end-btn">end</button>

<script type="text/javascript">
var listener = function () { alert(this); };
var wrappedListener = function () { listener.apply('string', arguments); };
document.getElementById('trap-start-btn').onclick = function () {
  document.addEventListener('click', listener);
};
document.getElementById('trap-switch-btn').onclick = function () {
  document.removeEventListener('click', listener);
  document.addEventListener('click', wrappedListener);
};
document.getElementById('trap-end-btn').onclick = function () {
  document.removeEventListener('click', listener);
  document.removeEventListener('click', wrappedListener);
};
</script>

---

title: 4. asynchronous
class: segue dark nobackground

---

In Javascript normal programing, we only think about single thread model(exclude html5 web worker).

Does single-thread means slow?!

Asynchronous and multi-thread in real life.

---

title: asynchronous? multi-thread? multi-process?
content_class: smaller

### multi-thread

* context switching overhead
* execution stack take up memory
* complicate concurrency

### multi-process (almost the same as multi-thread)

* high memory usage
* process scheduling overhead

### asynchronous

DONT means single thread, through Javascript programmer only see one thread in normal programing.

Handle many request in one process/thread, using thread pool and async IO api to wait time consuming stuff.

---

title: nodejs way
content_class: smaller

Node.js uses an event-driven, non-blocking I/O model that makes it lightweight and efficient, perfect for data-intensive real-time applications that run across distributed devices.

![nodejs event loop](./assets/event-loop.jpg)

---

title: scenario

### asynchronous
* 实时(non-block)

### multi-thread or process
* 计算密集型

---

title: problem
content_class: smaller

<pre class="prettyprint" data-lang="javascript">
// long long long chained callback
Qlet.prototype.loadQfo = function (callback) {
  loadLink(REMOTE_SRC+'/assets/css/style.css', function () {
    loadScript(REMOTE_SRC+'/lib/async.js', function () {
      loadScript(REMOTE_SRC+'/lib/easyXDM.js', function () {
        loadScript(REMOTE_SRC+'/lib/json2.js', function () {
          loadScript(REMOTE_SRC+'/dev/base_dev.js', function () {
            loadScript(REMOTE_SRC+'/assets/js/deps.js', function () {
              loadScript(REMOTE_SRC+'/src/loader.js', function () {
                // done
              });
            });
          });
        });
      });
    });
  });
};
// I LOVE THIS TRIANGLE
</pre>

---

title: solution
content_class: smaller

### 1. async lib

<pre class="prettyprint" data-lang="javascript">
var scripts = ['style.css', 'easyXDM.js'/* ... */];
async.eachSeries(scripts, function (src, callback) {
  loadScript(BASE_URL+src, {callback: callback});
});
</pre>

good solution

not readable for me

### 2. promise/A+ proposal

<pre class="prettyprint" data-lang="javascript">
// library q
Q.fcall(promisedStep1).then(promisedStep2).then(promisedStep3).then(function (value4) {
  // Do something with value4
}).catch(function (error) {
  // Handle any error from all above steps
}).done(function () { /* final step */ });
</pre>

excellent approach

---

title: 5. paradigm

* functional: memoization, curry
* class?
* mixin!
* prototype!

---

title: Functional programing
subtitle: curry
content_class: smaller

<pre class="prettyprint" data-lang="javascript">
Function.prototype.uncurryThis = function () {
  var f = this;
  return function () {
    var a = arguments, b = [].slice.call(a, 1);
    return f.apply(a[0], b);
  };
};
Function.prototype.curry = function () {
  var fn = this;
  var args = [].slice.call(arguments, 0);
  return function () {
    return fn.apply(this, args.concat([].slice.call(arguments, 0)));
  };
};
// working example
var add = function (x, y) { return x+y; };
add.curry(1);
add(2); // 3
</pre>

---

subtitle: why currying?
content_class: smaller

Currying is both useful and elegant when you want to cache re-usable computations.

<pre class="prettyprint" data-lang="javascript">
// if we don't use currying
String.prototype.csv = String.prototype.split;
var str1 = "John, Resig, Boston";
var str2 = "a b c";
str1.csv(/,\s*/);
str2.csv(/,\s*/);
// with currying(code from http://stackoverflow.com/a/114030/1027163)
String.prototype.csv = String.prototype.split.curry(/,\s*/);
str1.csv();
str2.csv();
// think about lazy evaluation?
var complex = function (x, y, z) {
  // very complex calculation here.
};
complex = complex.curry(1);
complex = complex.curry(2);
// don't do real calculation util real function being called
// complex(3);
// which I don't want to call this guy anymore :)
</pre>

---

title: memoization
content_class: smaller

<pre class="prettyprint" data-lang="javascript">
var hash = (function(){
  var hash = [];
  return function () {
    var cur, index, len = arguments.length, result = [];
    for (cur=0; cur&ltlen; cur++) {
      index = hash.indexOf(arguments[cur]);
      if (index === -1) { index = hash.push(arguments[cur]); }
      result.push(index);
    }
    return result.join('');
  };
})();
// underscore implementation
_.memoize = function(func, hasher) {
  var memo = {};
  hasher || (hasher = _.identity);
  return function() {
    var key = hasher.apply(this, arguments);
    return _.has(memo, key) ? memo[key] : (memo[key] = func.apply(this, arguments));
  };
};
var add = function (x, y) { return x+y; };
add = _.memoize(add, hash);
add(1, 2);
add(1, 2); // this time just return pre-computed result
</pre>

---

title: class?

<pre class="prettyprint" data-lang="java">
class Locator {
  JSON serialize (selection) {
    return 'json representation of selection';
  }
  BrowserSelection deserialize (json) {
    return browserSelection;
  }
}
class RangeLocator extend Locator {
  BrowserSelection deserialize (json) {
    return newBrowserSelection;
  }
}
// ugly, complex, extra rubbish code
</pre>

---

title: prototype!
content_class: smaller

<pre class="prettyprint" data-lang="javascript">
var Locator = function () {
  // initalize stuff
};
Locator.prototype.serialize = function (selection) {
  return 'json representation of selection';
};
Locator.prototype.deserialize = function (json) {
  return browserSelection;
};
var RangeLocator = function () {
  // initalize stuff
};
RangeLocator.prototype.deserialize = function (json) {
  return newBrowserSelection;
};
// change prototype chain. in ECMAScript5 we can use Object.create to do this dirty work
RangeLocator.prototype = new Locator();
RangeLocator.prototype.constructor = RangeLocator;
// still think like in java
</pre>

---

title: mixin!
content_class: smaller

<pre class="prettyprint" data-lang="javascript">
var mixin = function (src, extra) {
  var prop;
  for (prop in extra) {
    if (extra.hasOwnProperty(prop) {
      if (!src[prop]) {
        src[prop] = extra[prop];
      }
    }
  }
};
var locator = {};
locator.serialize = function (selection) {
  return 'json representation of selection';
};
locator.deserialize = function (json) {
  return browserSelection;
};
var rangeLocator = {};
rangeLocator.deserialize = function (json) {
  return newBrowserSelection;
};
rangeLocator = mixin(rangeLocator, locator);
// just a working example.
// we also need an object generator
</pre>

---

title: 6. framework, library and tool
class: segue dark nobackground

---

title: big lib VS small lib
content_class: smaller

* big lib: closure library, prototype, YUI, MooTools
* small lib: sizzle(jquery selector engine), underscore,  async, kriskowal/q(implement promise/A+)

> In the browser - small, loosely coupled modules are the future and large, tightly-bound monolithic libraries are the past! --- ender.

the core problem for small library is modular. the same as what we need in a team.

* commonjs proposal: requirejs, seajs
* language level solution. <iframe src="http://wiki.ecmascript.org/doku.php?id=harmony:modules" frameborder="0"></iframe>

---

content_class: smaller

### library
jquery, underscore, closure library, prototype, kissy, async, d3, three.js

### framework
angular, backbone

### tool
* test: selemium, jasmine
* compile: uglify, closure compiler
* automation: jake, grunt
* documentation: jsdoc, docco

---

title: tool

### compile
* closure compiler is slower than uglify
* but provide more advanced code evaluation

### automation
* jake provide a way to defined dependencies.
* grunt has a better ecosystem, got option inheritence, better than what shell do.

I prefer grunt now.

### documentation
* docco better fit in source code explanation.
* jsdoc could be used in code documentation.

---

title: Q & A
