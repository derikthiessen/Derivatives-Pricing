classdef Plotting
    % Class holding all the methods for plotting showing plots of certain strategies

    methods(Static)

        function plotTableLines(inputTable, xColumnName, lineColumnNames)
        
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
            
            % Add labels, title, and legend
            xlabel(xColumnName)
            ylabel('Values')
            title('Line Chart from Table')
            legend show % Display the legend
            grid on
        end
    end
end