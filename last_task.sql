
create table users(
	id serial unique not null, 
	created_at timestamp with time zone NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'), 
	first_name varchar(255), 
	last_name varchar(255), 
	email varchar(255), 
	create_visit_id integer, 
	source_key varchar(255)
	);


create table deals(
	id serial unique not null, 
	created_at timestamp with time zone NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'), 
	number_for_user integer, 
	user_id integer, 
	offer_id integer, 
	create_visit_id integer, 
	source_key varchar(255)
	);

create table offers(
	id serial unique not null,
	created_at timestamp with time zone NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'), 
	title varchar(255),
	cost integer
);

create table products(
	id serial unique not null,
	created_at timestamp with time zone NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'), 
	title varchar(255),
	cost integer,
	offer_id integer
);


insert into users values
(1, TIMESTAMP '2018-01-01 00:00:24', 'Мария', 'Вездесущая', 'mary@yopmail.com', 2349856,'utm:vk/cpm'),
(2, TIMESTAMP '2018-02-01 12:00:24', 'Елена', 'Майская', 'elena@yopmail.com',2389967,'utm:yadirect/cpc'),
(3, TIMESTAMP '2018-03-01 14:05:24', 'Владимир', 'Суровый', 'vova@yopmail.com',3454670,'utm:yadirect/cpc'),
(4, TIMESTAMP '2018-04-01 05:00:24', 'Софья', 'Красивая','sofya@yopmail.com', 4599234,'utm:insta/adv'),
(5, TIMESTAMP '2018-05-01 03:07:24', 'Александр', 'Панибратский', 'alex@yopmail.com', 4789009,'utm:insta/adv'),
(6, TIMESTAMP '2018-06-01 05:23:24', 'Валерий', 'Вежливый', 'valery@yopmail.com', 5439321,'utm:insta/adv');


insert into offers values
(1, TIMESTAMP '2017-12-11 12:04:45', 'Новогоднее поздравление', 1000),
(2, TIMESTAMP '2017-11-01 13:34:21', 'Набор из 2 книжек', 1500),
(3, TIMESTAMP '2018-02-03 20:23:51', 'Мастер-класс по макраме', 2000),
(4, TIMESTAMP '2018-03-13 16:10:24', 'Мастер класс по макраме расширенный', 4000);


insert into products values
(1, TIMESTAMP '2017-12-11 11:34:42', 'Новогоднее поздравление', 1000, 1),
(2, TIMESTAMP '2017-11-01 12:54:21', 'Как стать красивой', 700,2),
(3, TIMESTAMP '2017-11-01 13:15:20', 'Как стать счастливой', 800,2),
(4, TIMESTAMP '2018-02-03 18:33:41', 'Мастер-класс по макраме', 2000,3),
(5, TIMESTAMP '2018-03-13 15:46:36', 'Мастер класс по макраме расширенный', 4000,4);

insert into deals values 
(1, TIMESTAMP '2018-01-01 00:00:24', 1, 1, 1, 2349856,'utm:vk/cpm'),
(2, TIMESTAMP '2018-01-11 12:30:21', 2, 1, 2, 2376523,'utm:insta/sale'),
(3, TIMESTAMP '2018-02-04 13:08:32', 1, 2, 3, 2645674,'utm:vk/cpm'),
(4, TIMESTAMP '2018-03-01 14:05:24', 1, 3, 1, 3454670,'utm:/'),
(5, TIMESTAMP '2018-04-21 19:31:56', 1, 4, 4, 4678234,'utm:vk/cpm'),
(6, TIMESTAMP '2018-04-28 14:45:42', 2, 4, 2, 4692345,'utm:/'),
(7, TIMESTAMP '2018-05-12 17:31:54', 1, 5, 3, 4823423,'utm:insta/sale');



-- запросы

-- 1. Вывести имя, фамилию и email пользователей без заказов
select u.first_name, u.last_name, u.email
from users u 
left join deals d on u.id = d.user_id
group by u.first_name, u.last_name, u.email
having count(d.id) = 0;

-- 2. Вывести id заказов, которые были созданы одновременно с регистрацией пользователя

select d.id 
from deals d 
join users u on d.user_id = u.id and d.created_at = u.created_at;

-- 3. Вывести ключ самого популярного канала регистрации пользователей

with keys_reg as (
	select source_key, count(*) as cnt from users
	group by source_key
) 
select source_key from users
group by source_key
having count(*) = (select max(cnt) from keys_reg);

-- 4. Вывести ключ самого популярного канала создания заказа

with key_deal as (
	select id, source_key, row_number() over (partition by source_key) as num 
	from deals
	order by num desc
	limit 1)
select source_key from key_deal;


-- 5. Вывести ключ регистрации пользователей, которые сделали больше всего заказов

with key_reg as (
	select u.source_key, count(d.id) as cnt
	from users u 
	join deals d on u.id = d.user_id
	group by u.source_key
)
select source_key from key_reg where cnt = (select max(cnt) from key_reg);

-- 6. Вывести имя, фамилию пользователя, который принес больше всего денег

with users_money as (
	select u.first_name, u.last_name, sum(o.cost) over (partition by d.user_id) as money_brought
	from users u 
	join deals d on u.id = d.user_id
	join offers o on d.offer_id = o.id
) 
select first_name, last_name  
from users_money
group by first_name, last_name, money_brought
having money_brought = (select max(money_brought) from users_money)
;


-- 7. Вывести id пользователей, у которых больше 1 заказа

select user_id from deals where number_for_user > 1;

-- 8. Вывести id, title самого непопулярного предложения

with offers_paid as (
	select o.id, o.title, count(d.id) as cnt
	from deals d
	join offers o on d.offer_id = o.id
	group by o.id, o.title
)
select id, title from offers_paid
where cnt = (select min(cnt) from offers_paid);


-- 9. Вывести id, title, cost продуктов, которые покупают в первом заказе

with p_id as (
	select distinct p.id 
	from deals d
	join offers o on d.offer_id = o.id
	join products p on p.offer_id = o.id
	where d.number_for_user = 1
)
select id, title, cost from products
where id in (select * from p_id)
;


-- 10. Вывести id, title, cost предложений, после которых делают следующий заказ
with first_offers as (
	select distinct first_offer from
	(
	select id, user_id, offer_id, number_for_user,
	first_value(offer_id) over (partition by user_id order by number_for_user) as first_offer
	from deals
	) t1
	where number_for_user > 1
) select id, title, cost from offers where id in (select * from first_offers);


