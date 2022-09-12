import csv
import telegram
import os
import pandas as pd

# reading temp file
file_path = os.getenv("CHECK_PATH")
file_path_imp = os.getenv("CHECK_PATH2")
api_key = os.getenv("ITRADECRAPI")
user_id = os.getenv("USER_CALL")
user_id2 = os.getenv("USER_CALL2")
user_id3 = os.getenv("USER_CALL3")
# user_id4 = os.getenv('USER_CALL4')

user_ids = [user_id, user_id2, user_id3]

with open(file_path) as fp:
    data_read = pd.read_csv(fp)

data_read_t = data_read.to_markdown(index=False)

with open(file_path_imp) as fp:
    data_read_imp = pd.read_csv(fp)

data_read_imp_t = data_read_imp.to_markdown(index=False)

# set up bot
bot = telegram.Bot(token=api_key)
# send message if file has more than one row
if data_read.shape[0] > 1:
    for chat in user_ids:
        text0 = "There is a problem on Exports"
        bot.send_message(chat_id=chat, text=text0)
        bot.send_message(chat_id=chat, text=data_read_t)
else:
    for chat in user_ids:
        bot.send_message(chat_id=chat, text="Everything is fine with Exports!")

# send message if file has more than one row
if data_read_imp.shape[0] > 1:
    for chat in user_ids:
        text1 = "There is a problem on Imports"
        bot.send_message(chat_id=chat, text=text1)
        bot.send_message(chat_id=chat, text=data_read_imp_t)
else:
    for chat in user_ids:
        bot.send_message(chat_id=chat, text="Everything is fine with Imports!")
