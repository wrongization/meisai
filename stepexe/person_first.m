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
current_year = 2016;
% Create folder if it doesn't exist
output_folder = sprintf('person/%d',current_year);
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Filter athletes who participated only in 2020 or 2024 and not in other years
years_of_interest = [current_year-8, current_year-4];
athletes_before2 = ismember(years, years_of_interest) & ~ismember(years, setdiff(unique(years), years_of_interest));
% Output names of athletes who participated only in 2020 or 2024
athletes_names_before2 = names(athletes_before2);
disp('Athletes who participated only in 2020 or 2024:');
disp(athletes_names_before2);
% Get unique athletes who participated only in 2020 or 2024
unique_athletes = unique(names(athletes_before2));

% Initialize a table to store the count of athletes per country and sport
country_sport_count = table();

% Loop through each unique sport

for i = 1:length(unique_sports)
    
     sport = unique_sports{i};
     fileID = fopen(fullfile(output_folder, [sport  '.txt']), 'w');
     % Filter athletes for the current sport
     sport_filter = strcmp(sports, sport) & athletes_before2;
     
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
          only_before2_filter = country_filter & ismember(years, [current_year-8, current_year-4]);
          unique_athletes_before2 = unique(names(only_before2_filter));
          
          % Count the number of unique athletes who participated only in 2020 and 2024
          only_before2_count = length(unique_athletes_before2);
          
          % Calculate the ratio
          ratio = only_before2_count / athlete_count;
          
          % Append the result to the table


        fprintf(fileID, 'Country: %s  Ratio:%f/Hundred  Count:%d\n',country, 100*ratio, only_before2_count);
        ratiomul=ratio*100;
        country_sport_count = [country_sport_count; {sport,country, ratiomul, only_before2_count}];
     end
     fclose(fileID);
end

% Set table column names
country_sport_count.Properties.VariableNames = {'Sport','Country', 'Ratio',  'Onlybefore2Count'};

% Save the result to a CSV file
output_filename = fullfile('', 'person_str1.csv');
writetable(country_sport_count, output_filename);




