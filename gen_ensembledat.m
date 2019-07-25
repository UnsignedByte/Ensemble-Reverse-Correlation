ensembledat = readcell(fullfile('CFD Version 2.0.3', 'CFD 2.0.3 Norming Data and Codebook.xlsx'), 'Sheet', 'CFD 2.0.3 Norming Data'); %Read in ensemble excel
ensembledat = ensembledat(6:end,:);
ensembledat = ensembledat(strcmp(ensembledat(:,3), 'M'),:); %Get only males
ensembledat = {ensembledat(strcmp(ensembledat(:,2), 'B'),:),ensembledat(strcmp(ensembledat(:,2), 'W'),:)};
ensembledat{1} = [num2cell((1:size(ensembledat{1},1))') ensembledat{1}];
ensembledat{2} = [num2cell(((1:size(ensembledat{2},1))')+size(ensembledat{1},1)) ensembledat{2}];

%Replace each image name with the actual image matrix
for i = 1:2
    fnames = strcat('CFD-', ensembledat{i}(:,2), '-*-N.jpg');
    ensembledat{i}(:,2) = fullfile('CFD Version 2.0.3', 'CFD 2.0.3 Images', ensembledat{i}(:,2));
    for j = 1:size(ensembledat{i},1)
        imfile = dir(fullfile(ensembledat{i}{j,2}, fnames{j}));
        ensembledat{i}{j,2} = imresize(imread(fullfile(ensembledat{i}{j,2},imfile(1).name)), 0.25);
    end
end

save('ensembledat.mat', 'ensembledat', '-v7.3');