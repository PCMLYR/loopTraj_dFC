function [d] = spd_dist(X, Y, varargin)
    X = X + 1e-8 * eye(size(X,1));
    Y = Y + 1e-8 * eye(size(Y,1));
    if nargin == 2
        %DEFAULT : Euclidean distance
        d = norm(X-Y, 'fro');
    elseif nargin == 3
        if varargin{1} == 'A'
            % Affine Invariant Riemannien Metric
            X_sqr = X^(1/2);
            d = norm(logm(X_sqr\Y/X_sqr), 'fro');

        elseif varargin{1} == 'L'
            % Log-Euclidean Riemannian Metric
            d = norm(logm(X) - logm(Y), 'fro');

%             [VX, DX] = eig(X);
%             X2 = VX * diag(log(diag(DX))) * VX';
%             X2 = (X2 + X2') / 2;
% 
%             [VY, DY] = eig(Y);
%             Y2 = VY * diag(log(diag(DY))) * VY';
%             Y2 = (Y2 + Y2') / 2;
% 
%             d = norm(X2 - Y2, 'fro');
            
        elseif varargin{1} == 'K' || varargin{1} == 'J'
            % KL-Divergence metric, or called Jeffrey divergence
            d = trace(X\Y + Y\X - 2*eye(size(X))) / 2;
        elseif varargin{1} == 'S'
            % Stein divergence
            d = log(det((X+Y)/2)) - 0.5*log(det(X*Y));
        elseif varargin{1} == 'E'
            % Euclidean distance
            d = norm(X-Y, 'fro');
        end
    end
end

