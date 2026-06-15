classdef PrintLog
    %PRINTLOG Dispaly and print log file for HCP preprocessing codes
    % -----------------------------------------------------------
    % Written by Yueran Li in Dec 25, 2023.
    properties
        filepath;
    end
    
    methods
        function obj = PrintLog(root_path, prefix)
            root_dir = [root_path '/Logs/'];
            if ~exist(root_dir, 'dir') mkdir(root_dir); end
            if ~exist('prefix', 'var') prefix=''; end

            str_time = char(datetime('now'));
            new_str = strrep(str_time,' ', '_');
            new_str = strrep(new_str, ':', '-');
            obj.filepath = [root_dir, prefix, new_str, '.txt'];        
        end
        
        function printlog(obj, chars)
            disp(chars);
            fileID = fopen(obj.filepath, 'a+');
            fprintf(fileID, '%s\n', chars);
            fclose(fileID);
        end

        function log(obj, chars)
            fileID = fopen(obj.filepath, 'a+');
            fprintf(fileID, '%s\n', chars);
            fclose(fileID);
        end

        function printnow(obj)
            chars = char(datetime('now'));
            disp(chars);
            fileID = fopen(obj.filepath, 'a+');
            fprintf(fileID, '    %s\n', chars);
            fclose(fileID);
        end

        function delete(obj)
            delete(obj.filepath);
        end

        function edit(obj)
            edit(obj.filepath);
        end
    end
end

