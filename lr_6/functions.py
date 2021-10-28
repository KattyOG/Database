import database

def print_data(data):
    for line in data:
        for elem in line:
            print(elem, end=" ")
        print()

def scalar(db:database.Storage, abv):
    res = db.execute(f"select count(*) from beers where abv = \'{abv}\'") 
    print(f'Количество пива с abv = {abv} равно', res[0][0])

def req_join(db:database.Storage, abv):
    res = db.execute(
        f'select * from beers b join styles on b."style id" = styles.id and abv < {abv}'
        f' join recipes rp on b.id=rp.id'
    )
    if not res:
        print("Не было найдено пива с такими параметрами")

    print_data(res)

def otv(db:database.Storage):
    res = db.execute(
        "with cte as"
        "("
        "	select abv, count(*) over(partition by abv) as abv_of_each_num"	
        "   from beers"	
        ")"
        "select abv, abv_of_each_num from cte")
    print_data(res)

def print_tables(db:database.Storage):
    res = db.execute("select tablename from pg_tables where schemaname = 'public'")
    res = [f'{i + 1}: {table[0]}' for i, table in enumerate(res)]
    for row in res:
        print(row)
    return res

def meta_request(db:database.Storage, table_name):
    table_name = table_name[table_name.find(' ') + 1:]
    res = db.execute(
        f"select column_name, data_type from information_schema.columns where table_schema='public' and "
        f" table_name = '{table_name}';"
    )
    print_data(res)

def call_func(db:database.Storage, style):
    res = db.execute(
        f"select * from scalar_func('{style}')"
    )
    print("Вывод - ", res[0][0])

def call_table_func(db:database.Storage, abv):
    res = db.execute(
        f"select * from inserted_table_func('{abv}') "
    )
    print_data(res)

def call_procedure(db:database.Storage, begin_id, end_id, new_ibu):
    db.execute(
        f"drop table if exists new_table"
    )
    db.execute(
        f"select id, name, abv, ibu into new_table from beers order by id limit 20"
    )
    db.execute(
        f"call new_ibu_between_id({begin_id}, {end_id}, {new_ibu})"
    )
    res = db.execute(
        f"select * from new_table order by id;"
    )
    print_data(res)

def call_system_func(db:database.Storage):
    db.execute(
        f"drop table if exists data_table"
    )
    db.execute(
        f"CREATE TABLE data_table(name character varying(100), size int)"
    )
    db.execute(
        f"call table_info()"
    )
    res = db.execute(
        f"select * from data_table"
    )
    print_data(res)

def create_table(db:database.Storage):
    db.execute(
        f"drop table if exists copy_styles_table"
    )
    err = db.execute(
        f"create table copy_styles_table(name character varying(100), style character varying(100))"
    )
    if not err:
        print('Таблица copy_styles_table успешна создана')

def copy_data(db:database.Storage, path):
    err = db.copy_data(path)
    if err:
        print('Невозможно скопировать данные из-за ошибки - ', err)
        return
    res = db.execute(
        f"select * from copy_styles_table"
    )
    print_data(res)
    print('Успешно добавлена')


if __name__ == '__main__':

    data = {
        "dbname" : "best_beer_database",
        "host" : "localhost",
        "port" : "5432",
        "password" : "9520",
        "user" : "postgres"
    }

    db = database.Storage(data)

    flag = True

    while flag:
        print("\n")
        print("-------------------------MENU-------------------------", end='\n\n')
        try:
            task = int(input("Введите номер задания: "))
        except Exception as err:
            print("Некорректный номер - ", err)
            continue
        if not task:
            flag = False
        elif task == 1:
            abv = input('Введите abv : ')
            scalar(db, abv)
        elif task == 2:
            try:
                abv = int(input('Введите abv : '))
            except Exception as err:
                print('Возникла ошибка - ', err)
            else:
                req_join(db, abv)
        elif task == 3:
            otv(db)
        elif task == 4:
            print('Таблицы:')
            tables = print_tables(db)
            try:
                choice = int(input('Выберите таблицу: '))
            except Exception as err:
                print('Возникла ошибка - ', err)
            else:
                meta_request(db, tables[choice - 1])
        elif task == 5:
            style = input('Введите стиль: ') #Altbier, Apple Wine, Braggot
            call_func(db, style)
        elif task == 6:
            call_table_func(db, input('Введите abv : '))
        elif task == 7:
            try:
                begin_id = int(input('Введите начальный id: '))
                end_id = int(input('Введите конечный id: '))
                new_ibu = int(input('Введите новый ibu: '))
            except Exception as err:
                print('Возникла ошибка - ', err)
            else:
                call_procedure(db, begin_id, end_id, new_ibu)
        elif task == 8:
            call_system_func(db)
        elif task == 9:
            create_table(db)
        elif task == 10:
            copy_data(db, 'C:/database/styles.csv')

    print("Выход")
