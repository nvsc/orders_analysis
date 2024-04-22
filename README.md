Local installation:

In the project root folder, run in terminal

```sh
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Populate .env file

```sh
TARGET_PROJECT="!!!TARGET PROJECT ID"
TARGET_DATASET="!!!TARGET TEST DATASET ID"
ORDERS_PART_EXT_TABLE=valekseev_order_part_ext
ORDERS_PART_EXT_FILE=data/order_parts_ext.csv
PATH_TO_ACCOUNT_KEY_JSON=data/service_account_test_task.json
```

read .env file:
```sh
set -a; source .env; set +a;
```

Run load of order_parts_ext.csv file
```sh
python3 scripts/upload_to_bq.py --service_account_key_json=$PATH_TO_ACCOUNT_KEY_JSON --filename=$ORDERS_PART_EXT_FILE --dataset=$TARGET_DATASET --table=$ORDERS_PART_EXT_TABLE --date_column in_production_at
```

Invoke dbt run

```sh
dbt deps;
dbt run;
```

To generate analysis report, invoke
```sh
dbt compile;
cat target/compiled/orders_analysis/analyses/orders_upload_analysis/orders_upload_analysis_revenue.sql | bq query
```