filename = 'r2_total.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
A = readtable(filename, opts);

filename = 'r2_gold.csv';
opts = detectImportOptions(filename);
opts.VariableNamesLine = 1;
B = readtable(filename, opts);

% Define a small threshold value
threshold = 1e-3;

% Remove rows where any coordinate is close to zero for the first file
A(any(abs(A{:, 2:4}) < threshold, 2), :) = [];

% Remove rows where any coordinate is close to zero for the second file
B(any(abs(B{:, 2:4}) < threshold, 2), :) = [];

% Extract coordinates and values for the first file
x1 = A{:, 2};
y1 = A{:, 3};
z1 = A{:, 4};
values1 = A{:, 5};

% Extract coordinates and values for the second file
x2 = B{:, 2};
y2 = B{:, 3};
z2 = B{:, 4};
values2 = B{:, 5};

% Create a figure
figure;

% Plot the first 3D scatter plot
subplot(1, 2, 1);
scatter3(x1, y1, z1, 36, values1, 'filled');
colorbar;
title('3D Scatter Plot for r2\_total.csv');
xlabel('c1');
ylabel('c2');
zlabel('c3');
colormap(jet);
caxis([0.9 0.95]);

% Plot the second 3D scatter plot
subplot(1, 2, 2);
scatter3(x2, y2, z2, 36, values2, 'filled');
colorbar;
title('3D Scatter Plot for r2\_gold.csv');
xlabel('c1');
ylabel('c2');
zlabel('c3');
colormap(jet);
caxis([0.9 0.95]);