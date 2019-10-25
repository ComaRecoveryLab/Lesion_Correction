Qualitative and Quantitative Assessment of MRI Data

SNR: We calculated SNR for each subject using the “wm-anat-snr” FreeSurfer tool available in FreeSurfer v6.0. Voxels from the subject’s normalized T1 (norm.mgz) that containing white matter (WM) as defined by the subject’s aparc+aseg.mgz are used to calculate SNR with this tool.

 SNR = (mean WM)/(stdev WM)

We ran the following command for each subject:

  wm-anat-snr –s <Subject ID>

CNR: We calculated CNR for each subject using the “mri_cnr” FreeSurfer tool available in FreeSurfer v6.0. This tool finds the average between two CNRs: the subject’s (1) WM and gray matter (GM) CNR and (2) gray matter and cerebrospinal fluid (CSF) CNR. The average CNR is then calculated and reported for each hemisphere. Finally, the CNR for both hemispheres are averaged to produce a full brain CNR. 

WM-GM CNR = (delta(WM,GM)^2)/(total variance)
GM-CSF CNR = (delta(GM,CSF)^2)/(total variance)
Hemisphere CNR = (WM-GM CNR + GM-CSF CNR) x 2
Full Brain CNR = (Left Hemisphere CNR + Right Hemisphere CNR) x 2

We ran the following command for each subject:

  mri_cnr \
  $SUBJECTS_DIR/<Subject ID>/surf \
  $SUBJECTS_DIR/< Subject ID>/mri/orig.mgz

Lesion Correction Method

Please follow the manual lesion labeling instructions found in the fourth paragraph of the Lesion Correction – Methodological Principles and Approach section of the Supplemental Materials. Once the labels have been created for every applicable subject, use the “corrected_segstats.sh” command to create corrected volumetric measures for all your subjects.
Command usage: corrected_segstats.sh SUBJECTS_DIR SUBJECTS_LIST OUTPUT_TABLE

SUBJECTS_DIR:   The path to all of your FreeSurfer subjects’ directories
SUBJECTS_LIST:  The path to a file listing all of your subject IDs
OUTPUT_TABLE:   Your desired name for the output volume table. The file will be called $HEMI.<OUTPUT_TABLE>.
