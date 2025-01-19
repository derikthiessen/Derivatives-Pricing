addpath('classes');

config = load("config.mat");

data = readtable(config.datasetPath);

filteredData = data(data.Symbol == "MMM", :);

tickerPredictions = TickerPredictions("MMM", filteredData, [1, 3, 5]);

% Cell array to hold the column names of the created strategies
strategyColumnNames = {};

disp('Adding weighted moving average column...');
[tickerPredictions.stockData, wmaColumn] = TradingStrategies.addWeightedMovingAverage(tickerPredictions.stockData, 3, 'Close', [0.2, 0.2, 0.6]);
strategyColumnNames{end + 1} = wmaColumn;

disp('Adding momentum column...');
[tickerPredictions.stockData, momentumColumn] = TradingStrategies.addMomentum(tickerPredictions.stockData, 3, 'Close');
strategyColumnNames{end + 1} = momentumColumn;

disp('Adding Buy/Sell signal for the momentum column...');
[tickerPredictions.stockData, momentumSignalColumn] = TradingStrategies.addMomentumBuySellSignal(tickerPredictions.stockData, momentumColumn, 2);
strategyColumnNames{end + 1} = momentumSignalColumn;

disp('Adding Bollinger upper and lower bounds columns...');
[tickerPredictions.stockData, upperColumn, lowerColumn] = TradingStrategies.addBollingerBands(tickerPredictions.stockData, 'Close', 10, 2, 5);
strategyColumnNames{end + 1} = upperColumn;
strategyColumnNames{end + 1} = lowerColumn;

disp('Adding RSI column...');
[tickerPredictions.stockData, RSIColumn] = TradingStrategies.addRSI(tickerPredictions.stockData, 'Close', 10);
strategyColumnNames{end + 1} = RSIColumn;

disp('Adding Buy/Sell signal for the RSI column...');
[tickerPredictions.stockData, RSISignalColumn] = TradingStrategies.addRSIBuySellSignal(tickerPredictions.stockData, RSIColumn, 70);
strategyColumnNames{end + 1} = RSISignalColumn;

% Plotting the line chart using Plotting class
xColumnName = 'Date';
strategyColumnNames{end + 1} = 'Close';



% Plotting.plotStrategyPredictionLines(...
%     tickerPredictions.stockData, ...
%     xColumnName, ...
%     {'Close', wmaColumn, upperColumn, lowerColumn}, ...
%     'Price', ...
%     'Strategy Performance vs. Closing Price');



% Plotting.plotStrategyPredictionLines(...
%     tickerPredictions.stockData, ...
%     xColumnName, ...
%     RSIColumn, ...
%     'Index', ...
%     'RSI');



% Plotting.plotStrategyPredictionLines(...
%     tickerPredictions.stockData, ...
%     xColumnName, ...
%     {RSISignalColumn, momentumSignalColumn}, ...
%     'Buy / Sell Signal', ...
%     'RSI and Momentum Buy / Sell Signal');



% Combine strategies into one signal
disp('Building combined strategies...');
WMABollingerStrategyConditions = containers.Map;
WMABollingerStrategyConditions(wmaColumn) = "over";
WMABollingerStrategyConditions(upperColumn) = {"over", 0.05};

MomentumRSIStrategyConditions = containers.Map;
MomentumRSIStrategyConditions(momentumColumn) = 2;
MomentumRSIStrategyConditions(RSIColumn) = 50;

[tickerPredictions.stockData, BollingerAndWMACombinedStrategyColumn] = StrategyBuilder.buildCombinedStrategy(...
    tickerPredictions.stockData, 'Close', WMABollingerStrategyConditions, 'and', 'BollingerAndWMACombinedStrategy');

[tickerPredictions.stockData, MomentumAndRSICombinedStrategyColumn] = StrategyBuilder.buildCombinedStrategy(...
    tickerPredictions.stockData, 'Close', MomentumRSIStrategyConditions, 'or', 'MomentumAndRSICombinedStrategy');




% Plotting.plotPredictionAccuracyBars(...
%     tickerPredictions.stockData, ...
%     {BollingerAndWMACombinedStrategyColumn, MomentumAndRSICombinedStrategyColumn}, ...
%     tickerPredictions.priceValidationColumnNames, ...
%     'Prediction Accuracy of Combined Strategies');



Plotting.plotCumulativeValueAddedLines(...
    tickerPredictions.stockData, ...
    xColumnName, ...
    {BollingerAndWMACombinedStrategyColumn, MomentumAndRSICombinedStrategyColumn}, ...
    tickerPredictions.priceValidationColumnNames{1}, ...
    'Cumulative Value Added of Combined Strategies');