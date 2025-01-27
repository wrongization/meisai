filename = 'countrycode_gold_total_2020';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
A = readtable(filename, opts);

filename = 'str_2020.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 0;
C = readtable(filename, opts);

filename = 'str_2024.csv'; % out
opts = detectImportOptions(filename);
opts.VariableNamesLine = 0;
D = readtable(filename, opts);

country = A{:, 1};
gold = A{:, 2};
total = A{:, 3};
str = C{:, :};
strout = D{:, :};

% Add a column of ones to str for the intercept term
str = [ones(size(str, 1), 1) str];
strout = [ones(size(strout, 1), 1) strout];

% Perform multiple linear regression with gold as the dependent variable
coefficients_gold = regress(gold, str);
disp('Coefficients for gold model as column vector:');
disp(coefficients_gold);

% Perform multiple linear regression with total as the dependent variable
coefficients_total = regress(total, str);
disp('Coefficients for total model as column vector:');
disp(coefficients_total);

result_total = strout * coefficients_total;
result_total = round(result_total, 0);
disp('Resulting column vector for total after multiplying with strout:');
disp(result_total);

result_gold = strout * coefficients_gold;
result_gold = round(result_gold, 0);
disp('Resulting column vector for gold after multiplying with strout:');
disp(result_gold);

% Create table with country, result_total, and result_gold
result_table = table(country, result_total, result_gold, ...
    'VariableNames', {'Country', 'Total', 'Gold'});

% Display the table
disp(result_table);

% Save the table to a CSV file
writetable(result_table, 'result_table.csv');
