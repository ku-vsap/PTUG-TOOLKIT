function sequences = config_sequence(type)
% config sequences for evaluation
% the configuration files are placed in ./sequence_evaluation_config/;
switch type
    case 'single'
        dataset_name = 'single_set.txt';
    case 'multi'
        dataset_name = 'multi_set.txt';
    case 'all'
        dataset_name = 'all_set.txt';
    case 'trial'
        dataset_name = 'trial.txt';
    case 'ptuc_test'
        dataset_name = 'ptuc_test.txt';
    case 'ptuc_single_test'
        dataset_name = 'ptuc_single_test.txt';
    case 'ptuc_multi_test'
        dataset_name = 'ptuc_multi_test.txt';
    otherwise
        error('Error in evaluation dataset type! Either ''single_set'' or "multi_set" or ''all-set''.')
end

% check if the file exists
if ~exist(dataset_name, 'file')
    error('%s is not found!', dataset_name);
end

% load evaluation sequences
fid = fopen(dataset_name, 'r');
i = 0;
sequences = cell(100000, 1);
while ~feof(fid)
    i = i + 1;
    sequences{i, 1} = fgetl(fid);
end
sequences(i+1:end) = [];
fclose(fid);
end