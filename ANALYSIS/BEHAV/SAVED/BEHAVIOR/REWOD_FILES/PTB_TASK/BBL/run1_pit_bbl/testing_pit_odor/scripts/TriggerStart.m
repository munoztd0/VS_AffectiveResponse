function [time] = TriggerStart (trigger,var) % modified 21.05.2015 for BBL room

        time = GetSecs - var.time_MRI; % time_MRI is  define in the main function
        data_out = trigger; % trigger signaling when the odor is relased
        
        if var.experimentalSetup % variable define in the main function
            outp(57392, data_out);
        end
        
    end