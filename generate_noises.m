function noises = generate_noises(n, k)
    noises = cell(n,1);
    for i = 1:n
        noises{i} = generate_noise(k);
    end
    save('noises.mat', 'noises');
end