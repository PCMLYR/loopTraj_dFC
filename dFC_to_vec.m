function dFC_vec = dFC_to_vec(dFC)
    N = size(dFC,1); T = size(dFC,3);
%     dFC_vec = zeros((N+1)*N/2, T);
    dFC_vec = zeros(N, T);
    for i = 1:T
        FC = dFC(:,:,i);
%         mask = triu(ones(N));
        mask = eye(N);
        dFC_vec(:,i) = FC(mask==1);
    end
end