import yfinance as yf
import pandas as pd

def main():
    # Fetch the S&P 500 data from Wikipedia
    url = 'https://en.wikipedia.org/wiki/List_of_S%26P_500_companies'
    sp500_data = grab_sp500_data_from_wikipedia(url)
    
    # Drop improper tickers
    drop_improper_tickers(sp500_data)
    
    # Get list of tickers
    tickers = get_tickers_list(sp500_data)
    
    # Fetch historical data for all tickers
    tickers_historical_data = fetch_all_tickers_data(tickers)
    
    # Add descriptive columns to the historical data
    add_descriptive_columns(tickers_historical_data, sp500_data)
    
    # Print the historical data with added descriptive columns
    print(tickers_historical_data)

def grab_sp500_data_from_wikipedia(url: str) -> pd.DataFrame:
    # Read S&P 500 data from Wikipedia
    sp500_table = pd.read_html(url)[0]
    # Drop unnecessary columns
    sp500_table.drop(columns = ['Headquarters Location', 'CIK'], inplace=True)
    return sp500_table

def drop_improper_tickers(ticker_data: pd.DataFrame, column_name: str = 'Symbol', improper_tickers: list = ['BRK.B', 'BF.B']) -> None:
    # Drop rows with improper tickers
    ticker_data.drop(ticker_data[ticker_data[column_name].isin(improper_tickers)].index, inplace=True)

def get_tickers_list(data: pd.DataFrame, column_name: str = 'Symbol') -> list:
    # Get the list of ticker symbols from the dataframe
    return data[column_name].tolist()

def fetch_ticker_data(ticker_symbol: str, start_date: str) -> pd.DataFrame:
    # Fetch historical data for a given ticker symbol
    ticker = yf.Ticker(ticker_symbol)
    return ticker.history(start=start_date)

def fetch_all_tickers_data(ticker_symbols: list, start_date: str = '2024-01-01') -> dict:
    # Fetch historical data for all tickers in the list
    return {ticker_symbol: fetch_ticker_data(ticker_symbol, start_date) for ticker_symbol in ticker_symbols}

def add_descriptive_columns(historical_ticker_data_dictionary: dict, descriptive_data: pd.DataFrame) -> None:
    # Add descriptive columns from the Wikipedia data to the historical data
    for index, row in descriptive_data.iterrows():
        ticker = row['Symbol']
        
        # Ensure the ticker exists in the historical data dictionary
        if ticker in historical_ticker_data_dictionary:
            historical_ticker_data = historical_ticker_data_dictionary[ticker]
            
            # Add the descriptive columns to the historical data
            historical_ticker_data['Symbol'] = row['Symbol']
            historical_ticker_data['Security'] = row['Security']
            historical_ticker_data['GICS Sector'] = row['GICS Sector']
            historical_ticker_data['GICS Sub-Industry'] = row['GICS Sub-Industry']
            historical_ticker_data['Date Added'] = row['Date added']
            historical_ticker_data['Founded'] = row['Founded']

            # You can also check if the columns already exist and add them conditionally
            # For example, to avoid overwriting existing columns

# Run the main function
main()
