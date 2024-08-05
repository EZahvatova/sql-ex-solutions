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
  FROM incomes a
    full OUTER JOIN outcomes b
      ON a.point = b.point AND a.date = b.date
)
SELECT
  point,
--    DATETIME(ROUND(date / 1000), 'unixepoch')
 convert(varchar(10),    date, 103)
  AS day,
--total,
--lag(total) over(partition by point order by date) as previous_total,
--lead(total) over(partition by point order by date) as next_total,
sum(total) over (partition by point order by date) as total_rolling

FROM totals
order by point, date
;
