clear; clc;
close all;

%% Step 0 : Initiate parameters
% ---------- parameters for fMRI data reading ----------
root_path = '/media/yrli/KESU/HCP_100_unrelated_2025/';
session = 'LR';
% session = 'RL';
% data_type = 'fMRI';
data_type = 'fMRI2run';

% task = 'MOTOR';    max_frame_num = 263;
% task = 'LANGUAGE'; max_frame_num = 339;
% task = 'WM';       max_frame_num = 386;
task = 'EMOTION';  max_frame_num = 161;
% task = 'RELATIONAL';  max_frame_num = 207;

cifti_template = cifti_read(fullfile(root_path, 'HCP100_task', ...
                '100307', 'MNINonLinear', 'Results', ...
                ['tfMRI_' task '_' session], ...
                ['tfMRI_' task '_' session , ...
                '_Atlas_MSMAll_hp0_clean_rclean_tclean.dtseries.nii']));

if strcmp(data_type, 'fMRI2run')
    ses_name = 'LRRL';
else
    ses_name = session;
end

N_sub = 100;
max_rest_fnum = 1200;

abandon_frames = 5;

if_normalize = 2;
if_smooth = 1;
if_ica_fix = 1;

method = 'concatenate';
% method = 'mean';

after_normalize = 2;
% after_normalize = 1;
% after_normalize = 0;

% ======= parameters for mTC & dFC calculating ----------
% dFC calc
window_size = 10;
step = 1;
sess_len = max_frame_num - window_size + 1 - abandon_frames;

% mTC calc
% ------- uncomment this section if use Schaefer2018 Atlas -------
num_roi = 100;
% num_roi = 200;
% num_roi = 500;
% num_roi = 1000;
num_parcel = 7;
% roi_mask = 25:43; % 25:43 SomaMotorA in 400
% roi_mask = 44:59; % 44:59 SomaMotorB in 400
% roi_mask = 8:13; % 8:13 SomaMotor in 100
roi_mask = 1:num_roi; % all rois
atlas_path = fullfile('parcellation', 'Schaefer', 'fslr32k', 'cifti', ...
           ['Schaefer2018_' int2str(num_roi) 'Parcels_' int2str(num_parcel) ...
           'Networks_order.dlabel.nii']);
atlas_info_path = fullfile('parcellation', 'Schaefer', 'fslr32k', 'cifti', ...
           ['Schaefer2018_' int2str(num_roi) 'Parcels_' int2str(num_parcel) ...
           'Networks_order_info.txt']);

% ------- uncomment this section if use Yeo2011 Atlas  -------
% par.num_roi = 17;
% par.roi_mask = 1:17;
% atlas_path = [root_path 'GRETNA-2.0.0_release/Atlas/Yeo2011_17Networks_MNI152_FreeSurferConformed2mm.nii'];

roiTC_filename = [int2str(min(roi_mask)) 'to' int2str(max(roi_mask)) ...
                   'in' int2str(num_roi) '.mat'];
dFC_filename = [int2str(min(roi_mask)) 'to' int2str(max(roi_mask)) ...
            'in' int2str(num_roi), '_' int2str(window_size) ...
            'wsize_' int2str(step) 'step.mat'];

%% Step 0 : Make directory
task_roiTC_dir = fullfile('result_roiTC', task, 'avg');
rest_roiTC_dir = fullfile('result_roiTC', 'REST1', 'avg');
task_dFC_dir = fullfile('result_dFC', task, 'avg');
rest_dFC_dir = fullfile('result_dFC', 'REST1', 'avg');
traj_dir = fullfile('result_traj', task, 'avg');

if ~exist(task_roiTC_dir, "dir") mkdir(task_roiTC_dir); end
if ~exist(rest_roiTC_dir, "dir") mkdir(rest_roiTC_dir); end
if ~exist(task_dFC_dir, "dir") mkdir(task_dFC_dir); end
if ~exist(rest_dFC_dir, "dir") mkdir(rest_dFC_dir); end
if ~exist(traj_dir, "dir") mkdir(traj_dir); end

%% Step 1 : Read Group averaged fMRI data
disp('Read group averaged fMRI data');
datetime("now");
[avg_task, maskCft_task] = calc_meanTC(session, data_type, task, ses_name, ...
                                max_frame_num, N_sub, root_path, cifti_template, ...
                                if_normalize, if_smooth);
[avg_rest, maskCft_rest] = calc_meanTC(session, data_type, 'REST1', ses_name, ...
                                max_rest_fnum, N_sub, root_path, cifti_template, ...
                                if_normalize, if_smooth);

avg_task_roiTC_path = fullfile(task_roiTC_dir, roiTC_filename);
avg_rest_roiTC_path = fullfile(rest_roiTC_dir, roiTC_filename);
avg_task_dFC_path = fullfile(task_dFC_dir, dFC_filename);
avg_rest_dFC_path = fullfile(rest_dFC_dir, dFC_filename);

disp('Calculate/Read group averaged task roiTC and dFC');
datetime("now");
if ~exist(avg_task_dFC_path, "file")
    avg_task_roiTC = calc_roi_timecourse(avg_task, atlas_path, num_roi);
    if strcmp(data_type, 'fMRI2run')
        avg_task_dFC = cat(3, ...
            calc_dynamic_FC(avg_task_roiTC(:, 1:max_frame_num), ...
                        window_size, step, roi_mask), ...
            calc_dynamic_FC(avg_task_roiTC(:, (max_frame_num+1):(2*max_frame_num)), ...
                        window_size, step, roi_mask));
    else
        avg_task_dFC = calc_dynamic_FC(avg_task_roiTC, window_size, step, roi_mask);
    end
    avg_task_dFC = single(avg_task_dFC);
    save(avg_task_roiTC_path, 'avg_task_roiTC', '-v7.3');
    save(avg_task_dFC_path, 'avg_task_dFC', '-v7.3');
else
    load(avg_task_roiTC_path, 'avg_task_roiTC');
    load(avg_task_dFC_path, 'avg_task_dFC');
end

disp('Calculate/Read group averaged rest roiTC and dFC');
datetime("now");
if ~exist(avg_rest_dFC_path, "file")
    avg_rest_roiTC = calc_roi_timecourse(avg_rest, atlas_path, num_roi);
    if strcmp(data_type, 'fMRI2run')
        avg_rest_dFC = cat(3, ...
            calc_dynamic_FC(avg_rest_roiTC(:, 1:max_rest_fnum), ...
                        window_size, step, roi_mask), ...
            calc_dynamic_FC(avg_rest_roiTC(:, (max_rest_fnum+1):(2*max_rest_fnum)), ...
                        window_size, step, roi_mask));
    else
        avg_rest_dFC = calc_dynamic_FC(avg_rest_roiTC, window_size, step, roi_mask);
    end
    avg_rest_dFC = single(avg_rest_dFC);
    save(avg_rest_roiTC_path, 'avg_rest_roiTC', '-v7.3');
    save(avg_rest_dFC_path, 'avg_rest_dFC', '-v7.3');
else
    load(avg_rest_roiTC_path, 'avg_rest_roiTC');
    load(avg_rest_dFC_path, 'avg_rest_dFC');
end


%% Step 2 : Read Subject fMRI data

% for i = 1:N_sub
%     subdir = dir(fullfile(root_path, 'HCP100_task'));
%     id = subdir(i+2).name(1:6);
%     disp(['Processing sub-' id ' ' int2str(i) '/' int2str(N_sub)]); 
% 
%     %%% Read subject task block info
%     taskblock_LR = read_task_block(fullfile(root_path, 'HCP100_task/', ...
%                                         id, 'MNINonLinear', 'Results', ...
%                                         ['tfMRI_' task '_LR'], 'EVs/'), ...
%                                         task, max_frame_num);
%     taskblock_RL = read_task_block(fullfile(root_path, 'HCP100_task/', ...
%                                         id, 'MNINonLinear', 'Results', ...
%                                         ['tfMRI_' task '_RL'], 'EVs/'), ...
%                                         task, max_frame_num);
%     N_block = size(taskblock_LR.task_info_table, 1);
% 
%     %%% Read subject fMRI data 
%     if ~exist(fullfile('data_preread','REST1'),'dir') 
%         mkdir(fullfile('data_preread','REST1')); 
%     end
%     if ~exist(fullfile('data_preread',task),'dir') 
%         mkdir(fullfile('data_preread',task)); 
%     end
% 
%     preread_rest_path = fullfile('data_preread', 'REST1', ...
%                                 [id '_REST1_' ses_name '.mat']);
%     if ~exist(preread_rest_path, 'file')
%         [subTC_rest, maskCft_rest] = get_subTC(id, session, data_type, 'REST1',  ...
%                                         max_rest_fnum, root_path, ...
%                                         if_normalize, if_smooth);
%         save(preread_rest_path,  'subTC_rest', 'maskCft_rest');
%     else
%         load(preread_rest_path)
%     end
%     preread_task_path = fullfile('data_preread', task, ...
%                                 [id '_' task '_' ses_name '.mat']);
%     if ~exist(preread_task_path, 'file')
%         [subTC_task, maskCft_task] = get_subTC(id, session, data_type, task, ...
%                                         max_frame_num, root_path, ...
%                                         if_normalize, if_smooth);
%         [subTC_task(1:max_frame_num), ...
%         subTC_task((max_frame_num+1):(2*max_frame_num))] = ...
%                 baseline_correction(...
%                                 fullfile(root_path, 'HCP100_task/', ...
%                                             id, 'MNINonLinear', 'Results'), ...
%                                 3, 0.72, ...
%                                 subTC_task(1:max_frame_num), ...
%                                 subTC_task((max_frame_num+1):(2*max_frame_num)), ...
%                                 task, taskblock_LR.task_name);
%         disp('Baseline correction finished');
%         save(preread_task_path, 'subTC_task', 'maskCft_task');
%     else
%         load(preread_task_path)
%     end
% end

%% step 3 : define ISOMAP parameters and calculate embedded coordinate
% ----- parameters -----

%   Input
% === rest LR
% par.n_frame = sess_len;
% input_dFC = avg_rest_dFC(:,:, (abandon_frames+1):(abandon_frames+1+par.n_frame-1));
% === task LR
% par.n_frame = sess_len;
% input_dFC = avg_task_dFC(:,:, (abandon_frames+1):(abandon_frames+1+par.n_frame-1));
% === rest LR&RL
% par.n_frame = 2*sess_len;
% input_dFC = avg_rest_dFC(:,:, (abandon_frames+1):(abandon_frames+1+par.n_frame-1));
% === rest & task LR&RL
% par.n_frame = 4*sess_len;
% input_dFC = cat(3, ...
%     avg_rest_dFC(:,:, (abandon_frames+1):(abandon_frames+1+par.n_frame/2-1)), ...
%     avg_task_dFC(:,:, (abandon_frames+1):(abandon_frames+1+par.n_frame/2-1)));
% === rest & task LR
par.n_frame = 2*sess_len;
input_dFC = cat(3, ...
    avg_rest_dFC(:,:, (abandon_frames+1):(abandon_frames+1+par.n_frame/2-1)), ...
    avg_task_dFC(:,:, (abandon_frames+1):(abandon_frames+1+par.n_frame/2-1)));

%   Distance matrices calculation parameters
par.epsilon = 1e-8;

par.add_identity = 1;
par.delete_DistanceMatrix = 1; % 1 for debug
% par.k = fix(0.01*par.n_frame); % for A dist, use k = fix(0.65*par.n_frame)
par.k = 10;
par.dist_type = 'E';
% par.dist_type = 'A';
% par.dist_type = 'L';

%   Isomap parameters
par.n_dim = 3;
par.options.display = 0;
par.options.overlay = 1;
par.save_embedding_coord = 0;

par.force_calc = 0;
% par.force_calc = 1;

% ----- calculate embedded coordinate -----
disp('Isomap embedding trajectory');
datetime("now");

traj_filename = [int2str(min(roi_mask)) 'to' int2str(max(roi_mask)) ...
            'in' int2str(num_roi) '_' int2str(window_size) ...
            'wsize_' int2str(step) 'step_' int2str(par.n_frame) 'frames_'...
            int2str(abandon_frames) 'abandon.mat'];
avg_traj_path = fullfile(traj_dir, traj_filename);

if ~exist(avg_traj_path, "file") || par.force_calc == 1
    [D, embed_coord] = dFC_isomap(input_dFC, par, 'calc');
    if mean(embed_coord,1) < 0
        embed_coord = embed_coord .* [-1 -1 -1]; % keep trajectory at positive
    end
    save(avg_traj_path, 'embed_coord', '-v7.3');
else
    load(avg_traj_path, 'embed_coord');
end

% see_embed_coord = embed_coord';