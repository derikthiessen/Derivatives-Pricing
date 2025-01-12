classdef Strategies
    % Contains all the methods to add each individual prediction strategy to an input dataset
    
    methods(Static)
        
        function weightedAverage = calculateWeightedAverage(values, weights)
            weightedAverage = sum(values .* weights) / sum(weights);
        end

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
        
    end
end