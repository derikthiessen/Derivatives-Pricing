classdef Strategies
    % Contains all the methods to add each individual prediction strategy to an input dataset
    
    methods(Static)

        function stockData = addWeightedMovingAverage(stockData, periods, columnName, weights)
            
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
                weightedMovingAverage(i) = sum(values .* weights);
            end
            
            % Add the weighted moving average column to the table
            newColumnName = sprintf('%d_WeightedMovingAverage', periods);

            stockData.(newColumnName) = weightedMovingAverage;
        end
        
        function stockData = addMomentum(stockData, periods, columnName)
            
            if nargin < 3
                error('You must provide stockData, periods, and columnName as inputs.');
            end
        
            % Get the data from the specified column
            dataColumn = stockData.(columnName);
            
            % Initialize the momentum column
            momentumColumn = zeros(height(stockData), 1);
            
            % Calculate the momentum
            for i = periods:height(stockData)
                momentumCount = 0;
                for j = 1:periods
                    if dataColumn(i-j+1) > dataColumn(i-j)
                        momentumCount = momentumCount + 1;
                    end
                end
                momentumColumn(i) = momentumCount;
            end
            
            % Add the momentum column to the table
            newColumnName = sprintf('%d_Momentum', periods);
            stockData.(newColumnName) = momentumColumn;
        end
        
        function stockData = addBollingerBands(stockData, columnName, smaPeriods, numStdDev, StdDevWindowSize)

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
            upperBandColumnName = sprintf('BollingerUpperBand_%d', smaPeriods);
            lowerBandColumnName = sprintf('BollingerLowerBand_%d', smaPeriods);
            
            stockData.(upperBandColumnName) = upperBand;
            stockData.(lowerBandColumnName) = lowerBand;
        end
        
        function stockData = addRSI(stockData, columnName, windowSize)
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
            rsiColumnName = sprintf('RSI_%d', windowSize);
            stockData.(rsiColumnName) = rsi;
        end
        
    end
end