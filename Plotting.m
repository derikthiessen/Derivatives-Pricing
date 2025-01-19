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

        function plotHitRateBarChart(stockData, buyColumnName, priceValidationColumnName, chartTitle)
            
            closePrice = stockData.Close;
            
            buyColumn = stockData.(buyColumnName);
            priceValidationColumn = stockData.(priceValidationColumnName);
            
            hits = (buyColumn == 1) & (priceValidationColumn > closePrice);
            totalValidBuys = sum(~isnan(buyColumn));
            
            hitRate = sum(hits) / totalValidBuys;

            figure;
            bar(hitRate);
            title(chartTitle);
            ylabel('Hit Rate');
            xticklabels({buyColumnName});
            ylim([0 1]);
            grid on;

        end
    end
end