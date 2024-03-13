select * from cust_info;

-- 若表存在则删除表重新建表
drop table if exists cust_info;
create table cust_info
(
    ecif_cust_no    varchar(20) null comment '客户号',
    name            varchar(20) null comment '客户名称',
    cert_type       varchar(20) null comment '证件类型',
    cert_no         varchar(50) null comment '证件号码',
    nation_code     varchar(20) null comment '国籍',
    last_updated_ts varchar(20) null comment '最新更新时间，精确到秒'
)
    comment '客户信息表';
-- 表数据
INSERT INTO cust_info (ecif_cust_no, name, cert_type, cert_no, nation_code, last_updated_ts) VALUES ('100001','李四','021','320682202304041111','CHN','20211122112156');
INSERT INTO cust_info (ecif_cust_no, name, cert_type, cert_no, nation_code, last_updated_ts) VALUES ('100002','张三','021','320682202304042222','CHN','20210205072113');
INSERT INTO cust_info (ecif_cust_no, name, cert_type, cert_no, nation_code, last_updated_ts) VALUES ('100003','王二','011','320682202304043333','CHN','20200220091826');
INSERT INTO cust_info (ecif_cust_no, name, cert_type, cert_no, nation_code, last_updated_ts) VALUES ('100001','李四','021','320682202304041111','CHN','20220615091532');
INSERT INTO cust_info (ecif_cust_no, name, cert_type, cert_no, nation_code, last_updated_ts) VALUES ('100001','李四','021','320682202304041111','SGP','20221205164211');



select * from code_map;

drop table if exists code_map;
create table code_map
(
    code_type      varchar(20) null comment '代号编码',
    code_type_desc varchar(20) null comment '中文名称',
    code_value     varchar(20) null comment '代码值',
    code_desc      varchar(20) null comment '中文说明',
    code_flag      varchar(1)  null comment '有效标志 0-有效 1-删除'
)
    comment '客户信息系统公共代码';
-- 表数据
INSERT INTO code_map (code_type, code_type_desc, code_value, code_desc, code_flag) VALUES ('CC0101001','证件类型','011','第一代居民身份证','1');
INSERT INTO code_map (code_type, code_type_desc, code_value, code_desc, code_flag) VALUES ('CC0101001','证件类型','021','第二代居民身份证','1');
INSERT INTO code_map (code_type, code_type_desc, code_value, code_desc, code_flag) VALUES ('CC0101001','证件类型','031','临时身份证','1');
INSERT INTO code_map (code_type, code_type_desc, code_value, code_desc, code_flag) VALUES ('CC0101001','证件类型','042','中国护照','1');
INSERT INTO code_map (code_type, code_type_desc, code_value, code_desc, code_flag) VALUES ('CC0101001','证件类型','056','户口簿','1');
INSERT INTO code_map (code_type, code_type_desc, code_value, code_desc, code_flag) VALUES ('CC0101011','国籍','DEU','德国','1');
INSERT INTO code_map (code_type, code_type_desc, code_value, code_desc, code_flag) VALUES ('CC0101011','国籍','CHN','中国','1');
INSERT INTO code_map (code_type, code_type_desc, code_value, code_desc, code_flag) VALUES ('CC0101011','国籍','SGP','新加坡','1');


SELECT * FROM buy_flow;
DROP TABLE IF EXISTS buy_flow;
create table buy_flow
(
    ecif_cust_no varchar(20) null comment '客户号',
    transtime    varchar(20) null comment '最新更新时间，精确到秒',
    amt          float       null comment '购买金额',
    flag         varchar(1)  null comment '是否购买成功 0-是 1-否'
)
    comment '购买流水';

INSERT INTO buy_flow (ecif_cust_no, transtime, amt, flag) VALUES ('100001','20220905164211',1000.00,'1');
INSERT INTO buy_flow (ecif_cust_no, transtime, amt, flag) VALUES ('100001','20221005032312',2500.00,'1');
INSERT INTO buy_flow (ecif_cust_no, transtime, amt, flag) VALUES ('100001','20221005124106',1000.50,'1');
INSERT INTO buy_flow (ecif_cust_no, transtime, amt, flag) VALUES ('100001','20220304113452',4000.00,'0');
INSERT INTO buy_flow (ecif_cust_no, transtime, amt, flag) VALUES ('100001','20221006093614',3000.00,'1');



-- 获取每个客户每个月购买总金额，按照客户号、月份排序;最终返回字段包括：客户号、客户名称、证件类型（中文）、证件号码、国籍（中文）、月份、总金额
-- 答案SQL
select t1.ecif_cust_no, t1.name, t2.code_desc, t1.cert_no, t3.code_desc, t4.rq, t4.sumamt
from (
         select ecif_cust_no,
                name,
                cert_type,
                cert_no,
                nation_code,
                row_number() over (partition by ecif_cust_no order by last_updated_ts desc) as rn
         from cust_info
     ) t1
         left join code_map t2 on t1.cert_type = t2.code_value and t2.code_type = 'CC0101001'
         left join code_map t3 on t1.nation_code = t3.code_value and t3.code_type = 'CC0101011'
         left join (select ecif_cust_no, substr(transtime, 1, 6) rq, sum(amt) sumamt
                    from buy_flow
                    where flag = '1'
                    group by ecif_cust_no, substr(transtime, 1, 6)) t4
                   on t4.ecif_cust_no = t1.ecif_cust_no
where t1.rn = 1
order by t1.ecif_cust_no, t4.rq;

-- 流水按客户号分组;每个客户每月购买总金额

select ecif_cust_no,substr(transtime, 1, 6) as yuefen ,sum(amt) as sumamt  ,flag from buy_flow where flag = '1' group by ecif_cust_no, substr(transtime, 1, 6) ;


select C.*,D.code_desc as guojizhongwen from
(select A.ecif_cust_no, A.name, A.cert_type, A.cert_no,A.nation_code,B.code_desc as zhengjianleixingzhongwen from cust_info A, code_map B where A.cert_type = B.code_value) C, code_map D where C.nation_code = D.code_value;




-- 优化成两个左连接
select distinct A.ecif_cust_no, A.name, A.cert_type, A.cert_no,A.nation_code,B.code_desc as zhengjianleixingzhongwen,C.code_desc as guojizhongwen from cust_info A left join code_map B on A.cert_type = B.code_value and B.code_type = 'CC0101001' left join code_map C on A.nation_code = C.code_value and C.code_type = 'CC0101011';

-- 最后的结果
-- 根据left join拆分看，前两个是替换证件类型和国籍为中文，最后一个是补充每月购买总金额
select distinct A.ecif_cust_no,
                A.name,
                B.code_desc as cert_type,
                A.cert_no,
                C.code_desc as guojizhongwen,
                E.yuefen,
                E.sumamt
from cust_info A
         left join code_map B on A.cert_type = B.code_value and B.code_type = 'CC0101001'
         left join code_map C on A.nation_code = C.code_value and C.code_type = 'CC0101011'
         left join
     (select ecif_cust_no, substr(transtime, 1, 6) as yuefen, sum(amt) as sumamt, flag
      from buy_flow
      where flag = '1'
      group by ecif_cust_no, substr(transtime, 1, 6)) E on A.ecif_cust_no = E.ecif_cust_no
order by A.ecif_cust_no, E.yuefen;




select ecif_cust_no,
    name,
    cert_type,
    cert_no,
    nation_code,
    row_number() over (partition by ecif_cust_no order by last_updated_ts desc) as rn
from cust_info;



select sc.score， st.*
from sc
         left join student st
                   on sc.sid = st.sid
where sc.cid in (select c.cid
                 from course c
                          join teacher t
                               on c.tid = t.tid
                 where t.tname = '张三');
-- 张三老师教哪些课
-- 学习这些课的学生
-- 这些学生的信息和分数
