/*
Схема БД состоит из четырех таблиц:
Product(maker, model, type)
PC(code, model, speed, ram, hd, cd, price)
Laptop(code, model, speed, ram, hd, price, screen)
Printer(code, model, color, type, price)
Таблица Product представляет производителя (maker),
номер модели (model)
и тип ('PC' - ПК, 'Laptop' - ПК-блокнот или 'Printer' - принтер).
Предполагается, что номера моделей в таблице Product уникальны для всех производителей и типов продуктов. В таблице PC для каждого ПК, однозначно определяемого уникальным кодом – code, указаны модель – model (внешний ключ к таблице Product), скорость - speed (процессора в мегагерцах), объем памяти - ram (в мегабайтах), размер диска - hd (в гигабайтах), скорость считывающего устройства - cd (например, '4x') и цена - price (в долларах). Таблица Laptop аналогична таблице РС за исключением того, что вместо скорости CD содержит размер экрана -screen (в дюймах). В таблице Printer для каждой модели принтера указывается, является ли он цветным - color ('y', если цветной), тип принтера - type (лазерный – 'Laser', струйный – 'Jet' или матричный – 'Matrix') и цена - price.
*/

SELECT *
FROM Product a
  LEFT JOIN Laptop L
    ON a.model = L.model;
--1
/*
Найдите номер модели, скорость и размер жесткого диска для всех ПК стоимостью менее 500 дол. Вывести: model, speed и hd
 */
SELECT
  model,
  speed,
  hd
FROM PC
WHERE price < 500;
--2
/*
Найдите производителей принтеров. Вывести: maker
 */
SELECT
  maker
FROM Product
WHERE type = 'printer'
GROUP BY maker;
--3
/*
Найдите номер модели, объем памяти и размеры экранов ПК-блокнотов, цена которых превышает 1000 дол.
*/
SELECT
  model,
  ram,
  screen
FROM Laptop
WHERE price > 1000;
--4
/*
Найдите все записи таблицы Printer для цветных принтеров.
*/
SELECT*
FROM Printer
WHERE color = 'y';
--5
/*
Найдите номер модели, скорость и размер жесткого диска ПК, имеющих 12x или 24x CD и цену менее 600 дол.
*/
SELECT
  model,
  speed,
  hd
FROM PC
WHERE (cd = '12x' OR cd = '24x') AND price < 600;
--6
/*
Для каждого производителя, выпускающего ПК-блокноты c объёмом жесткого диска не менее 10 Гбайт, найти скорости таких ПК-блокнотов. Вывод: производитель, скорость.
*/
SELECT
  Product.maker,
  laptop.speed
FROM Product RIGHT JOIN Laptop
ON product.model=laptop.model
WHERE product.type='laptop' AND laptop.hd>=10
GROUP BY product.maker, laptop.speed;
--7
/*
Найдите номера моделей и цены всех имеющихся в продаже продуктов (любого типа) производителя B (латинская буква).
*/
SELECT
  Product.model,
  PC.price--, Product.type, 'PC'
FROM Product RIGHT JOIN PC
ON product.model=PC.model
WHERE product.maker='B'
UNION
SELECT
  Product.model,
  Laptop.price--, Product.type, 'Laptop'
FROM Product RIGHT JOIN Laptop
ON product.model=laptop.model
WHERE product.maker='B'
UNION
SELECT
  Product.model,
  Printer.price--, Product.type, 'P'
FROM Product RIGHT JOIN Printer
ON product.model=Printer.model
WHERE product.maker='B';
--8
/*
Найдите производителя, выпускающего ПК, но не ПК-блокноты.
*/
SELECT
  maker
FROM Product
WHERE type = 'PC'
  AND maker NOT IN
      (
        SELECT
          maker
        FROM Product
        WHERE type = 'Laptop'
      )
GROUP BY maker;
--9
/*
Найдите производителей ПК с процессором не менее 450 Мгц. Вывести: Maker
*/
SELECT
  maker
FROM Product RIGHT JOIN PC
ON Product.model=PC.model
WHERE speed >=450
GROUP BY maker;
--10
/*
Найдите модели принтеров, имеющих самую высокую цену. Вывести: model, price
*/
SELECT
  model,
  price
FROM Printer
WHERE price = (
  SELECT
    MAX(price)
  FROM Printer
);
--11
/*
Найдите среднюю скорость ПК.
 */
SELECT
  AVG(speed)
FROM PC;
--12
/*
Найдите среднюю скорость ПК-блокнотов, цена которых превышает 1000 дол.
*/
SELECT
  AVG(speed)
FROM Laptop
WHERE price > 1000;
--13
/*
Найдите среднюю скорость ПК, выпущенных производителем A.
 */
SELECT
  AVG(speed)
FROM PC
  JOIN Product
    ON Product.model = PC.model
WHERE maker = 'A';
--14
/*
Найдите класс, имя и страну для кораблей из таблицы Ships, имеющих не менее 10 орудий.
*/
SELECT
  ships.class,
  ships.name,
  classes.country
FROM ships
  JOIN classes
    ON classes.class = ships.class
WHERE numGuns >= 10;
--15
/*
Найдите размеры жестких дисков, совпадающих у двух и более PC. Вывести: HD
*/
SELECT
  hd
FROM PC
GROUP BY hd
HAVING COUNT(1) > 1;
--16
/*
Найдите пары моделей PC, имеющих одинаковые скорость и RAM. В результате каждая пара указывается только один раз, т.е. (i,j), но не (j,i), Порядок вывода: модель с большим номером, модель с меньшим номером, скорость и RAM.
*/
SELECT DISTINCT
  A.model AS model_1,
  B.model AS model_2,
  A.speed,
  A.ram
FROM PC AS A,
  PC AS B
WHERE A.speed = B.speed
  AND A.ram = B.ram
  AND A.model > B.model;
--17
/*
Найдите модели ПК-блокнотов, скорость которых меньше скорости каждого из ПК.
Вывести: type, model, speed
*/
SELECT DISTINCT
  type,
  a.model,
  a.speed
FROM Laptop a
  LEFT JOIN PC b
    ON a.model = b.model
  JOIN Product c
    ON c.model = a.model
WHERE a.speed < (
  SELECT
    MIN(speed)
  FROM PC
);
--18
/*
Найдите производителей самых дешевых цветных принтеров. Вывести: maker, price
*/
WITH v0 AS (
  SELECT
    maker,
    price
  FROM Printer a
    LEFT JOIN Product b
      ON a.model = b.model
  WHERE color = 'y'
)
SELECT DISTINCT
  maker,
  price
FROM v0
WHERE price = (
  SELECT
    MIN(price)
  FROM v0
);
--19
/*
Для каждого производителя, имеющего модели в таблице Laptop, найдите средний размер экрана выпускаемых им ПК-блокнотов.
Вывести: maker, средний размер экрана.
*/
SELECT
  maker,
  AVG(screen)
FROM Laptop a
  LEFT JOIN Product b
    ON a.model = b.model
GROUP BY maker;
--20
/*
Найдите производителей, выпускающих по меньшей мере три различных модели ПК. Вывести: Maker, число моделей ПК.
*/
SELECT
  maker,
  COUNT(1) AS Count_model
FROM Product
WHERE type = 'PC'
GROUP BY maker
HAVING COUNT(1) >= 3;
--21
/*
Найдите максимальную цену ПК, выпускаемых каждым производителем, у которого есть модели в таблице PC.
Вывести: maker, максимальная цена.
*/
SELECT
  maker,
  MAX(price) AS max_price
FROM PC a
  JOIN Product b
    ON a.model = b.model
GROUP BY maker;
--22
/*
Для каждого значения скорости ПК, превышающего 600 МГц, определите среднюю цену ПК с такой же скоростью. Вывести: speed, средняя цена.
*/
SELECT
  speed,
  AVG(price) AS avg_price
FROM PC a
WHERE speed > 600
GROUP BY speed;
--23
/*
Найдите производителей, которые производили бы как ПК
со скоростью не менее 750 МГц, так и ПК-блокноты со скоростью не менее 750 МГц.
Вывести: Maker
*/
WITH v0 AS (
  SELECT
    maker,
    speed
  FROM PC a
    LEFT JOIN Product b
      ON a.model = b.model
  WHERE speed >= 750
),
  v1 AS (
    SELECT
      maker,
      speed
    FROM Laptop c
      LEFT JOIN Product b
        ON c.model = b.model
    WHERE speed >= 750
  )
SELECT
  v0.maker
FROM v0
  INNER JOIN v1
    ON v0.maker = v1.maker
GROUP BY v0.maker;
--24
/*
Перечислите номера моделей любых типов, имеющих самую высокую цену по всей имеющейся в базе данных продукции.
*/
WITH v0 AS (
  SELECT
    model,
    price
  FROM PC
  UNION
  SELECT
    model,
    price
  FROM Printer
  UNION
  SELECT
    model,
    price
  FROM Laptop
)
SELECT
  model
FROM v0
WHERE price = (
  SELECT
    MAX(price)
  FROM v0
);
--25
/*
Найдите производителей принтеров, которые производят ПК с наименьшим объемом RAM и с самым быстрым процессором среди всех ПК, имеющих наименьший объем RAM. Вывести: Maker
 */
WITH v0 AS (
  SELECT
    maker,
    pr.model
  FROM Product p
    LEFT JOIN Printer pr
      ON pr.model = p.model
),
  v1 AS (
    SELECT
      maker,
      PC.model,
      ram,
      speed
    FROM Product p
      LEFT JOIN PC
        ON PC.model = p.model
    WHERE ram = (
      SELECT
        MIN(ram)
      FROM PC
    )
  )
SELECT DISTINCT
  v1.maker
FROM v1
WHERE maker IN (
  SELECT
    maker
  FROM v0
)
  AND speed = (
  SELECT
    MAX(speed)
  FROM v1
);
--26
/*
Найдите среднюю цену ПК и ПК-блокнотов, выпущенных производителем A (латинская буква). Вывести: одна общая средняя цена.
*/
WITH v0 AS (
  SELECT
    price
  FROM Product a
    LEFT JOIN PC b
      ON a.model = b.model
  WHERE maker = 'A'
  UNION ALL
  SELECT
    price
  FROM Product c
    LEFT JOIN Laptop b
      ON c.model = b.model
  WHERE maker = 'A'
)
SELECT
  AVG(price)
FROM v0;
--27
/*
Найдите средний размер диска ПК каждого из тех производителей, которые выпускают и принтеры. Вывести: maker, средний размер HD.
*/
SELECT
  maker,
  AVG(hd)
FROM PC a
  LEFT JOIN Product b
    ON a.model = b.model
WHERE maker IN
      (
        SELECT
          maker
        FROM Product
        WHERE type = 'Printer'
      )
GROUP BY maker;
--28
/*
Используя таблицу Product, определить количество производителей, выпускающих по одной модели.
*/
WITH v0 AS (
  SELECT
    1 AS a
  FROM Product
  GROUP BY maker
  HAVING COUNT(1) = 1
)
SELECT
  COUNT(1)
FROM v0;
-- 40
/*
Найти производителей, которые выпускают более одной модели,
при этом все выпускаемые производителем модели являются продуктами
одного типа.
Вывести: maker, type
*/
WITH v0 AS (
  SELECT
    maker,
    type,
    COUNT(1) AS c
  FROM Product
  GROUP BY maker, type
),v1 AS (
  SELECT
    maker
  FROM v0
  GROUP BY maker
  HAVING COUNT(1) = 1
)
SELECT
  b.maker,
  b.type
FROM v1 a
  LEFT JOIN v0 b
    ON a.maker = b.maker
WHERE c > 1;
--41
/*
Для каждого производителя, у которого присутствуют модели хотя бы в одной из таблиц PC, Laptop или Printer,
определить максимальную цену на его продукцию.
Вывод: имя производителя, если среди цен на продукцию данного производителя присутствует NULL, то выводить для этого производителя NULL,
иначе максимальную цену.
*/
WITH v0 AS (
  SELECT
    maker,
    price
  FROM PC a
    LEFT JOIN Product b
      ON a.model = b.model
  UNION
  SELECT
    maker,
    price
  FROM Laptop c
    LEFT JOIN Product b
      ON c.model = b.model
  UNION
  SELECT
    maker,
    price
  FROM Printer d
    LEFT JOIN Product b
      ON d.model = b.model
)
SELECT
  maker,
  MAX(price)
FROM v0
GROUP BY maker;
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
FROM Product
--order by maker,model
;
--idempotency . same result from 1 or 100 runs
;
--65
/*
Пронумеровать уникальные пары {maker, type} из Product, упорядочив их следующим образом:
- имя производителя (maker) по возрастанию;
- тип продукта (type) в порядке PC, Laptop, Printer.
Если некий производитель выпускает несколько типов продукции, то выводить его имя только в первой строке;
остальные строки для ЭТОГО производителя должны содержать пустую строку символов ('').
*/
WITH v0 AS (
  SELECT
    maker,
    type,
    CASE type
      WHEN 'PC' THEN 1
      WHEN 'Laptop' THEN 2
      WHEN 'Printer' THEN 3
      END AS mycase
  FROM Product
  GROUP BY maker, type
)
SELECT
  ROW_NUMBER() OVER (ORDER BY maker,mycase) AS rownum,
  CASE WHEN ((COUNT(1) OVER (
    PARTITION BY maker ORDER BY mycase
    )) = 1) THEN maker
       ELSE '' END
    AS maker,
  type
FROM v0;
--75
/*
Для тех производителей, у которых есть продукты с известной ценой хотя бы в одной из таблиц Laptop, PC, Printer найти максимальные цены на каждый из типов продукции.
Вывод: maker, максимальная цена на ноутбуки, максимальная цена на ПК, максимальная цена на принтеры.
Для отсутствующих продуктов/цен использовать NULL.
*/
WITH v0 AS (
  SELECT
    maker,
    a.model,
    price,
    d.type
  FROM PC a RIGHT JOIN product d
  ON a.model=d.model
  UNION
  SELECT
    maker, b.model, price, d.type
  FROM laptop b
    RIGHT JOIN product d
  ON b.model=d.model
  UNION
  SELECT
    maker, c.model, price, d.type
  FROM printer c
    RIGHT JOIN product d
  ON c.model=d.model
)
SELECT
  maker,
  CASE WHEN (type = 'Laptop') THEN MAX(price) END AS laptop,
  CASE WHEN (type = 'PC') THEN MAX(price) END AS pc,
  CASE WHEN (type = 'Printer') THEN MAX(price) END AS printer
FROM v0
WHERE price IS NOT NULL
GROUP BY maker, type;
--85
/*
Найти производителей, которые выпускают только принтеры или только PC.
При этом искомые производители PC должны выпускать
 */
WITH v0 AS (
  -- взять уникальные комбинации мейкер и тайп
  SELECT DISTINCT
    maker,
    type
  FROM Product
),v1 AS (
  -- вывести тех кто производит только 1 тип
  SELECT
    maker,
    MIN(type) AS min
  FROM v0
  GROUP BY maker
  HAVING COUNT(1) = 1
)
-- производители принтера
SELECT DISTINCT
  maker
FROM Product
WHERE type = 'Printer'
  AND maker IN (
  SELECT
    maker
  FROM v1
)
UNION
-- производители пк
SELECT
  maker
FROM Product
WHERE type = 'PC'
  AND maker IN (
  SELECT
    maker
  FROM v1
)
GROUP BY maker
HAVING COUNT(1) > 2;
--86
/*
Для каждого производителя перечислить в алфавитном порядке с разделителем "/" все типы выпускаемой им продукции.
Вывод: maker, список типов продукции
 */
WITH v0 AS (
  SELECT
    COALESCE(maker, maker) AS maker,
    COALESCE(type, type) AS types
  FROM Product
  GROUP BY COALESCE(maker, maker), COALESCE(type, type)
)
SELECT
  maker,
  GROUP_CONCAT(types SEPARATOR '/') as type
FROM v0
GROUP BY maker
ORDER BY type;
--89
/*
Найти производителей, у которых больше всего моделей в таблице Product, а также тех, у которых меньше всего моделей.
Вывод: maker, число моделей
 */
WITH v0 AS (
  SELECT
    maker,
    COUNT(model) AS qty
  FROM Product
  GROUP BY maker
)
SELECT
  a.maker,
  a.qty
FROM v0 a,
  v0 b,
  v0 c
GROUP BY a.maker, a.qty
HAVING MIN(b.qty) = a.qty OR MAX(c.qty) = a.qty;
--90
/*
Вывести все строки из таблицы Product, кроме трех строк с наименьшими номерами моделей и трех строк с наибольшими номерами моделей.
 */
SELECT *
FROM Product
WHERE model NOT IN (
  SELECT
    top 3 model
  FROM Product
  ORDER BY model DESC
)
  AND model NOT IN (
  SELECT
    top 3 model
  FROM Product
  ORDER BY model
)