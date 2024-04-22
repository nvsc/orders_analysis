

def main(credentials: str, filename: str, dataset: str, table: str, date_columns=None):
    from google.oauth2 import service_account
    import pandas as pd
    import pandas_gbq as pgbq

    credentials = service_account.Credentials.from_service_account_file(credentials)

    if not date_columns:
        date_columns = True

    df = pd.read_csv(filename, parse_dates=date_columns)

    pgbq.to_gbq(df, f"{dataset}.{table}", credentials=credentials, if_exists='replace')


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()

    parser.add_argument('--service_account_key_json')
    parser.add_argument('--filename')
    parser.add_argument('--dataset')
    parser.add_argument('--table')
    parser.add_argument('--date_column', nargs='*')
    args = parser.parse_args()
    main(args.service_account_key_json, args.filename, args.dataset, args.table, date_columns=args.date_column)