import csv
import re 
import random
# from faker import Faker
# fake = Faker()
with open('breweries.csv', "r") as f:
    file = open("breweries_new.csv", "w")
    file.write(f.readline())
    reader = csv.reader(f)
    for row in reader:
        if row[5].istitle() :
            row[5] = str(random.randint(10001,99999))
    file.write(",".join(row) + '\n')
    #     # i = fake.address()
#     # print(i)
#     # # print(i[0])
#         # i = fake.address()
#         i = row[1].split(' ')
#         if i[0].isupper():
#             row[1] = fake.name()
#         # i = i[1].split(',')
        
#         #if row[1].replace(" ", "").isalnum():
#         # if re.search("[\s\a\d]+", row[1]):

    file.close()