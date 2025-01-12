classdef Strategies
    % Contains all the methods to add each individual prediction strategy to an input dataset
    
    methods(Static)
        
        function weightedAverage = calculateWeightedAverage(values, weights)
            weightedAverage = sum(values .* weights) / sum(weights);
        end

        function stockData = addWeightedMovingAverage(stockData, periods, columnName, weights)
            
            % Validate input arguments
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
            newColumnName = [columnName '_WeightedMovingAvg'];
            
            stockData.(newColumnName) = weightedMovingAverage;
        end
        
    end
end