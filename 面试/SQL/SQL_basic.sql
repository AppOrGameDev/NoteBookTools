-- SQL基础
select * from user_info;
select * from user_interest;

INSERT INTO sqlbasic.user_info (id, name, sex, phone) VALUES (2, '关羽', '男', '12312345678');
INSERT INTO sqlbasic.user_info (id, name, sex, phone) VALUES (3, '张飞', '男', '12312345679');
INSERT INTO sqlbasic.user_info (id, name, sex, phone) VALUES (6, '赵云', '男', '12312345670');


INSERT INTO sqlbasic.user_interest (id, dance, base, foot) VALUES (2, '舞刀', '打仗', '过关');
INSERT INTO sqlbasic.user_interest (id, dance, base, foot) VALUES (4, '你猜', '不懂', '牛逼');
INSERT INTO sqlbasic.user_interest (id, dance, base, foot) VALUES (5, '呵呵', '哦哦', '哈哈');



-- 内连接
SELECT a.id,a.name,a.sex,a.phone,b.dance,b.base,b.foot
FROM user_info AS a
INNER JOIN user_interest as b
on a.id  = b.id ;
-- 如上内连接跟下面where一样;内连接都可以用where使用
select a.*,b.* from user_info a,user_interest b where a.id = b.id;

-- 左连接
SELECT a.id,a.name,a.sex,a.phone,b.dance,b.base,b.foot
FROM user_info AS a
LEFT JOIN user_interest as b
on a.id  = b.id ;

-- 右连接
SELECT a.id,a.name,a.sex,a.phone,b.dance,b.base,b.foot
FROM user_info AS a
RIGHT JOIN user_interest as b
on a.id  = b.id ;

-- 全连接
-- MySQL不支持全连接语法;可以使用union或者union all来代替
-- union写法(敲重点:union会去重)
SELECT a.id,a.name,a.sex,a.phone,b.dance,b.base,b.foot
FROM user_info AS a
LEFT JOIN user_interest as b
on a.id  = b.id
union
SELECT a.id,a.name,a.sex,a.phone,b.dance,b.base,b.foot
FROM user_info AS a
RIGHT JOIN user_interest as b
on a.id  = b.id ;

-- union all写法(敲重点:union all不会去重)
SELECT a.id,a.name,a.sex,a.phone,b.dance,b.base,b.foot
FROM user_info AS a
LEFT JOIN user_interest as b
on a.id  = b.id
union all
SELECT a.id,a.name,a.sex,a.phone,b.dance,b.base,b.foot
FROM user_info AS a
RIGHT JOIN user_interest as b
on a.id  = b.id ;

-- Oracle是支持全连接的



-- SQL注入:不能直接拼接SQL语句;而是要用占位符?0,?1
-- MySQL性能优化
# 当只需要一条记录时, 使用 limit 1。因为MySQL在找到一条记录后就直接返回，并不会继续查找除全部结果

# MySQL有两个引擎: MyISAM和InnoDB
# MyISAM 查询效率高，写效率低；（表锁）
# InnoDB 写效率高。（行锁）


# not exists 比 not in 好; not exists 利用索引; not in 要每个都比较

# 不要用 in，not in，is null，is not null，<> 不利于索引的操作符
#  经常比较的字段可以建索引

# 创建索引
# CREATE INDEX indexName ON table_name (column_name)
# 修改表结构(添加索引)
# ALTER table tableName ADD INDEX indexName(columnName)
# 创建表的时候直接指定
# CREATE TABLE mytable(
#
# ID INT NOT NULL,
#
# username VARCHAR(16) NOT NULL,
#
# INDEX [indexName] (username(length))
#
# );
# 删除索引的语法
# DROP INDEX [indexName] ON mytable;
# 创建索引
# CREATE UNIQUE INDEX indexName ON mytable(username(length))