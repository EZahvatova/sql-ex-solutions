import pandas as pd
import sqlite3

db = sqlite3.connect('Ships.db')
df: pd.DataFrame = pd.read_sql('SELECT * FROM Classes', db)


def pandas_as_sql():
    # where, join, groupby

    # SAVE TO EXCEL
    # df.to_csv('test.csv')

    # WHERE
    # df.loc
    # df.iloc

    # JOIN

    # groupby
    grouped = df.groupby('numGuns').count()

    """
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
    """
    # variant1
    df11 = df.loc[df['type'] == 'bb', 'country']
    df12 = df.loc[df['type'] == 'bc', 'country']
    result1 = set(df11) & set(df12)

    # variant2
    df21 = df[df['type'] == 'bb']
    df22 = df[df['type'] == 'bc']
    result2 = pd.merge(df21, df22, how='inner', on='country')['country']
    result2 = set(result2)
    assert result1 == result2

    # variant3
    df31: pd.Series = df.loc[df['type'] == 'bb', 'country']
    df32: pd.Series = df.loc[df['type'] == 'bc', 'country']
    result3 = df31[df31.isin(df32)]
    result3 = set(result3)
    assert result1 == result3
    x = 1


def pandas_as_excel():
    # vlookup
    def map_column(
        value):
        mapping = {8:'x', 12:'y'}
        return value * 2
        # return mapping[value]
        return mapping.get(value, 'NO VALUE 2')

    df['new'] = df['numGuns'].apply(map_column)
    result = df[['new', 'numGuns']]
    x = 1


def show_builtins():
    """
    M - Mutable
    I - Immutable

    Non-Iterable:
        class(?M):
            module(?I)
            function(M):
                lambda = unnamed function

        float(I):
            int(I)

    Iterable:
        O - Ordered
        U - Unordered
        string(I)

        list(M)
        tuple(I,O) = list который нельзя изменять
        set(M,U) = лист который нельзя упорядочить
        dict(M,O) = лист с ключами и значениями
    """
    x = [1]
    y = [1.2]
    z = x.append(y)
    x = 1


pandas_as_sql()
