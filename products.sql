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
/*Найти производителей,
  которые выпускают более одной модели,
  при этом все выпускаемые производителем модели являются продуктами
  одного типа.
Вывести: maker, type
*/
-- 40
WITH v0 AS (
  SELECT
    maker,
    type,
    COUNT(*) AS models
  FROM Product
  GROUP BY maker, type
)
SELECT
  maker,
  type
FROM v0
--where models>1
GROUP BY maker
HAVING COUNT(*) = 1 AND SUM(models) > 1;
SELECT *
FROM Product
