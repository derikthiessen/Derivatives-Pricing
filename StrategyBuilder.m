classdef StrategyBuilder
    % Class for combining common strategies that are already predefined in the TradingStrategies class
    % Takes an input data table and new column name and outputs the same table with the new column name added.
    % The new column contains a "Buy" or "Sell" signal (1 for Buy, 0 for Sell) that specifies if the user's
    % input strategy would have been a buy or a sell for that given day

    methods(Static)

        function stockData = buildCombinedStrategy(stockData, priceColumn, strategyConditions, logicalOperator, outputColumnTitle)
            
            if ~ismember(logicalOperator, ["and", "or"])
                error('Input for logicalOperator must be "and" or "or".');
            end
            
            % Initialize the decision column with NaN values
            stockData.(outputColumnTitle) = NaN(height(stockData), 1);
            
            % Map of strategy types to key phrases
            strategyMap = StrategyBuilder.mapColumnNamesToStrategies(strategyConditions);
            
            % Process conditions and apply logic
            conditionResults = false(height(stockData), length(strategyConditions));
            colIndex = 1;
            
            for columnName = keys(strategyConditions)
                columnNameStr = columnName{1};
                conditionValue = strategyConditions(columnNameStr);
                
                % Check if the column name is valid and present in strategyMap
                if isKey(strategyMap, columnNameStr)
                    switch strategyMap(columnNameStr)
                        case 'MovingAverage'
                            if isnumeric(conditionValue)
                                conditionResults(:, colIndex) = abs(stockData.(columnNameStr) - stockData.(priceColumn)) ./ stockData.(priceColumn) >= conditionValue;
                            elseif ismember(conditionValue, {'over', 'under'})
                                if conditionValue == "over"
                                    conditionResults(:, colIndex) = stockData.(columnNameStr) > stockData.(priceColumn);
                                else
                                    conditionResults(:, colIndex) = stockData.(columnNameStr) < stockData.(priceColumn);
                                end
                            else
                                error('Invalid condition for MovingAverage. Use "over", "under", or a numeric value.');
                            end
                        case 'Momentum'
                            conditionResults(:, colIndex) = stockData.(columnNameStr) >= conditionValue;
                        case 'Bollinger'
                            if isnumeric(conditionValue)
                                conditionResults(:, colIndex) = abs(stockData.(columnNameStr) - stockData.(priceColumn)) ./ stockData.(priceColumn) >= conditionValue;
                            elseif ismember(conditionValue, {'over', 'under'})
                                if conditionValue == "over"
                                    conditionResults(:, colIndex) = stockData.(columnNameStr) > stockData.(priceColumn);
                                else
                                    conditionResults(:, colIndex) = stockData.(columnNameStr) < stockData.(priceColumn);
                                end
                            else
                                error('Invalid condition for Bollinger. Use "over", "under", or a numeric value.');
                            end
                        case 'RSI'
                            conditionResults(:, colIndex) = stockData.(columnNameStr) >= conditionValue;
                        otherwise
                            error('Unknown strategy type.');
                    end
                    colIndex = colIndex + 1;
                else
                    error(['Column ', columnNameStr, ' not found or does not match any strategy types.']);
                end
            end
            
            % Calculate final buy decision
            if logicalOperator == "and"
                finalDecision = all(conditionResults, 2);
            else
                finalDecision = any(conditionResults, 2);
            end
            
            % Apply NaN logic
            nanRows = any(ismissing(stockData(:, [priceColumn, keys(strategyConditions)])), 2);
            stockData.(outputColumnTitle) = double(finalDecision);
            stockData.(outputColumnTitle)(nanRows) = NaN;
        end

        function strategyMap = mapColumnNamesToStrategies(strategyConditions)

            strategyMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

            for columnName = keys(strategyConditions)
                columnNameStr = columnName{1};
                lowerColumnNameStr = lower(columnNameStr);

                if contains(lowerColumnNameStr, 'rsi')
                    strategyMap(columnNameStr) = 'RSI';

                elseif contains(lowerColumnNameStr, 'momentum')
                    strategyMap(columnNameStr) = 'Momentum';

                elseif contains(lowerColumnNameStr, 'bollinger')
                    strategyMap(columnNameStr) = 'Bollinger';

                elseif contains(lowerColumnNameStr, 'movingaverage')
                    strategyMap(columnNameStr) = 'MovingAverage';
                
                else
                    errorString = sprintf(...
                        'The input column %s does not match any known strategy types. ', ...
                        'Please edit the column name to match one of the expected types (RSI, Momentum, Bollinger, MovingAverage), ', ...
                        'or add the strategy type to the if block in this function and the TradingStrategies class.', ...
                        columnNameStr);

                    error('MATLAB:InvalidValue', errorString);

                end
            end
        end
    end
end