-- 建表
-- 学生表
create table student
(
    sid   int         null,
    sname varchar(32) null,
    sage  int         null,
    ssex  varchar(8)  null
);
-- 教师表
create table teacher
(
    tid   int         null,
    tname varchar(16) null
);
-- 课程表
create table course
(
    cid   int         null,
    cname varchar(32) null,
    ct    int         null
);
-- 分数表
create table sc
(
    sid   int null,
    cid   int null,
    score int null
);
-- 数据准备
select * from student;
select * from Teacher;
select * from Course;
select * from SC;

insert into Student select 1,'刘一',18,'男' union all
 select 2,'钱二',19,'女' union all
 select 3,'张三',17,'男' union all
 select 4,'李四',18,'女' union all
 select 5,'王五',17,'男' union all
 select 6,'赵六',19,'女' ;

 insert into Teacher select 1,'叶平' union all
 select 2,'贺高' union all
 select 3,'杨艳' union all
 select 4,'周磊';

 insert into Course select 1,'语文',1 union all
 select 2,'数学',2 union all
 select 3,'英语',3 union all
 select 4,'物理',4;

 insert into SC
 select 1,1,56 union all
 select 1,2,78 union all
 select 1,3,67 union all
 select 1,4,58 union all
 select 2,1,79 union all
 select 2,2,81 union all
 select 2,3,92 union all
 select 2,4,68 union all
 select 3,1,91 union all
 select 3,2,47 union all
 select 3,3,88 union all
 select 3,4,56 union all
 select 4,2,88 union all
 select 4,3,90 union all
 select 4,4,93 union all
 select 5,1,46 union all
 select 5,3,78 union all
 select 5,4,53 union all
 select 6,1,35 union all
 select 6,2,68 union all
 select 6,4,71;

-- 查询“001”课程比“002”课程成绩高的所有学生的学号

select a.sid
from (select b.sid, b.score from sc b where b.cid = 1) a,
     (select c.sid, c.score from sc c where c.cid = 2) d
where a.score > d.score
  and a.sid = d.sid;

-- 查询平均成绩大于60分的同学的学号和平均成绩
select * from (select a.sid, avg(a.score) as avgscore from sc a group by a.sid) b where b.avgscore > 60;
-- 优化后(having是放在group by之后，即分组过后的过滤条件，having后面只能是返回true或false的条件语句)
select a.sid, avg(a.score) as avgscore from sc a group by a.sid having avgscore > 60;


-- 查询所有同学的学号、姓名、选课数、总成绩
select b.sid, b.sname, c.courseNum, c.sumNum
from student b,
     (select a.sid, count(a.cid) as courseNum, sum(a.score) as sumNum from sc a group by a.sid) c
where b.sid = c.sid;
-- 优化后
select a.sid, a.sname, count(b.cid) as courseNum, sum(b.score) as sumNum
from student a
         left join sc b on a.sid = b.sid
group by a.sid, a.sname;


-- 查询姓“李”的老师的个数
select a.tname,count(a.tname) from teacher a where a.tname like '李%' group by a.tname;

-- 查询没学过“叶平”老师课的同学的学号、姓名
-- 分页查询 limit 0,10  第一页10条记录
select d.sid, d.sname
from student d
where d.sid not in (select distinct c.sid
                    from sc c
                    where c.cid in (select b.cid
                                    from teacher a,
                                         course b
                                    where a.tname = '叶平'
                                      and a.tid = b.ct));
-- 学过这些课程ID的学生
select distinct c.sid
from sc c
where c.cid in (select b.cid
                from teacher a,
                     course b
                where a.tname = '叶平'
                  and a.tid = b.ct);
-- 叶平老师教的课程ID,
select b.cid
from teacher a,
     course b
where a.tname = '叶平'
  and a.tid = b.ct;

-- 查询学过“001”并且也学过编号“002”课程的同学的学号、姓名
select c.sid, c.sname
from student c
where c.sid in (select distinct d.sid
from (select a.sid,a.cid as onecid,b.cid  from sc a left join sc b on a.sid = b.sid having (a.cid = 1 and b.cid = 2)) d);
-- 更加优化的解法
select a.sid,a.sname from student a, sc b where a.sid = b.sid and b.cid = 1 and exists(select c.sid from sc c where a.sid = c.sid and c.cid = 2);

-- 查询学过“叶平”老师所教的所有课的同学的学号、姓名
select f.sid, f.sname
from student f,
     (select c.sid, count(c.sid) as ccount
      from sc c,
           course d,
           teacher e
      where c.cid = d.cid
        and d.ct = e.tid
        and e.tname = '叶平'
      group by c.sid
      having ccount = (select count(b.cid)
                       from teacher a,
                            course b
                       where a.tid = b.ct
                         and a.tname = '叶平')) g
where f.sid = g.sid;

select c.sid, count(c.sid) as ccount
from sc c,
     course d,
     teacher e
where c.cid = d.cid
  and d.ct = e.tid
  and e.tname = '叶平'
group by c.sid
having ccount = (select count(b.cid)
                 from teacher a,
                      course b
                 where a.tid = b.ct
                   and a.tname = '叶平');

select b.cid, count(b.cid) as ccount
from teacher a,
     course b
where a.tid = b.ct
  and a.tname = '叶平'
group by b.cid;
-- 叶平老师教的所有课的IDs
select count(b.cid)
from teacher a,
     course b
where a.tid = b.ct
  and a.tname = '叶平';


-- 查询课程编号“002”的成绩比课程编号“001”课程低的所有同学的学号、姓名
select c.sid, c.sname
from student c,
     (select a.sid, a.cid as twocid, a.score as twoscore, b.cid as onecid, b.score as onescore
      from sc a
               left join sc b on a.sid = b.sid
      having (a.cid = 2 and b.cid = 1 and a.score < b.score)) d
where c.sid = d.sid;


select d.sid, d.sname
from (select a.sid, a.sname, b.score, (select c.score from sc c where c.sid = a.sid and c.cid = 2) score2
      from student a,
           sc b
      where a.sid = b.sid
        and b.cid = 1) d
where d.score2 < d.score;


select * from sc;


select sid,COUNT(score) as sum from sc group by sid order by sum desc limit 2,1;
# 查询sc表,输出每个人第二高的成绩
# 再联合sc表剔除掉第一成绩的,剩下的再重复上面的求最大值
# 每个人最高成绩
select d.sid,max(d.score) from
(select b.sid,b.score from sc b,
(select a.sid,max(a.score) as max_score from sc a group by a.sid) c
where b.sid = c.sid and b.score < c.max_score) d group by d.sid;

select * from sc;


SELECT CURDATE(),DATE_ADD(CURDATE(),INTERVAL 1 day),DATE_SUB(CURDATE(),INTERVAL 1 day);
SELECT CURDATE(),DATE_ADD(CURDATE(),INTERVAL 1 MONTH),DATE_SUB(CURDATE(),INTERVAL 1 MONTH);
SELECT CURDATE(),DATE_ADD(CURDATE(),INTERVAL 1 year),DATE_SUB(CURDATE(),INTERVAL 1 year);

#
# 3. 索引什么时候会失效？
# 查询条件包含or，可能导致索引失效
# 如果字段类型是字符串，where时一定用引号括起来，否则索引失效
# like通配符可能导致索引失效。
# 联合索引，查询时的条件列不是联合索引中的第一个列，索引失效。
# 在索引列上使用 mysql 的内置函数，索引失效。
# 对索引列运算（如，+、-、*、/），索引失效。
# 索引字段上使用（！= 或者 < >，not in）时，可能会导致索引失效。
# 索引字段上使用is null， is not null，可能导致索引失效。
# 左连接查询或者右连接查询查询关联的字段编码格式不一样，可能导致索引失效。
# mysql 估计使用全表扫描要比使用索引快,则不使用索引。
#
# 4. 哪些场景不适合建立索引？
# 数据量少的表，不适合加索引
# 更新比较频繁的也不适合加索引
# 区分度低的字段不适合加索引（如性别）
# where、group by、order by等后面没有使用到的字段，不需要建立索引
# 已经有冗余的索引的情况（比如已经有a,b的联合索引，不需要再单独建立a索引）


# B树
# 是一种多路搜索树（并不是二叉的）：
# 1.定义任意非叶子结点最多只有M个儿子；且M>2；
# 2.根结点的儿子数为[2, M]；
# 3.除根结点以外的非叶子结点的儿子数为[M/2, M]；
# 4.每个结点存放至少M/2-1（取上整）和至多M-1个关键字；（至少2个关键字）
# 5.非叶子结点的关键字个数=指向儿子的指针个数-1；
# 6.非叶子结点的关键字：K[1], K[2], …, K[M-1]；且K[i] < K[i+1]；
# 7.非叶子结点的指针：P[1], P[2], …, P[M]；其中P[1]指向关键字小于K[1]的子树，P[M]指向关键字大于K[M-1]的子树，其它P[i]指向关键字属于(K[i-1], K[i])的子树；
# 8.所有叶子结点位于同一层；

# B树的特性：
# 1.关键字集合分布在整颗树中；
# 2.任何一个关键字出现且只出现在一个结点中；
# 3.搜索有可能在非叶子结点结束；
# 4.其搜索性能等价于在关键字全集内做一次二分查找；
# 5.自动层次控制；


# B+的特性：
# 1.所有关键字都出现在叶子结点的链表中（稠密索引），且链表中的关键字恰好是有序的；
# 2.不可能在非叶子结点命中；
# 3.非叶子结点相当于是叶子结点的索引（稀疏索引），叶子结点相当于是存储（关键字）数据的数据层；
# 4.更适合文件索引系统；

#
# B-树,B+树,B*树 总结对比
# 首先注意：B树就是B-树，"-"是个连字符号，不是减号。
# B-树是一种平衡的多路查找(又称排序)树，在文件系统中有所应用。主要用作文件的索引。其中的B就表示平衡(Balance)
# B+树有一个最大的好处，方便扫库，B树必须用中序遍历的方法按序扫库，而B+树直接从叶子结点挨个扫一遍就完了。
# B+树支持range-query(区间查询)非常方便，而B树不支持。这是数据库选用B+树的最主要原因。