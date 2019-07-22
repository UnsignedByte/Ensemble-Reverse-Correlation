Screen('Preference', 'SkipSyncTests', 1);
rng('Shuffle');
KbName('UnifyKeyNames');
init = upper(input('Initials: ', 's'));
[window, rect] = Screen('OpenWindow', 0, []);
ww = rect(3); wh = rect(4);

num = 6; % # in ensemble
ensembledat = readcell(fullfile('CFD Version 2.0.3', 'CFD 2.0.3 Norming Data and Codebook.xlsx'), 'Sheet', 'CFD 2.0.3 Norming Data'); %Read in ensemble excel
ensembledat = ensembledat(6:end,:);
ensembledat = ensembledat(strcmp(ensembledat(:,3), 'M'),:); %Get only males
ensembledat = {ensembledat(strcmp(ensembledat(:,2), 'B'),:),ensembledat(strcmp(ensembledat(:,2), 'W'),:)};

for i = 1:2
    fnames = strcat('CFD-', ensembledat{i}(:,1), '-*-N.jpg');
    ensembledat{i}(:,1) = fullfile('CFD Version 2.0.3', 'CFD 2.0.3 Images', ensembledat{i}(:,1));
    for j = 1:size(ensembledat{i},1)
        imfile = dir(fullfile(ensembledat{i}{j}, fnames{j}));
        ensembledat{i}{j} = imread(fullfile(ensembledat{i}{j},imfile(1).name));
    end
end

baseImg = rgb2gray(imread('male.jpg'));
subjects = 2; %4
trials = 3; %100

ensembles = {};
ensembledata = {};

for i = -1:1
    for j = 1:trials
        [ensembles{j+(i+1)*trials},ensembledata{j+(i+1)*trials}] = create_ensemble(ensembledat, num, i);
    end
end

tid = zeros(3,num);
for i = 1:3
    for j = 1:num
        tid(i,j) = Screen('MakeTexture', window, ensembles{i,j});
    end
end

siz = size(baseImg, 1);
res = zeros(siz,siz,trials); %what they choose
inv = zeros(siz,siz,trials); %what they dont

RestrictKeysForKbCheck([KbName('f'), KbName('j')]); %Restrict to f and j keys

noises = {};
order = horzcat(ones(1,trials),2*ones(1,trials), 3*ones(1,trials));
order = order(randperm(3*trails));

rows = 2;  cols = 3;
w = ww/5;
h = w*1718/2444;
[xC,yC] = meshgrid(linspace(ww/4,3*ww/4,cols),linspace(wh/4,3*wh/4,rows));
coordinates = [xC(:)'-(w/2);yC(:)'-(h/2);xC(:)'+(w/2);yC(:)'+(h/2)];

for t = 1:3*trials
    curEnsemble = tid(order(t),:);
    Screen('DrawTextures', window, curEnsemble, [], coordinates); % display in grid
    Screen('Flip', window);
    WaitSecs(1);
    Screen('Flip', window);
    
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
    WaitSecs(0.05);
end

Screen('CloseAll');
if ~isfolder('Ensemble RC Results') mkdir('Ensemble RC Results'); end %saving
cd 'Ensemble RC Results';
if ~isfolder(init) mkdir(init); end %saving
cd(init);
save('noises.mat', 'noises');
cd ../..;
