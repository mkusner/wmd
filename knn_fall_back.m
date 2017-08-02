function [err] = knn_fall_back(DE,ytr,yte,ks)

[n,ne] = size(DE);

[dists,ix] = mink(DE,ks(end));

pe = zeros(length(ks),ne);
for k = 1:length(ks)
    still_voting = logical(ones(1,ne));
    kcopy = ks(k);
    while true
        [vote,count] = mode(ytr(ix(1:kcopy,:)),1); % (k,ne)
        not_sure = (count < kcopy/2);
        if sum(still_voting .* not_sure) == 0
            pe(k,still_voting) = vote(still_voting);
            if sum(pe(k,:) == 0) ~= 0
                disp('there is an error');
                keyboard
            end
            break;
        end

        conf = still_voting - not_sure;
        conf = conf == 1;
        
        pe(k,conf) = vote(conf);

        still_voting = logical(still_voting .* not_sure);
        if kcopy == 1
            pe(k,still_voting) = vote(still_voting);
            if sum(pe(k,:) == 0) ~= 0
                disp('there is an error2');
                keyboard
            end
            break;
        end
        kcopy = kcopy - 2;
    end
end

err = ones(1,length(ks));
for k = 1:length(ks)
    err(k) = mean(pe(k,:) ~= yte);
end

end
