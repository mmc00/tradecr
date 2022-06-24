# import the libraries
import pandas as pd
import numpy as np
import os
import datetime as dt
from pathlib import Path

# params
tol = 0.001
limitmb = 40

# funs helpers
def write_hist_exp(path, limit=40, file2write=None):
    mb_hist = os.stat(path).st_size / 1000000
    if mb_hist <= limit:
        file = pd.concat([data_con_hist, data_con_long])
    else:
        file = data_con_long
    path2hist = Path.cwd().joinpath("data", file2write)
    file.to_csv(path2hist, sep="|", index=False)


# cheking files
path = Path.cwd().joinpath("temp")
path_con = [e for e in os.listdir(path) if e.startswith("con_data")][0]
path_chp = [e for e in os.listdir(path) if e.startswith("cap_data")][0]
print([path_con, path_chp])

# cleaning data

## reading data
### country data
data_con_raw = pd.read_excel(path.joinpath(path_con), skiprows=1)
data_con_raw = data_con_raw.rename(columns={data_con_raw.columns[0]: "country"})
cols_expected = [str(e) for e in list(range(1990, 2030)) + ["country"]]
cols2drop = [e for e in data_con_raw.columns if e not in cols_expected]
cols2drop = [e for e in cols2drop if not e.startswith("202")]
data_con_raw = data_con_raw.drop(columns=cols2drop, axis=0)
### chapter data
data_chp_raw = pd.read_excel(path.joinpath(path_chp), skiprows=1)
data_chp_raw = data_chp_raw.rename(columns={data_chp_raw.columns[0]: "chapter"})
cols_expected_chp = [str(e) for e in list(range(1990, 2030)) + ["chapter"]]
cols2drop_chp = [e for e in data_chp_raw.columns if e not in cols_expected_chp]
cols2drop_chp = [e for e in cols2drop_chp if not e.startswith("202")]
data_chp_raw = data_chp_raw.drop(columns=cols2drop_chp, axis=0)

## to long
### country data
data_con_long = pd.melt(data_con_raw, id_vars="country", var_name="year")
# data_con_long.loc[:, "value"] = data_con_long.loc[:, "value"].replace({"NaN": np.nan})
data_con_long.loc[:, "value"] = pd.to_numeric(
    data_con_long.loc[:, "value"], errors="coerce"
)
data_con_long = data_con_long.query("value == value").copy(deep=True)
### chapter data
data_chp_long = pd.melt(data_chp_raw, id_vars="chapter", var_name="year")
# data_chp_long.loc[:, "value"] = data_chp_long.loc[:, "value"].replace({"NaN": np.nan})
data_chp_long.loc[:, "value"] = pd.to_numeric(
    data_chp_long.loc[:, "value"], errors="coerce"
)
data_chp_long = data_chp_long.query("value == value").copy(deep=True)

## fixing countries names
data_con_long.loc[:, "country"] = data_con_long.loc[:, "country"].replace(
    {"Reino Unido-No UE": "Reino Unido", "Reino Unido-UE": "Reino Unido"}
)
data_con_long = data_con_long.query("country != 'Grand Total'").copy(deep=True)
data_chp_long = data_chp_long.query("chapter != 'Grand Total'").copy(deep=True)

## adding current time
### current time
now_var = dt.datetime.now()
### country data
data_con_long.loc[:, "time"] = now_var
### chapter data
data_chp_long.loc[:, "time"] = now_var

## group data
data_con_new = data_con_long.groupby(["year"]).agg({"value": np.sum})
data_con_new = data_con_new.rename(columns={"value": "new"})
data_con_new.index = data_con_new.index.astype("str").str.strip()

# reading historical data

## load
path_con_hist = Path.cwd().joinpath("data", "historical_country_data_procomer.csv")
data_con_hist = pd.read_csv(path_con_hist, delimiter="|")

## filter and group data
last_time = data_con_hist["time"].max()
data_con_old = data_con_hist.query("time == @last_time")
data_con_old = data_con_old.groupby(["year"]).agg({"value": np.sum})
data_con_old = data_con_old.rename(columns={"value": "old"})
data_con_old.index = data_con_old.index.astype("str").str.strip()

# comparing data
con_join = pd.merge(
    data_con_old, data_con_new, how="outer", left_index=True, right_index=True
)
con_join[["old", "new"]] = con_join[["old", "new"]].replace({np.nan: 0})
con_join["check"] = abs(con_join["old"] - con_join["new"])
con_join["check"] = con_join["check"] <= tol
con_status = con_join
con_check = con_join.query("~ check")

# results
## status and check files
path_con_status = Path.cwd().joinpath("data", "status_procomer.csv")
path_con_check = Path.cwd().joinpath("data", "check_procomer.csv")
con_status.to_csv(path_con_status, sep="|", index=False)
con_check.to_csv(path_con_check, sep="|", index=False)
## historical data
write_hist_exp(
    path=path_con_hist, limit=limitmb, file2write="historical_country_data_procomer.csv"
)
print("End of exports flow")
