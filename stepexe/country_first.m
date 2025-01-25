filename = 'athfix.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
A = readtable(filename, opts);
a1=0.5;
a2=0.3;
a3=0.2;
% View data
for k = 1:width(A)
   %disp(A.Properties.VariableNames{k})
   %disp(A{:, k})
   %disp(' ')
end
country_STR = table();
% Extract data
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
output_folder = sprintf('country/%d', current_year);
if ~exist(output_folder, 'dir')
   mkdir(output_folder);
end
% Loop through each sport
unique_years = unique(years);
for i = 1:length(unique_sports)
   avgratiosum_gold=0.0;
   avgratiosum_total=0.0;
   sport = unique_sports{i};
   sport_idx = strcmp(sports, sport);
   
   % Filter data for the current sport
   sport_years = years(sport_idx);
   sport_teams = teams(sport_idx);
   sport_countries = countries(sport_idx);
   sport_medal_if = medal_if(sport_idx);
   sport_events = events(sport_idx);
   
   
   % Filter years to only include the most recent 30 years
   recent_years = unique_years(unique_years >= (current_year - 32) & unique_years <= current_year-4);
   disp(recent_years)

   sum_total_year=zeros(length(recent_years));
   sum_gold_year=zeros(length(recent_years));
   
   % Unique countries
   unique_countries = unique(sport_countries);
   
   % Initialize data for plotting
   gold_medal_year_country = zeros(length(recent_years), length(unique_countries));
   silver_medal_year_country = zeros(length(recent_years), length(unique_countries));
   bronze_medal_year_country = zeros(length(recent_years), length(unique_countries));
   total_medal_year_country = zeros(length(recent_years), length(unique_countries));

   gold_medal_ratio_year_country = zeros(length(recent_years), length(unique_countries));
   total_medal_ratio_year_country = zeros(length(recent_years), length(unique_countries));
   
   % Loop through each year
   for j = 1:length(recent_years)
      year = recent_years(j);
      year_idx = sport_years == year;
      
      % Loop through each country
      for k = 1:length(unique_countries)
         country = unique_countries{k};
         country_idx = strcmp(sport_countries, country);
         
         % Find indices for the current year and country
         idx = year_idx & country_idx;
         
         % Get unique events for the current year and country
         unique_events = unique(sport_events(idx));
         
         % Initialize medal counts
         gold_medals = 0;
         silver_medals = 0;
         bronze_medals = 0;
         total_medals = 0;
         
         % Loop through each event
         for m = 1:length(unique_events)
            event = unique_events{m};
            event_idx = strcmp(sport_events, event);
            
            % Find indices for the current event
            event_year_country_idx = idx & event_idx;
            
            % Check if the event has a medal
            if any(strcmp(sport_medal_if(event_year_country_idx), 'Gold'))
               gold_medals = gold_medals + 1;
            end
            if any(strcmp(sport_medal_if(event_year_country_idx), 'Silver'))
               silver_medals = silver_medals + 1;
            end
            if any(strcmp(sport_medal_if(event_year_country_idx), 'Bronze'))
               bronze_medals = bronze_medals + 1;
            end
            if any(~strcmp(sport_medal_if(event_year_country_idx), 'no medal'))
               total_medals = total_medals + 1;
            end
         end
         
         % Calculate ratios
         total_events = length(unique_events);
         if total_events > 0
            gold_medal_year_country(j, k) = gold_medals;
            silver_medal_year_country(j, k) = silver_medals;
            bronze_medal_year_country(j, k) = bronze_medals;
            total_medal_year_country(j, k) = total_medals;
         end
      end
   end
   
   % Plotting
   %figure;
   %hold on;
   for t=1:length(recent_years)
      for c=1:length(unique_countries)
         sum_gold_year(t) = sum_gold_year(t) + gold_medal_year_country(t, c);
         sum_total_year(t) = sum_total_year(t) + total_medal_year_country(t, c);
      end
      for c=1:length(unique_countries)
         gold_medal_year_country(t, c) = gold_medal_year_country(t, c) / sum_gold_year(t);
         total_medal_year_country(t, c) = (a1*gold_medal_year_country(t, c)+a2*silver_medal_year_country(t,c)+a3*bronze_medal_year_country(t,c)) / sum_total_year(t);%比率设置
      end
   end
   gold_medal_ratio_year_country(t, c)=gold_medal_year_country(t, c);
   total_medal_ratio_year_country(t, c)=total_medal_year_country(t, c);
   fileID = fopen(fullfile(output_folder, [sport  '.txt']), 'w');
   % Initialize arrays to store data
   country_data = cell(length(unique_countries), 3);
   
   for k = 1:length(unique_countries)
      avgratiosum_gold = 0;
      avgratiosum_total = 0;
      for t = 1:length(recent_years)
         avgratiosum_gold = avgratiosum_gold + gold_medal_year_country(t, k);
         avgratiosum_total = avgratiosum_total + total_medal_year_country(t, k);
      end
      % Store data in the array
      country_data{k, 1} = unique_countries{k};
      country_data{k, 2} = 1000 * avgratiosum_gold / length(recent_years);
      country_data{k, 3} = 1000 * avgratiosum_total / length(recent_years);


      country_data{k, 3} = fillmissing(country_data{k, 3}, 'constant', 0);
      country_data{k, 2} = fillmissing(country_data{k, 2}, 'constant', 0);
   end
   fprintf(fileID, 'Sports: %s Years: %d \n',sport,length(recent_years));
   fprintf(fileID, 'goldratio:%f silverratio:%f bronzeratio:%f\n',a1,a2,a3);
   % Sort the data by avgratiosum_gold in descending order
   sorted_data = sortrows(country_data, -3);
   
   % Write sorted data to file
   for k = 1:length(unique_countries)
      fprintf(fileID, 'Country: %s  ', sorted_data{k, 1});
      fprintf(fileID, 'Total: %.2f/k  ', sorted_data{k, 3});
      fprintf(fileID, 'Gold: %.2f/k  \n', sorted_data{k, 2});
      country_STR = [country_STR; {sport,sorted_data{k, 1}, sorted_data{k, 3}, sorted_data{k, 2}}];
   end
   fclose(fileID);
   %hold off;
   %title(['Medal Ratios for ' sport]);
   %xlabel('Year');
   %ylabel('Medal Ratio');
   %legend('show');
   
   % Save the figure
  % saveas(gcf, fullfile(output_folder, ['Medal_Ratios_for_' sport '.png']));
end
country_STR.Properties.VariableNames = {'Sport','Country', 'Total', 'Gold'};

% Save the result to a CSV file
output_filename = fullfile('', 'country_str.csv');

writetable(country_STR, output_filename);
