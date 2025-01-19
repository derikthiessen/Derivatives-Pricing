classdef StrategyBuilder
    % Class for combining common strategies that are already predefined in the TradingStrategies class
    % Takes an input data table and new column name and outputs the same table with the new column name added.
    % The new column contains a "Buy" or "Sell" signal (1 for Buy, 0 for Sell) that specifies if the user's
    % input strategy would have been a buy or a sell for that given day

    methods(Static)

        function stockData = determineBuySignal(stockData, priceColumn, strategyConditions, logicalOperator, outputColumnTitle)
            % Validate logicalOperator
            if ~ismember(logicalOperator, ["and", "or"])
                error('logicalOperator must be "and" or "or".');
            end
            
            % Initialize the decision column with NaN values
            stockData.(outputColumnTitle) = NaN(height(stockData), 1);
            
            % Map of strategy types to key phrases
            strategyMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
            for columnName = fieldnames(stockData)'
                colNameStr = columnName{1};
                if contains(lower(colNameStr), 'rsi')
                    strategyMap(colNameStr) = 'RSI';
                elseif contains(lower(colNameStr), 'momentum')
                    strategyMap(colNameStr) = 'Momentum';
                elseif contains(lower(colNameStr), 'bollinger')
                    strategyMap(colNameStr) = 'Bollinger';
                elseif contains(lower(colNameStr), 'movingaverage')
                    strategyMap(colNameStr) = 'MovingAverage';
                end
            end
            
            % Process conditions and apply logic
            conditionResults = false(height(stockData), length(strategyConditions));
            colIndex = 1;
            
            for columnName = keys(strategyConditions)
                colNameStr = columnName{1};
                conditionValue = strategyConditions(colNameStr);
                
                % Check if the column name is valid and present in strategyMap
                if isKey(strategyMap, colNameStr)
                    switch strategyMap(colNameStr)
                        case 'MovingAverage'
                            if isnumeric(conditionValue)
                                conditionResults(:, colIndex) = abs(stockData.(colNameStr) - stockData.(priceColumn)) / stockData.(priceColumn) >= conditionValue;
                            elseif ismember(conditionValue, {'over', 'under'})
                                if conditionValue == "over"
                                    conditionResults(:, colIndex) = stockData.(colNameStr) > stockData.(priceColumn);
                                else
                                    conditionResults(:, colIndex) = stockData.(colNameStr) < stockData.(priceColumn);
                                end
                            else
                                error('Invalid condition for MovingAverage. Use "over", "under", or a numeric value.');
                            end
                        case 'Momentum'
                            conditionResults(:, colIndex) = stockData.(colNameStr) >= conditionValue;
                        case 'Bollinger'
                            % Similar logic to MovingAverage
                            if isnumeric(conditionValue)
                                conditionResults(:, colIndex) = abs(stockData.(colNameStr) - stockData.(priceColumn)) / stockData.(priceColumn) >= conditionValue;
                            elseif ismember(conditionValue, {'over', 'under'})
                                if conditionValue == "over"
                                    conditionResults(:, colIndex) = stockData.(colNameStr) > stockData.(priceColumn);
                                else
                                    conditionResults(:, colIndex) = stockData.(colNameStr) < stockData.(priceColumn);
                                end
                            else
                                error('Invalid condition for Bollinger. Use "over", "under", or a numeric value.');
                            end
                        case 'RSI'
                            conditionResults(:, colIndex) = stockData.(colNameStr) >= conditionValue;
                        otherwise
                            error('Unknown strategy type.');
                    end
                    colIndex = colIndex + 1;
                else
                    error(['Column ', colNameStr, ' not found or does not match any strategy types.']);
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
            stockData.(outputColumnTitle) = finalDecision;
            stockData.(outputColumnTitle)(nanRows) = NaN;
        end
    end
end