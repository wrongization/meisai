for yy = 2028:-4:1992
current_year = yy;
filename = 'athfix.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
A = readtable(filename, opts);
a1 = 0.5;
a2 = 0.3;
a3 = 0.2;

country_STR = table();
years = A{:, 5};
teams = A{:, 3};
countries = A{:, 4};
medal_if = A{:, end};
sports = A{:, 7};
events = A{:, 8};
unique_sports = unique(sports);
output_folder = sprintf('country/%d', current_year);
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
unique_years = unique(years);
for i = 1:length(unique_sports)
    avgratiosum_gold = 0.0;
    avgratiosum_total = 0.0;
    sport = unique_sports{i};
    sport_idx = strcmp(sports, sport);
    sport_years = years(sport_idx);
    sport_teams = teams(sport_idx);
    sport_countries = countries(sport_idx);
    sport_medal_if = medal_if(sport_idx);
    sport_events = events(sport_idx);
    recent_years = unique_years(unique_years >= (current_year - 32) & unique_years <= current_year - 4);
    sum_total_year = zeros(length(recent_years));
    sum_gold_year = zeros(length(recent_years));
    unique_countries = unique(sport_countries);
    gold_medal_year_country = zeros(length(recent_years), length(unique_countries));
    silver_medal_year_country = zeros(length(recent_years), length(unique_countries));
    bronze_medal_year_country = zeros(length(recent_years), length(unique_countries));
    total_medal_year_country = zeros(length(recent_years), length(unique_countries));
    gold_medal_ratio_year_country = zeros(length(recent_years), length(unique_countries));
    total_medal_ratio_year_country = zeros(length(recent_years), length(unique_countries));
    for j = 1:length(recent_years)
        year = recent_years(j);
        year_idx = sport_years == year;
        for k = 1:length(unique_countries)
            country = unique_countries{k};
            country_idx = strcmp(sport_countries, country);
            idx = year_idx & country_idx;
            unique_events = unique(sport_events(idx));
            gold_medals = 0;
            silver_medals = 0;
            bronze_medals = 0;
            total_medals = 0;
            for m = 1:length(unique_events)
                event = unique_events{m};
                event_idx = strcmp(sport_events, event);
                event_year_country_idx = idx & event_idx;
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
            total_events = length(unique_events);
            if total_events > 0
                gold_medal_year_country(j, k) = gold_medals;
                silver_medal_year_country(j, k) = silver_medals;
                bronze_medal_year_country(j, k) = bronze_medals;
                total_medal_year_country(j, k) = total_medals;
            end
        end
    end
    for t = 1:length(recent_years)
        for c = 1:length(unique_countries)
            sum_gold_year(t) = sum_gold_year(t) + gold_medal_year_country(t, c);
            sum_total_year(t) = sum_total_year(t) + total_medal_year_country(t, c);
        end
        for c = 1:length(unique_countries)
            gold_medal_year_country(t, c) = gold_medal_year_country(t, c) / sum_gold_year(t);
            total_medal_year_country(t, c) = (a1 * gold_medal_year_country(t, c) + a2 * silver_medal_year_country(t, c) + a3 * bronze_medal_year_country(t, c)) / sum_total_year(t);
        end
    end
    gold_medal_ratio_year_country(t, c) = gold_medal_year_country(t, c);
    total_medal_ratio_year_country(t, c) = total_medal_year_country(t, c);
    fileID = fopen(fullfile(output_folder, [sport '.txt']), 'w');
    country_data = cell(length(unique_countries), 3);
    for k = 1:length(unique_countries)
        avgratiosum_gold = 0;
        avgratiosum_total = 0;
        for t = 1:length(recent_years)
            avgratiosum_gold = avgratiosum_gold + gold_medal_year_country(t, k);
            avgratiosum_total = avgratiosum_total + total_medal_year_country(t, k);
        end
        country_data{k, 1} = unique_countries{k};
        country_data{k, 2} = 1000 * avgratiosum_gold / length(recent_years);
        country_data{k, 3} = 1000 * avgratiosum_total / length(recent_years);
        country_data{k, 3} = fillmissing(country_data{k, 3}, 'constant', 0);
        country_data{k, 2} = fillmissing(country_data{k, 2}, 'constant', 0);
    end
    fprintf(fileID, 'Sports: %s Years: %d \n', sport, length(recent_years));
    fprintf(fileID, 'goldratio:%f silverratio:%f bronzeratio:%f\n', a1, a2, a3);
    sorted_data = sortrows(country_data, -3);
    for k = 1:length(unique_countries)
        fprintf(fileID, 'Country: %s  ', sorted_data{k, 1});
        fprintf(fileID, 'Total: %.2f/k  ', sorted_data{k, 3});
        fprintf(fileID, 'Gold: %.2f/k  \n', sorted_data{k, 2});
        country_STR = [country_STR; {sport, sorted_data{k, 1}, sorted_data{k, 3}, sorted_data{k, 2}}];
    end
    fclose(fileID);
end
country_STR.Properties.VariableNames = {'Sport', 'Country', 'Total', 'Gold'};
outname = sprintf('country_str_%d.csv', current_year);
output_filename = fullfile('', outname);
writetable(country_STR, output_filename);

% Second Segment

filename = outname;
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
A = readtable(filename, opts);
sport = A{:, 1};
country = A{:, 2};
total = A{:, 3};
gold = A{:, 4};
data = table(sport, country, total, gold);
unique_sports = unique(sport);
normalized_total = total;
for i = 1:length(unique_sports)
    sport_name = unique_sports{i};
    sport_idx = strcmp(sport, sport_name);
    sport_total = total(sport_idx);
    min_total = min(sport_total);
    max_total = max(sport_total);
    if max_total == 0 && min_total == 0
        normalized_total(sport_idx) = 0;
    elseif max_total == min_total
        normalized_total(sport_idx) = 1;
    else
        normalized_total(sport_idx) = (sport_total - min_total) / (max_total - min_total);
    end
end
data.total = normalized_total;
outname = sprintf('normalized_country_str_%d.csv', current_year);
writetable(data, outname);
disp(data);

% Third Segment
filename = 'athfix.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
A = readtable(filename, opts);
names = A{:, 1};
years = A{:, 5};
teams = A{:, 3};
countries = A{:, 4};
medal_if = A{:, end};
sports = A{:, 7};
events = A{:, 8};
unique_sports = unique(sports);
output_folder = sprintf('person/%d', current_year);
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
years_of_interest = [current_year - 8, current_year - 4];
athletes_before2 = ismember(years, years_of_interest) & ~ismember(years, setdiff(unique(years), years_of_interest));
athletes_names_before2 = names(athletes_before2);
disp('Athletes who participated only in 2020 or 2024:');
disp(athletes_names_before2);
unique_athletes = unique(names(athletes_before2));
country_sport_count = table();
for i = 1:length(unique_sports)
    sport = unique_sports{i};
    fileID = fopen(fullfile(output_folder, [sport '.txt']), 'w');
    sport_filter = strcmp(sports, sport) & athletes_before2;
    unique_countries = unique(countries(sport_filter));
    for j = 1:length(unique_countries)
        country = unique_countries{j};
        country_filter = strcmp(countries, country) & sport_filter;
        athlete_count = length(unique(names(sport_filter)));
        only_before2_filter = country_filter & ismember(years, [current_year - 8, current_year - 4]);
        unique_athletes_before2 = unique(names(only_before2_filter));
        only_before2_count = length(unique_athletes_before2);
        ratio = only_before2_count / athlete_count;
        fprintf(fileID, 'Country: %s  Ratio:%f/Hundred  Count:%d\n', country, 100 * ratio, only_before2_count);
        ratiomul = ratio * 100;
        country_sport_count = [country_sport_count; {sport, country, ratiomul, only_before2_count}];
    end
    fclose(fileID);
end
country_sport_count.Properties.VariableNames = {'Sport', 'Country', 'Ratio', 'Onlybefore2Count'};
outname = sprintf('person_str_%d.csv', current_year);
output_filename = fullfile('', outname);
writetable(country_sport_count, output_filename);

% Fourth Segment
filename = outname;
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
A = readtable(filename, opts);
sport = A{:, 1};
country = A{:, 2};
str = A{:, 3};
count = A{:, 4};
data = table(sport, country, str, count);
unique_sports = unique(sport);
normalized_str = str;
for i = 1:length(unique_sports)
    sport_name = unique_sports{i};
    sport_idx = strcmp(sport, sport_name);
    sport_str = str(sport_idx);
    min_str = min(sport_str);
    max_str = max(sport_str);
    if max_str == 0 && min_str == 0
        normalized_str(sport_idx) = 0;
    elseif max_str == min_str
        normalized_str(sport_idx) = 1;
    else
        normalized_str(sport_idx) = (sport_str - min_str) / (max_str - min_str);
    end
end
data.str = normalized_str;
data = sortrows(data, {'sport', 'str'}, {'ascend', 'descend'});
outname = sprintf('normalized_person_str_%d.csv', current_year);
writetable(data, outname);
disp(data);


outname = sprintf('normalized_country_str_%d.csv', current_year);
% Fifth Segment
filename1 = outname;
opts1 = detectImportOptions(filename1);
opts1.VariableNamesLine = 1;
A = readtable(filename1, opts1);

outname = sprintf('normalized_person_str_%d.csv', current_year);
filename2 = outname;
opts2 = detectImportOptions(filename2);
opts2.VariableNamesLine = 1;
B = readtable(filename2, opts2);
filename = 'host.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
C = readtable(filename, opts);
mergedTable = outerjoin(A, B, 'Keys', {'sport', 'country'}, 'MergeKeys', true);
c1 = 0.6870;
c2 = 0.1865;
c3 = 0.1265;
host_city = C{C{:, 1} == current_year, 2};
if isempty(host_city)
    error('No host city found for the current year.');
end
MAIN = host_city{1};
sport = mergedTable{:, 1};
country = mergedTable{:, 2};
country_str = mergedTable{:, 3};
person_str = mergedTable{:, 5};
country_str = fillmissing(country_str, 'constant', 0);
person_str = fillmissing(person_str, 'constant', 0);
final = country_str * c1 + person_str * c2;
final(strcmp(country, MAIN)) = final(strcmp(country, MAIN)) + c3;
Table = table(sport, country, country_str, person_str, final);
Table = sortrows(Table, {'sport', 'final'}, {'ascend', 'descend'});
%writetable(Table, 'mergedTable.csv');
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
outname = sprintf('str_%d.csv', current_year);
writematrix(l, outname);
end