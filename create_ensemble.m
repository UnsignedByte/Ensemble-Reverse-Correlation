function ensemble = create_ensemble(num, endrange, percent, ensembledat, traitind) 
    %{
    endrange = double from 0-1: what fraction of total values from end/start are
    considered valid choices
    percent = what percent of values are part of the desired trait (0-1)
    %}
    valids = 1:size(ensembledat, 1)*endrange;
    
    respos = ensembledat(size(ensembledat, 1)-valids+1, [1 traitind]); %last n%, rated highest for trait
    resneg = ensembledat(valids,[1 traitind]); %first n%, rated lowest for trait
    
    ensemble = cat(1,respos(randsample(size(respos, 1), floor(num*percent)),:),  resneg(randsample(size(resneg, 1), num-floor(num*percent)),:));
    ensemble = ensemble(randperm(size(ensemble, 1)),:);
    fnames = strcat('CFD-', ensemble(:,1), '-*-N.jpg');
    ensemble(:,1) = fullfile('CFD Version 2.0.3', 'CFD 2.0.3 Images', ensemble(:,1));
    
    for i = 1:size(ensemble, 1)
        imfile = dir(fullfile(ensemble{i,1}, fnames{i}));
        ensemble{i, 1} = imread(fullfile(ensemble{i, 1},imfile(1).name));
    end
end