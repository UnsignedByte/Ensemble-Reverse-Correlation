function noise = generate_noise(size) %size is width and height of generated noise
    %size must be divisible by 32
    noise = zeros(size); %create size x size matrix for noise
    for c = 1:5 %cycles 2 to 32
        cycles = 2^c;
        noise = noise + subnoise(); %add grid subnoise to noise
    end
    noise = 255*noise / 5; %average noise then  multiply by 255
    function snoise = subnoise() %generate grid of noises given cycles
        snoise = nan(size);
        for i = 0:cycles-1 %loop through the cycles^2 chunks in the image
            for j = 0:cycles-1
                snoise(i*size/cycles+1:(i+1)*size/cycles,j*size/cycles+1:(j+1)*size/cycles) = subsubnoise(); %set one square in grid to noise
            end
        end
        function ssnoise = subsubnoise()
            [X, Y] = ndgrid(1:size/cycles); %create one single chunk size noise
            ssnoise = zeros(size/cycles);
            for jj = 1:2 %loop through the 2 phases
                for ii = 1:6 %loop through the 6 orientations
                    theta = (ii-1)*30; %index to degrees
                    ssnoise = ssnoise + sin((X*cosd(theta)-Y*sind(theta))*(4*pi*cycles/size) ... %generate rotated 2d sin wave
                        -pi*(jj-1)/2) ...%shift sin wave by phase
                        .*(rand*2-1); %set contrast to random between -1 and 1
                end
            end
            ssnoise = ssnoise / 12; %average the 12 sinusoids
        end
    end
end