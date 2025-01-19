classdef Plotting
    % Class holding all the methods for plotting 
    % Options include plotting: 
    %   a line chart of one or more strategies' outputs (plotStrategyPredictionLines),
    %   a bar chart of one or more strategies' prediction accuracy (plotPredictionAccuracyBars),
    %   a line chart of one or more strategies' cumulative value added compared to the price it is tracking (plotCumulativeValueAdded) 

    methods(Static)

        function plotStrategyPredictionLines(stockData, xColumnName, lineColumnNames, chartTitle)
        
            xData = stockData.(xColumnName);
            
            % Ensure lineColumnNames is a cell array of strings
            if ischar(lineColumnNames)
                lineColumnNames = {lineColumnNames};
            end
            
            hold on % required to be able to plot multiple lines on the same chart

            % Loop through the column names, and extract the y-axis data for each column
            for i = 1 : length(lineColumnNames)
               
                yData = stockData.(lineColumnNames{i});
                
                plot(xData, yData, 'DisplayName', lineColumnNames{i});
            end

            hold off
            
            xlabel(xColumnName)
            ylabel('Price')
            title(chartTitle)
            legend show 
            grid on

        end

        function plotPredictionAccuracyBars(stockData, strategyColumnNames, priceValidationColumnNames, chartTitle)
            
            % Ensure inputs are cell arrays
            if ischar(strategyColumnNames)
                strategyColumnNames = {strategyColumnNames};
            end
            if ischar(priceValidationColumnNames)
                priceValidationColumnNames = {priceValidationColumnNames};
            end
            
            % Initialize results array
            numStrategies = length(strategyColumnNames);
            numPriceValidations = length(priceValidationColumnNames);
            hitRates = zeros(numStrategies, numPriceValidations);
            barTitles = strings(numStrategies, numPriceValidations);
            
            % Loop over all combinations of strategy columns and price validation columns to calculate prediction accuracy
            for i = 1 : numStrategies
                for j = 1 : numPriceValidations
                    strategyColumn = stockData.(strategyColumnNames{i});
                    priceValidationColumn = stockData.(priceValidationColumnNames{j});
                    closePrice = stockData.Close;
                    
                    hits = ((strategyColumn == 1) & (priceValidationColumn > closePrice)) | ...
                           ((strategyColumn == 0) & (priceValidationColumn < closePrice));
                    
                    validIndices = ~isnan(strategyColumn) & ~isnan(priceValidationColumn) & ~isnan(closePrice);
                    totalValid = sum(validIndices);
                    totalHits = sum(hits(validIndices));
                    
                    hitRates(i, j) = totalHits / totalValid;
                    barTitles(i, j) = strategyColumnNames{i} + " & " + priceValidationColumnNames{j};
                end
            end
            
            hitRates = hitRates(:);
            barTitles = barTitles(:);
            
            bar(hitRates);
            title(chartTitle);
            ylabel('Accuracy');
            xticks(1 : length(barTitles));
            xticklabels(barTitles);
            xtickangle(45);
            ylim([0 1]);
            grid on;

        end

        function plotCumulativeValueAddedLines(stockData, xColumnName, strategyColumnNames, priceValidationColumnNames, chartTitle)
    
            % Ensure inputs are cell arrays
            if ischar(strategyColumnNames)
                strategyColumnNames = {strategyColumnNames};
            end
            
            if ischar(priceValidationColumnNames)
                priceValidationColumnNames = {priceValidationColumnNames};
            end
            
            % Initialize the cumulative value added matrix
            numStrategies = length(strategyColumnNames);
            numPriceValidations = length(priceValidationColumnNames);
            cumulativeValues = zeros(height(stockData), numStrategies * numPriceValidations);
            lineTitles = strings(numStrategies, numPriceValidations);
            
            % Loop through all combinations of strategy columns and price validation columns
            idx = 1;
            for i = 1 : numStrategies
                for j = 1 : numPriceValidations
                    strategyColumn = stockData.(strategyColumnNames{i});
                    priceValidationColumn = stockData.(priceValidationColumnNames{j});
                    closePrice = stockData.Close;
                    
                    % Compute cumulative value added based on buy/sell decisions
                    cumulativeValue = zeros(height(stockData), 1);
                    for k = 1:height(stockData)
                        if strategyColumn(k) == 1  % Buy
                            cumulativeValue(k) = priceValidationColumn(k) - closePrice(k); % Price validation is higher, adding value
                        elseif strategyColumn(k) == 0  % Sell
                            cumulativeValue(k) = closePrice(k) - priceValidationColumn(k); % Price validation is lower, subtracting value
                        end
                    end
                    
                    % Compute the cumulative sum
                    cumulativeValues(:, idx) = cumsum(cumulativeValue);
                    
                    lineTitles(idx) = strategyColumnNames{i} + " & " + priceValidationColumnNames{j};
                    idx = idx + 1;
                end
            end
            
            % Remove unused columns in case the matrix is larger than needed
            cumulativeValues = cumulativeValues(:, 1:idx-1);
            
            % Plot the cumulative value added lines
            figure;  % Open a new figure window
            
            hold on;
            
            % Loop over each column to plot the cumulative value added for each combination
            for i = 1 : size(cumulativeValues, 2)
                plot(stockData.(xColumnName), cumulativeValues(:, i), 'DisplayName', lineTitles(i));
            end
            
            hold off;
            
            xlabel(xColumnName);
            ylabel('Cumulative Value Added');
            title(chartTitle);
            legend show;
            grid on;
        end
        
    end
end