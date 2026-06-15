function X0 = centered_scaled(X)
%    INPUT : X - n points at R3 - 3*n double
%    OUTPUT: X0 - n points at S - 3*n double
    n=size(X,2);
    muX = mean(X,2);
    X0 = X - repmat(muX, 1, n);

    % the "centered" Frobenius norm
    normX = sqrt(trace(X0'*X0));
    
    % scale to equal (unit) norm
    X0 = X0 / normX;
end

