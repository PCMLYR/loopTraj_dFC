function [T] = so3_log_map(O1, O2)
    T = logm(O2*O1')*O1;
end