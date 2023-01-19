[TOC]

### 为什么需要`promise`

> 解决回调地狱问题
>
> 
>
> 什么是回调地狱？
>
> > 比如说发登录请求，获取用户ID；根据用户ID发请求获取用户详情；再根据用户是否有银行卡ID，查询银行卡信息；balabala就这样一直嵌套下去。这就是回调地狱问题
> >
> > `后一次的请求依赖前一次的请求返回结果`；`回调中嵌套回调`

### Promise基本使用

> Promise是一个构造函数，使用`new`实例化对象
>
> ```JS
> new Promise((resole,reject)=>{})
> ```
>
> Promise接收一个函数作为入参，这个函数又接受两个参数，`resolve`;`reject`
>
> ---
>
> Promise有两个重要属性
>
> 1. `state`状态
>
>    - `pending`准备/进行中
>
>    - `fulfilled`成功
>
>    - `rejected`失败
>
>    - 通过调用`resolve()`和`reject()`改变Promise状态`state`；而且`状态是一次性的，只能被改变一次，后面再改变是不生效的`
>
>      ```JS
>      const p = new Promise((resole, reject) => { resole() })
>      console.dir(p)
>      // p的状态为fulfilled
>      ```
>
>      ```JS
>      const p = new Promise((resole, reject) => { reject() })
>      console.dir(p)
>      // p的状态为rejected
>      ```
>
>      
>
> 2. `result`结果
>
>    ```JS
>    const p = new Promise((resole, reject) => {
>      // 通过调用resole传参,改变当前Promise对象的结果
>      resole('成功的结果')
>    })
>    console.dir(p)
>    // p的state为fulfilled,result为'成功的结果'
>    ```
>
>    ```JS
>    const p = new Promise((resole, reject) => {
>      // 通过调用reject传参,改变当前Promise对象的结果
>      reject('失败的结果')
>    })
>    console.dir(p)
>    // p的state为fulfilled,result为'失败的结果'
>    ```
>
>    

### Promise.\_proto\_上的方法

> - `then`方法
>
>   - 入参为两个函数，这两个函数的入参分别是调用`resolve`和`reject`的入参
>
>     ```JS
>     const p = new Promise((resole, reject) => {
>       // 通过调用resole传参,改变当前Promise对象的结果
>       resole('成功的结果')
>     })
>     console.dir(p)
>     p.then((result) => { console.log('成功时调用', result) }, (err) => { console.log('失败时调用', err) })
>     // 成功时调用 成功的结果
>     ```
>
>     
>
>     ```JS
>     const p = new Promise((resole, reject) => {
>       // 通过调用reject传参,改变当前Promise对象的结果
>       reject('失败的结果')
>     })
>     console.dir(p)
>     p.then((result) => { console.log('成功时调用', result) }, (err) => { console.log('失败时调用', err) })
>     // 失败时调用 失败的结果
>     ```
>
>     
>
>   - 出参为新的`Promise`且它的`state`为`pending`
>
>     - 链式操作`p.then().then().then()`
>
>   - `Promise`的`state`状态不改变不会执行`then`里面的方法
>
>     ```JS
>     const p = new Promise((resole, reject) => {
>     console.log('开始')
>     // 通过调用resole传参,改变当前Promise对象的结果
>     setTimeout(() => {
>     resole('成功的结果')
>     }, 3000)
>     })
>     console.dir(p)
>     p.then((result) => { console.log('成功时调用', result) }, (err) => { console.log('失败时调用', err) })
>     // 等待3s后才打印 成功时调用 成功的结果
>     ```
>
>   - `then`在成功的`resolve`方法中`return`可以将返回的`Promise`的`state`改为`fulfilled`；如果`resolve`执行报错会将返回的`Promise`的`state`改为`rejected`；如果不写`return`只要`resolve`顺利结束也是成功返回
>
>     ```JS
>     const p = new Promise((resole, reject) => {
>       console.log('开始')
>       // 通过调用resole传参,改变当前Promise对象的结果
>       setTimeout(() => {
>         resole('成功的结果')
>       }, 3000)
>     })
>     console.dir(p)
>     p.then((result) => { console.log('第一次成功时调用', result); return 'success' }, (err) => { console.log('第一次失败时调用', err); return 'failed' })
>       .then((result) => { console.log('第二次成功时调用', result); return 'success' }, (err) => { console.log('第二次失败时调用', err) })
>     // 第一次成功时调用 成功的结果
>     // 第二次成功时调用 success
>     ```
>
>     `then`在失败的`reject`方法中无论执行是否报错，是否有return，返回的`Promise`的`state`都为`rejected`
>
>     ```JS
>     const p = new Promise((resole, reject) => {
>       console.log('开始')
>       // 通过调用resole传参,改变当前Promise对象的结果
>       setTimeout(() => {
>         reject('失败的结果')
>       }, 3000)
>     })
>     console.dir(p)
>     p.then((result) => { console.log('第一次成功时调用', result); return 'success' }, (err) => { console.log('第一次失败时调用', err); return 'failed' })
>       .then((result) => { console.log('第二次成功时调用', result); return 'success' }, (err) => { console.log('第二次失败时调用', err) })
>     // 第一次失败时调用 失败的结果
>     // 第二次成功时调用 failed
>     ```
>
>     
>
>   - > - 失败执行`reject`函数后会一直返回`rejected`的`Promise`，然后继续执行下一个`then`的`reject`函数；`reject``reject``reject`一直执行下去；
>     >
>     > - 成功执行`resolve`函数要`成功return`，才会返回`fulfilled`的`Promise`，然后继续执行下一个`then`的`reject`函数；只有`then链条`上所有的`resolve`函数都顺利执行才是最后的成功；中间有一环执行报错了，则会进入到`rejected`，切换到执行`reject`函数
>     >
>     > - `resolve`可以进入到`reject`；但是`reject`回不去`resolve`
>
> - `catch`方法
>
>   - 入参为一个函数
>
>   - 出参为`rejected`的`Promise`
>
>   - 执行时机
>
>     1. 当`promise`的状态改为`rejected`时，被执行
>
>        ```JS
>        new Promise((resole, reject) => {
>          reject('失败的结果')
>        }).catch((reason) => {
>          console.log('rejected了，执行catch', reason)
>        })
>        // rejected了，执行catch 失败的结果
>        ```
>
>        
>
>     2. 当`promise`执行体`报错`时，被执行
>
>        ```JS
>        new Promise((resole, reject) => {
>          throw new Error('执行错误了')
>        }).catch((reason) => {
>          console.log('rejected了，执行catch', reason)
>        
>        // rejected了，执行catch Error: 执行错误了
>        //    at Pomise.html: 34: 19
>        //    at new Promise(<anonymous>)
>        //    at Pomise.html:33:9
>        ```
>
> - `then`和`catch`链式调用写法
>
>   ```js
>   new Promise((resole, reject) => {
>     // 执行体
>     console.log('开始hahaha')
>     resole('成功的结果')
>   }).then((value) => {
>     // 成功时执行
>     console.log('第一次成功时调用', value)
>   }).catch((reason) => {
>     // 失败时执行
>     console.log('第一次失败时调用', reason)
>   }).then((value) => {
>     // 成功时执行
>     console.log('第二次成功时调用', value)
>   }).catch((reason) => {
>     // 失败时执行
>     console.log('第二次失败时调用', reason)
>   }).then((value) => {
>     // 成功时执行
>     console.log('第三次成功时调用', value)
>   }).catch((reason) => {
>     // 失败时执行
>     console.log('第三次失败时调用', reason)
>   })
>   
>   //开始hahaha
>   //Pomise.html:45 第一次成功时调用 成功的结果
>   //Pomise.html:51 第二次成功时调用 undefined
>   //Pomise.html:57 第三次成功时调用 undefined
>   ```
>
>   
>
> - `finally`方法
>
>   - `finally`的回调函数`不接收任何参数`，finally方法里面的操作，应该是`与状态无关`，`不依赖于 Promise 的执行结果`。
>   - 不管`promise`最后的`状态`，在执行完then或catch指定的回调函数以后，`都会执行finally方法指定的回调函数`。
>
> - `then`和`catch`和`finally` 链式调用写法
>
>   ```js
>   new Promise((resole, reject) => {
>     // 执行体
>     console.log('开始hahaha')
>     resole('成功的结果')
>   }).then((value) => {
>     // 成功时执行
>     console.log('第一次成功时调用', value)
>   }).catch((reason) => {
>     // 失败时执行
>     console.log('第一次失败时调用', reason)
>   }).finally(() => {
>     // finally的回调函数不接收任何参数，finally方法里面的操作，应该是与状态无关的，不依赖于 Promise 的执行结果。
>     // 不管promise最后的状态，在执行完then或catch指定的回调函数以后，都会执行finally方法指定的回调函数。
>     console.log('第一次调用finally')
>   }).then((value) => {
>     // 成功时执行
>     console.log('第二次成功时调用', value)
>   }).catch((reason) => {
>     // 失败时执行
>     console.log('第二次失败时调用', reason)
>   }).finally(() => {
>     // finally的回调函数不接收任何参数，finally方法里面的操作，应该是与状态无关的，不依赖于 Promise 的执行结果。
>     // 不管promise最后的状态，在执行完then或catch指定的回调函数以后，都会执行finally方法指定的回调函数。
>     console.log('第二次调用finally')
>   }).then((value) => {
>     // 成功时执行
>     console.log('第三次成功时调用', value)
>   }).catch((reason) => {
>     // 失败时执行
>     console.log('第三次失败时调用', reason)
>   }).finally(() => {
>     // finally的回调函数不接收任何参数，finally方法里面的操作，应该是与状态无关的，不依赖于 Promise 的执行结果。
>     // 不管promise最后的状态，在执行完then或catch指定的回调函数以后，都会执行finally方法指定的回调函数。
>     console.log('第三次调用finally')
>   })
>   
>   //开始hahaha
>   //第一次成功时调用 成功的结果
>   //第一次调用finally
>   //第二次成功时调用 undefined
>   //第二次调用finally
>   //第三次成功时调用 undefined
>   //第三次调用finally
>   ```
>
>   