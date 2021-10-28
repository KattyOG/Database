import psycopg2 as pg

class TP:
    connection = None
    cursor = None
    def __init__(self, data):
        self.connection = pg.connect(**data)
        self.cursor = self.connection.cursor()
    def __del__(self):
        self.cursor.close()
        self.connection.close()
    def execute(self, data):
        try:
            self.cursor.execute(data)
        except Exception as e:
            return []
        try:
            return [row for row in self.cursor]
        except:
            return []