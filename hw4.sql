SELECT ('ФИО: Евгения Штраус');

-- используя функцию определения размера таблицы, вывести top-5 самых больших таблиц базы

select table_name, pg_total_relation_size(table_name) as table_size
from information_schema.tables
WHERE table_schema NOT IN ('information_schema','pg_catalog')
order by 2 desc
limit 5;


-- array_agg: собрать в массив все фильмы, просмотренные пользователем (без повторов)
select userid, array_agg(distinct movieid) as user_views
from ratings
group by 1;


-- таблица user_movies_agg, в которую сохраните результат предыдущего запроса
drop table if exists user_movies_agg;

select * into small_ratings from (select * from ratings limit 10000) t1;

select userid, user_views into public.user_movies_agg from 
(
	select userid, array_agg(distinct movieid) as user_views
	from small_ratings
	group by 1
) t1;


-- Используя следующий синтаксис, создайте функцию cross_arr оторая принимает на вход два массива arr1 и arr2.
-- Функциия возвращает массив, который представляет собой пересечение контента из обоих списков.
-- Примечание - по именам к аргументам обращаться не получится, придётся делать через $1 и $2.


-- версия sql
create or replace function cross_arr_s (int[], int[]) returns setof int  as 
	$$ 
	select unnest($1) 
	intersect
	select unnest($2)
	$$
	language sql;


-- версия plpgsql
create or replace function cross_arr(bigint[], bigint[]) RETURNS bigint[] AS 
$$
    DECLARE x integer;
    DECLARE arr bigint[];
    DECLARE numb integer;
BEGIN
    numb = 0;
    FOR x IN (select unnest($1) intersect select unnest($2)) LOOP
    	numb = numb + 1;
    	arr[numb] = x;
    END LOOP;
    RETURN arr;
END;
$$ LANGUAGE plpgsql;



-- Сформируйте запрос следующего вида: достать из таблицы всевозможные наборы u1, r1, u2, r2.
-- u1 и u2 - это id пользователей, r1 и r2 - соответствующие массивы рейтингов
-- ПОДСКАЗКА: используйте CROSS JOIN


select agg_1.userid as u1, agg_2.userid as u2, agg_1.user_views as ar1, agg_2.user_views as ar2 
from user_movies_agg as agg_1
cross join user_movies_agg as agg_2
where agg_1.userid <> agg_2.userid
;

-- Оберните запрос в CTE и примените к парам <ar1, ar2> функцию CROSS_ARR, которую вы создали
-- вы получите триплеты u1, u2, crossed_arr
-- созхраните результат в таблицу common_user_views
drop table if exists common_user_views;

with user_pairs as (
	select agg_1.userid as u1, agg_2.userid as u2, agg_1.user_views as ar1, agg_2.user_views as ar2 
	from user_movies_agg as agg_1
	cross join user_movies_agg as agg_2
	where agg_1.userid <> agg_2.userid
) select u1, u2, cross_arr(ar1, ar2) into public.common_user_views from user_pairs;

-- Оставить как есть - это просто SELECT из таблички common_user_views для контроля результата
select * from common_user_views LIMIT 3;

-- Создайте по аналогии с cross_arr функцию diff_arr, которая вычитает один массив из другого.
-- Подсказка: используйте оператор SQL EXCEPT.

create or replace function diff_arr(bigint[], bigint[]) RETURNS bigint[] AS 
$$
    DECLARE x integer;
    DECLARE arr bigint[];
    DECLARE numb integer;
BEGIN
    numb = 0;
    FOR x IN (select unnest($1) except select unnest($2)) LOOP
    	numb = numb + 1;
    	arr[numb] = x;
    END LOOP;
    RETURN arr;
END;
$$ LANGUAGE plpgsql;


-- Сформируйте рекомендации - для каждой пары посоветуйте для u1 контент, который видел u2, но не видел u1 (в виде массива).
-- Подсказка: нужно заджойнить user_movies_agg и common_user_views и применить вашу функцию diff_arr к соответствующим полям.
-- с векторами фильмов

with user_common as 
(
	select * from 
	common_user_views views join 
	user_movies_agg users
	on views.u2 = users.userid
	where views.cross_arr is not null
	order by array_length(views.cross_arr,1) desc
)
select u1, diff_arr(user_views,cross_arr) from user_common
limit 10;




------------------------------------------------------------------------------------------------------------------
