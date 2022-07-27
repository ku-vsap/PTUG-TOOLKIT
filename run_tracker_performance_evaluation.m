% tracker performance evaluation tool for our benchmark
% 07/19/2018

clc; clear; close all;

addpath('./utils/');
addpath('./sequence_evaluation_config/');

tmp_mat_path  = './tmp_mat/';          % path to save temporary results
path_anno     = './annos/';            % path to annotations
path_att      = './annos/att/';        % path to attribute
rp_all        = './tracking_results/'; % path to tracking results
save_fig_path = './res_fig/';          % path to result figures
save_fig_suf  = 'png';                 % suffix of figures, 'png' or 'eps'

delete(fullfile(tmp_mat_path,'*.mat'))

att_name      = {'Illumination Variation', 'Occlusion', 'Motion Blur', 'Pose Variation',...
    'Camouflage', 'Uniformaity'};
att_fig_name  = {'IV', 'OC', 'MB', 'PV', 'CA','UF'};

% 'all' --- evaluation with the whole benchmark
% 'single' --- evaluation with the single scenario of testset
% 'multi' --- evaluation with the group scenario of testset
evaluation_dataset_type = 'single';

% use normalization or not
norm_dst = true;    

% eval attrs or not
eval_att = true;

trackers   = config_tracker();
sequences  = config_sequence(evaluation_dataset_type);
plot_style = config_plot_style();

num_seq = numel(sequences);
num_tracker = numel(trackers);

% load tracker info
name_tracker_all = cell(num_tracker, 1);
for i = 1:num_tracker
    name_tracker_all{i} = trackers{i}.name;
end

% load sequence info
name_seq_all = cell(num_seq, 1);
for i = 1:num_seq
    name_seq_all{i} = sequences{i};
    seq_att         = dlmread(fullfile(path_att, [sequences{i} '.txt']));
    if i == 1
        att_all = cell(num_seq, 1);
    end
    att_all{i} = seq_att;
end

% parameters for evaluation
metric_type_set = {'error', 'overlap'};
eval_type       = 'OPE';
% ranking_type    = 'AUC';
ranking_type    = 'threshold';   % change it to 'AUC' for success plots
rank_num        = 35;



threshold_set_error   = 0:50;
if norm_dst
    threshold_set_error = threshold_set_error / 100;
end
threshold_set_overlap = 0:0.05:1; 

for i = 1:numel(metric_type_set)
    % error (for distance plots) or overlap (for success plots)
    metric_type = metric_type_set{i};
    switch metric_type
        case 'error'
            threshold_set = threshold_set_error;
            rank_idx      = 21; %precision standard pixel threshold
            x_label_name  = 'Location error threshold';
            y_label_name  = 'Precision';
            ranking_type    = 'threshold';
        case 'overlap'
            threshold_set = threshold_set_overlap;
            rank_idx      = 11; %overlap standard pixel threshold
            x_label_name  = 'Overlap threshold';
            y_label_name  = 'Success';
            ranking_type    = 'AUC';
    end
    
   
    t_num = numel(threshold_set);
    
    % we only use OPE for evaluation
    plot_type = [metric_type '_' eval_type];
    
    switch metric_type
        case 'error'
            title_name = ['Precision plots of ' eval_type];
            if norm_dst
                title_name = ['Norm. ' title_name];
            end
            title_name = [title_name ' on PTUG'];
            
        case 'overlap'
            title_name = ['Success plots of ' eval_type];
            title_name = [title_name ' on PTUG'];

    end
    
    dataName = [tmp_mat_path 'aveSuccessRatePlot_' num2str(num_tracker) ...
                'alg_'  plot_type '.mat'];
    %%{
    % evaluate tracker performance
    if ~exist(dataName, 'file')
        eval_tracker(sequences, trackers, eval_type, name_tracker_all, ...
                    tmp_mat_path, path_anno, rp_all, norm_dst);
    end
    
    % plot performance
    load(dataName);
    num_tracker = size(ave_success_rate_plot, 1);
    
    if rank_num > num_tracker || rank_num <0
        rank_num = num_tracker;
    end
    
    fig_name= [plot_type '_' ranking_type];
    idx_seq_set = 1:numel(sequences);
    
    % draw and save the overall performance plot
    plot_draw_save(num_tracker, plot_style, ave_success_rate_plot, ...
                   idx_seq_set, rank_num, ranking_type, rank_idx, ...
                   name_tracker_all, threshold_set, title_name, ...
                   x_label_name, y_label_name, fig_name, save_fig_path, ...
                   save_fig_suf);
    %%}
               
    %%{      
    % draw and save the per-attribute performance plot
    
    if eval_att
    
        att_trld = 0;
        att_num  = size(att_name, 2);

        for att_idx = 1:att_num    % for each attribute  

            idx_seq_set = zeros(num_seq,1);
            count = 1;
            empty_set_idx = [];
            for seq_idx = 1:num_seq
                idx_frm_set = find(att_all{seq_idx}(:,att_idx) > att_trld);
                if length(idx_frm_set) < 2
                    empty_set_idx(count) = seq_idx;
                    count = count + 1;
                    continue;
                end
                idx_seq_set(seq_idx) = seq_idx;
            end
            idx_seq_set(empty_set_idx,:) = [];
            clear empty_set_idx

            disp([att_name{att_idx} ' ' num2str(length(idx_seq_set))]);

            fig_name   = [att_fig_name{att_idx} '_'  plot_type '_' ranking_type];
            title_name = ['Plots of ' eval_type ': ' att_name{att_idx} ' (' num2str(length(idx_seq_set)) ')'];

            switch metric_type
                case 'overlap'
                    title_name = ['Success plots of ' eval_type ' - ' att_fig_name{att_idx} ' (' num2str(length(idx_seq_set)) ')'];
                case 'error'
                    title_name = ['Precision plots of ' eval_type ' - ' att_fig_name{att_idx} ' (' num2str(length(idx_seq_set)) ')'];
                    if norm_dst
                        title_name = ['Norm. ' title_name];
                    end
            end

                    % evaluate tracker performance

            dataName = [tmp_mat_path 'aveSuccessRatePlot_' num2str(num_tracker) ...
                'att_' num2str(att_idx) '_alg_'  plot_type '.mat'];     

            if ~exist(dataName, 'file')
                eval_atts(sequences, trackers, eval_type, name_tracker_all, ...
                            tmp_mat_path, path_anno, rp_all, att_idx, norm_dst);
            end

            load(dataName);
            num_tracker = size(ave_success_rate_plot, 1);

            if rank_num > num_tracker || rank_num <0
                rank_num = num_tracker;
            end

            fig_name= [plot_type '_' att_name{att_idx} '_' ranking_type];
            plot_atts_draw_save(num_tracker, plot_style, ave_success_rate_plot, ...
                       idx_seq_set, rank_num, ranking_type, rank_idx, ...
                       name_tracker_all, threshold_set, title_name, ...
                       x_label_name, y_label_name, fig_name, save_fig_path, ...
                       save_fig_suf, att_idx);
        end
       
    end
    %%}
end