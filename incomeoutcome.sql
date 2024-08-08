/*
Фирма имеет несколько пунктов приема вторсырья. Каждый пункт получает деньги
для их выдачи сдатчикам вторсырья. Сведения о получении денег на пунктах приема записываются в таблицу:
Income_o(point, date, inc)
Первичным ключом является (point, date). При этом в столбец date записывается только дата (без времени), т.е. прием денег (inc) на каждом пункте производится не чаще одного раза в день. Сведения о выдаче денег сдатчикам вторсырья записываются в таблицу:
Outcome_o(point, date, out)
В этой таблице также первичный ключ (point, date) гарантирует отчетность каждого пункта о выданных деньгах (out) не чаще одного раза в день.
В случае, когда приход и расход денег может фиксироваться несколько раз в день, используется другая схема с таблицами, имеющими первичный ключ code:
Income(code, point, date, inc)
Outcome(code, point, date, out)
Здесь также значения столбца date не содержат времени.
*/

--29
/*
В предположении, что приход и расход денег на каждом пункте приема фиксируется не чаще одного раза в день [т.е. первичный ключ (пункт, дата)], написать запрос с выходными данными (пункт, дата, приход, расход). Использовать таблицы Income_o и Outcome_o.
*/
SELECT
  CASE WHEN (a.point IS NULL) THEN b.point ELSE a.point END AS point,
  CASE WHEN (a.date IS NULL) THEN b.date ELSE a.date END AS date,
  inc AS income,
  out AS outcome
FROM Income_o a FULL OUTER JOIN outcome_o b
ON a.point=b.point AND a.date=b.date;
--30
/*
В предположении, что приход и расход денег на каждом пункте приема фиксируется произвольное число раз (первичным ключом в таблицах является столбец code), требуется получить таблицу, в которой каждому пункту за каждую дату выполнения операций будет соответствовать одна строка.
Вывод: point, date, суммарный расход пункта за день (out), суммарный приход пункта за день (inc). Отсутствующие значения считать неопределенными (NULL).
*/
SELECT
  CASE WHEN (a.point IS NULL) THEN b.point ELSE a.point END AS point,
  CASE WHEN (a.date IS NULL) THEN b.date ELSE a.date END AS date,
  SUM(out),
  SUM(inc)
FROM Income a FULL OUTER JOIN outcome b
ON a.code=b.code AND a.point=b.point AND a.date=b.date
GROUP BY CASE WHEN (a.point IS NULL) THEN b.point ELSE a.point
END, CASE WHEN
  (a.date IS NULL) THEN b.date ELSE a.date end;
--59
/*
Посчитать остаток денежных средств на каждом пункте приема для базы данных с отчетностью не чаще одного раза в день. Вывод: пункт, остаток.
*/
SELECT
  ss.point,
  ss.inc - dd.out
FROM (
  SELECT
    i.point,
    SUM(inc) AS inc
  FROM Income_o i
  GROUP BY i.point
) AS ss,
  (
    SELECT
      o.point,
      SUM(out) AS out
    FROM Outcome_o o
    GROUP BY o.point
  ) AS dd
WHERE ss.point = dd.point;
--60
/*
Посчитать остаток денежных средств на начало дня 15/04/01 на каждом пункте приема для базы данных с отчетностью не чаще одного раза в день. Вывод: пункт, остаток.
Замечание. Не учитывать пункты, информации о которых нет до указанной даты.
 */
SELECT
  COALESCE(a.point, b.point),
  COALESCE(a.date, b.date),
  SUM(out),
  SUM(inc)
FROM Income a FULL OUTER JOIN outcome b
ON
  a.point=b.point AND a.date=b.date
GROUP BY coalesce(a.point, b.point),
  coalesce(a.date, b.date)
WHERE a.date<'20010415' AND b.date<'20010415';
--64
/*
Используя таблицы Income и Outcome, для каждого пункта приема определить дни, когда был приход, но не было расхода и наоборот.
Вывод: пункт, дата, тип операции (inc/out), денежная сумма за день.
*/
WITH income_0 AS (
  SELECT
    point,
    date,
    SUM(inc) AS dayinc
  FROM Income
  GROUP BY point, date
), outcome_0 AS (
  SELECT
    point,
    date,
    SUM(out) AS dayout
  FROM Outcome
  GROUP BY point, date
)
SELECT
  COALESCE(a.point, b.point) AS point,
  COALESCE(a.date, b.date) AS date,
  CASE WHEN (a.dayinc IS NULL) THEN 'out'
       WHEN (b.dayout IS NULL) THEN 'inc' END AS operation,
  CASE WHEN (a.dayinc IS NULL) THEN b.dayout
       WHEN (b.dayout IS NULL) THEN a.dayinc
    END AS money_sum
FROM income_0 a
  LEFT JOIN outcome_0 b
    ON a.point = b.point AND a.date = b.date
WHERE (a.point IS NULL OR b.point IS NULL);
--69
/*
По таблицам Income и Outcome для каждого пункта приема найти остатки денежных средств на конец каждого дня,
в который выполнялись операции по приходу и/или расходу на данном пункте.
Учесть при этом, что деньги не изымаются, а остатки/задолженность переходят на следующий день.
Вывод: пункт приема, день в формате "dd/mm/yyyy", остатки/задолженность на конец этого дня.
*/
WITH incomes AS (
  SELECT
    point,
    date,
    SUM(inc) AS dayinc
  FROM Income
  WHERE inc IS NOT NULL
  GROUP BY point, date
),outcomes AS (
  SELECT
    point,
    date,
    SUM(out) AS dayout
  FROM Outcome
  WHERE out IS NOT NULL
  GROUP BY point, date
),totals AS (
  SELECT
    COALESCE(a.point, b.point) AS point,
    COALESCE(a.date, b.date) AS date,
      COALESCE(a.dayinc, 0) - COALESCE(b.dayout, 0) AS total
  FROM incomes a FULL OUTER JOIN outcomes b
  ON a.point = b.point AND a.date = b.date
)
SELECT
  point,
--    DATETIME(ROUND(date / 1000), 'unixepoch')
  convert(varchar(10), date, 103)
    AS day,
--total,
--lag(total) over(partition by point order by date) as previous_total,
--lead(total) over(partition by point order by date) as next_total,
  SUM(total) OVER (PARTITION BY point ORDER BY date) AS total_rolling

FROM totals
ORDER BY point, date;
