# Stock-Pricing-Models

## About
This repository allows for the user to input their own dataset, and build combinations of different common stock trading strategies, 
all tuned with their choice of parameters, to assess their trading effectiveness. Currently, four major stock trading strategies are 
supported: weighted moving average, momentum, Bollinger bands, and RSI. Each of these strategies can be tuned by the user (e.g., for
the weighted moving average, can select the number of periods to include in the average, as well as the respective weights) and combined
with other strategies to ultimately assess the combined strategy's effectiveness. The effectiveness is determined by buying / selling
the stock following the strategy and then completing the opposite transaction (selling if bought at first, buying if sold at first)
after x input periods. 'x' can be any offset, provided there are enough days in the dataset, and tests can also be conducted on multiple
offsets at once.

## Set-up
1. Dump your data into a csv file. At minimum, the data requires one column for the date and one for the price.
    - A sample dataset, which includes all the S&P 500 stocks along with their prices from January 2024 to December 2024,
    is provided in the src/dataset folder if desired to be used.

2. Copy the path of your data csv and place it in src/createConfig.m. Run the file to store the path.

3. Create an entrypoint file to run the functions and place it in the src/ folder. Add the following code to the top of the file:
    - addpath('classes');
    - config = load("config.mat");
    - data = readtable(config.datasetPath);

    The src/main.m file provided has an example of this set-up.

## Usage
For sample usage, you can view the src/main.m file in its entirety. More specific instructions provided below:

1. Create an instance of tickerPredictions. Input the ticker symbol, a data table which has read your dataset, and an array of numbers
which represent the period offsets you would like to use for validating strategy effectiveness.

2. Make function calls to the various functions in TradingStrategies to add the base strategies to your input dataset. The available functions, with their respective parameters, include:
    - addWeightedMovingAverage(stockData, periods, columnName, weights): adds a weighted moving average indicator.
        - stockData (table): input your instance of TickerPrediction's stockData property.
        - periods (integer): input an integer for the number of periods included in the moving average.
        - columnName (char array): input the name of your price column.
        - weights (array of decimal numbers) [optional]: input an array of decimal numbers representing the weights of the respective periods. The weights are mapped to the periods in ascending order, e.g. if periods = 2 and weights = {0.4, 0.6}, then the value one period ago has a weight of 0.4 and the value two periods ago has a weight of 0.6. Weights must sum to 1.
        - return values [table, char array]: the input stockData and the name of the new column added to stockData.
    
    - addMomentum(stockData, periods, columnName): adds a count of the number of periods in the last 'x' periods where the price increased from the previous period.
        - stockData (table): same as for addWeightedMovingAverage.
        - periods (integer): the number of periods included in the count.
        - columnName (char array): same as for addWeightedMovingAverage.
        - return values [table, char array]: the input stockData and the name of the new column added to stockData.
    
    - addBollingerBands(stockData, columnName, smaPeriods, numStdDev, StedDevWindowSize): adds upper and lower Bollinger bands with the input parameters.
        - stockData (table): same as for addWeightedMovingAverage.
        - columnName (char array): same as for addWeightedMovingAverage.
        - smaPeriods (integer): the number of periods to count for the SMA portion of the Bollinger band calculation.
        - numStdDev (numeric): the number of standard deviations to use for the calculation.
        - StdDevWindowSize (integer): the number of periods to count for the standard deviation portion of the calculation.
        - return values [table, char array, char array]: the input stockData and two char arrays of the new columns (upper and lower Bollinger bands) added to stockData.
    
    - addRSI(stockDatam columnName, windowSize): adds the Relative Strength Index (RSI) to the dataset.
        - stockData (table): The table containing the stock data.
        - columnName (char array): The column name of the price data.
        - windowSize (integer): The number of periods to use for calculating the average gains and losses.
        - return values [table, char array]: the input stockData and the name of the new column added to stockData.

    - addMomentumBuySellSignal(stockData, momentumColumnName, buyThreshold): adds a buy/sell signal based on momentum strategy to the dataset.
        - stockData (table): The table containing the stock data.
        - momentumColumnName (char array): The column name of the momentum data.
        - buyThreshold (numeric): The threshold above which the signal will be a "buy" (1), otherwise "sell" (0).
        - return values [table, char array]: the input stockData and the name of the new column added to stockData.

    - addRSISellSignal(stockData, momentumColumnName, buyThreshold): adds a buy/sell signal based on an RSI strategy to the dataset.
        - stockData (table): The table containing the stock data.
        - RSIColumnName (char array): The column name of the momentum data.
        - buyThreshold (numeric): The threshold above which the signal will be a "buy" (1), otherwise "sell" (0).
        - return values [table, char array]: the input stockData and the name of the new column added to stockData.

3. Build combined strategies using the buildCombinedStrategy function in the StrategyBuilder class. Pass in a boolean algebra operator and different columns, along with their according parameters, to the function to output a new column in stockData which contains a "buy" (1) or "sell" (0) indicator dependent on the inputs.
    - stockData (table): The table containing the stock data.
    - priceColumn (char array): the name of the price column in stockData.
    - strategyConditions (containers.Map): a map of the name of the desired column as the keys, with the respective strategy specifications as the values.
    - logicalOperator (char array): either "and" or "or". Specifies if the strategy should require all strategyConditions to be true, or only a single one.
    - outputColumnTitle (char array): the name of the column added to stockData.
    - return values (table, char array): the input stockData and the name of the new column added to stockData.

4. Plot the strategy outputs using one of the three plotting functions. Calling any of the functions will plot the chart directly and not return anything:

    - plotStrategyPredictionLines(stockData, xColumnName, lineColumnNames, yAxisTitle, chartTitle): plots a line chart for one or more strategy outputs.
        - stockData (table): the table containing the stock data.
        - xColumnName (char array): the name of the column to be used for the x-axis (typically the date column).
        - lineColumnNames (cell array of char arrays): the names of the columns to be plotted as lines.
        - yAxisTitle (char array): title for the y-axis.
        - chartTitle (char array): title for the chart.

    - plotPredictionAccuracyBars(stockData, strategyColumnNames, priceValidationColumnNames, chartTitle): plots a bar chart showing the prediction accuracy of various strategies.
        - stockData (table): input the data table containing the strategies and price validation columns.
        - strategyColumnNames (cell array of char arrays): the names of the strategy columns for which accuracy needs to be calculated.
        - priceValidationColumnNames (cell array of char arrays): the names of the columns containing the prices used for validation.
        - chartTitle (char array): title for the chart.  
    
    - plotCumulativeValueAddedLines(stockData, xColumnName, strategyColumnNames, priceValidationColumnNames, chartTitle): plots a line chart showing the cumulative value added by various strategies over time.
        - stockData (table): input the data table containing the strategies, price validation columns, and the date/period column.
        - xColumnName (char array): the name of the column to be used for the x-axis (typically the date or time period).
        - strategyColumnNames (cell array of char arrays): the names of the strategy columns for which cumulative value added needs to be calculated.
        - priceValidationColumnNames (cell array of char arrays): the names of the columns containing the prices used for validation.