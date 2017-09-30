clear;
files = dir('*.hdf');

n = length(files);
skip = 10;

for ii=1:ceil(n/skip)
    start = (ii-1)*skip + 1;
    stop = min( ii*skip, n );
    these_files = files(start:stop);
    
    % matrix which stores a histogram in each row
    X_tropics = [];
    lats_tropics = [];
    lons_tropics = [];
    %TODO: also save time information
    
    for file=these_files'
        for k=[6 8 10 12 14 16 18 20]
            dataset_name = strcat('/Data-Set-', num2str(k));
            data_all = hdfread(strcat(file.folder, '/', file.name), dataset_name, 'Index', {[1 1],[1 1],[6596 202]});
            data = data_all(:, 30:71);

            ANC2 = hdfread(strcat(file.folder, '/', file.name), '/ANC2');
            lats = ANC2{6}; lons = ANC2{7};
            
            tropics_inx = abs(lats - 90) <= 15;
            tropics_inx = tropics_inx(:);
            undefined_inx = any(data == 255, 2);
            undefined_inx = undefined_inx(:);
            saved_inx = tropics_inx & ~undefined_inx;
            
            %data_tropics = data(saved_inx,:);
            X_tropics = [X_tropics; data(saved_inx,:)];
            lats_tropics = [lats_tropics lats(saved_inx)];
            lons_tropics = [lons_tropics lons(saved_inx)];
            
%             
%             
%             data_tropics = data(tropics_inx,:);
%             
%             % 255 means UNDEFINED, so remove all those rows
%             any_undefined_tropics = any(data_tropics == 255, 2);
%             data_tropics = data_tropics(~any_undefined_tropics, :);
%             
%             % if all entries are zero, we will have problems normalizing
%             %% WAIT: no we won't! Because now we have an extra "no cloud" state
%             %all_zeros = all(data_extended_tropics == 0, 2);
%             %data_extended_tropics = data_extended_tropics(~all_zeros, :);
% 
%             % don't normalize, so that we use less memory
%             %%% now normalize, to make it a histogram
%             %%%data = double(data) ./ sum(data, 2);
% 
%             % append to X
%             X_tropics = [X_tropics; data_tropics];
        end
        
        fprintf('Finished file: %s\n', file.name);
    end

    %save(strcat('all_histograms_extended_tropics', num2str(ii), '.mat'), 'X_extended_tropics', '-v7.3');
    save(strcat('all_histograms_tropics', num2str(ii), '.mat'), 'X_tropics', 'lats_tropics', 'lons_tropics', '-v7.3');
end

% extended_tropics_files = dir('all_histograms_extended_tropics*.mat');
% X_extended_tropics_full = [];
% for file=extended_tropics_files'
%     load(file.name);
%     X_extended_tropics_full = [X_extended_tropics_full; X_extended_tropics];
% end
% save('all_histograms_extended_tropics.mat', 'X_extended_tropics_full');

tropics_files = dir('all_histograms_extended_tropics*.mat');
X_tropics_full = [];
lats_tropics_full = [];
lons_tropics_full = [];
for file=tropics_files'
    load(file.name);
    X_tropics_full = [X_tropics_full; X_tropics];
    lats_tropics_full = [lats_tropics_full lats_tropics];
    lons_tropics_full = [lons_tropics_full lons_tropics];
end
save('all_histograms_tropics.mat', 'X_tropics_full', 'lats_tropics_full', 'lons_tropics_full', '-v7.3');

% for file=files'
%     for k=[6 8 10 12 14 16 18 20]
%         dataset_name = strcat('/Data-Set-', num2str(k));
%         data_all = hdfread(strcat(file.folder, '/', file.name), dataset_name, 'Index', {[1 1],[1 1],[6596 202]});
%         data = data_all(:, 30:71);
%         
%         % 255 means UNDEFINED, so remove all those rows
%         any_undefined = any(data == 255, 2);
%         data = data(~any_undefined, :);
%         
%         % if all entries are zero, we will have problems normalizing
%         all_zeros = all(data == 0, 2);
%         data = data(~all_zeros, :);
%         
%         % now normalize, to make it a histogram
%         data = double(data) ./ sum(data, 2);
%         
%         % append to X
%         X = [X; data];
%     end
% end
% 
% save('all_histograms.mat', 'X');
