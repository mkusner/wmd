function [] = compute_rwmd(load_file,save_file)


    addpath('emd')

    load(load_file);

    n  = length(BOW_X);

    RWMD_D = zeros(n,n);

    parfor i = 1:n
        Ei = zeros(1,n);
        for j = (i+1):n
            if isempty(BOW_X{i}) || isempty(BOW_X{j})
                Ei(j) = Inf;
            else
                x1 = BOW_X{i}./sum(BOW_X{i});
                x2 = BOW_X{j}./sum(BOW_X{j});

                DD = distance(X{i},X{j}); % (ni,nj)
                m1 = sqrt(max(min(DD,[],1),0)); % (1,nj)
                m2 = sqrt(max(min(DD,[],2),0)); % (ni,1)
                dist1 = m1*x2';
                dist2 = m2'*x1';

                Ei(j) = max(dist1,dist2);
                

            end
        end
        RWMD_D(i,:) = Ei;
    end

    RWMD_D = RWMD_D + RWMD_D'; % because only upper triangular part is computed (similar to WMD)

    save(save_file,'RMD_D');


end

