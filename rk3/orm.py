from sqlalchemy import create_engine
from sqlalchemy import except_
from sqlalchemy.engine import Engine
from sqlalchemy.engine.result import ResultProxy
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, String, Integer, Date, Time, MetaData
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.schema import ForeignKey
from sqlalchemy import func, and_, or_, not_, cast, subquery
import json

engine = create_engine("postgresql+psycopg2://postgres:9520@localhost:5432/temp_database")
base = declarative_base()
meta_data = MetaData()
class Workers(base):
    __tablename__ = 'workers'
    id = Column(Integer, primary_key=True, nullable=False)
    fio = Column(String)
    birthday = Column(String)
    department = Column(String)
    def __init__(self, fio, birthday, department):
        self.fio = fio
        self.birthday = birthday
        self.department = department
    def __repr__(self):
        return "<Workers('%s', '%s', '%s')>" % (self.fio, self.birthday, self.department)

class Time_track(base):
    __tablename__ = 'time_track'
    id = Column(Integer, primary_key=True, nullable=False)
    id_workers = Column(Integer, ForeignKey('workers.id'), nullable=False)
    t_date = Column(Date)
    day = Column(String)
    t_time = Column(Time)
    t_type = Column(Integer)
    def __init__(self, id_workers, t_date, day, t_time, t_type):
        self.id_workers = id_workers
        self.t_date = t_date
        self.day = day
        self.t_time = t_time
        self.t_type = t_type
    def __repr__(self):
        return "<Time_track('%d', '%s', '%s', '%s', '%d')>" % (self.id_workers, self.t_date, self.day, self.t_time, self.t_type)
base.metadata.create_all(engine)
Session = sessionmaker(bind=engine)
session = Session()
tmp = session.query(Workers.department, func.count('department').label('cnt')).group_by(Workers.department).subquery()
query = session.query(tmp.c.department, tmp.c.cnt).filter(tmp.c.cnt > 10)
records = query.all()
for i in records:
    print(i)
tmp = session.query(Time_track.id_workers).group_by(Time_track.id_workers, Time_track.t_date)
tmp2 = session.query(Time_track.id_workers).filter(Time_track.t_type == 2).group_by(Time_track.id_workers, Time_track.t_date)
query = except_(tmp, tmp2)
query = session.query(query)
records = query.all()
for i in records:
    print(i)