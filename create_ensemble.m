function [ensemble,data] = create_ensemble(ensembledat, num, skew) %create num ensembles with skew

    wcols = [1 4 5]; %which columns of data to save

    if skew == -1 %skewed towards second element
        ensemble = ensembledat{1}(randperm(size(ensembledat{1},1),num-1), wcols); %1 of first type
        ensemble(num,:) = ensembledat{2}(randi(size(ensembledat{2},1)), wcols); %5 of second type
    elseif skew == 0 %unskwed
        ensemble = ensembledat{1}(randperm(size(ensembledat{1},1),num/2), wcols); %half first type
        ensemble(end+1:num,:) = ensembledat{2}(randperm(size(ensembledat{2},1),num/2), wcols); %half second type
    elseif skew == 1 %skewed towards first element
        ensemble = ensembledat{2}(randperm(size(ensembledat{2},1),num-1), wcols); %1 of second type
        ensemble(num,:) = ensembledat{1}(randi(size(ensembledat{1},1)), wcols); %5 of first type
    end

    ensemble = ensemble(randperm(num),:); %randomly sort ensembles
    data = ensemble(:, 2:end)'; %get classification data of ensemble images
    ensemble = cell2mat(ensemble(:,1)'); %convert to matrix
end
