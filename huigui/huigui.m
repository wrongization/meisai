filename = 'countrycode_gold_total_2024';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
A = readtable(filename, opts);


filename = 'str_2024.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
C = readtable(filename, opts);


filename = 'str_2028.csv';%out
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
D = readtable(filename, opts);

country = A{:, 1};
gold = A{:, 2};
total = A{:, 3};
sports = B{:, 1};
str = C{:, :};

strout = D{:, :};

% Perform multiple linear regression with gold as the dependent variable
mdl_gold = fitlm(str, gold);
disp('Linear regression model for gold:');
disp(mdl_gold);

% Extract and display coefficients as column vector for gold model
coefficients_gold = mdl_gold.Coefficients.Estimate;
disp('Coefficients for gold model as column vector:');
disp(coefficients_gold);

% Perform multiple linear regression with total as the dependent variable
mdl_total = fitlm(str, total);
disp('Linear regression model for total:');
disp(mdl_total);

% Extract and display coefficients as column vector for total model
coefficients_total = mdl_total.Coefficients.Estimate;
disp('Coefficients for total model as column vector:');
disp(coefficients_total);

% Multiply the coefficients by each row of str and output the result as a column vector
result_total = strout * coefficients_total(2:end) + coefficients_total(1);
result_total = round(result_total, 0);
disp('Resulting column vector after multiplying with strout:');
disp(result_total);

result_gold = strout * coefficients_gold(2:end) + coefficients_gold(1);
result_gold = round(result_gold, 0);
disp('Resulting column vector after multiplying with strout:');
disp(result_gold);

% Combine country and result_total into a table
output_table = table(country, result_total,result_gold, 'VariableNames', {'Country', 'ResultTotal','ResultGold'});

% Sort the table by the second column (ResultTotal) in descending order
output_table = sortrows(output_table, {'ResultTotal', 'ResultGold'}, {'descend', 'descend'});

% Write the sorted table to a CSV file
output_filename_combined = 'yuce2028new_total.csv';
writetable(output_table, output_filename_combined);
disp(['Country and result_total have been written to ', output_filename_combined, ' in descending order of ResultTotal.']);




