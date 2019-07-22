ensembledat = readcell(fullfile('CFD Version 2.0.3', 'CFD 2.0.3 Norming Data and Codebook.xlsx'), 'Sheet', 'CFD 2.0.3 Norming Data'); %Read in ensemble excel
ensembledat = ensembledat(6:end,:);
ensembledat = ensembledat(strcmp(ensembledat(:,3), 'M'),:); %Get only males
ensembledat = {ensembledat(strcmp(ensembledat(:,2), 'B'),:),ensembledat(strcmp(ensembledat(:,2), 'W'),:)};

%Replace each image name with the actual image matrix
for i = 1:2
    fnames = strcat('CFD-', ensembledat{i}(:,1), '-*-N.jpg');
    ensembledat{i}(:,1) = fullfile('CFD Version 2.0.3', 'CFD 2.0.3 Images', ensembledat{i}(:,1));
    for j = 1:size(ensembledat{i},1)
        imfile = dir(fullfile(ensembledat{i}{j}, fnames{j}));
        ensembledat{i}{j} = imresize(imread(fullfile(ensembledat{i}{j},imfile(1).name)), 0.5);
    end
end

save('ensembledat.mat', 'ensembledat', '-v7.3');