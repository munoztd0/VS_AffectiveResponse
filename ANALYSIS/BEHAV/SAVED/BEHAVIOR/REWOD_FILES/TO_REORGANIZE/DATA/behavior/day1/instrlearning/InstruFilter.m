function [gripsFrequence] = InstruFilter ()

matfilePath = fullfile(pwd,'matfiles'); % eventually change the
matfiles = dir(fullfile(matfilePath, '*.mat'));
workingdir = pwd;
gripsFrequence = [];

for i = 1:size(matfiles,1)
    
    cd matfiles
    name = matfiles(i).name;
    load(name);
    disp(['file ' num2str(i) ' ' name ]); %that allows to see which file does
    %not work
    
    cd (workingdir);
    
    seuil = data.maximalforce/100*50;% value
    
    nlines = size(ResultsInstru.mobilizedforce,1);
    ncolons = size(ResultsInstru.mobilizedforce,2);
    
    gripsFrequence (i,:) = countgrips(seuil,nlines,ncolons,ResultsInstru.mobilizedforce);    
end

end