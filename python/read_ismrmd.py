import os
import ismrmrd
import ismrmrd.xsd
import numpy as np

def read_ismrmrd(filename):

        # Load file
    #filename = './data/fs_0015_3T.h5'
    if not os.path.isfile(filename):
        print("%s is not a valid file" % filename)
        raise SystemExit
    dset = ismrmrd.Dataset(filename, 'dataset', create_if_needed=False)
    header = ismrmrd.xsd.CreateFromDocument(dset.read_xml_header())
    enc = header.encoding[0]

    # Matrix size
    eNx = enc.encodedSpace.matrixSize.x
    #eNy = enc.encodedSpace.matrixSize.y
    eNz = enc.encodedSpace.matrixSize.z
    eNy = (enc.encodingLimits.kspace_encoding_step_1.maximum + 1); #no zero padding along Ny direction

    # Field of View
    eFOVx = enc.encodedSpace.fieldOfView_mm.x
    eFOVy = enc.encodedSpace.fieldOfView_mm.y
    eFOVz = enc.encodedSpace.fieldOfView_mm.z
    
    # Save the parameters    
    param = dict();
    param['TRes'] =  str(header.sequenceParameters.TR)
    param['FOV'] = [eFOVx, eFOVy, eFOVz]
    param['TE'] = str(header.sequenceParameters.TE)
    param['TI'] = str(header.sequenceParameters.TI)
    param['echo_spacing'] = str(header.sequenceParameters.echo_spacing)
    param['flipAngle_deg'] = str(header.sequenceParameters.flipAngle_deg)
    param['sequence_type'] = header.sequenceParameters.sequence_type

    # Read number of Slices, Reps, Contrasts, etc.
    nCoils = header.acquisitionSystemInformation.receiverChannels
    try:
        nSlices = enc.encodingLimits.slice.maximum + 1
    except:
        nSlices = 1
        
    try:
        nReps = enc.encodingLimits.repetition.maximum + 1
    except:
        nReps = 1
               
    try:
        nPhases = enc.encodingLimits.phase.maximum + 1
    except:
        nPhases = 1;

    try:
        nSets = hdr.encoding.encodingLimits.set.maximum + 1;
    except:
        nSets = 1;

    try:
        nAverage = hdr.encoding.encodingLimits.average.maximum + 1;
    except:
        nAverage = 1;   
        
    # TODO loop through the acquisitions looking for noise scans
    firstacq=0
    for acqnum in range(dset.number_of_acquisitions()):
        acq = dset.read_acquisition(acqnum)

        # TODO: Currently ignoring noise scans
        if acq.isFlagSet(ismrmrd.ACQ_IS_NOISE_MEASUREMENT):
            #print("Found noise scan at acq ", acqnum)
            continue
        else:
            firstacq = acqnum
            print("Imaging acquisition starts acq ", acqnum)
            break

    # assymetry echo
    kx_prezp = 0;
    acq_first = dset.read_acquisition(firstacq)
    if  acq_first.center_sample*2 <  eNx:
        kx_prezp = eNx - acq_first.number_of_samples
         
    # Initialiaze a storage array
    param['kspace_dim'] = {'kx ky kz coil phase set slice rep avg'};
    all_data = np.zeros((eNx, eNy, eNz, nCoils, nPhases, nSets, nSlices, nReps, nAverage), dtype=np.complex64)

    # Loop through the rest of the acquisitions and stuff
    for acqnum in range(firstacq,dset.number_of_acquisitions()):
        acq = dset.read_acquisition(acqnum)

        # Stuff into the buffer
        y = acq.idx.kspace_encode_step_1
        z = acq.idx.kspace_encode_step_2
        phase =  acq.idx.phase;
        set =  acq.idx.set;
        slice =  acq.idx.slice;
        rep =  acq.idx.repetition;
        avg = acq.idx.average;        
        all_data[kx_prezp:, y, z, :,phase, set, slice, rep, avg ] = np.transpose(acq.data)
        
    return all_data,param