filename1 = 'normalized_country_str';
opts1 = detectImportOptions(filename1);
opts1.VariableNamesLine = 1;
A = readtable(filename1, opts1);

filename2 = 'normalized_person_str';
opts2 = detectImportOptions(filename2);
opts2.VariableNamesLine = 1;
B = readtable(filename2, opts2);

% Merge the tables based on the first two columns (sport and country)
mergedTable = outerjoin(A, B, 'Keys', {'sport', 'country'}, 'MergeKeys', true);
c1=0.6870;
c2=0.1865;
c3=0.1265;
MAIN='USA';

sport=mergedTable{:, 1};
country=mergedTable{:, 2};
country_str=mergedTable{:, 3};
person_str=mergedTable{:, 5};
final = country_str * c1 + person_str * c2;
final(strcmp(country, MAIN)) = final(strcmp(country, MAIN)) +c3 ;
Table=table(sport,country,country_str,person_str,final);

% Replace all NaN values with 0
Table{:, 3} = fillmissing(Table{:, 3}, 'constant', 0);
Table{:, 4} = fillmissing(Table{:, 4}, 'constant', 0);
Table{:, 5} = fillmissing(Table{:, 5}, 'constant', 0);
Table = sortrows(Table, {'sport', 'final'}, {'ascend', 'descend'});
% Save the final table to a new file
writetable(Table, 'final_str.csv');