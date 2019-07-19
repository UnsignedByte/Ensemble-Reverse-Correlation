clear all;  close all;
Screen('Preference', 'SkipSyncTests', 1);
rng('Shuffle');
KbName('UnifyKeyNames');
[w, rect] = Screen('OpenWindow', 0, []);

baseImg = rgb2gray(imread('male.jpg'));
trials = 3; %100
subjects = 2; %4
ww = rect(3); wh = rect(4); 
siz = size(baseImg, 1);
results = zeros(siz,siz,subjects); %each subject's avg
inverses = zeros(siz,siz,subjects); %avgs of unselected
for s = 1:subjects
    res = zeros(siz,siz,trials); %what they choose
    inv = zeros(siz,siz,trials); %what they dont
    for t = 1:trials
        n = round(generate_noise(siz));
        le = min(max(double(baseImg) + n,0),255); %0-255
        ri = min(max(double(baseImg) - n,0),255);
        Screen('DrawTexture', w, Screen('MakeTexture',w,le), [], [[ww/4;wh/2]-siz/2;[ww/4;wh/2]+siz/2]);
        Screen('DrawTexture', w, Screen('MakeTexture',w,ri), [], [[3*ww/4;wh/2]-siz/2;[3*ww/4;wh/2]+siz/2]);
        Screen('Flip',w);
        while 1 %wait till key release
            keyIsDown=KbCheck(-1);
            if ~keyIsDown break; end 
        end
        while 1 % f = left, j = right
            [keyIsDown,seconds,keycode]=KbCheck(-1);
            if strcmp(KbName(keycode),'f')
                res(:,:,t) = le;
                inv(:,:,t) = ri;
                break;
            end
            if strcmp(KbName(keycode),'j')
                res(:,:,t) = ri;
                inv(:,:,t) = le;
                break;
            end 
        end
        Screen('Flip',w);
        WaitSecs(0.05);
    end
    results(:,:,s) = mean(res,3);
    inverses(:,:,s) = mean(inv,3);
end
ci = mean(results,3); %final CI
aci = mean(inverses,3); %final anti CI
Screen('CloseAll');
if ~isfolder('Ensemble RC Results') mkdir('Ensemble RC Results'); end %saving 
cd 'Ensemble RC Results';
imwrite(ci,gray(256),'CI.jpg');
imwrite(aci,gray(256),'antiCI.jpg');
cd ../;

function noise = generate_noise(size)
    noise = zeros(size);
    for c = 1:5
        cycles = 2^c;
        noise = noise + subnoise();
    end
    noise = 255*noise / 5;
    function snoise = subnoise()
        snoise = nan(size);
        for i = 0:cycles-1
            for j = 0:cycles-1
                snoise(i*size/cycles+1:(i+1)*size/cycles,j*size/cycles+1:(j+1)*size/cycles) = subsubnoise();
            end
        end
        function ssnoise = subsubnoise()
            [X, Y] = ndgrid(1:size/cycles);
            ssnoise = zeros(size/cycles);
            for jj = 1:2
                for ii = 1:6
                    theta = (ii-1)*30;
                    ssnoise = ssnoise + sin((X*cosd(theta)-Y*sind(theta))*(4*pi*cycles/size) ... %generate sin wave
                        -pi*(jj-1)/2) ...%shift sin wave
                        .*(rand*2-1); %set contrast
                end
            end
            ssnoise = ssnoise / 12;
        end
    end
end


