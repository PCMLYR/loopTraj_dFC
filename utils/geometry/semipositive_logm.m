function logmX = semipositive_logm(X)
%     [U,S,V] = svd(X);
    [V,S] = eig(X);
    d = diag(S);
    posmin = min(d(d>0),[],'all');
    d(d<posmin) = 0.01*posmin;
%     logmX = U*diag(log(d))*V';
    logmX = V * diag(log(d)) / V;
end

