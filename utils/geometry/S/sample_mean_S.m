function [mu] = sample_mean_S(frames, iter)
    n_frame = size(frames, 3);
    mu = frames(:,:,1);
    for i = 1:iter
        v = zeros(size(frames,1), size(frames,2));
        for i_frame = 1:n_frame
            v = v + log_map_Sn(mu, frames(:,:,i_frame));
        end
        v = v/n_frame;
        mu = exp_map_Sn(mu, v);
    end
end