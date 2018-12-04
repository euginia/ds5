create table department(id serial unique not null, name varchar(255));
create table employee(id serial unique not null, department_id integer, chief_doc_id integer, name varchar(255), num_public integer);

insert into department values
('1', 'Therapy'), ('2', 'Neurology'), ('3', 'Cardiology'), ('4', 'Gastroenterology'), ('5', 'Hematology'), ('6', 'Oncology');

insert into employee values
('1', '1', '1', 'Kate', 4), ('2', '1', '1', 'Lidia', 2), ('3', '1', '1', 'Alexey', 1), ('4', '1', '2', 'Pier', 7), ('5', '1', '2', 'Aurel', 6),
('6', '1', '2', 'Klaudia', 1), ('7', '2', '3', 'Klaus', 12), ('8', '2', '3', 'Maria', 11), ('9', '2', '4', 'Kate', 10), ('10', '3', '5', 'Peter', 8),
('11', '3', '5', 'Sergey', 9), ('12', '3', '6', 'Olga', 12), ('13', '3', '6', 'Maria', 14), ('14', '4', '7', 'Irina', 2), ('15', '4', '7', 'Grit', 10),
('16', '4', '7', 'Vanessa', 16), ('17', '5', '8', 'Sascha', 21), ('18', '5', '8', 'Ben', 22), ('19', '6', '9', 'Jessy', 19), ('20', '6', '9', 'Ann', 18);


-- Вывести список названий департаментов и количество главных врачей в каждом из этих департаментов

select d.name, count(distinct e.chief_doc_id)
from department d
left join employee e
on d.id = e.department_id
group by 1;

-- Вывести список департамент id в которых работаю 3 и более сотрудника

select department_id
from employee 
group by 1
having count(id) > 3;


-- Вывести список департамент id с максимальным количеством публикаций
with num_pub as (
	select department_id, sum(num_public) as sum_pub
	from employee
	group by 1
)
select department_id, sum(num_public)
from employee
group by 1 
having sum(num_public) = (select max(sum_pub) from num_pub)
;


-- Вывести список имен сотрудников и департаментов с минимальным количеством публикаций(?)в своем департаментe

select d_name, e_name from (
	select d.name as d_name, e.name as e_name, e.num_public, row_number() over (partition by e.department_id order by e.num_public) as min_num_pub
	from department d
	left join employee e
	on d.id = e.department_id) t1
where min_num_pub = 1
;

-- Вывести список названий департаментов и среднее количество публикаций для тех департаментов, в которых работает более одного главного врача
with chief_cnt as (
	select department_id, count(distinct chief_doc_id)
	from employee 
	group by 1
	having count(distinct chief_doc_id) > 1
)
select d.name, avg(num_public)
from department d
left join employee e
on d.id = e.department_id
where d.id in (select department_id from chief_cnt)
group by 1
;

