function [O2] = so3_exp_map(O1, T)
    O2 = expm(T*O1')*O1;
end