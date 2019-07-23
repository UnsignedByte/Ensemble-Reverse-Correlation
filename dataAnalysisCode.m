%% Clear variables

clear all
close all

directoryPath = 'Ensemble RC Results';
userDirectory = dir(fullfile(directoryPath, 'user_*'));
baseImg = rgb2gray(imread('male.jpg'));

%% Declare Vairables

trials = 100; %100

% Create starting files for averagse Trusted & Untrusted Noise
%trustedNoise = zeros(1, filterSize, filterSize);
%untrustedNoise = zeros(1, filterSize, filterSize);

% Create a cell to generate multiple images later on
windowCell = cell(3,2);

%% Find different Skew Indices

for file=1:size(userDirectory,1)
    userPath = userDirectory(file).name;
   
    % Fetch user Files
    load(fullfile(directoryPath,userPath,'noises.mat'));
    
    %ensembleTypes = reshape(repelem([-1, 0, 1], trials), trials, 3)';
    load(fullfile(directoryPath,userPath,'chosen.mat'));
    trials = size(chosen, 2);
    noisesm = zeros(3,trials,512,512);
    for i = 1:3
        for j = 1:trials
            noisesm(i,j,:,:) = noises{i,j};
        end
    end
    
    meanIms = mean(chosen.*noisesm,2);
    save(fullfile(directoryPath,userPath,'meanIms.mat'), 'meanIms');
    for i = 1:3
        imwrite(uint8(reshape(meanIms(i,1,:,:),512,512)+double(baseImg)), fullfile(directoryPath, userPath, ['Skewed_Mean_' num2str(i-2) '.png']));
    end
end

%{
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
%}


