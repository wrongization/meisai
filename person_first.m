filename = 'athfix.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
A = readtable(filename, opts);

% Extract data
names = A{:, 1};
years = A{:, 5};
teams = A{:, 3};
countries = A{:, 4};
medal_if = A{:, end};
sports = A{:, 7};
events = A{:, 8};
% Unique sports
unique_sports = unique(sports);
current_year = 2020;
% Create folder if it doesn't exist
output_folder = sprintf('person/%d',current_year);
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Filter athletes who participated only in 2020 or 2024
years_of_interest = [current_year-8, current_year-4];
athletes_2020_2024 = ismember(years, years_of_interest);

% Get unique athletes who participated in 2020 or 2024
unique_athletes = unique(names(athletes_2020_2024));

% Initialize a table to store the count of athletes per country and sport
country_sport_count = table();

% Loop through each unique sport

for i = 1:length(unique_sports)
    
     sport = unique_sports{i};
     fileID = fopen(fullfile(output_folder, [sport  '.txt']), 'w');
     % Filter athletes for the current sport
     sport_filter = strcmp(sports, sport) & athletes_2020_2024;
     
     % Get unique countries for the current sport
     unique_countries = unique(countries(sport_filter));
     
     % Loop through each unique country
     for j = 1:length(unique_countries)
          country = unique_countries{j};
          
          % Filter athletes for the current country and sport
          country_filter = strcmp(countries, country) & sport_filter;
          
          % Count the number of unique athletes for the current country and sport
          athlete_count = length(unique(names(sport_filter)));
          
          % Filter athletes who participated only in 2020 and 2024
          only_2020_2024_filter = country_filter & ismember(years, [2020, 2024]);
          unique_athletes_2020_2024 = unique(names(only_2020_2024_filter));
          
          % Count the number of unique athletes who participated only in 2020 and 2024
          only_2020_2024_count = length(unique_athletes_2020_2024);
          
          % Calculate the ratio
          ratio = only_2020_2024_count / athlete_count;
          
          % Append the result to the table


        fprintf(fileID, 'Country: %s  Ratio:%f/Hundred  Count:%d\n',country, 100*ratio, only_2020_2024_count);
        ratiomul=ratio*100;
        country_sport_count = [country_sport_count; {sport,country, ratiomul, only_2020_2024_count}];
     end
     fclose(fileID);
end

% Set table column names
country_sport_count.Properties.VariableNames = {'Sport','Country', 'Ratio',  'Only2020_2024Count'};

% Save the result to a CSV file
output_filename = fullfile(output_folder, 'person_str.csv');
writetable(country_sport_count, output_filename);

