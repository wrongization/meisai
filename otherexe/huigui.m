predit_year = 2024;
min_year = 2016;
diff_judge = 3;
%1gold 2total 3avg_range_gold 4avg_range_total
diff_gold =0;
diff_medal = 5;
maxrange=234;
alpha=0.2;

filename = sprintf('str_%d.csv', predit_year);
opts = detectImportOptions(filename);
opts.VariableNamesLine = 0;
D = readtable(filename, opts);

filename = 'sports.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
S = readtable(filename, opts);

filename = 'countrycode.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
T = readtable(filename, opts);

years = min_year:4:predit_year-4;
str_data = [];
medal_data = [];
for year = years
    filename = sprintf('str_%d.csv', year);
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

country = T{:, 1};
gold = medal_data{:, 2};
total = medal_data{:, 3};
sports = S{:, 1};
str = str_data{:, :};
strout = D{:, :};

grouped_medal_data = varfun(@sum, medal_data, 'InputVariables', {'Gold', 'Total'}, 'GroupingVariables', 'CountryCode');

sorted_grouped_medal_data_total = sortrows(grouped_medal_data, 'sum_Total', 'descend');
sorted_grouped_medal_data_gold = sortrows(grouped_medal_data, 'sum_Gold', 'descend');
top_countries_total = sorted_grouped_medal_data_total.CountryCode(1:maxrange);
top_countries_gold = sorted_grouped_medal_data_gold.CountryCode(1:maxrange);
top_indices_total = find(ismember(medal_data.CountryCode, top_countries_total));
less_top_indices_total = find(~ismember(medal_data.CountryCode, top_countries_total));
top_indices_gold = find(ismember(medal_data.CountryCode, top_countries_gold));
less_top_indices_gold = find(~ismember(medal_data.CountryCode, top_countries_gold));

disp('Top countries based on total medals:');
disp(top_countries_total);

disp('Top countries based on gold medals:');
disp(top_countries_gold);

top_countries_total_table = table((1:maxrange)', top_countries_total, 'VariableNames', {'Rank', 'CountryCode'});
top_countries_gold_table = table((1:maxrange)', top_countries_gold, 'VariableNames', {'Rank', 'CountryCode'});

if(diff_judge == 1)
    idx_gt = gold > diff_gold;
    idx_le = gold <= diff_gold;
elseif(diff_judge == 2)
    idx_gt = total > diff_medal;
    idx_le = total <= diff_medal;
elseif(diff_judge == 3)
    idx_gt = top_indices_gold;
    idx_le = less_top_indices_gold;
elseif(diff_judge == 4)
    idx_gt = gold > top_indices_total;
    idx_le = gold <= less_top_indices_total;
end

fix_idx_gt=mod(find(idx_gt) - 1, 234) + 1;
fix_idx_le=mod(find(idx_le) - 1, 234) + 1;

str_part1 = str(idx_gt, :);
gold_part1 = gold(idx_gt);
total_part1 = total(idx_gt);

str_part2 = str(idx_le, :);
gold_part2 = gold(idx_le);
total_part2 = total(idx_le);

output_table_part1 = table(country(fix_idx_gt), gold_part1, total_part1, 'VariableNames', {'Country', 'Gold', 'Total'});
output_table_part2 = table(country(fix_idx_le), gold_part2, total_part2, 'VariableNames', {'Country', 'Gold', 'Total'});

disp('Part 1: Countries with gold medals > 5');
disp(output_table_part1);

disp('Part 2: Countries with gold medals <= 5');
disp(output_table_part2);

% Perform multiple linear regression for part 1 using regress
[b_gold_part1, ~, ~, ~, stats_gold_part1] = regress(gold_part1, [ones(size(str_part1, 1), 1) str_part1]);
[b_total_part1, ~, ~, ~, stats_total_part1] = regress(total_part1, [ones(size(str_part1, 1), 1) str_part1]);

% Perform multiple linear regression for part 2 using regress
[b_gold_part2, ~, ~, ~, stats_gold_part2] = regress(gold_part2, [ones(size(str_part2, 1), 1) str_part2]);
[b_total_part2, ~, ~, ~, stats_total_part2] = regress(total_part2, [ones(size(str_part2, 1), 1) str_part2]);

valid_idx_gt = all(~isnan(strout(fix_idx_gt,:)), 2);
[pred_gold_part1, CI_gold_part1] = predict_regress(b_gold_part1, strout(fix_idx_gt(valid_idx_gt),:), alpha);
[pred_total_part1, CI_total_part1] = predict_regress(b_total_part1, strout(fix_idx_gt(valid_idx_gt),:), alpha);

valid_idx_le = all(~isnan(strout(fix_idx_le,:)), 2);
[pred_gold_part2, CI_gold_part2] = predict_regress(b_gold_part2, strout(fix_idx_le(valid_idx_le),:), alpha);
[pred_total_part2, CI_total_part2] = predict_regress(b_total_part2, strout(fix_idx_le(valid_idx_le),:), alpha);

combined_pred_gold = zeros(size(country));
combined_pred_total = zeros(size(country));
combined_CI_gold = zeros(size(country, 1), 2);
combined_CI_total = zeros(size(country, 1), 2);

combined_pred_gold(fix_idx_gt) = pred_gold_part1;
combined_pred_gold(fix_idx_le) = pred_gold_part2;

combined_pred_total(fix_idx_gt) = pred_total_part1;
combined_pred_total(fix_idx_le) = pred_total_part2;

combined_CI_gold(fix_idx_gt, :) = CI_gold_part1;
combined_CI_gold(fix_idx_le, :) = CI_gold_part2;

combined_CI_total(fix_idx_gt, :) = CI_total_part1;
combined_CI_total(fix_idx_le, :) = CI_total_part2;

pred_gold = round(combined_pred_gold);
pred_total = round(combined_pred_total);

CI_gold = combined_CI_gold;
CI_total = combined_CI_total;

total_lower = round(CI_total(:, 1), 0);
total_upper = round(CI_total(:, 2), 0);

gold_lower = round(CI_gold(:, 1), 0);
gold_upper = round(CI_gold(:, 2), 0);

output_table = table(country, pred_total, pred_gold, total_lower, total_upper, gold_lower, gold_upper, 'VariableNames', {'Country','total', 'gold', 'TlLower', 'TlUpper', 'GLower', 'GUpper'});

output_table = sortrows(output_table, {'total', 'gold'}, {'descend', 'descend'});
outname = sprintf('%d_sortedbytotal_%d.csv', predit_year,(predit_year-min_year)/4);
writetable(output_table, outname);

output_table = sortrows(output_table, {'gold','total', }, {'descend', 'descend'});
outname1 = sprintf('%d_sortedbygold_%d.csv', predit_year,(predit_year-min_year)/4);
writetable(output_table, outname1);

function [pred, CI] = predict_regress(b, X, alpha)
    X = [ones(size(X, 1), 1) X];
    pred = X * b;
    se = sqrt(sum((X * b - pred).^2) / (size(X, 1) - size(X, 2)));
    t_val = tinv(1 - alpha / 2, size(X, 1) - size(X, 2));
    CI = [pred - t_val * se, pred + t_val * se];
end
