%% PROGRAM RECORDS MEAN, STANDARD DEV, AREAS OF PRIORITY FOR EACH USER'S CHOICE OF TRUSTWORTHINESS GIVEN ENSEMBLE SKEW

%% Clear variables

clear all
close all

%% Declare Vairables

trials = 100;
filterSize = 512;
windowCell = cell(3,2);
userStandardDev = zeros(3,1);

%% Declare File and Photo Paths

directoryPath = 'Ensemble RC Results';
userDirectory = dir(fullfile(directoryPath, 'user_*'));
baseImg = rgb2gray(imread('male.jpg'));


maskSize = 1580;
maskImg = round(double(rgb2gray(imread('ovalmask.jpg'))),1);
maskImg = maskImg(1:maskSize, 431:maskSize+430);
maskImg = imresize(maskImg, filterSize/maskSize);
maskImg = reshape(maskImg, filterSize^2, 1);
%% Find different Skew Indices

% Iterate through each User
for file=1:size(userDirectory,1)
    userPath = userDirectory(file).name;
   
    % Fetch user Files
    load(fullfile(directoryPath,userPath,'noises.mat'));
    load(fullfile(directoryPath,userPath,'chosen.mat'));
    
    % Reset Trial Size
    trials = size(chosen, 2);
    noisesm = zeros(3, trials, filterSize, filterSize);
    
    % Transfer Noise Data, by Row (The Noise's Skew Index)
    for i = 1:3
        for j = 1:trials
            noisesm(i,j,:,:) = noises{i,j};
        end
    end
    
    %Define List of Noise Arrays and their Mean
    userImgSet = chosen.*noisesm;
    meanIms = mean(userImgSet,2);
    
    % Save the Noise Mean
    save(fullfile(directoryPath,userPath,'meanIms.mat'), 'meanIms');
    for i = 1:3
        
        % Find variance of all arrays in set
        selectUserImgSet = reshape(userImgSet(i,:,:,:), trials, filterSize, filterSize);
        baselineImgSet = reshape(meanIms(i,1,:,:), 1, filterSize, filterSize);
        stdevImg = zeros(filterSize^2,1);
        
        aggregateDiff = (selectUserImgSet(:,:,:)-baselineImgSet).^2;
        
        for pixel=1:filterSize^2
            stdevImg(pixel) = sqrt(sum(aggregateDiff(:,floor((pixel-1)/filterSize)+1, mod(pixel, filterSize)+1)))/trials;
        end
        
        disp(['The standard deviation for row ' num2str(i) ' is: ' num2str(mean(stdevImg))]);
        
        userStandardDev(i) = mean(stdevImg);
        
        % Open new Drawing Window, and Display Mean Image
        windowCell{i,1} = figure;
        meanImg = reshape(meanIms(i,1,:,:), filterSize, filterSize);
        dispMeanImg = meanImg+double(baseImg);
        imwrite(uint8(dispMeanImg), fullfile(directoryPath, userPath, ['Skewed_Mean_' num2str(i-2) '.png']));
        
        % Find areas of importance
        emphasizedImg = zeros(filterSize,filterSize,3);
        flatMeanImg = round(reshape(meanImg, filterSize^2, 1));
        flatBaseImg = round(reshape(baseImg, 1, filterSize, filterSize));
        
        % Create RBG Image to display
        
        for layer=1:3
            emphasizedImg(:, :, layer) = flatBaseImg;
        end
        
        % Open new Drawing Window, and Display Areas of Priority
        windowCell{i,2} = figure;
        
        selectIndices = find(maskImg(:) == 0);
        flatMeanImg(selectIndices) = NaN;
       
        [preferVals, preferIndices] = maxk(flatMeanImg(:), 100);
        [deterVals, deterIndices] = mink(flatMeanImg(:), 100);
       
        emphasizedImg(mod(preferIndices, filterSize)+1, floor((preferIndices-1)./filterSize)+1, 2) = 255;
        emphasizedImg(mod(deterIndices, filterSize)+1, floor((deterIndices-1)./filterSize)+1, 1) = 255;
        
        imwrite(uint8(emphasizedImg), fullfile(directoryPath, userPath, ['Weighted_Areas_Skewed_Mean_' num2str(i-2) '.png']));
    end
end

% Save Deviation Data
save(fullfile([directoryPath, userPath,'UserStandardDev.mat']), 'userStandardDev');
