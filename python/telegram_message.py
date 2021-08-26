import csv
import telegram
import os

# reading temp file
file_path = os.getenv('CHECK_PATH')
api_key = os.getenv('ITRADECRAPI')
user_id = os.getenv('USER_CALL')

with open(file_path) as fp:
    reader = csv.reader(fp, delimiter=",", quotechar='"')
    data_read = [row for row in reader]

# set up bot 
bot = telegram.Bot(token=api_key)
# send message if file has more than one row  
if(len(data_read) > 1):
  bot.send_message(chat_id=user_id, text= data_read)
else:
  bot.send_message(chat_id=user_id, text="Everything its right!")