%% Clear variables

clear all
close all

directoryPath = '/Users/benfalken/Documents/MATLAB/TrialRecords';
userDirectory = dir(directoryPath);
userFiles = size(userDirectory(4:end),1);

%% Declare Vairables

trials = 9; %100
filterSize = 512;

% Create starting files for averagse Trusted & Untrusted Noise
trustedNoise = zeros(1, filterSize, filterSize);
untrustedNoise = zeros(1, filterSize, filterSize);

% Create a cell to generate multiple images later on
windowCell = cell(3,2);

%% Create Chosen Array

chosen = ones(3,trials);

for trial=1:trials
    chosen(randperm(3,1),trial) = -1;
end

save([directoryPath 'chosen.mat'], 'chosen');

%% Find different Skew Indices

for file=1:userFiles
    userPath = userDirectory(3+file).name;
    % Fetch user Files
    noiseTypes = matfile([directoryPath '/' userPath '/noises.mat']);
    %ensembleTypes = reshape(repelem([-1, 0, 1], trials), trials, 3)';
    chosenEnsembles = matfile([directoryPath '/' userPath '/chosen.mat']);
    
    blackSkewIndices = find(chosenEnsembles.chosen(1,:) == -1);
    neutralSkewIndices = find(chosenEnsembles.chosen(2,:) == -1);
    whiteSkewIndices = find(chosenEnsembles.chosen(3,:) == -1);


    noiseTypes = cell2mat(noiseTypes.noises);
    noiseTypes = reshape(noiseTypes, trials, filterSize, filterSize);
    trustedNoise(end+1:end+trials,:,:) = noiseTypes;
end
% Find ensemble skew based on position at which matrix is marked
trustedNoise = trustedNoise(2:end,:,:);
skewArray = [blackSkewIndices, neutralSkewIndices, whiteSkewIndices];

%% Sum up each Skew-Indexed Image

for skew=1:3
    imageIndices = skewArray(skew);
    sumImage = zeros(filterSize, filterSize);
    for index=1:length(imageIndices)
        disp(size(trustedNoise(index,:,:)));
        sumImage = sumImage + reshape(trustedNoise(index,:,:), filterSize, filterSize);
    end
    meanImage = sumImage ./ length(imageIndices);
    
    windowCell{skew,1} = figure;
    graySumImage = uint8(meanImage);
    image(graySumImage);
    colormap(gray(256));
    
    threshold = [mean(meanImage)-std(meanImage), mean(meanImage)+std(meanImage)];
    
    blankBackground = zeros(filterSize, filterSize);
    
    preferImage = find(meanImage > threshold(2) | meanImage < threshold(1));
    windowCell{skew,2} = figure;
    blankBackground(preferImage) = 255;
    blankBackground = uint8(blankBackground);
    image(blankBackground);
    colormap(gray(256));
end



