Screen('Preference', 'SkipSyncTests', 1);
rng('Shuffle');
KbName('UnifyKeyNames');
init = upper(input('Initials: ', 's'));
[w, rect] = Screen('OpenWindow', 0, []);
ww = rect(3); wh = rect(4);


num = 6; % # in ensemble
trait = 'Trustworthy'; %Trait of skewed ensemble
reversed = 0; %Trait or anti-trait? 0 = skew towards trait, -1 = skew opposite
ensembledat = readcell(fullfile('CFD Version 2.0.3', 'CFD 2.0.3 Norming Data and Codebook.xlsx'), 'Sheet', 'CFD 2.0.3 Norming Data'); %Read in ensemble excel
traitind = find(strcmp(ensembledat(5,:), trait));
ensembledat = ensembledat(6:end,:);
ensembledat = sortrows(ensembledat, traitind);

if reversed == 1
    ensembledat = flip(ensembledat, 1);
end

rows = 2;  cols = 3;
h = 1718/10;
w = 2444/10;
[xC,yC] = meshgrid(linspace(ww/4,3*ww/4,cols),linspace(wh/4,3*wh/4,rows));
coordinates = [xC(:)'-(w/2);yC(:)'-(h/2);xC(:)'+(w/2);yC(:)'+(h/2)];

baseImg = rgb2gray(imread('male.jpg'));
trials = 3; %100
subjects = 2; %4
siz = size(baseImg, 1);
res = zeros(siz,siz,trials); %what they choose
inv = zeros(siz,siz,trials); %what they dont

RestrictKeysForKbCheck([KbName('f'), KbName('j')]); %Restrict to f and j keys

noises = {};

for t = 1:trials
    noises{t} = generate_noise(siz);
    ims = (cat(3, min(uint8(double(baseImg) + noises{t}),255), min(uint8(double(baseImg) - noises{t}),255)));
    ims = ims(:,:,randperm(2));
    Screen('DrawTexture', w, Screen('MakeTexture',w,ims(:,:,1)), [], [[ww/4;wh/2]-siz/2;[ww/4;wh/2]+siz/2]);
    Screen('DrawTexture', w, Screen('MakeTexture',w,ims(:,:,2)), [], [[3*ww/4;wh/2]-siz/2;[3*ww/4;wh/2]+siz/2]);
    Screen('Flip',w);

    [~, keyCode] = KbStrokeWait();

    if keyCode(KbName('f')) == 1
        res(:,:,t) = ims(:,:,1);
        inv(:,:,t) = ims(:,:,2);
    elseif keyCode(KbName('j')) == 1
        res(:,:,t) = ims(:,:,2);
        inv(:,:,t) = ims(:,:,1);
    end
    Screen('Flip',w);
    WaitSecs(0.05);
end

Screen('CloseAll');
if ~isfolder('Ensemble RC Results') mkdir('Ensemble RC Results'); end %saving
cd 'Ensemble RC Results';
if ~isfolder(init) mkdir(init); end %saving
cd(init);
save('noises.mat', 'noises');
cd ../..;
