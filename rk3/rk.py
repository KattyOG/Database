import database
from datetime import datetime

def f_task(base:database.TP):
    res = base.execute(f"select department from(select department, count(*) as count from workers group by department)as tm where count > 10") 
    print(res)

def s_task(base:database.TP):
    res = base.execute(
        f'select id_workers'
        f' from time_track group by id_workers, t_date'
        f' except'
        f' select id_workers'
        f' from time_track where t_type = 2 group by id_workers,  t_date')
    print(f'Количество сотрудников, которые не выходят с рабочего места в течение всего рабочего дня равно', res[0][0])

def t_task(base:database.TP, date):
    t_date = datetime.strptime(date, "%d-%m-%Y")
    t_date = t_date.date()
    res = base.execute(
        f'with dep as(select id_workers, min_time from('
        f' select id_workers, min(t_time) as min_time from('
        f' select id_workers, t_date, t_time'
        f' from time_track'
        f' where t_date = \'{t_date}\' and t_type = 1'
        f' )tmp group by id_workers)temp where min_time > \'9:00\''
        f' )select distinct department from dep join workers wrk on wrk.id = dep.id_workers'
        )
    print(f'Отделы, в которых есть сотрудники, опоздавшие в определенную дату ', res)


if __name__ == '__main__':
    data = {
        "dbname" : "temp_database",
        "host" : "localhost",
        "port" : "5432",
        "password" : "9520",
        "user" : "postgres"
    }
    base = database.TP(data)
    fl = True
    while fl:
        try:
            num = int(input("номер задания: "))
        except Exception as err:
            continue
        if not num:
            fl = False
        elif num == 1:
            f_task(base)
        elif num == 2:
            s_task(base)
        elif num == 3:
            date = input('Введите дату : ')
            t_task(base, date)