function [T] = spd_exp_map(T, Y, type)
    if type == 'A'
        % Affine Invariant
        Y_sqr = Y^(1/2);
        T = Y_sqr*expm(Y_sqr\T/Y_sqr)*Y_sqr;
    end
end