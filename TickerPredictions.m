classdef TickerPredictions
    % Contains methods to perform a variety of different prediction
    % techniques on one set of time-series data.

    properties
        stockData table % holds all the data for a particular ticker
        priceValidationTable table % holds the price for each date offset by one day earlier for model comparison
        dataStartDate datetime % holds the start date for the input time series
        dataEndDate datetime % holds the end date for the input time series

        % NEED TO DEFINE THE OTHER ATTRIBUTES HERE, WHICH INCLUDE THE 
        % VARIOUS DESCRIPTIVE COLUMNS FOUND IN THE DATA DUMP
    end

    methods
        % Constructor
        function obj = TickerPredictions(inputData)
            validateattributes(inputData, {'table'}, {});
            obj.stockData = inputData;

            obj.stockData = obj.convertDateColumnToDatetime();
            obj.dataStartDate = obj.getDataStartDate();
            obj.dataEndDate = obj.getDataEndDate();
        end
        
        % Converts the date column from cells to a datetime
        function stockData = convertDateColumnToDatetime(obj)
            
            stockData = obj.stockData;

            % Converts the input column from a cell array to a string array
            if iscell(obj.stockData.Date)
                stockData.Date = string(obj.stockData.Date);
            end

            % Checks if the input column 'Date' is a datetime object--if it is not, convert it to one
            if ~isa(obj.stockData.Date, 'datetime')
                stockData.Date = datetime(...
                    stockData.Date, ...
                    'InputFormat', ...
                    'yyyy-MM-dd HH:mm:ssXXX', ...
                    'TimeZone', ...
                    'UTC');
                
                % Removes the timezone from the datetime
                stockData.Date.TimeZone = '';
            end
        end

        % Grabs the start date of the time series
        function startDate = getDataStartDate(obj)
            startDate = obj.stockData.Date(1);
        end

        % Grabs the end date of the time series
        function endDate = getDataEndDate(obj)
            endDate = obj.stockData.Date(end);
        end
    end
end