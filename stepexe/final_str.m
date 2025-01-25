current_year=2016;
filename1 = 'normalized_country_str';
opts1 = detectImportOptions(filename1);
opts1.VariableNamesLine = 1;
A = readtable(filename1, opts1);

filename2 = 'normalized_person_str';
opts2 = detectImportOptions(filename2);
opts2.VariableNamesLine = 1;
B = readtable(filename2, opts2);

filename = 'host.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
C = readtable(filename, opts);


% Merge the tables based on the first two columns (sport and country)
mergedTable = outerjoin(A, B, 'Keys', {'sport', 'country'}, 'MergeKeys', true);
c1=0.6870;
c2=0.1865;
c3=0.1265;
% Convert current_year to corresponding host city using table C
host_city = C{C{:, 1} == current_year, 2};
if isempty(host_city)
    error('No host city found for the current year.');
end
MAIN = host_city{1};
sport=mergedTable{:, 1};
country=mergedTable{:, 2};
country_str=mergedTable{:, 3};
person_str=mergedTable{:, 5};
country_str = fillmissing(country_str, 'constant', 0);
person_str = fillmissing(person_str, 'constant', 0);
final = country_str * c1 + person_str * c2;
final(strcmp(country, MAIN)) = final(strcmp(country, MAIN)) +c3 ;
Table=table(sport,country,country_str,person_str,final);


Table = sortrows(Table, {'sport', 'final'}, {'ascend', 'descend'});
writetable(Table, 'mergedTable.csv');
table1 = Table;
uniqueValues1 = unique(table1{:,1});
uniqueValues2 = unique(table1{:,2});
n1 = length(uniqueValues1);
n2 = length(uniqueValues2);
l = zeros(n2, n1);

[~, idx1] = ismember(table1{:,1}, uniqueValues1);
[~, idx2] = ismember(table1{:,2}, uniqueValues2);

for i = 1:height(table1)
    l(idx2(i), idx1(i)) = table1{i, 5};
end

% Save the matrix to a CSV file
sprintf(outname,'str_%dcsv',current_year);
writematrix(l, outname);