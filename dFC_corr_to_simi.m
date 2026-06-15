function new_dFC = dFC_corr_to_simi(dFC)
    N = size(dFC,1); T = size(dFC,3);
    new_dFC = zeros(N,N,T);
    for i = 1:T
        d = sqrt(diag(dFC(:,:,i)));
        new_dFC(:,:,i) = dFC(:,:,i) ./ (d*d');
    end
end