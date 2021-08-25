import csv

with open("C:\\Documentos\\tradecr\\data\\check_procomer.csv") as fp:
    reader = csv.reader(fp, delimiter=",", quotechar='"')
    # next(reader, None)  # skip the headers
    data_read = [row for row in reader]

jota = type(data_read)

print(6+3)
type()