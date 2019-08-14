%% Setup Screen Parameters

Screen('Preference', 'SkipSyncTests', 1);
rng('Shuffle');
KbName('UnifyKeyNames');
init = ['user_' upper(input('Initials: ', 's'))];
[window, rect] = Screen('OpenWindow', 0, []);
HideCursor();
ww = rect(3); wh = rect(4);
Screen('BlendFunction', window,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
RestrictKeysForKbCheck([]);

%% Define Trial Variables

num = 6; % # in ensemble

baseImg = rgb2gray(imread('male.jpg')); %base image

trials = 300; %300 trials per skew

siz = size(baseImg, 1); %size of base image (512)
sk = [-1 0]; %which skews included
nsk = size(sk,2); %number of types of skews

%% Check for and Load Ensemble Data

if isfile('ensembledat.mat')
    load('ensembledat.mat'); %load pregenerated ensembles
else
    gen_ensembledat; %if nonexistent, generate the ensembles
end

ensembles = cell(nsk, trials); %cell of all ensemble images
ensembledata = cell(nsk, trials); %cell of information about ensemble members

%% Generate Noise

if isfile('noises.mat')
    load('noises.mat'); %load pregenerated noise
    noises = noises(1:trials,:); %cut to fit trials
else
    generate_noises(trials, siz); %generate noise if nonexistent
end

noises = repmat(noises, 1,nsk)'; %replicate noises across skews
for i = 1:nsk
    noises(i,:) = noises(i, randperm(trials)); %shuffle noises per skew
    for j = 1:trials
        %generate random ensemble of 6 images from ensembledat by skew
        [ensembles{i,j},ensembledata{i,j}] = create_ensemble(ensembledat, num, sk(i));
    end
end

%% Generate Textures

ord = randperm(nsk*trials); %random order of all trials

w = ww/4; %width of ensemble image
h = w*1718/2444; %height of ensemble image

mask = imread('ovalmask.jpg'); %mask for ensemble image
mask = imresize(mask, size(ensembledat{1}{1,2}(:,:,1))); %resize to ensemble image size
mask = mask(:,:,1); %take one channel


siz1 = size(ensembledat{1},1); %number of first type of image (black males)
siz2 = size(ensembledat{2},1); %number of second type of image (white males)
for i = 1:siz1+siz2
    DrawFormattedText(window, ['Making Textures...\n' num2str(floor(i/(siz1+siz2)*100)) '%'], 'center', 'center');
    Screen('Flip', window);
    if i > siz1 %if in second section
        a = ensembledat{2}{i-siz1, 2}; %get image
        a(:,:,4) = mask; %mask image
        ensembledat{2}{i-siz1, 2} = Screen('MakeTexture', window, a); %save texture id
    else %image in first section
        a = ensembledat{1}{i, 2}; %get image
        a(:,:,4) = mask; %mask image
        ensembledat{1}{i, 2} = Screen('MakeTexture', window, a); %save texture id
    end
end

radius = wh/3; %radius of ensemble circle
th = linspace(360/num, 360, num); %6 directions of images
x_circle = ww/2+cosd(th)*radius; %x positions of images
y_circle = wh/2+sind(th)*radius; %y positions of images

coordinates = [x_circle(:)'-(w/2);y_circle(:)'-(h/2);x_circle(:)'+(w/2);y_circle(:)'+(h/2)]; %coordinates of images centered

ens_time = 0.5; %time ensemble is shown
delay1 = 0; %time btwn ensemble and rc
delay2 = 0.5; %time of crosshair

chosen = ones(nsk, trials); %List of chosen thingse

cross = [-ww/100 ww/100 0 0;0 0 -ww/100 ww/100]; %crosshair position
crossW = wh/500; %crosshair width

%% Instructions

showBaseImg = Screen('MakeTexture', window, baseImg); %make baseimage texture

%set font info
Screen('TextFont',window, 'Arial');
Screen('TextSize',window, 30);
Screen('TextStyle', window, 0);

DrawFormattedText(window, ...
    ['You will have ' num2str(trials*nsk) ' trials to complete.\nThe following trial will be an example with instructions.\nPress any key to continue.'], ...
    'center',300);
Screen('Flip', window);

KbStrokeWait(); %wait for press

curNoise = generate_noise(siz); %generate and show noise example
ims = (cat(3, min(uint8(double(baseImg) + curNoise),255), min(uint8(double(baseImg) - curNoise),255)));

DrawFormattedText(window,...
    'Focus on the crosshair in the center.', ...
    'center',300);
Screen('DrawLines', window, cross, crossW, 0, [ww/2 wh/2], 2);
Screen('Flip', window);
WaitSecs(delay2);

%% Run a example trial using the last ensemble

t = trials*nsk; 
curEnsemble = ensembles{ceil(ord(t)/trials),mod(ord(t),trials)+1} + ensembledat{1}{1,2};

curNoise = noises{ceil(ord(t)/trials),mod(ord(t),trials)+1};

Screen('DrawLines', window, cross, crossW, 0, [ww/2 wh/2], 2);
Screen('DrawTextures', window, curEnsemble, [], coordinates); % display in grid
Screen('Flip', window);
WaitSecs(ens_time);
Screen('Flip', window);
WaitSecs(delay1);

DrawFormattedText(window,...
    'Choose the image that appears more dominant out of the 2 shown.', ...
    'center',100);

Screen('DrawTexture', window, Screen('MakeTexture',window,ims(:,:,1)), [], [[ww/3;wh/2]-wh/6;[ww/3;wh/2]+wh/6]);
Screen('DrawTexture', window, Screen('MakeTexture',window,ims(:,:,2)), [], [[2*ww/3;wh/2]-wh/6;[2*ww/3;wh/2]+wh/6]);

DrawFormattedText(window, ...
    'Click either f or j to begin.\n Click f for left image, and j for right image.', ...
    'center',wh-100);

Screen('Flip', window);

%% Run Trials
RestrictKeysForKbCheck([KbName('f'), KbName('j')]); %Restrict to f and j keys
KbStrokeWait();

for t = 1:nsk*trials
    Screen('DrawLines', window, cross, crossW, 0, [ww/2 wh/2], 2); %draw cross
    Screen('Flip', window, 0, 1);
    WaitSecs(delay2);
    %get current ensemble texture ids
    curEnsemble = ensembles{ceil(ord(t)/trials),mod(ord(t),trials)+1} + ensembledat{1}{1,2};

    curNoise = noises{ceil(ord(t)/trials),mod(ord(t),trials)+1}; %get current noise

    Screen('DrawTextures', window, curEnsemble, [], coordinates); % display in circle
    Screen('Flip', window);
    WaitSecs(ens_time);
    Screen('Flip', window);
    WaitSecs(delay1);

    %get postive and negative noise images
    ims = (cat(3, min(uint8(double(baseImg) + curNoise),255), min(uint8(double(baseImg) - curNoise),255)));
    imsord = randperm(2); %randomize ordering of choice images (positive or negative noise)
    ims = ims(:,:,imsord); %sort ims according to order
    
    %Draw images side by side
    Screen('DrawTexture', window, Screen('MakeTexture',window,ims(:,:,1)), [], [[ww/3;wh/2]-wh/6;[ww/3;wh/2]+wh/6]);
    Screen('DrawTexture', window, Screen('MakeTexture',window,ims(:,:,2)), [], [[2*ww/3;wh/2]-wh/6;[2*ww/3;wh/2]+wh/6]);
    Screen('Flip',window);

    [~, keyCode] = KbStrokeWait(); %get resulting keypress

    if keyCode(KbName('f')) == 1 && imsord(1) == 2 %check if left chosen
        chosen(ceil(ord(t)/trials),mod(ord(t),trials)+1) = -1;
    elseif keyCode(KbName('j')) == 1 && imsord(1) == 1 %check if right chosen
        chosen(ceil(ord(t)/trials),mod(ord(t),trials)+1) = -1;
    end
    Screen('Flip',window);
end

%% End and Save Files

Screen('CloseAll'); %close screen
if ~isfolder('Ensemble RC Results') mkdir('Ensemble RC Results'); end
cd 'Ensemble RC Results';
if ~isfolder(init) mkdir(init); end %save files
cd(init);
save('noises.mat', 'noises');
save('ensembles.mat', 'ensembles');
save('ensembledata.mat', 'ensembledata');
save('chosen.mat', 'chosen');
cd ../..;
