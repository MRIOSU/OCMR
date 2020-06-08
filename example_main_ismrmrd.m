% This is an example of Matlab script to read K-space from cardiac ISMRMD *.h5 data, and display the
% sampling pattern and time-averaged image
% Last modified: 0608-2020 by Chong Chen (Chong.Chen@osumc.edu)

close all;
restoredefaultpath

[fileName,dirName,FilterIndex] = uigetfile('*.h5','MultiSelect', 'on');
for k = 1:size(cellstr(fileName),2)
    if iscell(fileName)
        filename = fileName{k};
    else
        filename = fileName;
    end

    %% read the data 
    [data, param] = read_ismrmrd([dirName filename]);
    
    %% Average the data if size(data,dim_average) > 1
    dim_average = 9;
    data = sum(data,dim_average)/size(data,dim_average);
    
    %% Show the sampling pattern of first slice
    samp = logical(sum(abs(data),4)); tmp_slc = 1;
    figure; subplot(1,2,2); imagesc( squeeze(samp(end/2,:,1,1,:,1,tmp_slc)));
    xlabel('phase');ylabel('ky');
    subplot(1,2,1); imagesc( squeeze(samp(:,:,1,1,1,1,tmp_slc)));
    xlabel('ky');ylabel('kx');
    
    %% Show the time-averaged image
    CH = size(data,4); SLC = size(data,7); dims_phase = 5; dims_set = 6;    
    figure
    for sl = 1:SLC
        kdata = data(:,:,:,:,:,:,sl);
        samp_avg = sum(sum(samp(:,:,:,1,:,:,sl),dims_phase),dims_set);
        kdata_avg = sum(sum(kdata,dims_phase),dims_set)./(repmat(samp_avg,[1,1,1,size(kdata,4)])+eps);
        image_avg = ifft2c(kdata_avg);
        subplot(min(2,SLC),ceil(SLC/2),sl); imagesc(sqrt(sum(image_avg.*conj(image_avg),4))); 
        colormap(gray); axis image;title(['slice:' num2str(sl)])       
    end
     
end

function [x] = ifft2c(x)
x = fftshift(ifft(ifftshift(x,1),[],1),1)*sqrt(size(x,1));
x = fftshift(ifft(ifftshift(x,2),[],2),2)*sqrt(size(x,2));
end