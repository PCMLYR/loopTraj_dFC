function [Xframes_centered] = centered_scaled_sequence(Xframes)
    n_frame = size(Xframes, 3);
    for i_frame = 1:n_frame
        Xframes_centered(:,:,i_frame) = centered_scaled(Xframes(:,:,i_frame));
    end
end

