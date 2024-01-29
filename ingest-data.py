#!/usr/bin/env python
# coding: utf-8
import argparse
import os
from time import time
import requests
import pandas as pd
from sqlalchemy import create_engine

def download_file(url, filename):
    response = requests.get(url)
    response.raise_for_status()
    with open(filename, 'wb') as file:
        file.write(response.content)
        
def convert_dates(df, columns):
    for col in columns:
        df[col] = pd.to_datetime(df[col])
    return df

def main(params):
    filename = 'output.csv.gz' if params.url.endswith('.csv.gz') else 'output.csv'
    download_file(params.url, filename)

    engine = create_engine(f'postgresql://{params.user}:{params.password}@{params.host}:{params.port}/{params.db}')
    
    first_chunk = True
    
    with pd.read_csv(filename, iterator=True, chunksize=100000) as df_iter:
        for df in df_iter:
            df = convert_dates(df, df.filter(like='datetime').columns)
            if first_chunk:
                df.head(0).to_sql(name=params.table_name, con=engine, if_exists='replace')
                first_chunk = False
            df.to_sql(name=params.table_name, con=engine, if_exists='append')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Ingest CSV data to Postgres')

    parser.add_argument('--user', default='root', help='user name for postgres')
    parser.add_argument('--password', default='root', help='password for postgres')
    parser.add_argument('--host', default='localhost', help='host for postgres')
    parser.add_argument('--port', default=5432, help='port for postgres')
    parser.add_argument('--db', default='ny_taxi', help='database name for postgres')
    parser.add_argument('--table_name', required=True, help='name of the table where we will write the results to')
    parser.add_argument('--url', required=True, help='url of the csv file')

    args = parser.parse_args()

    main(args)