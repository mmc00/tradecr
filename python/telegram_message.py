import csv
import telegram
import os

# reading temp file
file_path = os.getenv('TEMP_PATH')
api_key = os.getenv('ITRADECRAPI')
user_id = os.getenv('MOLINA_TELEGRAM')

with open(file_path) as fp:
    reader = csv.reader(fp, delimiter=",", quotechar='"')
    data_read = [row for row in reader]

# send message if file has more than one row  
if(len(data_read) > 1):
  print("Everything its right!")
else:
  bot = telegram.Bot(token=api_key)
  bot.send_message(chat_id=user_id, text= data_read)