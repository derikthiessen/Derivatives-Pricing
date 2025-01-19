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

        function plotPredictionAccuracyChart(stockData, actionColumnName, priceValidationColumnName, chartTitle)
            
            closePrice = stockData.Close;
            
            actionColumn = stockData.(actionColumnName);
            priceValidationColumn = stockData.(priceValidationColumnName);
            
            hits = ((actionColumn == 1) & (priceValidationColumn > closePrice)) | ...
                   ((actionColumn == 0) & (priceValidationColumn < closePrice));
            
            validIndices = ~isnan(actionColumn) & ~isnan(priceValidationColumn) & ~isnan(closePrice);
            totalValid = sum(validIndices);
            totalHits = sum(hits(validIndices));
            
            hitRate = totalHits / totalValid;
            
            bar(hitRate);
            title(chartTitle);
            ylabel('Accuracy');
            xticks(1);
            xticklabels({actionColumnName});
            ylim([0 1]);
            grid on;

        end
    end
end