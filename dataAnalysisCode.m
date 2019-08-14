%% PROGRAM RECORDS MEAN, STANDARD DEV, AREAS OF PRIORITY FOR EACH USER'S CHOICE OF TRUSTWORTHINESS GIVEN ENSEMBLE SKEW

%% Clear variables

clear all
close all

%% Declare Vairables

global baseImg maleMask

trials = 100; %# of trials (default)
baseImg = rgb2gray(imread('male.jpg')); %base image
filterSize = size(baseImg,1); %Size of base image
windowCell = cell(3,2); %graph windows shown
userStandardDev = zeros(3,1); %standard deviations of each user

%% Declare File and Photo Paths

directoryPath = 'Ensemble RC Results'; %Path to saved data
userDirectory = dir(fullfile(directoryPath, 'user_*')); %take all folders starting with user_

%% Find different Skew Indices

maleMask = imread('malemask.png'); %Read ellipse mask
maleMask = double(maleMask(:,:,1)/255); %take only 1 color channel and divide by 255

nsk = 2; %number of skew types

totalAverageNoises = zeros(filterSize,filterSize,nsk); %average of all noises over all users
allDems = cell(4); %Saved demographics for user

% Iterate through each User
for file=1:size(userDirectory,1)
    userPath = userDirectory(file).name; %get path to data

    % Fetch user Files
    load(fullfile(directoryPath,userPath,'noises.mat'));
    load(fullfile(directoryPath,userPath,'chosen.mat'));
    load(fullfile(directoryPath,userPath,'demographics.mat'));
    allDems(file,:) = demographics;

    trials = size(chosen, 2); %Set trial size to file
    nsk = size(chosen, 1); %Set nsk to file
    noisesm = zeros(nsk, trials, filterSize, filterSize); %Create matrix of all noises

    % Transfer Noise Data, by Row (The Noise's Skew Index)
    for i = 1:nsk
        for j = 1:trials
            noisesm(i,j,:,:) = noises{i,j}; %essentially cell2mat for 4d
        end
    end

    %Define List of Noise Arrays and their Mean
    userImgSet = chosen.*noisesm; %list of chosen noises for user
    meanIms = mean(userImgSet,2); %mean of chosen noises by skew

    % Save the Noise Mean
    save(fullfile(directoryPath,userPath,'meanIms.mat'), 'meanIms'); %save the mean images
    for i = 1:nsk
        % Open new Drawing Window, and Display Mean Image
        %windowCell{i,1} = figure;
        meanImg = squeeze(meanIms(i,1,:,:)); %take mean image of skew
        stdev = std2(meanImg); %Get standard deviation of noise
        userStandardDev(i) = mean(stdev); %save standard deviation of noise
        totalAverageNoises(:,:,i) = totalAverageNoises(:,:,i)+meanImg; %add user average to all average
        meanImg = 15/stdev*meanImg; %scale noise such that stdev = 15
        %Save images with positive and negative noise
        imwrite(uint8(double(baseImg)+meanImg), fullfile(directoryPath, userPath, ['Mean_' num2str(i-2) '_norm.png']));
        imwrite(uint8(double(baseImg)-meanImg), fullfile(directoryPath, userPath, ['Mean_' num2str(i-2) '_rev.png']));

        % Create RBG Image to save
        emphasizedImg = getWeights(meanImg);

        %emphasizedImg(mod(preferIndices, filterSize)+1, floor((preferIndices-1)./filterSize)+1, 2) = 255;
        %emphasizedImg(mod(deterIndices, filterSize)+1, floor((deterIndices-1)./filterSize)+1, 1) = 255;

        % Save weighted images
        imwrite(uint8(emphasizedImg), fullfile(directoryPath, userPath, ['Weighted_Areas_Mean_' num2str(i-2) '.png']));
    end

    % Save stdev Data
    save(fullfile(directoryPath, userPath,'UserStandardDev.mat'), 'userStandardDev');
end

    
if ~isfolder(fullfile(directoryPath, 'Average'))
    mkdir(fullfile(directoryPath, 'Average'));
end
for i = 1:nsk
    tAN = totalAverageNoises(:,:,i); %get average over all users
    tAN = 15/std2(tAN)*tAN; %scale stdev to 15
    %save positive and negative average images
    imwrite(uint8(double(baseImg)+tAN), fullfile(directoryPath, 'Average', ['Mean_' num2str(i-2) '_norm.png']));
    imwrite(uint8(double(baseImg)-tAN), fullfile(directoryPath, 'Average', ['Mean_' num2str(i-2) '_rev.png']));
    
    %Get outlier  areas and save rgb image
    tImg = getWeights(tAN);
    imwrite(uint8(tImg), fullfile(directoryPath, 'Average', ['Weighted_Areas_Mean_' num2str(i-2) '.png']));
end

%save demographic data for all users
save(fullfile(directoryPath, 'Average', 'demographics'), 'allDems');

function eI = getWeights(mI) %Get outlier areas in image
    global baseImg maleMask
    eI = repmat(baseImg,1,1,3); %3 channel image
    filtmeanImg = imgaussfilt(mI.*maleMask,10); %gaussian filter image to lower noisiness
    miiqr = iqr(filtmeanImg(filtmeanImg~=0)); %iqr of nonzero elements of filtered mean image
    mimean = mean(filtmeanImg(filtmeanImg~=0)); %mean of nonzero elements of filtered mean image
    outlierfactor = 1.5; %number of IQR from mean needed to be outlier

    eI(:,:,2) = eI(:,:,2)+uint8(double(255-eI(:,:,2)).*(filtmeanImg>(mimean+miiqr*outlierfactor))); %second channel set to high outliers (green)
    eI(:,:,1) = eI(:,:,1)+uint8(double(255-eI(:,:,1)).*(filtmeanImg<(mimean-miiqr*outlierfactor))); %first channel set to low outliers (red)
end