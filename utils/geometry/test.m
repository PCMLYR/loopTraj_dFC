pa(:,1) = [1;2;3];
pa(:,2) = [4;5;6];
pb(:,1) = [1;2;100];
pb(:,2) = [4;5;100];
I1 = get_I_direct(pa(:,1), pa(:,2), 1);
I2 = get_I_direct(pb(:,1), pb(:,2), 1);
I = eye(3);
% log_map_det(I1,I2)
% log_map_det(I,I1)
% dist_spd(I1, I2, 'R')
% dist_spd(I1, I2, 'D')
% logm(I1)
[Ih, x] = det_1_decompose(I1);
V = log_map(I1, I2);
% exp_map(I1, V, 0.3);
It = geodesic_det_1(I1,I2,2);
% rebuild_point_from_I(It, pa(:,1), 1);
i = 1;
for t = 0:0.01:1
    p1t = pa(:,1) + (pb(:,1)-pa(:,1))*t;
    p2t = pa(:,2) + (pb(:,2)-pa(:,2))*t;
    I_lt = get_I_direct(p1t, p2t, 1);
    dis(i) = dist_spd(I1, I_lt, 'D');
    i = i + 1;
end
plot(0:0.01:1, dis)

