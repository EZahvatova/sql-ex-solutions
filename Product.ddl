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
CREATE TABLE IF NOT EXISTS Product
(
  maker varchar,
  model INTEGER,
  type  varchar
);
CREATE TABLE IF NOT EXISTS PC
(
  code  INTEGER,
  model INTEGER,
  speed INTEGER,
  ram   INTEGER,
  hd    INTEGER,
  cd    INTEGER,
  price INTEGER
);
CREATE TABLE IF NOT EXISTS Printer
(
  code  INTEGER,
  model INTEGER,
  color varchar,
  type  varchar,
  price INTEGER
);
CREATE TABLE IF NOT EXISTS
  Laptop
(
  code   INTEGER,
  model  INTEGER,
  speed  INTEGER,
  ram    INTEGER,
  hd     INTEGER,
  price  INTEGER,
  screen INTEGER
);
drop view test;
create VIEW test as
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

FROM v0
;