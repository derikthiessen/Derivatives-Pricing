classdef Strategies
    % Contains all the methods to add each individual prediction strategy to an input dataset
    
    methods(Static)

        function [stockData, newColumnName] = addWeightedMovingAverage(stockData, periods, columnName, weights)
            
            if nargin < 4

                % If weights are not provided, default to equal weights
                weights = ones(1, periods) / periods;
            
            % If weights are provided, check if the sum of weights is 1
            else

                if abs(sum(weights) - 1) > eps
                    error('MATLAB:InvalidValue', 'Weights must sum to 1.');
                end
                
                % Check if the number of weights matches the number of periods
                if length(weights) ~= periods
                    error('MATLAB:InvalidValue', 'The number of weights must match the number of periods.');
                end
            end
            
            % Get the data from the specified column
            dataColumn = stockData.(columnName);
            
            % Initialize the weighted moving average column
            weightedMovingAverage = NaN(height(stockData), 1);
            
            % Calculate the weighted moving average
            for i = periods:height(stockData)
                values = dataColumn(i-periods+1:i); % Get the last 'periods' values

                values = values'; % Transposes the 'values' column vector into a row vector so that the element-wise multiplication results in a row vector

                weightedMovingAverage(i) = sum(values .* weights);

            end
            
            % Add the weighted moving average column to the table
            newColumnName = sprintf('WeightedMovingAverage%dPeriods', periods);

            stockData.(newColumnName) = weightedMovingAverage;
        end
        
        function [stockData, newColumnName] = addMomentum(stockData, periods, columnName)
            
            if nargin < 3
                error('You must provide stockData, periods, and columnName as inputs.');
            end
        
            % Get the data from the specified column
            dataColumn = stockData.(columnName);
            
            % Initialize the momentum column
            momentumColumn = NaN(height(stockData), 1);

            % Calculate the momentum
            for i = (periods + 1) : height(stockData) % looping over the entire column to get each momentum value
                momentumCount = 0;

                for j = (i - periods) : (i - 1) % looping over the 'periods' window for the specific i column

                    if dataColumn(j + 1) > dataColumn(j)
                        momentumCount = momentumCount + 1;
                    end
                    

                end

                momentumColumn(i) = momentumCount;
            end
            
            % Add the momentum column to the table
            newColumnName = sprintf('Momentum%dPeriods', periods);
            stockData.(newColumnName) = momentumColumn;
        end
        
        function [stockData, upperBandColumnName, lowerBandColumnName] = addBollingerBands(stockData, columnName, smaPeriods, numStdDev, StdDevWindowSize)

            % Validate inputs
            if nargin < 5
                error('You must provide stockData, columnName, periods, numStdDev, and StdDevWindowSize as inputs.');
            end
        
            % Get the data from the specified column
            dataColumn = stockData.(columnName);
            
            % Initialize the new columns
            upperBand = NaN(height(stockData), 1);
            lowerBand = NaN(height(stockData), 1);
            
            % Calculate the Bollinger Bands
            for i = smaPeriods:height(stockData)

                % Calculate the SMA
                sma = mean(dataColumn(i-smaPeriods+1:i));
                
                % Calculate the standard deviation over the last 10 periods
                stdDevWindow = min(StdDevWindowSize, i);
                stdDev = std(dataColumn(i-stdDevWindow+1:i));
                
                % Calculate the bands
                upperBand(i) = sma + numStdDev * stdDev;
                lowerBand(i) = sma - numStdDev * stdDev;
            end
            
            % Add the new columns to the table
            upperBandColumnName = sprintf('BollingerUpperBand%dSMA_Periods', smaPeriods);
            lowerBandColumnName = sprintf('BollingerLowerBand%dSMA_Periods', smaPeriods);
            
            stockData.(upperBandColumnName) = upperBand;
            stockData.(lowerBandColumnName) = lowerBand;
        end
        
        function [stockData, newColumnName] = addRSI(stockData, columnName, windowSize)
            % Validate inputs
            if nargin < 3
                error('You must provide stockData, columnName, and windowSize as inputs.');
            end
        
            % Get the data from the specified column
            dataColumn = stockData.(columnName);
        
            % Initialize the new RSI column
            rsi = NaN(height(stockData), 1);
        
            % Calculate the RSI
            for i = windowSize+1:height(stockData)
                % Calculate gains and losses
                gains = max(dataColumn(i-windowSize+1:i) - dataColumn(i-windowSize:i-1), 0);
                losses = max(dataColumn(i-windowSize:i-1) - dataColumn(i-windowSize+1:i), 0);
        
                % Calculate average gains and losses
                avgGain = mean(gains);
                avgLoss = mean(losses);
        
                % Calculate the Relative Strength (RS)
                rs = avgGain / avgLoss;
        
                % Calculate RSI
                rsi(i) = 100 - (100 / (1 + rs));
            end
        
            % Add the new RSI column to the table
            newColumnName = sprintf('RSI%dAvgWindowSize', windowSize);
            stockData.(newColumnName) = rsi;
        end

        function [stockData, newColumnName] = addMomentumBuySellSignal(stockData, momentumColumnName, buyThreshold)
            
            % Initialize the BuySellSignal column with "Sell" by default
            buySellSignal = repmat("Sell", height(stockData), 1);
            
            % Find the indices where the momentum value meets or exceeds the buyThreshold
            buyIndices = stockData.(momentumColumnName) >= buyThreshold;
            
            buySellSignal(buyIndices) = "Buy";
            
            % Determine the new columnName
            newColumnName = momentumColumnName + "BuySellSignal";

            stockData.newColumnName = buySellSignal;
        end
        
    end
end