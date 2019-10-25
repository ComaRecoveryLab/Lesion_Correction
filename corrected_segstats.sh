#!/bin/bash

# Wrapper script to extract correction volumetric data.

export SUBJECTS_DIR=$1
SUBJECTS_LIST=$2
OUTPUT_TABLE=$3

if [[ $SUBJECTS_DIR == "" ]] || [[ $SUBJECTS_LIST == "" ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--h" ]] ; then

	echo "The purpose of this program is to take in surface labels of lesion-induced"
	echo "innacuracies in your subject's pial surfaces, and use them as masks to create"
	echo "a 'corrected' volumetric statistics table. The 'corrected' table will only"
	echo "include regions of the subject's cortex that don't overlap with the surface"
	echo "label."
	echo ""
	echo "Please provide the SUBJECTS_DIR, SUBJECTS_LIST, and OUTPUT_TABLE so that the"
	echo "program can apply the volume correction to all subjects with lesion labels."
	echo ""
	echo "Usage: corrected_segstats.sh SUBJECTS_DIR SUBJECTS_LIST OUTPUT_TABLE"
	exit 0

fi

cd $SUBJECTS_DIR

# Loop through both hemispheres.
for HEMI in lh rh; do

	HEMI_SUBJECTS_LIST=""
	
	# Open a loop that will read through all subjects in the subjects_list.txt.
	while IFS= read -r SUBJECT; do
	
		# Check to make sure there is a manual label for the current hemisphere.
		if [ -f $SUBJECTS_DIR/$SUBJECT/label/${HEMI}.lesion-01.label ]; then

			# Create an empty string that will eventually be a list of lesions in this subjects current hemisphere.
			LABEL_LIST=""

			# Loop through lesion labels in the current subjects hemisphere.
			for LABEL_PATH in $SUBJECTS_DIR/$SUBJECT/label/${HEMI}.lesion-*.label; do

				# Make a list of all lesion labels in the current subject's hemisphere.
				LABEL_LIST="$LABEL_LIST $LABEL_PATH"

			done		

			# Make an annotation of all the lesion labels in the current hemisphere.
			mris_label2annot \
				--s $SUBJECT \
				--h $HEMI \
				--l $LABEL_LIST \
				--annot-path $SUBJECT/label/${HEMI}.all-lesions.annot \
				--ctab $FREESURFER_HOME/FreeSurferColorLUT.txt \
				--sd $SUBJECTS_DIR

			# Turn the annotation file into a surface overlay.
			mri_annotation2label \
				--subject $SUBJECT \
				--hemi $HEMI \
				--annotation all-lesions \
				--seg $SUBJECT/label/${HEMI}.all-lesions.mgz \
				--ctab $FREESURFER_HOME/FreeSurferColorLUT.txt \
				--sd $SUBJECTS_DIR

			# Extract corrected volumetric stats
			mri_segstats \
				--annot $SUBJECT $HEMI aparc \
				--i $SUBJECT/surf/${HEMI}.volume \
				--mask $SUBJECT/label/${HEMI}.all-lesions.mgz \
				--maskinvert \
				--o $SUBJECT/stats/$HEMI.aparc.volume.corrected.stats \
				--ctab-default
				--sd $SUBJECTS_DIR
		
			HEMI_SUBJECTS_LIST="$HEMI_SUBJECTS_LIST $SUBJECT"

		fi

		# Create a table with every subject's corrected volumetric stats file.
		aparcstats2table \
			--subjects $HEMI_SUBJECTS_LIST \
			--hemi=$HEMI \
			--measure=volume \
			--parc=aparc.volume.corrected \
			--tablefile=${HEMI}.${OUTPUT_TABLE} \

	# Close the subject loop and specify the text file to loop through.
	done < $SUBJECTS_LIST

# Close the hemisphere loop.
done 

