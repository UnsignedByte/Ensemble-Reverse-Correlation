%% Update File

%{

clear all;
close all;


% Initialize the File TrialRecords
dataFilePath = '/Users/benfalken/Desktop/TrialRecords';
userData = dir([dataFilePath '*.mat']);

% Define Individual File Dimensions
filterSize = 512; % Change as needed
trialNum = 100;
numEnsembleFaces = 1; % DISPLAY ENSEMBLE INFO AS A SCALAR

sumChosen = floor(255*rand(trialNum, filterSize, filterSize));
sumRejected = floor(255*rand(trialNum, filterSize, filterSize));

sumAntiChosen = floor(255*rand(trialNum, filterSize, filterSize));
sumAntiRejected = floor(255*rand(trialNum, filterSize, filterSize));

racialComposition = ones(4, trialNum, numEnsembleFaces);

for index=1:4
    trialData = {sumChosen, sumRejected, sumAntiChosen, sumAntiRejected, racialComposition}; %racialComposition};
    
    save([dataFilePath '/' num2str(index) '.mat'], 'trialData', '-v7.3');
end

disp('Data saved.');
%}

%% Program Parameters

% Clear all variables
clear all;
close all;

% Initialize the File TrialRecords
dataFilePath = '/Users/benfalken/Desktop/TrialRecords/';
userDataFolder = dir([dataFilePath '*.mat']);

dataFolderLen = length(userDataFolder);

% Define Individual File Dimensions
filterSize = 512;
trialNum = 100;
numEnsembleFaces = 6;

% Create array containing all images for user's and all trials
userAverages = zeros(4, trialNum*dataFolderLen, filterSize, filterSize);

% Create array containing all ensembles over all trials
ensembleAverages = zeros(size(userAverages,1), trialNum*dataFolderLen);

% Create mean array for the four image averages
userMeans = zeros(size(userAverages,1), filterSize, filterSize);
ensembleMeans = zeros(size(userAverages,1), 1);

% Figure Cell to load multiple Images
figureCell = cell(size(userAverages,1)+1);

%% Iterate Through File

% Iterate through File TrialRecords

for userFile=1:dataFolderLen
    
    % Get File from name
    userName = userDataFolder(userFile).name;
    disp(userName);
    userTrialData = matfile([dataFilePath userName]); 
    
    % Get and analyze data
    cellData = readData(userTrialData.trialData, trialNum, dataFolderLen, filterSize, userAverages, ensembleAverages); % Rename later
    % Get data from function
    userAverages = cell2mat(cellData(1));
    ensembleAverages = cell2mat(cellData(2));
    
end

% After data recieved, go through each image type, find average and
% correlate
for imageClass=1:size(userAverages,1)
    
    % Find each set of images for trustworthy, anti-trustworthy etc.
    searchAverages = reshape(userAverages(imageClass,:,:,:), trialNum*dataFolderLen, filterSize, filterSize);
    
    % Find where the list is cut off (the whole column of images is not
    % used)
    for index=1:trialNum*dataFolderLen
        if searchAverages(index,:,:) == zeros(1, filterSize, filterSize)
            classColumnLength = index-1;
            disp(classColumnLength);
            break
        end
    end
    
    disp(classColumnLength);
    
    meanImage = mean(searchAverages(:));
    
    % PRESENTABLE CODE ENDS HERE
end

figureCell(end) = figure;

binNames = {'Trust', 'Untrust', 'Anti-Trust', 'Anti-Untrust'};

barh(ensembleMeans)
set(gca,'yticklabel',binNames)

% Next Steps: Create an elliptically shaped mask around both objects and
% find Cronbach's r

% Return racial index for each averaged reaction

%% Read File Data

function cellData = readData(trialData, trialNum, dataFolderLen, filterSize, userAverages, ensembleAverages)

    % Filled index helps to append in the right places - it increases when
    % more elements added
    filledIndex = 0;
    disp(ensembleAverages(:,1:3));
 
    for chosenColumn=1:4
        
        % NOTE THAT EACH IMAGE CELL WILL BE OF VARYING LENGTH
        
        %Fetch all data from the user file
        
        imageColumn = cell2mat(trialData(1, chosenColumn,:,:,:)); %The images are in columns 1-4
        imageColumn = reshape(imageColumn(:,:,:), 1, size(imageColumn,1), filterSize, filterSize, 1);
        
        ensembleColumn = cell2mat(trialData(1, 5)); % The ensemble values are in column 5
        ensembleColumn = ensembleColumn(chosenColumn,:);
        disp(ensembleColumn(1:5));
        
        userAverages(chosenColumn, filledIndex+1:filledIndex+size(imageColumn,2),:,:) = imageColumn;
        disp(size(ensembleAverages));
        ensembleAverages(chosenColumn, filledIndex+1:filledIndex+size(imageColumn,2)) = ensembleColumn;
        
        %disp(ensembleAverages(chosenColumn, filledIndex+1:filledIndex+size(imageColumn,2)));
        
        filledIndex = filledIndex + size(imageColumn,2);
        %disp(chosenColumn);
        %disp(ensembleAverages(:,1));
        %disp(userAverages(1,1,:,:));
    end

disp('Done Looping');  

disp(ensembleAverages(:,1:3));

userAverages = reshape(userAverages, 4, trialNum*dataFolderLen, filterSize, filterSize);
ensembleAverages = reshape(ensembleAverages, 4, trialNum*dataFolderLen, 1);

%disp(userAverages(:,1,:,:));
disp(ensembleAverages(:,1:3));

% prepare to return data
cellData = {userAverages, ensembleAverages};

end