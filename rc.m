clear all;  close all;
Screen('Preference', 'SkipSyncTests', 1);
rng('Shuffle');
KbName('UnifyKeyNames');
init = upper(input('Initials: ', 's'));
[w, rect] = Screen('OpenWindow', 0, []);

trait = 'Trustworthy'; %Trait of skewed ensemble
reversed = 0; %Trait or anti-trait?
ensembledat = readcell(fullfile('CFD Version 2.0.3', 'CFD 2.0.3 Norming Data and Codebook.xlsx'), 'Sheet', 'CFD 2.0.3 Norming Data'); %Read in ensemble excel
ensembledat = dat(6:end,:);
ensembledat = sortrows(dat, tid);

if reversed
    ensembledat = flip(ensembledat, 1);
end

tid = find(strcmp(ensembledat(5,:), trait));


baseImg = rgb2gray(imread('male.jpg'));
trials = 3; %100
subjects = 2; %4
ww = rect(3); wh = rect(4);
siz = size(baseImg, 1);
res = zeros(siz,siz,trials); %what they choose
inv = zeros(siz,siz,trials); %what they dont

RestrictKeysForKbCheck([KbName('f'), KbName('j')]); %Restrict to f and j keys

for t = 1:trials
    n = generate_noise(siz);
    ims = (cat(3, min(uint8(double(baseImg) + n),255), min(uint8(double(baseImg) - n),255)));
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
ci = uint8(mean(res,3)); %final CI
aci = uint8(mean(inv,3)); %final anti CI
Screen('CloseAll');
if ~isfolder('Ensemble RC Results') mkdir('Ensemble RC Results'); end %saving
cd 'Ensemble RC Results';
if ~isfolder(init) mkdir(init); end %saving
cd(init);
imwrite(ci,gray(256),'CI.jpg');
imwrite(aci,gray(256),'antiCI.jpg');
cd ../..;
