function [T] = spd_log_map(X, Y, type)
    % X : start point. Y : end point. T : tangent vector
    if type == 'A'
        % Affine Invariant
        Y_sqr = Y^(1/2);
        T = Y_sqr*logm(Y_sqr\X/Y_sqr)*Y_sqr;

    end
end