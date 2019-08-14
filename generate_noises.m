function noises = generate_noises(n, k) %generate n noises with size k
    noises = cell(n,1); %cell for n noises
    for i = 1:n
        noises{i} = generate_noise(k); %generate noise
    end
    save('noises.mat', 'noises'); %save file
end