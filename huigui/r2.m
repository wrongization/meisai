filename1 = 'normalized_country_str';
opts1 = detectImportOptions(filename1);
opts1.VariableNamesLine = 1;
T = readtable(filename1, opts1);

filename2 = 'normalized_person_str';
opts2 = detectImportOptions(filename2);
opts2.VariableNamesLine = 1;
B = readtable(filename2, opts2);


filename = 'countrycode_gold_total_2024';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
A = readtable(filename, opts);
% Merge the tables based on the first two columns (sport and country)
mergedTable = outerjoin(T, B, 'Keys', {'sport', 'country'}, 'MergeKeys', true);
MAIN='FRA';
sport=mergedTable{:, 1};
country=mergedTable{:, 2};
country_str=mergedTable{:, 3};
person_str=mergedTable{:, 5};
country_str = fillmissing(country_str, 'constant', 0);
person_str = fillmissing(person_str, 'constant', 0);

c1=0;
c2=0;
c3=0;


for k = 0:0.05:1
    c12 = 1 - k;
    c3 = k;
    for j = 0:0.05:c12
        c1 = c12 - j;
        c2 = j;
        final = country_str * c1 + person_str * c2;
        final(strcmp(country, MAIN)) = final(strcmp(country, MAIN)) + c3;
        Table = table(sport, country, country_str, person_str, final);

        Table = sortrows(Table, {'sport', 'final'}, {'ascend', 'descend'});

        table1 = Table;
        uniqueValues1 = unique(table1{:, 1});
        uniqueValues2 = unique(table1{:, 2});
        n1 = length(uniqueValues1);
        n2 = length(uniqueValues2);
        l = zeros(n2, n1);

        [~, idx1] = ismember(table1{:, 1}, uniqueValues1);
        [~, idx2] = ismember(table1{:, 2}, uniqueValues2);

        for i = 1:height(table1)
            l(idx2(i), idx1(i)) = table1{i, 5};
        end
        writematrix(l, 'str.csv');
        filename2 = 'str.csv';
        opts2 = detectImportOptions(filename2);
        opts2.VariableNamesLine = 1;
        f = readtable(filename2, opts2);
        % Read the data from the CSV file
        gold = A{:, 2};
        total = A{:, 3};
        str = f{:, :};
        % Perform multiple linear regression with gold as the dependent variable
        mdl_gold = fitlm(str, gold);
        %disp('Linear regression model for gold:');
        %disp(mdl_gold);

        % Extract and display coefficients as column vector for gold model
        coefficients_gold = mdl_gold.Coefficients.Estimate;
        %disp('Coefficients for gold model as column vector:');
        %disp(coefficients_gold);

        % Display R-squared value for gold model
        R2_gold = mdl_gold.Rsquared.Ordinary;
        %disp('R-squared for gold model:');
        %disp(R2_gold);

        % Display confidence intervals for gold model
        CI_gold = coefCI(mdl_gold);
        %disp('Confidence intervals for gold model:');
        %disp(CI_gold);

        % Perform multiple linear regression with total as the dependent variable
        mdl_total = fitlm(str, total);
        %disp('Linear regression model for total:');
        %disp(mdl_total);

        % Extract and display coefficients as column vector for total model
        coefficients_total = mdl_total.Coefficients.Estimate;
        %disp('Coefficients for total model as column vector:');
        %disp(coefficients_total);

        % Display R-squared value for total model
        R2_total = mdl_total.Rsquared.Ordinary;
        %disp('R-squared for total model:');
        %disp(R2_total);

        % Display confidence intervals for total model
        CI_total = coefCI(mdl_total);
        %disp('Confidence intervals for total model:');
        %disp(CI_total);
        % Save the results to CSV files
        results_total = table(c1, c2, c3, R2_total, ...
            coefficients_total', ...
            CI_total(:)', ...
            'VariableNames', {'c1', 'c2', 'c3', 'R2_total', ...
            'coefficients_total', ...
            'CI_total'});
        results_gold = table(c1, c2, c3, R2_gold, ...
            coefficients_gold', ...
            CI_gold(:)', ...
            'VariableNames', {'c1', 'c2', 'c3', 'R2_gold', ...
            'coefficients_gold', ...
            'CI_gold'});
        if exist('r2_total.csv', 'file')
            writetable(results_total, 'r2_total.csv', 'WriteMode', 'append');
        else
            writetable(results_total, 'r2_total.csv');
        end
        if exist('r2_gold.csv', 'file')
            writetable(results_gold, 'r2_gold.csv', 'WriteMode', 'append');
        else
            writetable(results_gold, 'r2_gold.csv');
        end

        % Sort the results by R2_total and R2_gold in descending order
        
        

    end
end
if exist('r2_total.csv', 'file')
            total_data = readtable('r2_total.csv');
            total_data = sortrows(total_data, 'R2_total', 'descend');
            writetable(total_data, 'r2_total.csv');
end
if exist('r2_gold.csv', 'file')
    gold_data = readtable('r2_gold.csv');
    gold_data = sortrows(gold_data, 'R2_gold', 'descend');
    writetable(gold_data, 'r2_gold.csv');
end




