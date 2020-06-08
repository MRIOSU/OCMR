function [Kdata, param] = read_ismrmrd(file_name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Before running the code, Please download the ISMRMRD matlab library here:
% https://github.com/ismrmrd/ismrmrd/tree/master/matlab/%2Bismrmrd
%
% Input:  *.h5 file name
% Output: Kdata    k-space data, orgnazide as {'kx'  'ky'  'kz'  'coil'  'phase'  'set'  'slice'  'rep'  'avg'}
%         param  some parameters of the scan
%                param.enc_Size = [kx ky kz]
%                param.enc_FOV = [FOV_x, FOV_y, thickness]  
%                param.ksapce_dim = {'kx'  'ky'  'kz'  'coil'  'phase'  'set'  'slice'  'rep'  'avg'}
%                param.sequenceParameters (TR, TE, TI, flipAngle_deg, sequence_type, echo_spacing)
%

% This is a function to read K-space from ISMRMD *.h5 data
% Modifid by Chong Chen (Chong.Chen@osumc.edu) based on the Matlab script "test_recon_dataset.m"
% from https://github.com/ismrmrd/ismrmrd/tree/master/examples/matlab
%
% Capabilities:
%   2D/3D + Time
%   partial fourier
%   Assymetry Echo
%   multiple slices/slabs
%   multiple contrasts, repetitions
%   multiple averages
%   
% Limitations:
%   ignores noise scans (no pre-whitening)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loading an existing file %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename = file_name;
if exist(filename, 'file')
    dset = ismrmrd.Dataset(filename, 'dataset');
else
    error(['File ' filename ' does not exist.  Please generate it.'])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Read some fields from the XML header %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We need to check if optional fields exists before trying to read them
hdr = ismrmrd.xml.deserialize(dset.readxml);

%% Encoding and reconstruction information
% Matrix size
enc_Nx = hdr.encoding.encodedSpace.matrixSize.x;
enc_Ny = hdr.encoding.encodedSpace.matrixSize.y;
enc_Nz = hdr.encoding.encodedSpace.matrixSize.z;

% Field of View
enc_FOVx = hdr.encoding.encodedSpace.fieldOfView_mm.x;
enc_FOVy = hdr.encoding.encodedSpace.fieldOfView_mm.y;
enc_FOVz = hdr.encoding.encodedSpace.fieldOfView_mm.z;

param.enc_Size = [enc_Nx  enc_Ny  enc_Nz];
param.enc_FOV = [enc_FOVx enc_FOVy enc_FOVz];

param.sequenceParameters = hdr.sequenceParameters;

% Number of slices, coils, repetitions, contrasts etc.
% We have to wrap the following in a try/catch because a valid xml header may
% not have an entry for some of the parameters

try
    nSlices = hdr.encoding.encodingLimits.slice.maximum + 1;
catch
    nSlices = 1;
end

try
    nCoils = hdr.acquisitionSystemInformation.receiverChannels;
catch
    nCoils = 1;
end

try
    nReps = hdr.encoding.encodingLimits.repetition.maximum + 1;
catch
    nReps = 1;
end


try
    nPhases = hdr.encoding.encodingLimits.phase.maximum + 1;
catch
    nPhases = 1;
end

try
    nSets = hdr.encoding.encodingLimits.set.maximum + 1;
catch
    nSets = 1;
end

try
    nAverage = hdr.encoding.encodingLimits.average.maximum + 1;
catch
    nAverage = 1;
end

% TODO add the other possibilities

%% Read all the data
% Reading can be done one acquisition (or chunk) at a time,
% but this is much faster for data sets that fit into RAM.
D = dset.readAcquisition();

%% Discard PilotTone Signal
userParameterName = [hdr.userParameters.userParameterLong.name];
userParameterValue = [hdr.userParameters.userParameterLong.value];
 if ( contains(userParameterName,'PilotTone') && userParameterValue(4) == 1)
     for p = 1:D.getNumber
         D.data{p}([1:3,end],:) = 0;
     end
 end

%% Extract noise scans and phase corr scan
isNoise = D.head.flagIsSet('ACQ_IS_NOISE_MEASUREMENT');
noiseScan = find(isNoise==0,1,'first') - 1;
if noiseScan > 0
    noise = D.select(1:noiseScan);
else
    noise = [];
end
meas  = D.select( (noiseScan + 1):D.getNumber);
clear D;

isPhaseCorr = meas.head.flagIsSet('ACQ_IS_PHASECORR_DATA');
PhaseCorrScan = find(isPhaseCorr==0,1,'first') - 1;
if noiseScan > noiseScan
    phasecorr = meas.select( 1 : PhaseCorrScan);
else
    phasecorr = [];
end

param.noise = noise;
param.phasecorr = phasecorr;

meas  = meas.select( (PhaseCorrScan + 1):meas.getNumber);

%% assymetry echo
kx_prezp = 0;
if ( meas.head.center_sample(1)*2 <  enc_Nx)
    kx_prezp = enc_Nx - meas.head.number_of_samples(1);
end

%% isotropic resolution
ky_prezp = floor((enc_Ny - hdr.encoding.encodingLimits.kspace_encoding_step_1.center*2)/2);
param.Phase_Encoding_max = (hdr.encoding.encodingLimits.kspace_encoding_step_1.maximum + 1);

%% Read the K-space
param.kspace_dim = {'kx',  'ky',  'kz', 'coil', 'phase', 'set', 'slice', 'rep', 'avg'};
Kdata = zeros(enc_Nx, enc_Ny, enc_Nz, nCoils, nPhases, nSets, nSlices, nReps, nAverage);
isReverse = meas.head.flagIsSet('ACQ_IS_REVERSE');
for p = 1:meas.getNumber
    ky = meas.head.idx.kspace_encode_step_1(p) + 1 + ky_prezp;
    kz = meas.head.idx.kspace_encode_step_2(p) + 1;
    phase =  meas.head.idx.phase(p) + 1;
    set =  meas.head.idx.set(p) + 1;
    slice =  meas.head.idx.slice(p) + 1;
    rep =  meas.head.idx.repetition(p) + 1;
    avg = meas.head.idx.average(p) + 1;
    if isReverse(p)
        Kdata((kx_prezp+1):end,ky,kz,:,phase, set, slice, rep, avg) = flipud(meas.data{p});
    else
        Kdata((kx_prezp+1):end,ky,kz,:,phase, set, slice, rep, avg) = (meas.data{p});
    end   
end

end
