classdef TickerPredictions
    % Contains methods to perform a variety of different prediction
    % techniques on one set of time-series data.

    properties
        ticker string % holds the ticker symbol
        stockData table % holds all the data for a particular ticker
        priceValidationTable table % holds the price for each date offset by one day earlier for model comparison
        dataStartDate datetime % holds the start date for the input time series
        dataEndDate datetime % holds the end date for the input time series
        securityName string % holds the name of the security
        gicsSector string % holds the GICS sector
        gicsSubIndustry string % holds the GICS sub-industry
        dateAdded datetime % holds the date that the security was added to the S&P 500
        yearFounded double % holds the year that the security was founded

        % NEED TO DEFINE THE OTHER ATTRIBUTES HERE, WHICH INCLUDE THE 
        % VARIOUS DESCRIPTIVE COLUMNS FOUND IN THE DATA DUMP
    end

    methods
        % Constructor
        function obj = TickerPredictions(ticker, inputData)
            validateattributes(ticker, {'string'}, {})
            obj.ticker = ticker;

            validateattributes(inputData, {'table'}, {});
            obj.stockData = inputData;

            obj.stockData = TickerPredictions.convertDateColumnToDatetime(obj.stockData);
            obj.dataStartDate = obj.getDataStartDate();
            obj.dataEndDate = obj.getDataEndDate();
            obj.securityName = obj.getSecurityName();
            obj.gicsSector = obj.getGicsSector();
            obj.gicsSubIndustry = obj.getGicsSubIndustry();
            obj.dateAdded = obj.getDateAdded();
            obj.yearFounded = obj.getYearFounded();
        end

        % Grabs the start date of the time series
        function startDate = getDataStartDate(obj)
            startDate = obj.stockData.Date(1);
        end

        % Grabs the end date of the time series
        function endDate = getDataEndDate(obj)
            endDate = obj.stockData.Date(end);
        end

        % Grabs the security name
        function securityName = getSecurityName(obj)
            securityName = obj.stockData.Security(1);
        end

        % Grabs the GICS Sector
        function gicsSector = getGicsSector(obj)
            gicsSector = obj.stockData.GICSSector(1);
        end

        % Grabs the GICS Sub-Industry
        function gicsSubIndustry = getGicsSubIndustry(obj)
            gicsSubIndustry = obj.stockData.GICSSub_Industry(1);
        end

        % Grabs the date added
        function dateAdded = getDateAdded(obj)
            dateAdded = obj.stockData.DateAdded(1);
        end

        % Grabs the year founded
        function yearFounded = getYearFounded(obj)
            yearFounded = obj.stockData.Founded(1);
        end
    end

    methods(Static)

        % Converts the date column from cells to a datetime
        function stockData = convertDateColumnToDatetime(stockData)

            % Converts the input column from a cell array to a string array
            if iscell(stockData.Date)
                stockData.Date = string(stockData.Date);
            end

            % Checks if the input column 'Date' is a datetime object--if it is not, convert it to one
            if ~isa(stockData.Date, 'datetime')
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
    end
end