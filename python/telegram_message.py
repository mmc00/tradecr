import csv
import telegram
import os

# reading temp file
file_path = os.getenv('CHECK_PATH')
file_path_imp = os.getenv('CHECK_PATH')
api_key = os.getenv('ITRADECRAPI')
user_id = os.getenv('USER_CALL')

with open(file_path) as fp:
    reader = csv.reader(fp, delimiter=",", quotechar='"')
    data_read = [row for row in reader]

with open(file_path_imp) as fp:
    reader_imp = csv.reader(fp, delimiter=",", quotechar='"')
    data_read_imp = [row for row in reader_imp]    

# set up bot 
bot = telegram.Bot(token=api_key)
# send message if file has more than one row  
if(len(data_read) > 1):
  text0 = ("There is a problem on Exports" + "/n" + data_read)
  bot.send_message(chat_id=user_id, text=text0)
else:
  bot.send_message(chat_id=user_id, text = "Everything its right with Exports!")

# send message if file has more than one row  
if(len(data_read_imp) > 1):
  text1 = ("There is a problem on Imports" + "/n" + data_read_imp)
  bot.send_message(chat_id=user_id, text=text1)
else:
  bot.send_message(chat_id=user_id, text="Everything its right with Imports!")