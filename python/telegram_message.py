import csv
import telegram
import os
from tabulate import tabulate

# reading temp file
file_path = os.getenv('CHECK_PATH')
file_path_imp = os.getenv('CHECK_PATH')
api_key = os.getenv('ITRADECRAPI')
user_id = os.getenv('USER_CALL')

with open(file_path) as fp:
    reader = csv.reader(fp, delimiter=",", quotechar='"')
    data_read = [row for row in reader]

data_read_t = tabulate(data_read)
with open(file_path_imp) as fp:
    reader_imp = csv.reader(fp, delimiter=",", quotechar='"')
    data_read_imp = [row for row in reader_imp]    

data_read_imp_t = tabulate(data_read_imp)
# set up bot 
bot = telegram.Bot(token=api_key)
# send message if file has more than one row  
if(len(data_read) > 1):
  text0 = ("There is a problem on Exports")
  bot.send_message(chat_id=user_id, text=text0)
  bot.send_message(chat_id=user_id, text=data_read_t)
else:
  bot.send_message(chat_id=user_id, text = "Everything its right with Exports!")

# send message if file has more than one row  
if(len(data_read_imp) > 1):
  text1 = ("There is a problem on Imports")
  bot.send_message(chat_id=user_id, text=text1)
  bot.send_message(chat_id=user_id, text=data_read_imp_t)
else:
  bot.send_message(chat_id=user_id, text="Everything its right with Imports!")
