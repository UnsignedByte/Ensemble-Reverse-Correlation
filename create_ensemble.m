function ensemble,data = create_ensemble(num, skew)

    wcols = [1 3 4]; %which columns of data to save

    if skew == -1
        ensemble = ensembledat{1}(randperm(size(ensembledat{1},1),num-1), wcols);
        ensemble(num,:) = ensembledat{2}(randi(size(ensembledat{2},1)), wcols);
    elseif skew == 0
        ensemble = ensembledat{1}(randperm(size(ensembledat{1},1),num/2), wcols);
        ensemble(end+1:num,:) = ensembledat{2}(randperm(size(ensembledat{2},1),num/2), wcols);
    elseif skew == 1
        ensemble = ensembledat{2}(randperm(size(ensembledat{2},1),num-1), wcols);
        ensemble(num,:) = ensembledat{1}(randi(size(ensembledat{1},1)), wcols);
    end
    
    ensemble = ensemble(randperm(num),:);
    data = ensemble(:, 2:end)';
    ensemble = ensemble(:,1)';
    fnames = strcat('CFD-', ensemble, '-*-N.jpg');
    ensemble = fullfile('CFD Version 2.0.3', 'CFD 2.0.3 Images', ensemble);
    
    for i = 1:num
        imfile = dir(fullfile(ensemble{i}, fnames{i}));
        ensemble{i} = imread(fullfile(ensemble{i},imfile(1).name));
    end
end