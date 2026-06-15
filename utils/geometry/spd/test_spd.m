A = [3 0 ; 0 1];
B = [8 2; 2 6];
tic
for i = 1:10000
    T = spd_log_map(A,B,'A');
    Tr = spd_log_map(B,A,'A');
    Ar = spd_exp_map(T,B,'A');
%     At = spd_geodesic(A,B,0.1,'A');

%     dA = spd_dist(A,B,'A');
    dL = spd_dist(A,B,'L');
%     dK = spd_dist(A,B,'K');
end
toc

As{1} = A;
As{2} = B;
% spd_mean(As, 0.1, 'K')
% spd_geodesic(A,B,0.5,'A')