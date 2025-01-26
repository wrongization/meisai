% Define the number of top countries to select
numTopCountries = 40;

filename = '2028_sortedbytotal_3_final.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
A = readtable(filename, opts);

filename = '2028_sortedbygold_2_final.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
B = readtable(filename, opts);

[~, idxA, idxB] = intersect(A{:, 1}, B{:, 1});

% Extract data for matching countries
countries = A{idxA, 1};
total_medals = A{idxA, 2};
total_medals_lower = A{idxA, 4};
total_medals_upper = A{idxA, 5};
gold_medals = B{idxB, 3};
gold_medals_lower = B{idxB, 6};
gold_medals_upper = B{idxB, 7};

% Calculate half-width of confidence intervals
total_medals_halfwidth = (total_medals_upper - total_medals_lower) / 2;
gold_medals_halfwidth = (gold_medals_upper - gold_medals_lower) / 2;

% Sort by total medals and select top countries
[~, sortIdxTotal] = sort(total_medals, 'descend');
topIdxTotal = sortIdxTotal(1:numTopCountries);

% Sort by gold medals and select top countries
[~, sortIdxGold] = sort(gold_medals, 'descend');
topIdxGold = sortIdxGold(1:numTopCountries);

% Create a new figure
figure;

% Plot total medals box plot for top countries
subplot(2, 1, 1);
boxplot([total_medals_lower(topIdxTotal), total_medals(topIdxTotal), total_medals_upper(topIdxTotal)]', 'Labels', countries(topIdxTotal));
title('Total Medals');
ylabel('Number of Medals');
xtickangle(45);

% Add y-axis values on top of the bars for total medals
for i = 1:length(topIdxTotal)
    text(i, total_medals(topIdxTotal(i)) + 0.5, num2str(total_medals(topIdxTotal(i))), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 8, 'Color', 'blue');
end

% Plot gold medals box plot for top countries
subplot(2, 1, 2);
boxplot([gold_medals_lower(topIdxGold), gold_medals(topIdxGold), gold_medals_upper(topIdxGold)]', 'Labels', countries(topIdxGold));
title('Gold Medals');
ylabel('Number of Medals');
xtickangle(45);

% Add y-axis values on top of the bars for gold medals
for i = 1:length(topIdxGold)
    text(i, gold_medals(topIdxGold(i)) + 0.5, num2str(gold_medals(topIdxGold(i))), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 8, 'Color', 'blue');
end

% Create tables for the final output
finalTableTotal = table(countries(topIdxTotal), total_medals(topIdxTotal), total_medals_halfwidth(topIdxTotal), ...
    'VariableNames', {'Country', 'TotalMedals', 'TotalMedalsHalfWidth'});

finalTableGold = table(countries(topIdxGold), gold_medals(topIdxGold), gold_medals_halfwidth(topIdxGold), ...
    'VariableNames', {'Country', 'GoldMedals', 'GoldMedalsHalfWidth'});

% Display the tables
disp(['Top ', num2str(numTopCountries), ' by Total Medals:']);
disp(finalTableTotal);

disp(['Top ', num2str(numTopCountries), ' by Gold Medals:']);
disp(finalTableGold);

% Write the tables to CSV files
writetable(finalTableTotal, ['Top', num2str(numTopCountries), '_TotalMedals.csv']);
writetable(finalTableGold, ['Top', num2str(numTopCountries), '_GoldMedals.csv']);
