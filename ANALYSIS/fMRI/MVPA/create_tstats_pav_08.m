function create_tstats_pav_08(subID)

% created by Logan
% last modified on MAY 2019 by Eva to get the beta on the onsets of the
% anticipation phase only


% | add spm12 to matlab path
addpath(genpath('/usr/local/external_toolboxes/spm12/'))
spm('defaults','FMRI');
spm_jobman('initcfg');

% | define path
subID = char(subID);
%subID = '07';

ana_name = fullfile ('MVPA-08');
homedir = '/home/eva/PAVMOD/';

%homedir = '/Users/evapool/mountpoint/';
spm_dir = fullfile(homedir,'DATA','brain','MODELS','RSA',ana_name,['sub-' subID],'glm','beta_everytrial_pav');


%==========================================================================
%% Section 1: Make T Stats
%==========================================================================

maketstat(spm_dir, subID)
    
%==========================================================================
%% Section 2: Concatenate Scans
%==========================================================================
concatenateScans(spm_dir)

 
%==========================================================================
%% Auxiliary function
%==========================================================================

    function [] = maketstat(spm_dir, subID)

        
        %copy SPM.mat and rename so it doesn't become overwritten
        source_file      = fullfile (spm_dir,'SPM.mat');
        destination_file = fullfile(spm_dir,'SPM_glm.mat');
        copyfile(source_file, destination_file);
        
        imp = load([spm_dir,'/SPM_glm.mat']);
        
        
        %?get regressors corresponding to the Trials by locating 'Trial' in
        %regressor name
        names = imp.SPM.xX.name;
        temp_inds = strfind(names,'Trial');
        temp_inds2 = cell2mat(cellfun(@isempty, temp_inds, 'UniformOutput', 0));
        ant_trial_inds = find(~temp_inds2);
        
        matlabbatch{1}.spm.stats.con.spmmat = {[spm_dir,'/SPM_tstats.mat']};
        
        %create contrasts and t-stats for all the trials
        num_betas = length(names);
        num_trials = length(ant_trial_inds);
        for i=1:num_trials
            %create a contrast vector with everything zero except that trial a one
            contrast_vector = zeros(1,num_betas);
            contrast_vector(ant_trial_inds(i)) = 1;
            matlabbatch{1}.spm.stats.con.consess{i}.tcon.name = ['Trial ',num2str(i)];
            matlabbatch{1}.spm.stats.con.consess{i}.tcon.convec = contrast_vector;
            matlabbatch{1}.spm.stats.con.consess{i}.tcon.sessrep = 'none';
        end
        matlabbatch{1}.spm.stats.con.delete = 1;
        
        save([spm_dir,'/batch_contrasts_model-',subID,'.mat'],'matlabbatch');
        spm_jobman('run',matlabbatch)
    end

    function [] = concatenateScans(spm_dir)
        imp = load([spm_dir,'/SPM_glm.mat']);
        
        %get regressors corresponding to the Trials by locating 'Trial' in
        %regressor name
        names = imp.SPM.xX.name;
        temp_inds = strfind(names,'Trial');
        temp_inds2 = cell2mat(cellfun(@isempty, temp_inds, 'UniformOutput', 0));
        trial_inds = find(~temp_inds2);
        
        %get scan filenames of the tstats we created
        scan_filenames = {};
        for i=1:length(trial_inds)
            tstat_num = i;
            %add beta number to 1000 so number is 4 digits long in string
            temp_tstat_str = num2str(1000+tstat_num);
            tstat_str = ['spmT_',temp_tstat_str,'.nii'];
            %change the leading 1 to a 0
            if strcmp(tstat_str(6),'1')
                tstat_str(6) = '0';
            else
                disp('error: no leading 1')
                break
            end
            scan_filenames{end+1,1} = [spm_dir,'/',tstat_str,',1'];
        end
        
        %concatenate tstats for every trial in a 4D volume
        matlabbatch{1}.spm.util.cat.vols = scan_filenames;
        matlabbatch{1}.spm.util.cat.name = 'tstat_all_trials_4D.nii';
        matlabbatch{1}.spm.util.cat.dtype = 4;
        
        spm_jobman('run',matlabbatch)
    end

end
