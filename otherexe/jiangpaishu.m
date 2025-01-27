current_year = 2016;

filename = 'summerOly_medal_counts';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
A = readtable(filename, opts);

% Filter rows where the year is equal to current_year
year_column = A{:, end};
A = A(year_column == current_year, :);

filename = 'athfix.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
C = readtable(filename, opts);

% Extract data
country = A{:, 2};
total = A{:, end-1};
gold = A{:, end-4};

countryfull = unique(C{:, 3});
countrycode = unique(C{:, 4});

% Create a table with countrycode, gold, and total
countrycode_gold_total = table();

for i = 1:length(countrycode)
    idx = strcmp(C{:, 4}, countrycode{i});
    if any(idx)
        country_name = C{idx, 3}{1};
        gold_medals = gold(strcmp(country, country_name));
        total_medals = total(strcmp(country, country_name));
        if isempty(gold_medals)
            gold_medals = 0;
        end
        if isempty(total_medals)
            total_medals = 0;
        end
        countrycode_gold_total = [countrycode_gold_total; {countrycode{i}, gold_medals, total_medals}];
    end
end

countrycode_gold_total.Properties.VariableNames = {'CountryCode', 'Gold', 'Total'};
outname = sprintf("countrycode_gold_total_%d.csv", current_year);
% Save the table to a CSV file
writetable(countrycode_gold_total, outname);
