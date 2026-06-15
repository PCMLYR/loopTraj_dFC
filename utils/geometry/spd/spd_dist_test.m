function [d] = spd_dist_test(X, Y)
%SPD_DIST_TEST 此处显示有关此函数的摘要
%   此处显示详细说明
    [~,S1,~] = svd(X);
    [~,S2,~] = svd(Y);
    d = norm(S1-S2,'fro');
end

