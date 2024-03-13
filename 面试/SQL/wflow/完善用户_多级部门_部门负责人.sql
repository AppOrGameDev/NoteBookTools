# 部门表
select * from  wflow_pro.wflow_departments;
# 角色表
select * from  wflow_pro.wflow_roles;
# 用户部门关系表
select * from  wflow_pro.wflow_user_departments;
# 用户角色关系表
select * from  wflow_pro.wflow_user_roles;
# 用户表
select * from  wflow_pro.wflow_users;

# 业务部           leader 铁蛋
# 生产管理部        leader 天边云 52458514
# 行政人事部        leader 海中岛 52141256
# 客服部           leader 李秋香
# xx科技有限公司    leader 旅人
# 销售服务部        leader 隔壁老王
# 研发部           leader 张三

# 组织架构



# INSERT INTO wflow_pro.wflow_users (user_id, user_name, pingyin, py, alisa, avatar, sign, sex, entry_date, leave_date, created, updated) VALUES (52458514, '天边云', 'tianbianyun', 'tby', 'tby', null, null, true, '2019-09-16', null, CURRENT_TIME, CURRENT_TIME);
# INSERT INTO wflow_pro.wflow_users (user_id, user_name, pingyin, py, alisa, avatar, sign, sex, entry_date, leave_date, created, updated) VALUES (52141256, '海中岛', 'haizhongdao', 'hzd', 'hzd', null, null, true, '2019-09-16', null, CURRENT_TIME, CURRENT_TIME);
# INSERT INTO wflow_pro.wflow_users (user_id, user_name, pingyin, py, alisa, avatar, sign, sex, entry_date, leave_date, created, updated) VALUES (32568741, '陆上山', 'lushangshan', 'lss', 'lss', null, null, true, '2019-09-16', null, CURRENT_TIME, CURRENT_TIME);



# INSERT INTO wflow_pro.wflow_user_departments (id, user_id, dept_id, created) VALUES (12, '52458514', '231535', CURRENT_TIME);
# INSERT INTO wflow_pro.wflow_user_departments (id, user_id, dept_id, created) VALUES (13, '52141256', '264868', CURRENT_TIME);
# INSERT INTO wflow_pro.wflow_user_departments (id, user_id, dept_id, created) VALUES (14, '32568741', '231535', CURRENT_TIME);

select * from wflow_pro.wflow_model_historys;
select * from wflow_pro.wflow_models;