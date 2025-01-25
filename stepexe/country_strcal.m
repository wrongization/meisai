filename = 'country_str.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
A = readtable(filename, opts);

sport = A{:,1};
country = A{:,2};
total = A{:,3};
gold = A{:,4};

% Convert to table for easier manipulation
data = table(sport, country, total, gold);

% Find unique sports
unique_sports = unique(sport);

% Initialize a new column for normalized total
normalized_total = total;

% Loop through each sport and normalize the total values
for i = 1:length(unique_sports)
    sport_name = unique_sports{i};
    sport_idx = strcmp(sport, sport_name);
    
    sport_total = total(sport_idx);
    min_total = min(sport_total);
    max_total = max(sport_total);
    
    % Normalize the total values for the current sport
    if max_total == 0 && min_total == 0
        normalized_total(sport_idx) = 0;
    elseif max_total == min_total
        normalized_total(sport_idx) = 1;
    else
        normalized_total(sport_idx) = (sport_total - min_total) / (max_total - min_total);
    end
end

% Update the table with normalized total values
data.total = normalized_total;
% Write the updated table to a new CSV file
writetable(data, 'normalized_country_str.csv');

% Display the updated table
disp(data);
