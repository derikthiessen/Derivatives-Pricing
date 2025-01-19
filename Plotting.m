classdef Plotting
    % Class holding all the methods for plotting showing plots of certain strategies

    methods(Static)

        function plotTableLines(inputTable, xColumnName, lineColumnNames, chartTitle)
        
            xData = inputTable.(xColumnName);
            
            % Ensure lineColumnNames is a cell array of strings
            if ischar(lineColumnNames)
                lineColumnNames = {lineColumnNames};
            end
            
            hold on % required to be able to plot multiple lines on the same chart

            % Loop through the column names, and extract the y-axis data for each column
            for i = 1 : length(lineColumnNames)
               
                yData = inputTable.(lineColumnNames{i});
                
                plot(xData, yData, 'DisplayName', lineColumnNames{i});
            end

            hold off
            
            xlabel(xColumnName)
            ylabel('Price')
            title(chartTitle)
            legend show 
            grid on
            
        end

        function plotPredictionAccuracyChart(stockData, strategyColumnNames, priceValidationColumnNames, chartTitle)
            
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
                for j = 1:numPriceValidations
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
            
            % Reshape and plot bar chart
            hitRates = hitRates(:);
            barTitles = barTitles(:);
            
            bar(hitRates);
            title(chartTitle);
            ylabel('Accuracy');
            xticks(1:length(barTitles));
            xticklabels(barTitles);
            xtickangle(45);
            ylim([0 1]);
            grid on;

        end
    end
end