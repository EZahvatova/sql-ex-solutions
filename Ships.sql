/*
Рассматривается БД кораблей, участвовавших во второй мировой войне. Имеются следующие отношения:
Classes (class, type, country, numGuns, bore, displacement)
Ships (name, class, launched)
Battles (name, date)
Outcomes (ship, battle, result)
Корабли в «классах» построены по одному и тому же проекту, и классу присваивается либо имя первого корабля, построенного по данному проекту, либо названию класса дается имя проекта, которое не совпадает ни с одним из кораблей в БД. Корабль, давший название классу, называется головным.
Отношение Classes содержит имя класса, тип (bb для боевого (линейного) корабля или bc для боевого крейсера), страну, в которой построен корабль, число главных орудий, калибр орудий (диаметр ствола орудия в дюймах) и водоизмещение ( вес в тоннах). В отношении Ships записаны название корабля, имя его класса и год спуска на воду. В отношение Battles включены название и дата битвы, в которой участвовали корабли, а в отношении Outcomes – результат участия данного корабля в битве (потоплен-sunk, поврежден - damaged или невредим - OK).
Замечания. 1) В отношение Outcomes могут входить корабли, отсутствующие в отношении Ships. 2) Потопленный корабль в последующих битвах участия не принимает.
*/

--31
/*
Для классов кораблей, калибр орудий которых не менее 16 дюймов, укажите класс и страну.
*/
SELECT
  class,
  country
FROM Classes
WHERE bore >= 16;
--33
/*
Укажите корабли, потопленные в сражениях в Северной Атлантике (North Atlantic). Вывод: ship.
*/
SELECT
  ship
FROM Outcomes
WHERE battle = 'North Atlantic' AND result = 'sunk';
--34
/*
По Вашингтонскому международному договору от начала 1922 г. запрещалось строить линейные корабли водоизмещением более 35 тыс.тонн. Укажите корабли, нарушившие этот договор (учитывать только корабли c известным годом спуска на воду). Вывести названия кораблей.
*/
SELECT
  name
FROM Ships a
  LEFT JOIN Classes b
    ON a.class = b.class
WHERE displacement > 35000 AND launched > 1921 AND type = 'bb';
--36
/*
Перечислите названия головных кораблей, имеющихся в базе данных (учесть корабли в Outcomes).
 */
SELECT
  ship
FROM Outcomes
UNION
SELECT
  name
FROM Ships
WHERE name = class;
--37
/*
Найдите классы, в которые входит только один корабль из базы данных (учесть также корабли в Outcomes).
 */
WITH v0 AS (
  SELECT DISTINCT
    class
  FROM Outcomes
    LEFT JOIN Classes
      ON class = Outcomes.ship
  WHERE ship NOT IN (
    SELECT
      name
    FROM Ships
  )
  UNION ALL
  SELECT
    class
  FROM Ships
)
SELECT
  class
FROM v0
GROUP BY class
HAVING COUNT(class) = 1;
--38
/*
Найдите страны, имевшие когда-либо классы обычных боевых кораблей ('bb') и имевшие когда-либо классы крейсеров ('bc').
*/
SELECT
  country
FROM Classes
WHERE type = 'bb'
INTERSECT
SELECT
  country
FROM Classes
WHERE type = 'bc';
--39
/*
Найдите корабли, `сохранившиеся для будущих сражений`; т.е. выведенные из строя в одной битве (damaged), они участвовали в другой, произошедшей позже.
*/
WITH v0 AS (
  SELECT
    ship,
    date,
    result
  FROM Outcomes a
    LEFT JOIN Battles b
      ON a.battle = b.name
)
SELECT DISTINCT
  a.ship
FROM v0 a
  LEFT JOIN v0 b
    ON a.ship = b.ship
    AND a.date < b.date
WHERE a.result IN ('OK', 'damaged')
  AND b.result IN ('OK', NULL);
--42
/*
Найдите названия кораблей, потопленных в сражениях, и название сражения, в котором они были потоплены.
*/
SELECT
  ship,
  battle
FROM Outcomes
WHERE result = 'sunk';
--43
/*
Укажите сражения, которые произошли в годы, не совпадающие ни с одним из годов спуска кораблей на воду.
*/
SELECT
  name
FROM Battles
WHERE year(date) NOT IN (
  SELECT
    year(launched)
  FROM Ships
)
  AND date IS NOT NULL;
--44
/*
Найдите названия всех кораблей в базе данных, начинающихся с буквы R
*/
WITH v0 AS (
  SELECT
    class
  FROM Classes
  UNION
  SELECT
    name
  FROM Ships
  UNION
  SELECT
    ship

  FROM Outcomes
)
SELECT
  class
--  source,
--  COUNT(1)
FROM v0
--GROUP BY 1--, 2
--having count(1)>1
WHERE class LIKE 'R%';
--45
/*
Найдите названия всех кораблей в базе данных, начинающихся с буквы R.
*/
WITH v0 AS (
  SELECT
    class
  FROM Classes
  UNION
  SELECT
    name
  FROM Ships
  UNION
  SELECT
    ship
  FROM Outcomes
)
SELECT *
FROM v0
WHERE class LIKE '% % %';
--46
/*
 Для каждого корабля, участвовавшего в сражении при Гвадалканале (Guadalcanal), вывести название, водоизмещение и число орудий.
 */
WITH v0 AS (
  SELECT
    name,
    class
  FROM Ships
  UNION
  SELECT
    class,
    class
  FROM Classes
)
SELECT
  a.name,
  displacement,
  numguns
FROM v0 a RIGHT JOIN outcomes b
ON a.name=b.ship
  LEFT JOIN classes c
  ON a.class=c.class
WHERE b.battle = 'Guadalcanal';
--47
/*
Определить страны, которые потеряли в сражениях все свои корабли.
*/
WITH v0 AS (
  SELECT
    COALESCE(c.country, d.country) AS country,
    COALESCE(a.ship, b.name) AS ship,
    result
  FROM Ships b
    FULL JOIN
  Outcomes a
      ON a.ship = b.name
    LEFT JOIN Classes c
      ON b.class = c.class
    LEFT JOIN Classes d
      ON a.ship = d.class
),sunk AS (
  SELECT
    country,
    ship
  FROM v0
  WHERE result = 'sunk'
),alive AS (
  SELECT
    a.country
  FROM v0 a
    LEFT JOIN sunk b
      ON a.country = b.country
      AND a.ship = b.ship
  WHERE b.ship IS NULL
    AND a.country IS NOT NULL
)
SELECT DISTINCT
  country
FROM v0
WHERE country NOT IN (
  SELECT
    country
  FROM alive
)
;
--48
/*
Найдите классы кораблей, в которых хотя бы один корабль был потоплен в сражении
*/
WITH v0 AS (
  SELECT
    class,
    result
  FROM Outcomes o
    LEFT JOIN Classes c
      ON o.ship = c.class
  UNION
  SELECT
    class,
    result
  FROM Outcomes o
    LEFT JOIN Ships s
      ON o.ship = s.name
)
SELECT
  class
FROM v0
WHERE result = 'sunk' AND class NOT NULL;
--49
/*
Найдите названия кораблей с орудиями калибра 16 дюймов (учесть корабли из таблицы Outcomes).
*/
WITH v0 AS (
  SELECT
    name,
    bore
  FROM Classes c RIGHT JOIN ships s
  ON c.class=s.class
  UNION
  SELECT
    ship, bore
  FROM
    classes c RIGHT JOIN Outcomes o
  ON o.ship=c.class
)
SELECT
  v0.name
FROM v0
WHERE bore = '16';
--50
/*
Найдите сражения, в которых участвовали корабли класса Kongo из таблицы Ships.
*/
SELECT DISTINCT
  battle
FROM Ships s
  LEFT JOIN Outcomes o
    ON s.name = o.ship
WHERE class = 'Kongo' AND battle <> 'NULL';
--51
/*
Найдите названия кораблей, имеющих наибольшее число орудий среди всех имеющихся кораблей такого же водоизмещения (учесть корабли из таблицы Outcomes).
 */
WITH v0 AS (
  SELECT
    name,
    numGuns,
    displacement
  FROM Classes c RIGHT JOIN ships s
  ON c.class=s.class
  UNION
  SELECT
    ship, numguns, displacement
  FROM
    classes c RIGHT JOIN Outcomes o
  ON o.ship=c.class
), v1 AS (
  SELECT
    v0.displacement,
    MAX(numGuns) AS numguns
  FROM v0
  GROUP BY displacement
)
SELECT
  name
FROM v0 RIGHT JOIN v1
ON v0.displacement=v1.displacement
  AND v0.numguns=v1.numguns
WHERE name IS NOT NULL;
--52
/*
Определить названия всех кораблей из таблицы Ships, которые могут быть линейным японским кораблем,
имеющим число главных орудий не менее девяти, калибр орудий менее 19 дюймов и водоизмещение не более 65 тыс.тонн
*/
SELECT
  name
FROM Classes c RIGHT JOIN ships s
ON c.class=s.class
WHERE country='Japan'
    AND type='bb'
    AND numguns>=9
    AND bore
    <19
    AND displacement<=65000;
--53
/*
Определите среднее число орудий для классов линейных кораблей.
Получить результат с точностью до 2-х десятичных знаков.
 */
SELECT
  AVG(CAST(numGuns AS numeric))
FROM Classes
WHERE type = 'bb';
--54
/*
С точностью до 2-х десятичных знаков определите среднее число орудий всех линейных кораблей (учесть корабли из таблицы Outcomes)
*/
WITH v0 AS (
  SELECT
    name,
    class
  FROM Ships
  UNION
  SELECT
    class,
    class
  FROM Classes
  UNION
  SELECT
    ship,
    class
  FROM Outcomes a
    LEFT JOIN Ships b
      ON a.ship = b.name
)
SELECT
  AVG(CAST(numGuns AS numeric))
FROM v0 b
  LEFT JOIN Classes c
    ON b.class = c.class
WHERE type = 'bb';
--55
/*Для каждого класса определите год, когда был спущен на воду первый корабль этого класса. Если год спуска на воду головного корабля неизвестен, определите минимальный год спуска на воду кораблей этого класса. Вывести: класс, год.
*/
WITH v0 AS (
  SELECT
    class,
    launched
  FROM Ships
  UNION
  SELECT
    class,
    NULL
  FROM Classes
)
SELECT
  class,
  MIN(launched)
FROM v0
GROUP BY class;
--56
/*Для каждого класса определите число кораблей этого класса, потопленных в
сражениях. Вывести: класс и число потопленных кораблей.
*/
WITH potential_ships AS (
  SELECT
    name,
    class
  FROM Ships
  UNION
  SELECT
    class,
    class
  FROM Classes
)
SELECT
  class,
  SUM(
    CASE
      WHEN result = 'sunk'
        THEN 1
      ELSE 0
      END)
FROM potential_ships a
  LEFT JOIN Outcomes b
    ON a.name = b.ship
GROUP BY class;
-- 57
/*
Для классов, имеющих потери в виде потопленных кораблей и не менее 3 кораблей в базе данных, вывести имя класса и число потопленных кораблей
*/
WITH potential_ships AS (
  SELECT
    name,
    class
  FROM Ships
  UNION
  SELECT
    class,
    class
  FROM Classes
),v0 AS (
  SELECT
    class,
    SUM(CASE WHEN result = 'sunk' THEN 1 ELSE 0 END) AS sunk,
    COUNT(1) AS c

  FROM potential_ships a
    LEFT JOIN outcomes b
      ON b.ship = a.name
  GROUP BY class

)
SELECT
  class,
  sunk
FROM v0
WHERE sunk > 0
  AND c >=3;
--70
/*
Укажите сражения, в которых участвовало по меньшей мере три корабля одной и той же страны.
*/
WITH potential_ships AS (
  SELECT
    name,
    country
  FROM Ships a
    LEFT JOIN Classes c
      ON a.class = c.class
  UNION
  SELECT
    class,
    country
  FROM Classes
), v1 AS (
  SELECT DISTINCT
    battle,
    ship,
    country,
    1 AS c

  FROM Outcomes b
    LEFT JOIN potential_ships a
      ON a.name = b.ship

  WHERE country IS NOT NULL
), v2 AS (
  SELECT
    country,
    battle
  FROM v1
  GROUP BY country, battle
  HAVING SUM(c) >= 3
)
SELECT DISTINCT
  battle
FROM v2;
--73
/*
Для каждой страны определить сражения, в которых не участвовали корабли данной страны.
Вывод: страна, сражение
*/
WITH potential_ships AS (
  SELECT
    name,
    Ships.class,
    country
  FROM Ships
    LEFT JOIN Classes
      ON Classes.class = Ships.class
  UNION
  SELECT
    class,
    class,
    country
  FROM Classes
), country_battle AS (
  SELECT
    country,
    battle
  FROM potential_ships a
    LEFT JOIN Outcomes b
      ON a.name = b.ship
  WHERE battle IS NOT NULL
),all_battles AS (
  SELECT
    battle
  FROM Outcomes
  UNION
  SELECT
    name
  FROM Battles
),all_countries AS (
  SELECT
    country
  FROM Classes
),full_set AS (
  SELECT DISTINCT
    a.country,
    b.battle
  FROM all_countries a
    CROSS JOIN all_battles b
)
SELECT
  a.*
FROM full_set a
  LEFT JOIN country_battle b
    ON a.country = b.country
    AND a.battle = b.battle
WHERE b.battle IS NULL;
--74
/*
Вывести все классы кораблей России (Russia). Если в базе данных нет классов кораблей России, вывести классы для всех имеющихся в БД стран.
Вывод: страна, класс
*/
SELECT DISTINCT
  country,
  class
FROM Classes
WHERE EXISTS(
  SELECT * FROM Classes WHERE country = 'Russia'
  )
  AND country = 'Russia'
UNION
SELECT DISTINCT
  country,
  class
FROM Classes
WHERE NOT EXISTS(
  SELECT * FROM Classes WHERE country = 'Russia'
  );


