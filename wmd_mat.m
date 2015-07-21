
addpath('emd')


load_file = 'twitter.mat';
save_file = 'wmd_d_twitter.mat';


load(load_file)
n = length(BOW_X);

WMD_D = zeros(n,n);

parfor i = 1:n
    Ei = zeros(1,n);
    for j = (i+1):n
        if isempty(BOW_X{i}) || isempty(BOW_X{j})
            Ei(j) = Inf; 
        else
        x1 = BOW_X{i}./sum(BOW_X{i});
        x2 = BOW_X{j}./sum(BOW_X{j});
        D = distance(X{i},X{j});
        D(D < 0) = 0;
        D = sqrt(D);
        [emd,flow]=emd_mex(x1,x2,D);
        Ei(j) = emd;
        end
    end
    WMD_D(i,:) = Ei;
end

save(save_file,'WMD_D')
