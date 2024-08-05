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
CREATE TABLE IF NOT EXISTS Classes
(
  class        varchar,
  type         varchar,
  country      varchar,
  numGuns      INTEGER,
  bore         INTEGER,
  displacement INTEGER
);
CREATE TABLE IF NOT EXISTS Ships
(
  name     varchar,
  class    varchar,
  launched INTEGER
);
CREATE TABLE IF NOT
  EXISTS Battles
(
  name varchar,
  date datetime
);
CREATE TABLE IF NOT EXISTS
  Outcomes
(
  ship   varchar,
  battle varchar,
  result varchar
);