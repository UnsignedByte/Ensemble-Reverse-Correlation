ensembledat = readcell(fullfile('CFD Version 2.0.3', 'CFD 2.0.3 Norming Data and Codebook.xlsx'), 'Sheet', 'CFD 2.0.3 Norming Data'); %Read in ensemble excel
ensembledat = ensembledat(6:end,:); %Ignore title rows
ensembledat = ensembledat(strcmp(ensembledat(:,3), 'M'),:); %Take all items with 'M' as the gender (male)
ensembledat = {ensembledat(strcmp(ensembledat(:,2), 'B'),:), ...
    ensembledat(strcmp(ensembledat(:,2), 'W'),:)}; %Create cell with two cells inside, taking 'B' and 'W' ethnicities
ensembledat{1} = [num2cell((1:size(ensembledat{1},1))') ensembledat{1}]; %add row number starting from 1 to first cell
ensembledat{2} = [num2cell(((1:size(ensembledat{2},1))')+size(ensembledat{1},1)) ensembledat{2}]; 
%continue numbering second cell from the last number in the first cell

%Replace each image name with the actual image matrix
for i = 1:2
    fnames = strcat('CFD-', ensembledat{i}(:,2), '-*-N.jpg'); %Get list of image names using the ID
    %Convert to list of directories
    ensembledat{i}(:,2) = fullfile('CFD Version 2.0.3', 'CFD 2.0.3 Images', ensembledat{i}(:,2));
    for j = 1:size(ensembledat{i},1) %loop through each directory
        imfile = dir(fullfile(ensembledat{i}{j,2}, fnames{j}));  %Find all images in folder matching name
        ensembledat{i}{j,2} = imresize(imread(fullfile(ensembledat{i}{j,2},imfile(1).name)), 0.25);
        %take first matching image and shrink to 1/4 size, then save
    end
end

save('ensembledat.mat', 'ensembledat', '-v7.3'); %Save full data 