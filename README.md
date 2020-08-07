# OCMR (v1.0) 
## Open-Access Dataset for Multi-Coil k-space Data for Cardiovascular Magnetic Resonance Imaging

Cardiovascular MRI (CMR) is a non-invasive imaging modality that provides excellent soft-tissue contrast without the use of ionizing radiation. The limited efficiency of MRI data acquisition and physiological motions necessitate data undersampling. Recovering diagnostic quality CMR images from highly undersampled data has been active area of research, and several data acquisition and processing methods have been proposed to accelerate CMR. The availability of data to objectively evaluate and compare different reconstruction methods could expedite innovation and promote clinical translation of these methods. In this work, we introduce an open-access dataset, called OCMR, that provides multi-coil k-space data from 53 fully sampled cardiac cine series (comprising 81 slices) and 212 real-time, prospectively undersampled cardiac cine series (comprising 842 slices). The fully sampled data are intended for quantitative comparison and evaluation of image reconstruction methods. The free-breathing, prospectively undersampled data are intended to qualitatively evaluate the performance and generalizability of the reconstruction methods. The data were collected on three Siemens Magnetom scanners: Prisma (3T), Avanto (1.5T) and Sola (1.5T). The OCMR dataset is comprised of HDF5 files, with data in each file following the ISMRMRD format. Each file in the dataset is assigned eight attributes, which allows selecting a subset of the dataset.

For more details, visit www.ocmr.info -- a dedicated website for the OCMR dataset.

## Download OCMR Data 
Below are the instructions to read OCMR data into Matlab and Python. Running the code will generate a nine-dimensional array, kData, for the k-space data and a structure, param, that captures acquisition parameters.

## Read Data Using Matlab
### Step 1: Download data
Download tar archive (ocmr_cine.tar.gz) by visiting https://ocmr.s3.amazonaws.com/data/ocmr_cine.tar.gz. This single file contains the entire dataset.
### Step 2: Download wrapper
Download Matlab wrapper (read_ocmr.m) and an example Matlab script (example_ocmr.m) from https://github.com/MRIOSU/OCMR/tree/master/Matlab. 
### Step 3: Download ISMRMRD libraries
Download ISMRMRD libraries from https://github.com/ismrmrd/ismrmrd/tree/master/matlab/%2Bismrmrd. Note, only the subfolder ‘/+ismrmrd’ is required.
### Step 4: Read the Data
Place read_ocmr.m, example_ocmr.m, and the entire ‘/+ismrmrd’ subfolder in one folder. Execute example_ocmr.m in Matlab and select the data file to be read; it will generatea nine-dimensional array (kData) for the k-space data and a structure (param) that captures acquisition parameters.

Note, the file listing the attributes of each data file can be found here: https://ocmr.s3.amazonaws.com/ocmr_data_attributes.csv.

## Read Data Using Python
### Step 1: Download wrapper
Download read_ocmr.py and example_ocmr.ipynb from https://github.com/MRIOSU/OCMR/tree/master/Python.
### Step 2: Read the data
Execute example_ocmr.ipynb; it will generate a nine-dimensional array (kData) for the k-space data and a structure (param) that captures acquisition parameters. Note, this step eliminates the need to explicitly download the large tar file, ocmr_cine.tar.gz.
### Step 3: Read selected files
By adjusting the filters in example_ocmr.ipynb, one could download selected files based on the attributes. Note, the file listing the attributes of each data file can be found here: https://ocmr.s3.amazonaws.com/ocmr_data_attributes.csv.

## Data Structure
Once a data file is read into Matlab or Python, it yields the k-space array, kData, and a structure, param. The kData array has nine dimensions: [kx, ky, kz, coil, phase, set, slice, rep, avg], which represent frequency encoding, first phase encoding, second phase encoding, coil, phase (time), set (velocity encoding), slice, repetition, and number of averages, respectively. For example, a cine stack with frequency encoding size 160, phase encoding size 120, number of coils 18, number of frames 60, number of slices 10 will generate kData with these dimension: 160x120x1x18x60x1x10x1x1. The second output, param, provides pertinent acquisition parameters. For example, param.FOV, param.TRes, param.flipAngle_deg, param.sequence_type specify field-of-view, temporal resolution, flip angle, and the type of sequence, respectively.

## Anonymization
All ISMRMRD data included in OCMR have been de-identified, where Protected Health Information (PHI) as well as scan date and location have been removed. All images have been manually inspected to ensure that identifying facial features are not included.

## Future Directions
The current version (v1.0) of OCMR only includes cardiac cine data. We intend to progressively expand the size of cardiac cine data and include additional CMR applications, including 2D phase-contrast MRI.

## Contact Information
For help with downloading and reading the data, contact Chong Chen (chen.7211@osu.edu); for feedback or questions about the OCMR dataset, contact Rizwan Ahmad (ahmad.46@osu.edu)
