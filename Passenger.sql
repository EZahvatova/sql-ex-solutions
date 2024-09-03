/*
Схема БД состоит из четырех отношений:
Company (ID_comp, name)
Trip(trip_no, ID_comp, plane, town_from, town_to, time_out, time_in)
Passenger(ID_psg, name)
Pass_in_trip(trip_no, date, ID_psg, place)
Таблица Company содержит идентификатор и название компании, осуществляющей перевозку пассажиров. Таблица Trip содержит информацию о рейсах: номер рейса, идентификатор компании, тип самолета, город отправления, город прибытия, время отправления и время прибытия. Таблица Passenger содержит идентификатор и имя пассажира. Таблица Pass_in_trip содержит информацию о полетах: номер рейса, дата вылета (день), идентификатор пассажира и место, на котором он сидел во время полета. При этом следует иметь в виду, что
- рейсы выполняются ежедневно, а длительность полета любого рейса менее суток; town_from <> town_to;
- время и дата учитывается относительно одного часового пояса;
- время отправления и прибытия указывается с точностью до минуты;
- среди пассажиров могут быть однофамильцы (одинаковые значения поля name, например, Bruce Willis);
- номер места в салоне – это число с буквой; число определяет номер ряда, буква (a – d) – место в ряду слева направо в алфавитном порядке;
- связи и ограничения показаны на схеме данных.
*/

--63
/*
Определить имена разных пассажиров, когда-либо летевших на одном и том же месте более одного раза.
*/
WITH v0 AS (
  SELECT
    name,
    place,
    a.ID_psg,
    COUNT(1) AS count
  FROM Passenger a
    LEFT JOIN Pass_in_trip b
      ON a.ID_psg = b.ID_psg
  GROUP BY name, place, a.ID_psg
  HAVING COUNT(1) > 1
)
SELECT
  name
FROM v0
GROUP BY name;
--72
/*
Среди тех, кто пользуется услугами только какой-нибудь одной компании, определить имена разных пассажиров, летавших чаще других.
Вывести: имя пассажира и число полетов.
*/
WITH v0 AS (
  SELECT
    name,
    c.ID_comp,
    COUNT(1) c
  FROM Pass_in_trip b
    LEFT JOIN Passenger a
      ON a.ID_psg = b.ID_psg
    LEFT JOIN Trip c
      ON b.trip_no = c.trip_no
  GROUP BY name, ID_comp
)
SELECT
  name,
  c
FROM v0
WHERE c = (
  SELECT
    MAX(c)
  FROM v0
);
--76
/*
Определить время, проведенное в полетах, для пассажиров, летавших всегда на разных местах. Вывод: имя пассажира, время в минутах.
*/
SELECT
  name,
  place,
  datediff(minute, time_out, time_in) AS minutes
FROM Passenger a
  LEFT JOIN Pass_in_trip b
    ON a.ID_psg = b.ID_psg
  LEFT JOIN Trip c
    ON b.trip_no = c.trip_no
GROUP BY name, place,
         datediff(minute, time_out, time_in)
HAVING count(1)=1;