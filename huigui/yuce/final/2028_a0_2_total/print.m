filename = '2028_sortedbytotal_3_final.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
A = readtable(filename, opts);

% Extract data from the table
countries = A{1:20, 1};
total_medals = A{1:20, 2};
gold_medals = A{1:20, 3};
total_medals_lower = A{1:20, 4};
total_medals_upper = A{1:20, 5};
gold_medals_lower = A{1:20, 6};
gold_medals_upper = A{1:20, 7};

% Create a new figure
figure;

% Plot total medals box plot
subplot(2, 1, 1);
boxplot([total_medals_lower, total_medals, total_medals_upper]', 'Labels', countries);
title('Total Medals');
ylabel('Number of Medals');
xtickangle(45);

% Plot gold medals box plot
subplot(2, 1, 2);
boxplot([gold_medals_lower, gold_medals, gold_medals_upper]', 'Labels', countries);
title('Gold Medals');
ylabel('Number of Medals');
xtickangle(45);

% Adjust layout
tight_layout();