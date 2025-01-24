filename = 'person_str.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
A = readtable(filename, opts);

sport = A{:,1};
country = A{:,2};
str = A{:,3};
count = A{:,4};

% Convert to table for easier manipulation
data = table(sport, country, str, count);

% Find unique sports
unique_sports = unique(sport);

% Initialize a new column for normalized str
normalized_str = str;

% Loop through each sport and normalize the str values
for i = 1:length(unique_sports)
    sport_name = unique_sports{i};
    sport_idx = strcmp(sport, sport_name);
    
    sport_str = str(sport_idx);
    min_str = min(sport_str);
    max_str = max(sport_str);
    
    % Normalize the str values for the current sport
    normalized_str(sport_idx) = (sport_str - min_str) / (max_str - min_str);
end

% Update the table with normalized str values
data.str = normalized_str;

% Sort the table by sport and then by normalized_str in descending order
data = sortrows(data, {'sport', 'str'}, {'ascend', 'descend'});

% Write the updated table to a new CSV file
writetable(data, 'normalized_person_str.csv');

% Display the updated table
disp(data);
