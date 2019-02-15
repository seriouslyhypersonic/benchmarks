% 
% Creates a semilog plot for dgemm benchmarks
% GFLOPS are computed 

% Load the benchmark file
[file, path] = uigetfile('.csv', 'Import benchmark');
filename = [path file];
if(not(filename))
    errordlg('No file was selected.');
    return
end
data = readtable(filename);

% If commas are used as decimal separator, replace with dot
question = ['Does the file ' file ' use comma as decimal separator'];
dlgTitle = 'Decimal separator';
hasCommaDecimalSeparator = questdlg(question, dlgTitle, 'Yes', 'No', 'Yes');

if(hasCommaDecimalSeparator)
    if (not(isnumeric(data.Baseline)))
        data.Baseline = str2double(strrep(data.Baseline, ',', '.'));
    end
    if (not(isnumeric(data.us_Iteration)))
        data.us_Iteration = str2double(strrep(data.us_Iteration, ',', '.'));
    end
end

name = data.Group{1};                                    % Benchmark name
experiments = string(unique(data.Experiment, 'stable')); % Experiment names
nExperiments = length(experiments);

% Number of runs for each experiment (different problem spaces)
nRuns = zeros(nExperiments, 1);
for i=1:nExperiments
    nRuns(i) = sum(count(data.Experiment, experiments(i)));
end

% Compute GFLOPS
prompt = {'Number of cores:', ...
    'CPU frequency (GHz)', ...
    'Floating point operations per cicle'};
dlgTitle = 'Compute peak GFLOPS';
dims = [1, 25];
defInput = {'4', '3.50', '16'};
answer = inputdlg(prompt, dlgTitle, dims, defInput);
answer = cellfun(@str2num, answer);
peakGflops = prod(answer)

% FLOP MN(1+2K) ~ 2MNK for K >> 1 (no approx. because for K = 2, K ~ 1)
gflops = ((data.ProblemSpace.^2) .* (1+2*data.ProblemSpace)) * (1E-9);  
gflops = gflops ./ (data.us_Iteration * 1E-6); % t in us

for i=1:nExperiments
    range = 1+(i-1)*nRuns(i) : i*nRuns(i);
    semilogx(data.ProblemSpace(range), gflops(range));
    hold on
end
title('C = \alpha \times A^T \times B^T + \beta C');
xlabel('Matrix dim (n x n)');
ylabel('GFLOPS');
legend(experiments);
hold off
