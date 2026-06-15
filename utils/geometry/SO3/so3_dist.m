function d = so3_dist(O1, O2)
    d = norm(logm(O2*O1')*O1, 'fro');
end