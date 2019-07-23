%% Setup Screen Parameters

Screen('Preference', 'SkipSyncTests', 1);
rng('Shuffle');
KbName('UnifyKeyNames');
init = ['user_' upper(input('Initials: ', 's'))];
[window, rect] = Screen('OpenWindow', 0, []);
HideCursor();
ww = rect(3); wh = rect(4);
Screen('BlendFunction', window,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%% Define Trial Variables

num = 6; % # in ensemble

baseImg = rgb2gray(imread('male.jpg'));


trials = 30; %100

siz = size(baseImg, 1);

%% Check for and Load Ensemble Data

if isfile('ensembledat.mat')
    load('ensembledat.mat');
else
    gen_ensembledat;
end

ensembles = cell(3, trials);
ensembledata = cell(3, trials);

noises = cell(trials,1);

%% Generate Noise

for i = 1:trials
    DrawFormattedText(window, ['Generating Noise...\n' num2str(floor(i/trials*100)) '%'], 'center', 'center');
    Screen('Flip', window);
    noises{i} = generate_noise(siz);
end
noises = repmat(noises, 1,3)';
for i = 1:3
    noises(i,:) = noises(i, randperm(trials));
end

for i = -1:1
    for j = 1:trials
        [ensembles{i+2,j},ensembledata{i+2,j}] = create_ensemble(ensembledat, num, i);
    end
end

%% Generate Textures

ord = randperm(3*trials);

w = ww/4;
h = w*1718/2444;

mask = imread('ovalmask.jpg');
mask = imresize(mask, size(ensembles{1,1}{1}(:,:,1)));
mask = mask(:,:,1);

tid = cell(3*trials, num);
for i = 1:3*trials
    for j = 1:num
        DrawFormattedText(window, ['Making Textures...\n' num2str(floor(((i-1)*num+j)/trials/num/3*100)) '%'], 'center', 'center');
        Screen('Flip', window);
        a = ensembles{ceil(ord(i)/trials),mod(ord(i),trials)+1}{j};
        a(:,:,4) = mask;
        tid{i,j} = Screen('MakeTexture', window, a);
    end
end
res = zeros(siz,siz,trials); %what they choose
inv = zeros(siz,siz,trials); %what they dont

RestrictKeysForKbCheck([KbName('f'), KbName('j')]); %Restrict to f and j keys


radius = wh/3;
th = linspace(360/num, 360, num);
x_circle = ww/2+cosd(th)*radius;
y_circle = wh/2+sind(th)*radius;

coordinates = [x_circle(:)'-(w/2);y_circle(:)'-(h/2);x_circle(:)'+(w/2);y_circle(:)'+(h/2)];

ens_time = 1; %time ensemble is shown
delay1 = 0.5; %time btwn ensemble and rc
delay2 = 1; %time of crosshair
delay3 = 3;

chosen = ones(3, trials); %List of chosen thingse

cross = [-ww/100 ww/100 0 0;0 0 -ww/100 ww/100];
crossW = wh/500;

%% Instructions

showBaseImg = Screen('MakeTexture', window, baseImg);

Screen('TextFont',window, 'Arial');
Screen('TextSize',window, 30);
Screen('TextStyle', window, 0);

DrawFormattedText(window, ...
    'You will have 300 trials to complete.', ...
    'center',300);
Screen('Flip', window);

WaitSecs(delay3);

DrawFormattedText(window,...
    'You will be shown various images based off of this picture.', ...
    'center',300);
Screen('DrawTexture', window, showBaseImg, [], [(ww-siz)/2, (wh-siz)/2, (ww+siz)/2, (wh+siz)/2]);
Screen('Flip', window);

WaitSecs(delay3);

DrawFormattedText(window,...
    'Choose which Image appears more trustworthy, out of the 2 you are shown.', ...
    'center',300);

Screen('Flip', window);

WaitSecs(delay3);

DrawFormattedText(window, ...
    'Click either f or j to begin.\n\n Click f for left image, and j for right image.', ...
    'center',300);

Screen('Flip', window);

WaitSecs(delay3);

%% Run Trials

for t = 1:3*trials
    Screen('DrawLines', window, cross, crossW, 0, [ww/2 wh/2], 2);
    Screen('Flip', window);
    WaitSecs(delay2);
    curEnsemble = cell2mat(tid(t,:)');

    curNoise = noises{ceil(ord(t)/trials),mod(ord(t),trials)+1};
    Screen('DrawLines', window, cross, crossW, 0, [ww/2 wh/2], 2);

    Screen('DrawTextures', window, curEnsemble, [], coordinates); % display in grid
    Screen('Flip', window);
    WaitSecs(ens_time);
    Screen('Flip', window);
    WaitSecs(delay1);

    ims = (cat(3, min(uint8(double(baseImg) + curNoise),255), min(uint8(double(baseImg) - curNoise),255)));
    imsord = randperm(2);
    ims = ims(:,:,imsord);
    Screen('DrawTexture', window, Screen('MakeTexture',window,ims(:,:,1)), [], [[ww/4;wh/2]-siz/2;[ww/4;wh/2]+siz/2]);
    Screen('DrawTexture', window, Screen('MakeTexture',window,ims(:,:,2)), [], [[3*ww/4;wh/2]-siz/2;[3*ww/4;wh/2]+siz/2]);
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
