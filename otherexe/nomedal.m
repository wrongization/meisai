filename = 'athfix.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
A = readtable(filename, opts);

filename = 'countrycode.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
B = readtable(filename, opts);

filename = 'Top234_TotalMedals.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
C = readtable(filename, opts);

% Extract the country codes and medal status from A
countryCodesA = A{:, 4};
medalStatusA = A{:, end};

% Extract the country codes and medal counts from C
countryCodesC = C{:, 1};
medalCountsC = C{:, 2};

uniqueCountriesA = unique(countryCodesA);

% Initialize an array to store countries with only "no medal" in A but medals in C
countriesWithNoMedalButMedalsInC = {};

% Loop through each unique country in A
for i = 1:length(uniqueCountriesA)
    country = uniqueCountriesA{i};
    % Get the indices of the current country in A
    countryIndicesA = strcmp(countryCodesA, country);
    % Get the medal statuses for the current country in A
    countryMedalStatusesA = medalStatusA(countryIndicesA);
    % Check if the country has only "no medal" in A
    if all(strcmp(countryMedalStatusesA, 'No medal'))
        % Check if the country has a medal count greater than 0 in C
        countryIndicesC = strcmp(countryCodesC, country);
        if any(countryIndicesC) && any(medalCountsC(countryIndicesC) > 0)
            countriesWithNoMedalButMedalsInC{end+1} = country; %#ok<AGROW>
        end
    end
end
disp(countriesWithNoMedalButMedalsInC);
% Convert the cell array to a table
T = table(countriesWithNoMedalButMedalsInC', 'VariableNames', {'Country'});

% Write the table to a CSV file
writetable(T, 'countries_with_no_medal_but_medals_in_C.csv');

% Display the result
disp('Countries with only "no medal" in A but medals in C:');
disp(countriesWithNoMedalButMedalsInC);
