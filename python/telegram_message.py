import csv
import telegram
import os
from tabulate import tabulate

# reading temp file
file_path = os.getenv('CHECK_PATH')
file_path_imp = os.getenv('CHECK_PATH2')
api_key = os.getenv('ITRADECRAPI')
user_id = os.getenv('USER_CALL')
user_id2 = os.getenv('USER_CALL2')

user_ids = [user_id, user_id2]

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
  for chat in user_ids:
    text0 = ("There is a problem on Exports")
    bot.send_message(chat_id=chat, text=text0)
    bot.send_message(chat_id=chat, text=data_read_t)
else:
  for chat in user_ids:
    bot.send_message(chat_id=chat, text = "Everything is fine with Exports!")

# send message if file has more than one row  
if(len(data_read_imp) > 1):
  for chat in user_ids:
    text1 = ("There is a problem on Imports")
    bot.send_message(chat_id=chat, text=text1)
    bot.send_message(chat_id=chat, text=data_read_imp_t)
else:
  for chat in user_ids:
    bot.send_message(chat_id=chat, text="Everything is fine with Imports!")
