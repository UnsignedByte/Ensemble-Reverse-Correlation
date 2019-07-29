%% PROGRAM RECORDS MEAN, STANDARD DEV, AREAS OF PRIORITY FOR EACH USER'S CHOICE OF TRUSTWORTHINESS GIVEN ENSEMBLE SKEW

%% Clear variables

clear all
close all

%% Declare Vairables

global baseImg maleMask

trials = 100;
baseImg = rgb2gray(imread('male.jpg'));
filterSize = size(baseImg,1);
windowCell = cell(3,2);
userStandardDev = zeros(3,1);

%% Declare File and Photo Paths

directoryPath = 'Ensemble RC Results';
userDirectory = dir(fullfile(directoryPath, 'user_*'));

%% Find different Skew Indices

maleMask = imread('malemask.png');
maleMask = double(maleMask(:,:,1)/255);

nsk = 2;

totalAverageNoises = zeros(filterSize,filterSize,nsk);
allDems = cell(4);

% Iterate through each User
for file=1:size(userDirectory,1)
    userPath = userDirectory(file).name;

    % Fetch user Files
    load(fullfile(directoryPath,userPath,'noises.mat'));
    load(fullfile(directoryPath,userPath,'chosen.mat'));
    load(fullfile(directoryPath,userPath,'demographics.mat'));
    allDems(file,:) = demographics;

    % Reset Trial Size
    trials = size(chosen, 2);
    nsk = size(chosen, 1);
    noisesm = zeros(nsk, trials, filterSize, filterSize);

    % Transfer Noise Data, by Row (The Noise's Skew Index)
    for i = 1:nsk
        for j = 1:trials
            noisesm(i,j,:,:) = noises{i,j};
        end
    end

    %Define List of Noise Arrays and their Mean
    userImgSet = chosen.*noisesm;
    meanIms = mean(userImgSet,2);

    % Save the Noise Mean
    save(fullfile(directoryPath,userPath,'meanIms.mat'), 'meanIms');
    for i = 1:nsk

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
        %windowCell{i,1} = figure;
        meanImg = reshape(meanIms(i,1,:,:), filterSize, filterSize);
        totalAverageNoises(:,:,i) = totalAverageNoises(:,:,i)+meanImg;
        meanImg = 15/std2(meanImg)*meanImg;
        %Draw noise + image with scaled stdev
        imwrite(uint8(double(baseImg)+meanImg), fullfile(directoryPath, userPath, ['Mean_' num2str(i-2) '_norm.png']));
        imwrite(uint8(double(baseImg)-meanImg), fullfile(directoryPath, userPath, ['Mean_' num2str(i-2) '_rev.png']));

        % Create RBG Image to display
        
        % Idunno why, but the mask image is transposed so

        % Open new Drawing Window, and Display Areas of Priority
        %windowCell{i,2} = figure;
        
        emphasizedImg = getWeights(meanImg);

        %emphasizedImg(mod(preferIndices, filterSize)+1, floor((preferIndices-1)./filterSize)+1, 2) = 255;
        %emphasizedImg(mod(deterIndices, filterSize)+1, floor((deterIndices-1)./filterSize)+1, 1) = 255;

        % Again transposes, does it switch Back, idk
        imwrite(uint8(emphasizedImg), fullfile(directoryPath, userPath, ['Weighted_Areas_Mean_' num2str(i-2) '.png']));
    end

    % Save Deviation Data
    save(fullfile(directoryPath, userPath,'UserStandardDev.mat'), 'userStandardDev');
end

    
if ~isfolder(fullfile(directoryPath, 'Average'))
    mkdir(fullfile(directoryPath, 'Average'));
end
for i = 1:nsk
    tAN = totalAverageNoises(:,:,i);
    tAN = 15/std2(tAN)*tAN;
    imwrite(uint8(double(baseImg)+tAN), fullfile(directoryPath, 'Average', ['Mean_' num2str(i-2) '_norm.png']));
    imwrite(uint8(double(baseImg)-tAN), fullfile(directoryPath, 'Average', ['Mean_' num2str(i-2) '_rev.png']));
    
    tImg = getWeights(tAN);
    imwrite(uint8(tImg), fullfile(directoryPath, 'Average', ['Weighted_Areas_Mean_' num2str(i-2) '.png']));
end

save(fullfile(directoryPath, 'Average', 'demographics'), 'allDems');

function eI = getWeights(mI)
    global baseImg maleMask
    eI = repmat(baseImg,1,1,3);
    filtmeanImg = imgaussfilt(mI.*maleMask,10);
    miiqr = iqr(filtmeanImg(filtmeanImg~=0));
    mimean = mean(filtmeanImg(filtmeanImg~=0));
    outlierfactor = 1.5;

    eI(:,:,2) = eI(:,:,2)+uint8(double(255-eI(:,:,2)).*(filtmeanImg>(mimean+miiqr*outlierfactor)));
    eI(:,:,1) = eI(:,:,1)+uint8(double(255-eI(:,:,1)).*(filtmeanImg<(mimean-miiqr*outlierfactor)));
end