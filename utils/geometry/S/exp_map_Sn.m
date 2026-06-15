function [T] = exp_map_Sn(X, V)
    theta = norm(V, 'fro');
    T = cos(theta)*X + sin(theta)/theta*V;
end