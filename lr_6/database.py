import psycopg2 as pg

class Storage:
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
            print('Error occured - ', e)
            return []
        try:
            return [row for row in self.cursor]
        except:
            return []

    def copy_data(self, path):
        try:
            self.cursor.execute(f"copy copy_styles_table from '{path}' delimiter ',' csv header")
        except Exception as err:
            return err
        else:
            return None