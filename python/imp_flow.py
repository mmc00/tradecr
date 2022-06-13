# libraries
from pathlib import Path
import datetime as dt
import requests
import xml.etree.ElementTree as ET
import pandas as pd
import numpy as np
import re
import os

# params
## params for BCCR API call
base = "https://gee.bccr.fi.cr/Indicadores/Suscripciones/WS/wsindicadoreseconomicos.asmx/ObtenerIndicadoresEconomicos?"
final_day = dt.datetime.now().date().replace(month=12, day=31).strftime("%d/%m/%Y")
params_bccr = {
    "Indicador": "1993",
    "FechaInicio": "01/01/1999",
    "FechaFinal": final_day,
    "Nombre": "Marlon",
    "Subniveles": "S",
    "CorreoElectronico": os.getenv("BCCR_USER"),
    "Token": os.getenv("BCCR_PASS"),
}
## tolarence
tol = 0.001
limitmb = 40

# funs helpers
def write_hist_imp(path, limit=40, file2write=None):
    mb_hist = os.stat(path).st_size / 1000000
    if mb_hist <= limit:
        file = pd.concat(
            [
                agg_imp.drop(columns=["cod"]).rename(columns={"date": "time"}),
                data_imp_hist,
            ]
        )
    else:
        file = agg_imp.drop(columns=["cod"]).rename(columns={"date": "time"})
    path2hist = Path.cwd().joinpath("data", file2write)
    file.to_csv(path2hist, sep="|", index=False)


# Call 2 API
try:
    response = requests.get(base, params=params_bccr)
except requests.exceptions.Timeout as e:
    raise SystemExit(e)
# Maybe set up for a retry, or continue in a retry loop
except requests.exceptions.TooManyRedirects as e:
    raise SystemExit(e)
# Tell the user their URL was bad and try a different one
except requests.exceptions.RequestException as e:
    # catastrophic error. bail.
    raise SystemExit(e)

# Data frame from response
## creation
root = ET.fromstring(response.content)
rows = {
    "cod": [x.text for x in root.findall(".//COD_INDICADORINTERNO")],
    "date": [x.text for x in root.findall(".//DES_FECHA")],
    "value": [x.text for x in root.findall(".//NUM_VALOR")],
}
raw_df = pd.DataFrame(rows)
## format date
raw_df.loc[:, "date"] = pd.to_datetime(raw_df.loc[:, "date"])
raw_df.loc[:, "year"] = raw_df.date.dt.year
raw_df.loc[:, "month"] = raw_df.date.dt.month
## filtering data
current_year = dt.datetime.now().year
agg_imp = raw_df.query("month == 12 | year == @current_year").copy(deep=True)
agg_imp.loc[:, "date"] = dt.datetime.now()
## aggregate data
new_data = agg_imp.groupby(["year", "month"]).agg({"value": np.sum})
new_data = new_data.reset_index()
new_data = new_data.rename(columns={"value": "new"})
new_data.loc[:, "new"] = pd.to_numeric(new_data.loc[:, "new"])
new_data.loc[:, "new"] = round(new_data.loc[:, "new"], 4)

# Historical data
## format
path_imp_hist = Path.cwd().joinpath("data", "historical_imp_data_bccr.csv")
data_imp_hist = pd.read_csv(path_imp_hist, sep="|")
data_imp_hist.loc[:, "time"] = pd.to_datetime(data_imp_hist.loc[:, "time"])
data_imp_hist.loc[:, "year"] = data_imp_hist.loc[:, "year"].astype("str").str.strip()
# data_imp_hist.loc[:, "year"] = data_imp_hist.loc[:, "year"].replace({"NaN": np.nan})
# data_imp_hist.loc[:, "year"] = data_imp_hist.loc[:, "year"].replace({"nan": np.nan})
data_imp_hist.loc[:, "year"] = pd.to_numeric(
    data_imp_hist.loc[:, "year"], errors='coerce', downcast="integer"
)
data_imp_hist.loc[:, "year"] = round(data_imp_hist.loc[:, "year"], 0)
# data_imp_hist.loc[:, "value"] = data_imp_hist.loc[:, "value"].replace({"NaN": np.nan})
# data_imp_hist.loc[:, "value"] = data_imp_hist.loc[:, "value"].replace({"nan": np.nan})
data_imp_hist.loc[:, "value"] = pd.to_numeric(
    data_imp_hist.loc[:, "value"], errors="coerce"
)
## last rows by date
last_time = data_imp_hist["time"].min()
## aggregate data and filter
data_imp_hist = data_imp_hist.query("time == @last_time").copy(deep=True)
data_impagg_hist = data_imp_hist.groupby(["year", "month"]).agg({"value": np.sum})
data_impagg_hist = data_impagg_hist.rename(columns={"value": "old"})
data_impagg_hist = data_impagg_hist.reset_index()
data_impagg_hist.year = data_impagg_hist.year.astype(int)
data_impagg_hist.month = data_impagg_hist.month.astype(int)
data_impagg_hist.loc[:, "old"] = data_impagg_hist.loc[:, "old"].round(4)
data_impagg_hist = data_impagg_hist.query("month == 12 | year == @current_year").copy(
    deep=True
)

# compare data
## data
compare_data = (
    pd.merge(new_data, data_impagg_hist, how="left", on=["month", "year"])
    .assign(
        old=lambda x: np.where(np.isnan(x["old"]), 0, x["old"]),
        new=lambda x: np.where(np.isnan(x["new"]), 0, x["new"]),
    )
    .assign(check=lambda x: abs(x["old"] - x["new"]) <= tol)
)
## write
path_imp_status = Path.cwd().joinpath("data", "status_bccr.csv")
compare_data.to_csv(path_imp_status, sep="|", index=False)

# write historical data
write_hist_imp(
    path=path_imp_hist, limit=limitmb, file2write="historical_imp_data_bccr.csv"
)
print("End of imports flow")
