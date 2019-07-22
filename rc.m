Screen('Preference', 'SkipSyncTests', 1);
rng('Shuffle');
KbName('UnifyKeyNames');
init = upper(input('Initials: ', 's'));
[window, rect] = Screen('OpenWindow', 0, []);
ww = rect(3); wh = rect(4);

num = 6; % # in ensemble

baseImg = rgb2gray(imread('male.jpg'));
subjects = 2; %4
trials = 3; %100

if isfile('ensembledat.mat')
    load('ensembledat.mat');
else
    gen_ensembledat;
end

ensembles = {};
ensembledata = {};

for i = -1:1
    for j = 1:trials
        [ensembles{j+(i+1)*trials},ensembledata{j+(i+1)*trials}] = create_ensemble(ensembledat, num, i);
    end
end

tid = cell(3*trials, num);
for i = 1:3*trials
    for j = 1:num
        tid{i,j} = Screen('MakeTexture', window, ensembles{i}{j});
    end
end

siz = size(baseImg, 1);
res = zeros(siz,siz,trials); %what they choose
inv = zeros(siz,siz,trials); %what they dont

RestrictKeysForKbCheck([KbName('f'), KbName('j')]); %Restrict to f and j keys

noises = {};

rows = 2;  cols = 3;
w = ww/7;
h = w*1718/2444;
[xC,yC] = meshgrid(linspace(ww/3,2*ww/3,cols),linspace(wh/3,2*wh/3,rows));
coordinates = [xC(:)'-(w/2);yC(:)'-(h/2);xC(:)'+(w/2);yC(:)'+(h/2)];

ens_time = 1; %time ensemble is shown
delay1 = 0.5; %time btwn ensemble and rc
delay2 = 3; %time of crossheir

for t = 1:3*trials
    Screen('FillArc', window, 0,[[ww/2;wh/2]-wh/100;[ww/2;wh/2]+wh/100],0,360);
    Screen('Flip', window);
    WaitSecs(delay2);
    curEnsemble = cell2mat(tid(t,:)');
    Screen('FillArc', window, 0,[[ww/2;wh/2]-wh/100;[ww/2;wh/2]+wh/100],0,360);
    Screen('DrawTextures', window, curEnsemble, [], coordinates); % display in grid
    Screen('Flip', window);
    WaitSecs(ens_time);
    Screen('Flip', window);
    WaitSecs(delay1);
    
    noises{t} = generate_noise(siz);
    ims = (cat(3, min(uint8(double(baseImg) + noises{t}),255), min(uint8(double(baseImg) - noises{t}),255)));
    ims = ims(:,:,randperm(2));
    Screen('DrawTexture', window, Screen('MakeTexture',window,ims(:,:,1)), [], [[ww/4;wh/2]-siz/2;[ww/4;wh/2]+siz/2]);
    Screen('DrawTexture', window, Screen('MakeTexture',window,ims(:,:,2)), [], [[3*ww/4;wh/2]-siz/2;[3*ww/4;wh/2]+siz/2]);
    Screen('Flip',window);

    [~, keyCode] = KbStrokeWait();

    if keyCode(KbName('f')) == 1
        res(:,:,t) = ims(:,:,1);
        inv(:,:,t) = ims(:,:,2);
    elseif keyCode(KbName('j')) == 1
        res(:,:,t) = ims(:,:,2);
        inv(:,:,t) = ims(:,:,1);
    end
    Screen('Flip',window);
    
end

Screen('CloseAll');
if ~isfolder('Ensemble RC Results') mkdir('Ensemble RC Results'); end %saving
cd 'Ensemble RC Results';
if ~isfolder(init) mkdir(init); end %saving
cd(init);
save('noises.mat', 'noises');
cd ../..;
