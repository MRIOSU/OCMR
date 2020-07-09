% This is an example of Matlab script to read multi-coil k-space data from ISMRMD *.h5
% Last modified: 06-08-2020 by Chong Chen (Chong.Chen@osumc.edu)
% The example fully sampled dataset 'fs_0005_1_5T.h5' can be downloaded here: https://ocmr.s3.us-east-2.amazonaws.com/data/fs_0005_1_5T.h5
% The example undersampled dataset 'us_0165_pt_1_5T.h5' can be downloaded here: https://ocmr.s3.us-east-2.amazonaws.com/data/us_0165_pt_1_5T.h5 

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
    [kData, param] = read_ocmr([dirName filename]);
    %K data is orgnazide as {'kx'  'ky'  'kz'  'coil'  'phase'  'set'  'slice'  'rep'  'avg'}
    
    %% Average the data if size(data,dim_average) > 1
    dim_average = 9;
    kData = sum(kData,dim_average)/size(kData,dim_average);
    RO = size(kData,1); CH = size(kData,4); SLC = size(kData,7); dims_phase = 5; dims_set = 6;
    
    %% Show the sampling pattern of first slice
    samp = logical(sum(abs(kData),4)); slc_idx = ceil(SLC/2);
    figure; subplot(1,3,[1 2]); imagesc( squeeze(samp(:,:,1,1,1,1,slc_idx))');
    xlabel('kx');ylabel('ky');    
    subplot(1,3,3); imagesc( squeeze(samp(end/2,:,1,1,:,1,slc_idx)));
    xlabel('phase (time)');ylabel('ky');
    
    %% Show the time-averaged image (Sum of Square coil combination)
    %%image_avg_sos {'x','y','z', 'coil = 1'};

    kdata = kData(:,:,:,:,:,:,slc_idx);
    samp_avg = sum(sum(samp(:,:,:,1,:,:,slc_idx),dims_phase),dims_set);
    kdata_avg = sum(sum(kdata,dims_phase),dims_set)./(repmat(samp_avg,[1,1,1,size(kdata,4)])+eps);
    image_avg_sos = sqrt(sum(abs(ifft2c(kdata_avg)).^2,4)); %Sum-of-Square
    figure; imagesc(image_avg_sos,[0,0.6*max(abs(image_avg_sos(:)))]);colormap(gray); 
    axis image;title(['slice:' num2str(slc_idx) ' (with RO oversampling)'])
    
    %% Reconstruct the fully-sampled dataset (Sum of Square coil combination)
    %%image_sos {'x','y','z','coil = 1', 'phase'};
    if (sum(samp(end/2,:,1,1,1,1,1),2) == size(samp,2)) % check if the dataset is fully sampled
        image = ifft2c(kdata);
        image_sos_tmp = sqrt(sum(abs(image).^2,4)); % Sum-of-Square
        image_sos = image_sos_tmp(ceil(RO/4):ceil(RO/4*3),:,:,:,:,:); % Remove readout oversampling
        fig_cine = figure;
        for rep = 1:5 % repeate 5 times
            for frame_idx = 1:size(image,5)
                figure(fig_cine);
                imagesc(image_sos(:,:,1,1,frame_idx,1,1), [0,0.6*max(abs(image_sos(:)))]); colormap(gray);
                axis image;title(['slice:' num2str(slc_idx) ' (without RO oversampling)']); pause(0.04);
            end
        end
    end
    
end

function [x] = ifft2c(x)
x = fftshift(ifft(ifftshift(x,1),[],1),1)*sqrt(size(x,1));
x = fftshift(ifft(ifftshift(x,2),[],2),2)*sqrt(size(x,2));
end
