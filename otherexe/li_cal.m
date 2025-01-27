filename = "2024_combined_gold_results";
opts = detectImportOptions(filename);
opts.VariableNamesLine = 0;
A = readtable(filename, opts);

filename = "countrycode_gold_total_2024";
opts = detectImportOptions(filename);
opts.VariableNamesLine = 0;
B = readtable(filename, opts);
real= B{:, 2};

numDimensions = 4;


A{:, 2:numDimensions+1}(A{:, 2:numDimensions+1} <= 0) = exp(A{:, 2:numDimensions+1}(A{:, 2:numDimensions+1} <= 0)-3);
real(real <= 0) = exp(real(real <= 0)-3);
% Define the objective function
objFunc = @(x) sum(abs(log(real) - log(A{:, 2:numDimensions+1}) * x'));


% Define the number of particles and dimensions
numParticles = 1000;

% Define the maximum number of iterations
maxIter = 500;
w = 0.4;
c1 = 1.8;
c2 = 1.8;


rangeMin = 0;
rangeMax = 1;

% Initialize the particle positions and velocities
positions = rangeMin + (rangeMax - rangeMin) * rand(numParticles, numDimensions);
velocities = zeros(numParticles, numDimensions);

% Initialize the personal best positions and the global best position
personalBestPositions = positions;
personalBestScores =zeros(numParticles, 1);
for i = 1:numParticles
    personalBestScores(i) = objFunc(personalBestPositions(i, :));
end
[globalBestScore, bestIdx] = min(personalBestScores);
globalBestPosition = personalBestPositions(bestIdx, :);

% Main loop of the PSO algorithm
for iter = 1:maxIter
    % Update velocities and positions
    for i = 1:numParticles
        r1 = rand(1, numDimensions);
        r2 = rand(1, numDimensions);
        velocities(i, :) = w .* velocities(i, :) ...
            + c1 * r1 .* (personalBestPositions(i, :) - positions(i, :)) ...
            + c2 * r2 .* (globalBestPosition - positions(i, :));
        positions(i, :) = positions(i, :) + velocities(i, :);
        
        % Ensure the positions are within the defined range
        positions(i, :) = max(min(positions(i, :), rangeMax), rangeMin);
        
        % Evaluate the objective function
        score = objFunc(positions(i, :));
        
        % Update personal best
        if score < personalBestScores(i)
            personalBestScores(i) = score;
            personalBestPositions(i, :) = positions(i, :);
        end
        
        % Update global best
        if score < globalBestScore
            globalBestScore = score;
            globalBestPosition = positions(i, :);
        end
    end
end

% Display the results
disp('Global Best Position:');
disp(globalBestPosition);
disp('Global Best Score:');
disp(globalBestScore);

% Normalize the global best position
normalizedWeights = globalBestPosition / sum(globalBestPosition);
% Calculate the weighted sum for each country
weightedSum = log(A{:, 2:numDimensions+1}) * normalizedWeights';
weightedSum = exp(weightedSum);
% Create a new table with the country names and the weighted sum
resultTable = table(A{:, 1}, weightedSum, 'VariableNames', {'Country', 'WeightedSum'});
resultTable = sortrows(resultTable, 'WeightedSum', 'descend');

% Display the result table
disp(resultTable);