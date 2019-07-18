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