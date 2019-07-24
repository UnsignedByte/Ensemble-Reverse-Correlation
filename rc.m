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

baseImg = rgb2gray(imread('male.jpg'));

trials = 300; %100

siz = size(baseImg, 1);
sk = [-1 0]; %which skews included
nsk = size(sk,2); %number of types of skews

%% Check for and Load Ensemble Data

if isfile('ensembledat.mat')
    load('ensembledat.mat');
else
    gen_ensembledat;
end

ensembles = cell(nsk, trials);
ensembledata = cell(nsk, trials);

%% Generate Noise

if isfile('noises.mat')
    load('noises.mat');
    noises = noises(1:trials,:);
else
    generate_noises(trials, siz);
end

noises = repmat(noises, 1,nsk)';
for i = 1:nsk
    noises(i,:) = noises(i, randperm(trials));
    for j = 1:trials
        [ensembles{i,j},ensembledata{i,j}] = create_ensemble(ensembledat, num, sk(i));
    end
end

%% Generate Textures

ord = randperm(nsk*trials);

w = ww/4;
h = w*1718/2444;

mask = imread('ovalmask.jpg');
mask = imresize(mask, size(ensembledat{1}{1,2}(:,:,1)));
mask = mask(:,:,1);


siz1 = size(ensembledat{1},1);
siz2 = size(ensembledat{2},1);
for i = 1:siz1+siz2
    DrawFormattedText(window, ['Making Textures...\n' num2str(floor(i/(siz1+siz2)*100)) '%'], 'center', 'center');
    Screen('Flip', window);
    if i > siz1
        a = ensembledat{2}{i-siz1, 2};
        a(:,:,4) = mask;
        ensembledat{2}{i-siz1, 2} = Screen('MakeTexture', window, a);
    else
        a = ensembledat{1}{i, 2};
        a(:,:,4) = mask;
        ensembledat{1}{i, 2} = Screen('MakeTexture', window, a);
    end
end

res = zeros(siz,siz,trials); %what they choose
inv = zeros(siz,siz,trials); %what they dont

radius = wh/3;
th = linspace(360/num, 360, num);
x_circle = ww/2+cosd(th)*radius;
y_circle = wh/2+sind(th)*radius;

coordinates = [x_circle(:)'-(w/2);y_circle(:)'-(h/2);x_circle(:)'+(w/2);y_circle(:)'+(h/2)];

ens_time = 0.5; %time ensemble is shown
delay1 = 0; %time btwn ensemble and rc
delay2 = 0.5; %time of crosshair

chosen = ones(nsk, trials); %List of chosen thingse

cross = [-ww/100 ww/100 0 0;0 0 -ww/100 ww/100];
crossW = wh/500;

%% Instructions

showBaseImg = Screen('MakeTexture', window, baseImg);

Screen('TextFont',window, 'Arial');
Screen('TextSize',window, 30);
Screen('TextStyle', window, 0);

DrawFormattedText(window, ...
    ['You will have ' num2str(trials*nsk) ' trials to complete.\nThe following trial will be an example with instructions.\nPress any key to continue.'], ...
    'center',300);
Screen('Flip', window);

KbStrokeWait();

curNoise = generate_noise(siz);
ims = (cat(3, min(uint8(double(baseImg) + curNoise),255), min(uint8(double(baseImg) - curNoise),255)));

DrawFormattedText(window,...
    'Focus on the crosshair in the center.', ...
    'center',300);
Screen('DrawLines', window, cross, crossW, 0, [ww/2 wh/2], 2);
Screen('Flip', window);
WaitSecs(delay2);
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
    Screen('DrawLines', window, cross, crossW, 0, [ww/2 wh/2], 2);
    Screen('Flip', window, 0, 1);
    WaitSecs(delay2);
    curEnsemble = ensembles{ceil(ord(t)/trials),mod(ord(t),trials)+1} + ensembledat{1}{1,2};

    curNoise = noises{ceil(ord(t)/trials),mod(ord(t),trials)+1};

    Screen('DrawTextures', window, curEnsemble, [], coordinates); % display in grid
    Screen('Flip', window);
    WaitSecs(ens_time);
    Screen('Flip', window);
    WaitSecs(delay1);

    ims = (cat(3, min(uint8(double(baseImg) + curNoise),255), min(uint8(double(baseImg) - curNoise),255)));
    imsord = randperm(2);
    ims = ims(:,:,imsord);
    %DrawFormattedText(window, num2str(t), 'center', 'center');
    Screen('DrawTexture', window, Screen('MakeTexture',window,ims(:,:,1)), [], [[ww/3;wh/2]-wh/6;[ww/3;wh/2]+wh/6]);
    Screen('DrawTexture', window, Screen('MakeTexture',window,ims(:,:,2)), [], [[2*ww/3;wh/2]-wh/6;[2*ww/3;wh/2]+wh/6]);
    Screen('Flip',window);

    [~, keyCode] = KbStrokeWait();

    if keyCode(KbName('f')) == 1 && imsord(1) == 2
        chosen(ceil(ord(t)/trials),mod(ord(t),trials)+1) = -1;
    elseif keyCode(KbName('j')) == 1 && imsord(1) == 1
        chosen(ceil(ord(t)/trials),mod(ord(t),trials)+1) = -1;
    end
    Screen('Flip',window);

end

%% End and Save Files

Screen('CloseAll');
if ~isfolder('Ensemble RC Results') mkdir('Ensemble RC Results'); end %saving
cd 'Ensemble RC Results';
if ~isfolder(init) mkdir(init); end %saving
cd(init);
save('noises.mat', 'noises');
save('ensembles.mat', 'ensembles');
save('ensembledata.mat', 'ensembledata');
save('chosen.mat', 'chosen');
cd ../..;
