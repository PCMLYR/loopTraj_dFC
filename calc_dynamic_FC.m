function dFC_matrix = calc_dynamic_FC(timecourse_data, window_size, step, roi_mask)
    t = floor((size(timecourse_data,2) - window_size + 1) / step);
    data = timecourse_data(roi_mask, :);
    num_roi = size(data,1);
    dFC_matrix = zeros(num_roi, num_roi, t);
    for i = 1:t
        head = 1+(i-1)*step; tail = window_size+(i-1)*step; 
        signal_window = data(:, head:tail);
        % meanm = mean(signal_window,2);
        % dFC_matrix(:,:,i) = (signal_window - meanm)*(signal_window - meanm)' ./ (window_size-1);
        dFC_matrix(:,:,i) = corr(signal_window');
    end

    % NaN value check
    if any(isnan(dFC_matrix))
        nan_indices = find(all(all(isnan(dFC_matrix),3),2));
        disp("    Find NaN indices: ");
        disp(nan_indices);
        for ind = nan_indices
            dFC_matrix(ind,:,:) = dFC_matrix(ind-1,:,:);
            dFC_matrix(:,ind,:) = dFC_matrix(:,ind-1,:);
            dFC_matrix(ind,ind,:) = 1;
        end
    end
end

