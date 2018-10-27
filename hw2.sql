select 'ФИО: Евгения Штраус';

-- 1. Простые выборки
-- 1.1 SELECT , LIMIT - выбрать 10 записей из таблицы rating
select * from ratings limit 10;

-- Для всех дальнейших запросов выбирать по 10 записей 
-- 1.2 WHERE, LIKE - выбрать из таблицы links всё записи, у которых imdbid оканчивается на "42", а поле movieid между 100 и 1000
select * from links 
where imdbid like '%42' 
and movieid between 100 and 1000;

-- 2. Сложные выборки: JOIN
-- 2.1 INNER JOIN выбрать из таблицы links все imdb_id, которым ставили рейтинг 5
select distinct imdbid
from links 
join ratings
on links.movieid = ratings.movieid
where ratings.rating = 5
;
-- 3. Аггрегация данных: базовые статистики
-- 3.1 COUNT() Посчитать число фильмов без оценок
select count(*) from ratings where rating is null;

-- 3.2 GROUP BY, HAVING вывести top-10 пользователей, у который средний рейтинг выше 3.5
select userid, avg(rating) 
from ratings
group by userid
having avg(rating) > 3.5
order by avg(rating) desc
limit 10;

-- 4. Иерархические запросы
-- 4.1 Подзапросы: достать 10 imbdId из links у которых средний рейтинг больше 3.5. 

select l.imdbid, avg(r.rating) avg_rating
from links l
join ratings r
on l.movieid = r.movieid
group by 1
having avg(r.rating) > 3.5
order by avg(rating) desc
limit 10;


-- 4.2 Common Table Expressions: посчитать средний рейтинг по пользователям, у которых более 10 оценок
-- Нужно подсчитать средний рейтинг по все пользователям, которые попали под условие - то есть в ответе должно быть одно число.
with users_r as (
	select userid from ratings
	group by 1
	having count(*) > 10
)
select avg(rating) from ratings
where userid in (select * from users_r)
;