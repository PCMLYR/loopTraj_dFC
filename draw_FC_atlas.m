function figure_id = draw_FC_atlas(FC, ...
    atlas_raw_name, network_colors, network_names, num_roi, num_parcel, figure_id)

    if ~exist('figure_id','var') 
        figure_id = randi(100) + 100;
    end

    if isa(figure_id, 'matlab.graphics.axis.Axes')
        % figure_id is target_handle
        % axes(figure_id); 
        ax = figure_id;
    else % figure_id is digit
        figure(figure_id);
        set(gcf, 'Position', [100 100 800 800], 'Color', 'w');
        ax = gca;
    end
    
    % recognize each ROI belong to which network
    roi_network_idx = zeros(num_roi, 1);
    for i = 1:num_roi
        current_label = atlas_raw_name{i}; 
        for net_k = 1:num_parcel
            if contains(current_label, network_names{net_k}, 'IgnoreCase', true)
                roi_network_idx(i) = net_k;
                break;
            end
        end
        if roi_network_idx(i) == 0; roi_network_idx(i) = 8; end % unkown network
    end

    % sort input FC in ID order
    [sorted_net_ids, sort_idx] = sort(roi_network_idx);
    FC_sorted = FC(sort_idx, sort_idx);
    
    % draw FC matrix
    imagesc(FC_sorted, 'Parent', ax);
    hold(ax, 'on');
    
    colormap(ax, slanCM('coolwarm'));
    set(ax, 'CLim', [-1 1]);
    % clim([-1 1]);      
    % colorbar;       
    
    % plot side atlas colorbar
    colorline_width = 5; 
    offset = 0;    
    for i = 1:num_roi
        net_id = sorted_net_ids(i);
        if net_id <= 7
            c = network_colors(net_id, :);
        else
            c = [0.5, 0.5, 0.5]; % unkown network
        end
        % left atlas colorbar
        line([0.5, 0.5]+offset, [i-0.5, i+0.5], ...
            'Color', c, 'LineWidth', colorline_width, 'Parent', ax);
        % up atlas colorbar
        line([i-0.5, i+0.5], [0.5, 0.5]+offset, ...
            'Color', c, 'LineWidth', colorline_width, 'Parent', ax);
    end
    
    axis(ax, 'square'); % 关键：指定 ax
    axis(ax, 'tight');
    set(ax, 'YDir', 'reverse'); % 确保矩阵左上角是 (1,1)
    set(ax, 'XTick', [], 'YTick', []);
    
    % add network names and divide lines
    unique_nets = unique(sorted_net_ids);
    for k = 1:length(unique_nets)
        net_id = unique_nets(k);
        if net_id > 7; continue; end
      
        indices = find(sorted_net_ids == net_id);
        center_pos = mean(indices);
        % % add network names at left
        % text(-15, center_pos, network_names{net_id}, ...
        %     'HorizontalAlignment', 'right', 'Rotation', 45, 'FontSize', 10, ...
        %     'FontWeight', 'bold', 'Color', network_colors(net_id,:), 'Parent', ax);  
        % % add network names at up
        % text(center_pos, -15, network_names{net_id}, ...
        %     'HorizontalAlignment', 'left', 'Rotation', 45, 'FontSize', 10, ...
        %     'FontWeight', 'bold', 'Color', network_colors(net_id,:), 'Parent', ax);
        % % add horiental divide lines
        % line([0.5 num_roi+0.5], [max(indices) max(indices)]+0.5, ...
        %     'Color', 'k', 'LineWidth', 0.5, 'Parent', ax);
        % % add vertical divide lines
        % line([max(indices) max(indices)]+0.5, [0.5 num_roi+0.5], ...
        %     'Color', 'k', 'LineWidth', 0.5, 'Parent', ax);
    end
    
    % ax = gca;
    % ax.Position = [0.15 0.15 0.7 0.7]; % [left bottom width height]
end

