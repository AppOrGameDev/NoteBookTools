### 集合常用API

#### 数组常用API

1. 创建数组

    ```js
    // 创建长度为3的数组
    let arr = new Array(3) // [,,]
    
    // 返回['G','r','e','g']
    let arr = new Array('Greg')
    
    //如果省略new 这只创建长度为1的数组
    let arr = new Array(3) // [3]
    let arr = new Array('Greg') // ['Greg']
    
    // 入参将类数组结构转换成新的数组实例
    let arr = Array.from(arr) // 入参可以是Array,Map,Set,或者迭代器
    
    // 将一组参数转换成数组
    let arr = Array.of(a,b,c,d) //[a,b,c,d]
    
    // ... 展开运算法
    // ...只能展开类数组，不能展开对象
    //典型应用场景:合并数组
    let newArr = [newHeader,...oldArr,newFooter] // 添加新头和尾结点的数组
    //典型应用场景:合并多个对象
    let personObj = {...oldPerson, name:'newName'} // 将name属性的Value替换为newName
    
    // 检测是否尾数组
    if (arr instanceof Array) {
        // 是数组,balabala
    }
    if (Array.isArray(arr)) {
        // 是数组,balabala
    }
    
    // js迭代集合中的元素要用of，如果是用in则迭代的是索引值，比如说index
    ```
    
2. 数组复制和填充

    ```js
    // 用填充值补全 开始<=索引<结束
    // 索引开始/结束值遇到负数就加一个数组长度; 忽略正数超过长度,负数低于长度的索引，越界了
    // 填充值是必填,开始和结束索引值非必填
    arr.fill(填充的值,索引开始值,索引结束值)
    
    // 从复制的位置开始,复制长度,插入到插入位置
    // 插入位置索引必填,后面两个非必填
    arr.copyWith(插入位置索引,复制位置索引,复制长度)
    ```

3. 数组转换

    ```js
    arr.toString()
    arr.valueOf()
    // 都是[a, b, c]  这样的字符串
    
    // 自定义连接符
    arr.join("|")  // 用|连接数组元素
    ```

    

4. 栈

    ```js
    arr.push(item1, item2, item3) // 入栈,可以一次入栈多个
    arr.pop() // 出栈,并返回弹出的结点
    ```

    

5. 队列

    ```js
    arr.push(item1, item2, item3) // 入队列尾部,可以一次入多个
    arr.pop() // 出队列尾部,并返回弹出的结点
    // 以上操作队列尾部
    
    arr.unshift(item1, item2, item3) // 入队列头部,可以一次入多个
    arr.shift() // 弹出队列第一个,并返回弹出的结点
    // 以上操作队列头部
    ```

    

6. 排序

    ```js
    arr.sort() // 正序
    arr.reverse() // 倒叙
    // 数字和字符串的大小比较
    
    // 自定义比较函数
    arr.sort((a, b) => a < b ? 1 : a > b ? : -1 : 0)
    ```

    

7. 操作

    ```js
    // 打平数组
    let newarr = arr,concat(item, [item1, item2]) // 复制原数组，在新数组尾部加入参数中的元素和数组展开后的多个元素，得到一个新数组并返回；原数组不变
    
    
    let newarr = arr.slice(开始复制索引值, 结束复制索引值) // 返回 开始复制<= 索引 < 结束复制 的新的数组
    
    // 以上方法都不会对原数组有改动，都是返回的新数组
    
    // 删除数组某些元素,则必传2个参数， 删除的索引位置,删除长度;返回的数组就是删除的元素
    // 插入元素,则必传3个及以上参数, 插入索引位置,删除长度0,插入元素
    // 替换元素,则必传3个及以上参数, 插入索引位置,删除长度,插入元素
    let newarr =  arr.splice(删除/插入的索引位置,删除长度,插入的元素1,插入的元素2,插入的元素3)
    ```

    

8. 搜索和位置

    ```js
    // 严格相等
    arr.indexOf(要搜索的元素,起始位置)
    arr.lastIndexOf(要搜索的元素,起始位置)
    arr.includes(要搜索的元素,起始位置)
    
    // 断言
    let item = arr.find((element, index, array) => {return element==1}) // 查找元素为1的元素
    let itemIndex = arr.findIndex((element, index, array) => {return element==1}) // 查找元素为1的元素索引
    ```

    

9. 迭代

    ```js
    // 入参都是函数,是以数组每一项作为参数运行的函数
    
    // 数组arr每个元素都大于2,则返回true,否则返回false
    let isAllBig2 = arr.every((item, index, array)=>{return item > 2}) // 传入函数，数组每个元素都为true则为true
    
    // 数组arr有一个元素大于2,则返回true,否则返回false
    let is ExistBig2 = arr.some((item, index, array)=>{return item > 2}) // 传入函数，数组有一个元素为true则为true
    
    // 返回大于2的元素组成的新数组
    let newarr = arr.filter((item, index, array)=>{return item > 2}) // 返回执行为true的元素，组成的新数组
    
    // 返回元素组每一项都乘2的结果，组成的新数组
    let newarr = arr.map((item, index, array)=>{ item * 2}) // 构造一个跟原数组一一对应的新数组
    
    // 对数组每一项都执行操作,修改了原数组。没有返回值，类似for循环
    arr.forEach((item, index, array)=>{ /*执行操作*/})
    ```

10. 归并

    ```js
    // 数组每个项之和
    // pre 上一次归并的值
    // curr 当前元素值
    // 函数返回结果作为下
    let sum = arr.reduce((pre, curr, index, array) => pre + curr) // 
    ```

    