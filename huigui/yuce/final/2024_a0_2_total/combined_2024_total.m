x=8;
for i = 1:x
    filename = sprintf('2024_sortedbytotal_%d.csv', i);
    opts = detectImportOptions(filename);
    opts.VariableNamesLine = 1;
    S = readtable(filename, opts);
    
    % Extract the country names and gold medal counts
    countryNames = S{:, 1};
    TotalCounts = S{:, 2};
    
    % Create a table with the country names and gold counts
    T = table(countryNames, TotalCounts, 'VariableNames', {'Country', sprintf('TotalCount_%d', i)});
    
    % Join the new table with the combined results table
    if i == 1
        combinedResults = T;
    else
        combinedResults = outerjoin(combinedResults, T, 'Keys', 'Country', 'MergeKeys', true);
    end
end

% Display the combined results
disp(combinedResults);

% Write the combined results to a CSV file
writetable(combinedResults, '2024_combined_total_results.csv');