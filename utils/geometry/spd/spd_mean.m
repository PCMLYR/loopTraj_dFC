function [Xmean] = spd_mean(Xs, type)
    % Xs is cell 
    n_X = max(size(Xs));
    
    if type == 'A'
        Xold = eye(size(Xs{1}, 1));
        for iter = 1:50
            X_sqt = Xold^(1/2);
            sum = zeros(size(Xs{1}, 1));
            for i_X = 1:n_X
                sum = sum + logm(X_sqt\ Xs{i_X} /X_sqt);
            end
            sum = sum/n_X;
            Xmean = X_sqt*expm(sum)*X_sqt;
            
            if norm(Xmean - Xold) < 0.0001
                break;
            end
            Xold = Xmean;
        end
        
    elseif type == 'L'
%         sum = zeros(size(Xs{1}, 1));
%         for i_X = 1:n_X
%             sum = sum + logm(Xs{i_X});
%         end
%         sum = sum/n_X;
%         Xmean = expm(sum);
        
        S = 0;
        for i_X = 1:n_X
            [V, D] = eig(Xs{i_X});
            X = V * diag(log(diag(D))) * V';
            X = (X + X') / 2;
            S = S + X;
        end
        S = S / n_X;
        [VS, DS] = eig(S);
        Xmean = VS * diag(exp(diag(DS))) * VS';
        Xmean = (Xmean + Xmean') / 2;
        
    elseif type == 'K'
%         sum_X = zeros(size(Xs{1}, 1));
%         sum_invX = zeros(size(Xs{1}, 1));
%         for i_X = 1:n_X
%             sum_X = sum_X + Xs{i_X};
%             sum_invX = sum_invX + inv(Xs{i_X});
%         end
% 
%         sum_invX_sqr = sum_invX^(1/2);
%   
%         Xmean = sum_invX_sqr \ (sum_invX_sqr * sum_X * sum_invX_sqr) / sum_invX_sqr;
        
        
        P = 0;
        Q = 0;
        for i = 1:n_X
            P = P + inv(Xs{i});
            Q = Q + Xs{i};
        end
        [V, D] = eig(P);
        d = diag(D).^0.5;
        M = V * diag(d) * V';
        M = (M + M') / 2;
        N = V * diag(1./d) * V';
        N = (N + N') / 2;
        S = M * Q * M;
        S = (S + S') /2;
        [VS, DS] = eig(S);
        ds = diag(DS).^0.5;
        T = VS * diag(ds) * VS';
        T = (T + T') / 2;
        Xmean = N * T * N;
        Xmean = (Xmean + Xmean') / 2;
        
        
    elseif type == 'E'
        sum = zeros(size(Xs{1}, 1));
        for i_X = 1:n_X
            sum = sum + Xs{i_X};
        end
  
        Xmean = sum/n_X;
        
    end
end