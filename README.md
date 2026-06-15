# dFC-Isomap: Manifold Learning of Dynamic Functional Connectivity Trajectories

Official implementation of CogSci 2026 paper **“Looped Manifold Trajectories of Dynamic Functional Connectivity Reveal Continuous Task-related Brain Reconfiguration”**.

This repository contains MATLAB code for computing dynamic functional connectivity (dFC), embedding resting-state and task fMRI dFC into a shared low-dimensional manifold with Isomap, and visualizing looped task-related brain reconfiguration trajectories.

## Overview

The main analysis scripts are:

```matlab
Run_ROI_dFC_Isomap.m
Run_ROI_dFC_Plot.m
```

`Run_ROI_dFC_Isomap.m` computes group-averaged ROI time courses, sliding-window dFC matrices, and Isomap embedding coordinates.

`Run_ROI_dFC_Plot.m` visualizes the learned trajectories, including temporal coloring, rest/task coloring, task-condition coloring, and selected FC matrices along the trajectory.

## Data requirements

The code assumes HCP-style preprocessed resting-state and task fMRI data in CIFTI format. Data are not included in this repository.

Default root directory:

```text
[YOUR_HCP_ROOT]/HCP_100_unrelated_2025/
├── HCP100_task/
├── HCP100_rest/
└── HCP100_structual/
```

The scripts use HCP task/rest CIFTI files and HCP EV files, together with Schaefer atlas CIFTI parcellations:

```text
parcellation/Schaefer/fslr32k/cifti/
```

Before running the code, edit `root_path` in the scripts to match your local HCP data directory.

## Software requirements

The code was written in MATLAB and requires:

- MATLAB
- Connectome Workbench
- FieldTrip / CIFTI MATLAB I/O utilities
- HCP utility functions for reading HCP CIFTI time series
- Schaefer atlas files
- `slanCM` colormap function for visualization

Add the required toolboxes and local utilities by running:

```matlab
Addpath
```

## Quick start

### 1. Configure paths

Edit `root_path` in:

```matlab
Run_ROI_dFC_Isomap.m
Read_TaskBlock.m
```

and update local toolbox paths in:

```matlab
Addpath.m
```

### 2. Configure task and atlas scale

In `Run_ROI_dFC_Isomap.m`, set the task:

```matlab
task = 'EMOTION';  max_frame_num = 161;
% task = 'MOTOR'; max_frame_num = 263;
```

Set the Schaefer atlas resolution:

```matlab
num_roi = 100;
% num_roi = 200;
% num_roi = 500;
% num_roi = 1000;
```

Default dFC and Isomap parameters:

```matlab
window_size = 10;
step = 1;
par.k = 10;
par.n_dim = 3;
```

### 3. Run dFC-Isomap

```matlab
Run_ROI_dFC_Isomap
```

### 4. Plot trajectories

```matlab
Run_ROI_dFC_Plot
```

## Main outputs

The pipeline writes outputs to:

```text
result_roiTC/<TASK>/avg/      # ROI-wise mean BOLD time courses
result_dFC/<TASK>/avg/        # Sliding-window dFC matrices
result_traj/<TASK>/avg/       # Isomap trajectory coordinates
```

The key output variable is:

```matlab
embed_coord
```

which stores the low-dimensional coordinates of the rest-task dFC trajectory.

## Citation

If you use this code, please cite:

```bibtex
@inproceedings{li2026looped,
  title     = {Looped Manifold Trajectories of Dynamic Functional Connectivity Reveal Continuous Task-related Brain Reconfiguration},
  author    = {Li, Yueran and Chang, Xinle and Yang, Yang and Ye, Chenfei and Zhao, Yu and Su, Jingyong},
  booktitle = {Proceedings of the Annual Meeting of the Cognitive Science Society},
  year      = {2026},
  note      = {Accepted. DOI to be added}
}
```

## License

This project is released under the MIT License.
