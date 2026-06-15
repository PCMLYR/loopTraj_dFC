% run Run_ROI_dFC_Isomap.m to load variables in workspace
clc;
close all;

traj_len = size(embed_coord,1);

offset = window_size/2 + abandon_frames;

%% Figure 1 : Trajectory visualization

% ----- figure 1: embedding trajectory -----
% full
colors = slanCM('jet', par.n_frame);
ticklabels = {'1' num2str(floor(traj_len/2)) num2str(traj_len)};
draw_3d_traj(embed_coord, colors, par.add_identity, ticklabels, 1);
% only task
% colors = slanCM('jet', par.n_frame/2);
% ticklabels = {'1' num2str(floor(traj_len/4)) num2str(traj_len/2)};
% draw_3d_traj(embed_coord((traj_len/2+1):traj_len,:), ...
%             colors, par.add_identity, ticklabels, 1);
% colorbar off

% ----- figure 2: embedding trajectory with rest/task label -----
colors = [repmat([0 0.4470 0.7410], traj_len/2, 1); ...
            repmat([0.6350 0.0780 0.1840], traj_len/2, 1)];
ticklabels = {"","Rest","","Task",""};
draw_3d_traj(embed_coord, colors, par.add_identity, ticklabels, 2);
colorbar off

%% figure 2: trajectory with task label
figure_id = 3;
% offset = 0;
draw_task_traj(embed_coord((sess_len+1):2*sess_len, :), ...
    task, 'fMRI', session, offset, max_frame_num, figure_id);
% draw_task_traj(embed_coord(1:sess_len, :), ...
%     task, 'fMRI', session, offset, max_frame_num, figure_id);

%% figure 3: plot some FCs
atlas_cifti = ft_read_cifti(atlas_path, 'mapname', 'array');
atlas_label = atlas_cifti.dlabel; % 64984
atlas_raw_name = atlas_cifti.dlabellabel;

% Yeo 7 atlas network colors (RGB) and names
network_colors = load(fullfile("utils", "parcellation", "Yeo", ...
                [num2str(num_parcel) 'NetworksColors.mat'])).colors;
network_colors = network_colors(2:end,:)./255; % into range [0,1]
network_names = {'Vis', 'SomMot', 'DorsAttn', 'SalVentAttn', 'Limbic', 'Cont', 'Default'};

% example_FC_ind_list = [61,66,69,73]; % emotion shape
% for ind = example_FC_ind_list
%     draw_FC_atlas(input_dFC(:,:,sess_len+ind), ...
%         atlas_raw_name, network_colors, network_names, num_roi, num_parcel, ...
%         1000+ind);
%     % draw_FC_atlas(input_dFC(:,:,ind), ...
%     %     atlas_raw_name, network_colors, network_names, num_roi, num_parcel, ...
%     %     1000+ind);
% end

% example_FC_ind_list = [61,66,69,73; 120,124,128,132; 5,8,12,15]; % emotion shape
% example_FC_ind_list = [90,94,97,100; 30,34,39,43]; % emotion face
% example_FC_ind_list = [61,66,69,73; 34,39,45,50]; % emotion shape&face
% example_FC_ind_list = [149,155,163,167; 87,90,93,95; 65,76,79,83; ...
%                         179,182,185,188; 129,134,136,140]; % motor lf lh rf rh t
% example_FC_ind_list = [142,143,144,145];
example_FC_ind_list = [128,129,130,131];
example_FC_ind_list = example_FC_ind_list(1,:);
example_FC_ind_list = example_FC_ind_list'; 
figure(1000);
set(gcf, 'Position', [500 500 2500 1000], 'Color', 'w');
M = size(example_FC_ind_list,1); N = size(example_FC_ind_list,2);
for i_plt = 1:M*N
    ind = example_FC_ind_list(i_plt);
    handle = subplot(N, M, i_plt);
    draw_FC_atlas(input_dFC(:,:,sess_len+ind), ...
        atlas_raw_name, network_colors, network_names, num_roi, num_parcel, ...
        handle); 
end

%% figure 4: x and y coord
figure_id = 4;
figure(figure_id);
draw_signal_with_task(embed_coord((sess_len+1):2*sess_len, 1), ...
                    task, session, sess_len, offset, figure_id);
hold on
plot(1:traj_len, embed_coord(:,1), 'k-', 'LineWidth', 1);
yline(0, 'k--', 'LineWidth',1);

figure_id = 5;
figure(figure_id);
draw_signal_with_task(embed_coord((sess_len+1):2*sess_len, 2), ...
                    task, session, sess_len, offset, figure_id);
hold on
plot(1:traj_len, embed_coord(:,2), 'k-', 'LineWidth', 1);
yline(0, 'k--', 'LineWidth',1);