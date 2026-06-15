function [Yt] = spd_geodesic(X, Y, t, type)
    % input: 
    %       X : start point
    %       Y : end point
    if type == 'A'
        % Affine Invariant
        X_sqr = X^(1/2);
        Yt = X_sqr * expm(t .* (logm(X_sqr\Y/X_sqr)) ) * X_sqr;
    end
end

