function roi_meanTC = calc_roi_timecourse(fmri_timecourse, atlas_path, num_roi)
% Calculate ROI-wise mean time course of input fMRI sequence
    atlas_cifti = ft_read_cifti(atlas_path, 'mapname', 'array');
    atlas_label = atlas_cifti.dlabel; % 64984

    roi_meanTC = zeros(num_roi, size(fmri_timecourse, 2));
    for i_roi = 1:num_roi
        roi_meanTC(i_roi,:) = mean(fmri_timecourse(atlas_label == i_roi, :), 1);
    end
end

