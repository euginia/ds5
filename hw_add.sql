-- Создаём партиционированную таблицу с рейтингами

CREATE TABLE links_parted (
	movieid bigint,               
	imdbid character varying(20),
	tmdbid character varying(20) 
);


-- Создаём шарды -табличку с ограничениями на одно из полей - ключ шарда.

CREATE TABLE links_parted_0 (
    CHECK ( movieid % 2 = 0 )
) INHERITS (links_parted);

CREATE TABLE links_parted_1 (
    CHECK ( movieid % 2 = 1 )
) INHERITS (links_parted);

-- Чтобы заливка происходила правильно, нужно создать дополнительное правило-триггер

CREATE RULE links_insert_0 AS ON INSERT TO links_parted
WHERE ( movieid % 2 = 0 )
DO INSTEAD INSERT INTO links_parted_0 VALUES ( NEW.* );


CREATE RULE links_insert_1 AS ON INSERT TO links_parted
WHERE ( movieid % 2 = 1 )
DO INSTEAD INSERT INTO links_parted_1 VALUES ( NEW.* );


--Проверим, как все работает

INSERT INTO links_parted (
    SELECT *
    FROM links
    limit 10000
);

-- Проверяем результат

SELECT COUNT (*)
FROM links_parted
;

-- Ещё одна проверка

SELECT COUNT (*)
FROM links_parted_0
;

SELECT COUNT (*)
FROM links_parted_1
;