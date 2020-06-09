# OCMR (v1.0) 
## Open-Access Repository for Multi-Coilk-space Data for Cardiovascular Magnetic ResonanceImaging

Cardiovascular MRI (CMR) is a non-invasive imaging modality that provides excellent soft-tissue contrast. 
The limited efficiency of MRI data acquisition and physiological motions requireaccelerating the acquisition process. 
Recovering diagnostic quality CMR images from highlyundersampled data has been active area of research. 
Several data acquisition and processingmethods have been proposed to accelerate CMR. Platforms to objectively evaluate and 
comparedifferent processing can expedite innovation and promote clinical translation of these methods. In this work, we introduce an open-access repository, called OCMR, that provides multi-coil
k-space data from cardiac cine.

OCMR is the fist open-access repository that provides multi-coil k-space data for cardiac cine. The
fully sampled datasets are intended for quantitative comparison and evaluation of image reconstruction
methods. The free-breathing, prospectively undersampled datasets are intended to qualitatively
evaluate the generalizability of the reconstruction method.
There are a total of 265 datasets in OCMR. 53 of those datasets have no undersampling in the
phase encoding direction, while the remaining 212 are prospectively undersampled. The datasets
were collected on three Siemens Magnetom scanners: Prisma (3T), Avanto (1.5T) and Sola (1.5T).
The data from the OCMR repository can be downloaded from the link on www.ocmr.edu. Each
dataset is assigned eight binary labels, which allows downloading a subset of the datasets.


## Reading Data into Matlab
### Step 1: Download OCMR data
Download data from the OCMR repository from the link on this page www.ocmr.edu.
As described above, selective datasets can be collected using attributes provided in Table 1.
### Step 2: Download Matlab code
Download ISMRMRD libraries from https://github.com/ismrmrd/ismrmrd/tree/master/matlab/%2Bismrmrd, Matlab wrapper read_ocmr.m, and an example of Matlab script example_main_ocmr.m from https://github.com/MRIOSU/OCMR.
### Step 3: Read the Data
Put read_ocmr.m, example_main_ocmr.m and ‘/+ismrmrd’ in the same folder. Execute example_main_ocmr.m in Matlab.
It will generate an nine-dimensional array, (kData),
for the k-space data and structure (param) that captures the acquisition parameters.

The instructions to read the data using Python will be available
in future.

## Data Structure
Once a dataset is read into Matlab, it yields the k-space array kData and the parameter param.
The array kData has nine dimensions: [kx, ky, kz, coil, phase, set, slice, rep, avg], which represent
frequency encoding, first phase encoding, second phase encoding, coil, phase (time), set (velocity
encoding), slice, repetition and number of averages, respectively. For example, an array with
frequency encoding size 160, phase encoding size 120, number of coils 18, number of frames 60,
number of slices 10 will have kData with these dimension: 160x120x1x18x60x1x10x1x1.
The second output, param, provides pertinent acquisition parameters. For example, param.FOV,
param.TRes, param.flipAngle_deg, param.sequence_type specifies field-of-view, temporal resolution,
flip angle and the type of sequence. Note, the spatial resolution, [dx; dy; dz], can be calculated
by [param.FOV(1)/size(kData,1); param.FOV(2)/size(kData,2); param.FOV(3)/size(kData,3)].
Usually, param.FOV(1) read from the data is much larger than param.FOV(2), since there is 2-fold
oversampling along the frequency encoding (kx) direction to avoid tissue overlap.
## Anonymization
All ISMRMRD datasets included in OCMR have been de-identified, where Protected Health Information
(PHI) as well as scan date and location have been removed. All datasets have been manually
inspected to ensure that identifying facial features are not included.

## Future Directions
The current version (v1.0) of OCMR
only includes cardiac cine data. Also, with 53 fully sampled datasets and 212 prospectively under-
sampled datasets, we recognize that the size of OCMR is small. We intend to progressively expand
the size of cardiac cine data and include additional CMR applications, including 2D PC-CMR.
## Acknowledgments
This work was partly funded by the National Institutes of Health under grant NIH R01HL135489.
