classdef TickerPredictions
    % Contains methods to perform a variety of different prediction
    % techniques on one set of time-series data.

    properties
        ticker string % holds the ticker symbol
        stockData table % holds all the data for a particular ticker
        numRows double % holds the number of rows where prices are given for the input dataset
        dataStartDate datetime % holds the start date for the input time series
        dataEndDate datetime % holds the end date for the input time series
        securityName string % holds the name of the security
        gicsSector string % holds the GICS sector
        gicsSubIndustry string % holds the GICS sub-industry
        dateAdded datetime % holds the date that the security was added to the S&P 500
        yearFounded double % holds the year that the security was founded
        priceValidationColumnNames cell % holds the newly created column names that shift the data backwards
    end

    methods
        % Constructor
        function self = TickerPredictions(ticker, inputData, numPeriodsShifts)
            validateattributes(ticker, {'string'}, {})
            self.ticker = ticker;

            validateattributes(inputData, {'table'}, {});
            self.stockData = inputData;

            self.stockData = TickerPredictions.convertDateColumnToDatetime(self.stockData);
            [updatedStockData, priceValidationColumnNames] = self.shiftClosePriceBack(numPeriodsShifts);
            self.stockData = updatedStockData;
            self.priceValidationColumnNames = priceValidationColumnNames;
            self.numRows = self.getNumRows();
            self.dataStartDate = self.getDataStartDate();
            self.dataEndDate = self.getDataEndDate();
            self.securityName = self.getSecurityName();
            self.gicsSector = self.getGicsSector();
            self.gicsSubIndustry = self.getGicsSubIndustry();
            self.dateAdded = self.getDateAdded();
            self.yearFounded = self.getYearFounded();
        end

        % Grabs the number of rows in the stockData
        function numRows = getNumRows(self)
            numRows = height(self.stockData);
        end

        % Grabs the start date of the time series
        function startDate = getDataStartDate(self)
            startDate = self.stockData.Date(1);
        end

        % Grabs the end date of the time series
        function endDate = getDataEndDate(self)
            endDate = self.stockData.Date(end);
        end

        % Grabs the security name
        function securityName = getSecurityName(self)
            securityName = self.stockData.Security(1);
        end

        % Grabs the GICS Sector
        function gicsSector = getGicsSector(self)
            gicsSector = self.stockData.GICSSector(1);
        end

        % Grabs the GICS Sub-Industry
        function gicsSubIndustry = getGicsSubIndustry(self)
            gicsSubIndustry = self.stockData.GICSSub_Industry(1);
        end

        % Grabs the date added
        function dateAdded = getDateAdded(self)
            dateAdded = self.stockData.DateAdded(1);
        end

        % Grabs the year founded
        function yearFounded = getYearFounded(self)
            yearFounded = self.stockData.Founded(1);
        end

        function [stockData, priceValidationColumnNames] = shiftClosePriceBack(self, numPeriodsShifts)
                
            % Throw an error if no arguments were given
            if nargin == 0
                error('Function requires a tabular input of stock price data.');
            
            % Use a default of only a one row shift if none is passed
            elseif nargin == 1
                numPeriodsShifts = [1];
            
            % If an array of shifts is passed by the user, validate that all shifts
            % are appropriate given the input data    
            else
                numPeriodsShifts = self.validateInputNumPeriodsShifts(numPeriodsShifts);
            end

            % Holds the stockData so it can be continually updated
            stockData = self.stockData;

            % Initializes a zeros array to hold the newly created column names
            priceValidationColumnNames = cell(1, numel(numPeriodsShifts));

            % Add each value in numPeriodsShifts as an offset column to the closing price column
            for i = 1:numel(numPeriodsShifts)
                value = numPeriodsShifts(i);
                [stockData, newColumnName] = TickerPredictions.addPriceValidationColumn(stockData, value);
                priceValidationColumnNames{i} = string(newColumnName);
            end
        end
        
        % Ensures that the input array for numPeriodsShifts is valid;
        % if it is valid, returns the array in ascending order
        function numPeriodsShifts = validateInputNumPeriodsShifts(self, numPeriodsShifts)
            
            % Throw an error if there are duplicate values in the array
            if numel(numPeriodsShifts) ~= numel(unique(numPeriodsShifts))
                error('MATLAB:InvalidValue', ...
                'Input array for numPeriodsShifts cannot have duplicate values.');
            end

            for value = numPeriodsShifts
                
                % Throw an error if the value is not numeric
                if ~isnumeric(value)
                    errorString = sprintf(...
                        'All inputs for numPeriodsShifts should be numeric. Received: %s', ...
                        mat2str(value));

                    error('MATLAB:InvalidType', errorString);
                
                % Throw an error if the value is not an integer
                elseif value ~= floor(value)
                    errorString = sprintf(...
                        'All inputs for numPeriodsShifts should be integers. Received: %s', ...
                        mat2str(value));

                    error('MATLAB:InvalidValue', errorString);

                % Throw an error if the value is not at least 1
                elseif value < 1
                    errorString = sprintf(...
                        'All inputs for numPeriodsShifts should be at least 1. Received: %s', ...
                        mat2str(value));

                    error('MATLAB:InvalidValue', errorString);
                
                % Throw an error if the value is greater than the number of rows in the dataset
                elseif value >= self.numRows
                    errorString = sprintf(...
                        'All inputs for numPeriodsShifts should be less than the number of rows. Num rows: %s. Input received: %s', ...
                        mat2str(self.numRows), mat2str(value));

                    error('MATLAB:InvalidValue', errorString);
                end
            
                % If all checks passed, return the array sorted in ascending order
                numPeriodsShifts = sort(numPeriodsShifts);

            end
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

        % Adds a column to stockData which contains the price of the next periodOffset unit of time
        function [stockData, columnName] = addPriceValidationColumn(stockData, periodOffset)
            columnName = sprintf('Offset_%d', periodOffset);
            closingPriceValues = stockData.Close;
            offsetData = [closingPriceValues((periodOffset + 1) : end); NaN(periodOffset, 1)];
            stockData.(columnName) = offsetData;
        end
    end
end