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
SELECT *
  --DISTINCT a.ship
FROM v0 a
  LEFT JOIN v0 b
    ON a.ship = b.ship
    AND a.date < b.date
WHERE a.result IN ('OK', 'damaged')
  AND b.result IN ('OK', NULL);
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
  ON a.class=c.class;
--47
/*
Определить страны, которые потеряли в сражениях все свои корабли.
*/
WITH v0 AS (
  SELECT
    country,
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
SELECT *
  --country
FROM v0
--WHERE result = 'sunk' AND country not null
;
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
    country,
    name,
    result
  FROM potential_ships a
    LEFT JOIN Classes b
      ON a.class = b.class
    LEFT JOIN Outcomes c
      ON a.name = c.ship
), sunk AS (
  SELECT
    name
  FROM v0
  WHERE result = 'sunk'
),healthy AS (
  SELECT
    name
  FROM v0
  WHERE name NOT IN (
    SELECT
      name
    FROM sunk
  )
)
SELECT
  country
FROM v0
GROUP BY 1
HAVING SUM(1 * (name IN (
  SELECT
    name
  FROM healthy
))) = 0;
WITH v0 AS (
  SELECT
    COALESCE(c.country, d.country) AS country,
    a.ship,
    result
  FROM Outcomes a
    LEFT JOIN Ships b
      ON a.ship = b.name
    LEFT JOIN Classes c
      ON b.class = c.class
    LEFT JOIN Classes d
      ON a.ship = d.class
  WHERE COALESCE(c.country, d.country) IS NOT NULL
)
SELECT DISTINCT
  country
FROM v0
WHERE ship NOT IN (
  SELECT
    ship
  FROM v0
  WHERE result != 'sunk'
)
  AND ship IN (
  SELECT
    ship
  FROM v0
  WHERE result = 'sunk'
);
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
-- вывести список классов кораблей которые участвовали в битвах с четным числом
-- outcomes(ship,battle), battles(name,date)
-- /2==0
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
    CASE WHEN b.date % 2 = 0 THEN 1
         ELSE 0 END
    )
FROM potential_ships p
  LEFT JOIN Outcomes o
    ON o.ship = p.name
  LEFT JOIN Battles b
    ON b.name = o.battle
GROUP BY class;
-- 57
/* Для классов, имеющих потери в виде потопленных кораблей и не менее 3 кораблей в базе данных, вывести имя класса и число потопленных кораблей
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
  SUM(CASE WHEN result = 'sunk' THEN 1 ELSE 0 END)
FROM potential_ships a
  LEFT JOIN Outcomes b
    ON a.name = b.ship
GROUP BY class;

/*
--58
Для каждого типа продукции и каждого производителя из таблицы Product c точностью до двух десятичных знаков найти процентное отношение числа моделей данного типа данного производителя к общему числу моделей этого производителя.
Вывод: maker, type, процентное отношение числа моделей данного типа к общему числу моделей производителя
*/

SELECT DISTINCT
  maker,
  type,
  (
        100.0 *
        COUNT(1) OVER w1
      /
        COUNT(1) OVER w2
    )
    AS rate
FROM Product
  WINDOW
    w1 AS (PARTITION BY type,maker),
    w2 AS (PARTITION BY maker);
WITH v0 AS (
  SELECT
    maker,
    type,
    COUNT(1) AS nominator
  FROM Product
  GROUP BY type, maker
),v1 AS (
  SELECT
    maker,
    COUNT(1) AS denominator
  FROM Product
  GROUP BY maker
)
SELECT
  v0.maker,
  type,
  100.0 * nominator / denominator
FROM v0
  LEFT JOIN v1
    ON v0.maker = v1.maker;
SELECT
  maker,
  model,
  type,
  COUNT(1) OVER (PARTITION BY maker ORDER BY model)

FROM Product
ORDER BY maker, model, type;
SELECT
  maker,
  model,
    model - LEAD(model, 2) OVER (
    PARTITION BY maker ORDER BY model
    )

FROM Product
--order by maker,model
;
--idempotency . same result from 1 or 100 runs
;
--70
/*

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
), v1 AS (
  SELECT DISTINCT
    battle,
    ship,
    class,
    country,
    COUNT(1) AS c

  FROM potential_ships a RIGHT JOIN Outcomes b
  ON a.NAME = b.ship
    LEFT JOIN classes C
    ON a.class = C.class
-- all outcomes battle is not null so we right join instead
--  WHERE battle IS NOT NULL
)
SELECT DISTINCT
  battle
FROM v1
WHERE c > 3;
--60
/*

 */
SELECT
  COALESCE(a.point, b.point),
  COALESCE(a.date, b.date),
  SUM(out),
  SUM(inc)
FROM income a FULL OUTER JOIN outcome b
ON
  a.point=b.point AND a.date=b.date
GROUP BY coalesce(a.point, b.point),
  coalesce(a.date, b.date)
WHERE a.date<'20010415' AND b.date<'20010415';
--58
/*
Для каждого типа продукции и каждого производителя из таблицы Product c точностью до двух десятичных знаков найти процентное отношение числа моделей данного типа данного производителя к общему числу моделей этого производителя.
Вывод: maker, type, процентное отношение числа моделей данного типа к общему числу моделей производителя
 */
SELECT DISTINCT
  maker,
  type,
  (
        100.0 *
        COUNT(1) OVER (PARTITION BY type, maker)
      /
        COUNT(1) OVER (PARTITION BY maker)
    )
    AS rate
FROM Product;
