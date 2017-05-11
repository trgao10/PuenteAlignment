aligned_path = '../viewer/aligned_meshes/';
renamed_aligned_path = '~/Downloads/renamed_aligned_meshes/';
spreadsheet_path = '~/Dropbox/Transmission/data/PNASExtPlaty319/ClassificationTable.xlsx';

fileNames = cellfun(@(x) strrep(x, '_aligned', ''), getFileNames(aligned_path), 'UniformOutput', 0);
system(['rm -rf ' renamed_aligned_path]);
touch(renamed_aligned_path);
[~,ClTable,~] = xlsread(spreadsheet_path);

T = cell2table(ClTable(2:end,3:end),...
    'VariableNames', ClTable(1,3:end),...
    'RowNames', ClTable(2:end,1));

LabelType = 'Generic3';

for j=1:length(fileNames)
    idx = find(strcmpi(fileNames{j},T.Row));
    label = T(idx,LabelType).Variables;
    label = label{1};
    system(['cp ' aligned_path fileNames{j} '_aligned.obj ' renamed_aligned_path label '_' fileNames{j} '.obj']);
end