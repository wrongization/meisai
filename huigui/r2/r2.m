
predit_year = 2024;
c1=0;
c2=0;
c3=0;
c_step=0.05;
maxchange_years=32;

changeyear=maxchange_years;
filename1= sprintf('normalized_country_str_%d.csv', predit_year);
opts1 = detectImportOptions(filename1);
opts1.VariableNamesLine = 1;
T = readtable(filename1, opts1);

filename2 = sprintf('normalized_person_str_%d.csv', predit_year);
opts2 = detectImportOptions(filename2);
opts2.VariableNamesLine = 1;
B = readtable(filename2, opts2);

filename = 'host.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
C = readtable(filename, opts);


filename = sprintf('countrycode_gold_total_%d.csv', predit_year);
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
A = readtable(filename, opts);
% Merge the tables based on the first two columns (sport and country)
mergedTable = outerjoin(T, B, 'Keys', {'sport', 'country'}, 'MergeKeys', true);
sport=mergedTable{:, 1};
country=mergedTable{:, 2};
country_str=mergedTable{:, 3};
person_str=mergedTable{:, 5};
country_str = fillmissing(country_str, 'constant', 0);
person_str = fillmissing(person_str, 'constant', 0);


for k = 0:c_step:1
    c12 = 1 - k;
    c3 = k;
    for j = 0:c_step:c12
        c1 = c12 - j;
        c2 = j;


        for for_year = predit_year-changeyear:4:predit_year

        host_city = C{C{:, 1} == for_year, 2};
        MAIN = host_city{1};


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
        outname=sprintf('str_r2_%d.csv', for_year);
        writematrix(l, outname);

        end

        for delta = 4:4:changeyear
            min_year = predit_year - delta;
            filename = sprintf('str_r2_%d.csv', predit_year);
            opts = detectImportOptions(filename);
            opts.VariableNamesLine = 0;
            D = readtable(filename, opts);


            years = min_year:4:predit_year-4;
            str_data = [];
            medal_data = [];
            for year = years
                filename = sprintf('str_r2_%d.csv', year);
                opts = detectImportOptions(filename);
                opts.VariableNamesLine = 0;
                temp_table = readtable(filename, opts);
                str_data = [str_data; temp_table];
                
                filename = sprintf('countrycode_gold_total_%d.csv', year);
                opts = detectImportOptions(filename);
                opts.VariableNamesLine = 1;
                temp_table2 = readtable(filename, opts);
                medal_data = [medal_data; temp_table2];
            end



            % Assign the combined data to str
            gold = medal_data{:, 2};
            total = medal_data{:, 3};
            str = str_data{:, :};


            mdl_gold = fitlm(str, gold);

            coefficients_gold = mdl_gold.Coefficients.Estimate;
            
            Rsquared_gold=mdl_gold.Rsquared.Ordinary;
 
            R2_gold = mdl_gold.Rsquared.Ordinary;

            CI_gold = coefCI(mdl_gold);

            mdl_total = fitlm(str, total);

            Rsquared_total=mdl_total.Rsquared.Ordinary;

            coefficients_total = mdl_total.Coefficients.Estimate;

            R2_total = mdl_total.Rsquared.Ordinary;

            CI_total = coefCI(mdl_total);

            results_total = table(delta,c1, c2, c3, R2_total , Rsquared_total ,...
                coefficients_total', ...
                CI_total(:)', ...
                'VariableNames', {'deltayears','c1', 'c2', 'c3', 'R2_total','Rsquared_total', ...
                'coefficients_total', ...
                'CI_total'});
            results_gold = table(delta,c1, c2, c3, R2_gold , Rsquared_gold ,...
                coefficients_gold', ...
                CI_gold(:)', ...
                'VariableNames', {'deltayears','c1', 'c2', 'c3', 'R2_gold','Rsquared_gold'...
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
end
if exist('r2_total.csv', 'file')
            total_data = readtable('r2_total.csv');
            total_data = sortrows(total_data, 'Rsquared_total', 'descend');
            writetable(total_data, 'r2_total.csv');
end
if exist('r2_gold.csv', 'file')
    gold_data = readtable('r2_gold.csv');
    gold_data = sortrows(gold_data, 'Rsquared_gold', 'descend');
    writetable(gold_data, 'r2_gold.csv');
end




