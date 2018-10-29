SELECT ('ФИО: Евгения Штраус');

/* Оконные функции.
Вывести список пользователей в формате userId, movieId, normed_rating, avg_rating где

userId, movieId - без изменения
для каждого пользователя преобразовать рейтинг r в нормированный - normed_rating=(r - r_min)/(r_max - r_min), где r_min и r_max соответственно 
минимально и максимальное значение рейтинга у данного пользователя
avg_rating - среднее значение рейтинга у данного пользователя
Вывести первые 30 таких записей
*/

select userid, movieid, rating,
(rating - min(rating) over (partition by userid)) / (max(rating) over (partition by userid) - min(rating) over (partition by userid)) as normed_rating,
avg(rating) over (partition by userid) as avg_rating
from ratings
limit 30; 

-- Напишите команду создания таблички keywords у неё должно быть 2 поля - id(числовой) и tags (текстовое). 

CREATE TABLE IF NOT EXISTS keywords (
id integer,
tags varchar(255)
);


-- Напишите команду копирования данных из файла в созданную вами таблицу

\copy keywords FROM '/data/keywords.csv' DELIMITER ',' CSV HEADER



 -- запрос 3

with top_rated as (
	select movieid, avg(rating) avg_rating
	from ratings
	group by 1
	having count(distinct userid) > 50
	order by avg_rating desc, movieid asc
	limit 150
)
select t.movieid, avg_rating, tags into top_rated_tags from top_rated t
join keywords k
on t.movieid = k.movieid


-- выгрузка данных
\copy (SELECT * FROM top_rated_tags) TO 'top_rated_tags.csv' WITH CSV HEADER DELIMITER as ';';