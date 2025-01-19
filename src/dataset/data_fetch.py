import yfinance as yf
import pandas as pd

def main():
    
    url = 'https://en.wikipedia.org/wiki/List_of_S%26P_500_companies'
    sp500_data = grab_sp500_data_from_wikipedia(url)
    
    drop_improper_tickers(sp500_data)
    
    tickers = get_tickers_list(sp500_data)
    
    tickers_historical_data = fetch_all_tickers_data(tickers)
    
    add_descriptive_columns(tickers_historical_data, sp500_data)
    
    output = merge_data_into_one_table(tickers_historical_data)

def grab_sp500_data_from_wikipedia(url: str) -> pd.DataFrame:
    print('Beginning to get tickers from Wikipedia')
    sp500_table = pd.read_html(url)[0]
    sp500_table.drop(columns = ['Headquarters Location', 'CIK'], inplace = True)
    print('Successfully got tickers from Wikipedia')
    return sp500_table

def drop_improper_tickers(ticker_data: pd.DataFrame, column_name: str = 'Symbol', improper_tickers: list = ['BRK.B', 'BF.B', 'PPG']) -> None:
    print('Beginning to drop improper tickers')
    ticker_data.drop(ticker_data[ticker_data[column_name].isin(improper_tickers)].index, inplace = True)
    print('Successfully dropped improper tickers')

def get_tickers_list(data: pd.DataFrame, column_name: str = 'Symbol') -> list:
    return data[column_name].tolist()

def fetch_ticker_data(ticker_symbol: str, start_date: str) -> pd.DataFrame:
    print(f'Beginning to get yahoo finance historical data for {ticker_symbol}')
    ticker = yf.Ticker(ticker_symbol)
    data = ticker.history(start = start_date)
    data.reset_index(inplace = True)
    print(f'Successfully got yahoo finance historical data for {ticker_symbol}')
    return data

def fetch_all_tickers_data(ticker_symbols: list, start_date: str = '2024-01-01') -> dict[str, pd.DataFrame]:
    return {ticker_symbol: fetch_ticker_data(ticker_symbol, start_date) for ticker_symbol in ticker_symbols}

def add_descriptive_columns(historical_ticker_data_dictionary: dict[str, pd.DataFrame], descriptive_data: pd.DataFrame) -> None:
    for index, row in descriptive_data.iterrows():
        ticker = row['Symbol']
        
        if ticker in historical_ticker_data_dictionary:
            historical_ticker_data = historical_ticker_data_dictionary[ticker]
            
            historical_ticker_data['Symbol'] = row['Symbol']
            historical_ticker_data['Security'] = row['Security']
            historical_ticker_data['GICS Sector'] = row['GICS Sector']
            historical_ticker_data['GICS Sub-Industry'] = row['GICS Sub-Industry']
            historical_ticker_data['Date Added'] = row['Date added']
            historical_ticker_data['Founded'] = row['Founded']

def merge_data_into_one_table(historical_ticker_data_dictionary: pd.DataFrame,
                              column_names: list[str] = None
                              ) -> pd.DataFrame:
    if column_names is None:
        column_names = [
            'Date',
            'Symbol',
            'Security',
            'GICS Sector',
            'GICS Sub-Industry',
            'Date Added',
            'Founded',
            'Open',
            'High',
            'Low',
            'Close',
            'Volume',
            'Dividends',
            'Stock Splits'
        ]

    return_df = pd.DataFrame(columns = column_names)

    ticker_dfs = list(historical_ticker_data_dictionary.values())
    ticker_dfs = [return_df, *ticker_dfs]
    
    print('Beginning to merge all tickers\' data into one dataframe')
    result = pd.concat(ticker_dfs, ignore_index = True)
    print('Successfully merged all data')

    return result

def dump_data_to_csv(all_data: pd.DataFrame, 
                     path: str
                     ) -> None:
    print('Beginning to dump data to a csv file')
    all_data.to_csv(path)
    print('Successfully dumped data to a csv file')
main()