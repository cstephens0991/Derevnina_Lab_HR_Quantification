# Instructions for Semi-automated HR Quantification

The following document will provide a step-by-step guide to the collection of quantitative HR data from agroinfiltrated leaves. The pipeline is currently suitable for both _Nicotiana benthamiana_ and lettuce (_Lactucs sativa_) leaves, but will be adapted for additional species in future.

For instructions regarding the preparation of _Agrobacterium tumefaciens_ cultures and carrying out agroinfiltration, please refer to the "Agroinfiltration Protocol.docx" document.

## Collection of fluorescence images

Use the ImageQuant 800 to collect fluorescence images of agroinfiltrated leaves (a setting including the Cy3 and/or IRlong channels is recommended). Note that, if using the “Lettuce_leaves” setting, image collection time is ~3 minutes. 

![ImageQuant homescreen]("./md_files/1_home-screen.svg" "Homescreen for ImageQuant 800 software")

## Formatting for saving image files
When saving images, please use the following file naming format:
TLT_PT1,PT2,PT3,PT4,PT5_L1
Where TLT  is the “top-level treatment”, or treatment applied to each patch on the whole leaf, PT1 is patch treatment #1; the patch at the top-left of the leaf. L1 is leaf number 1. 
 
Note that both the ImageQuant software (and Windows more generally) have strict character limits for file and path names. Therefore using concise names where possible is recommended. As an example, the following leaf would be saved as “LsNRC0_EV,041-DV,601-DV,301-DV,800-DV_L1”:
 
In this example, LsNRC0 is coexpressed with empty vector or autoactive sensor LsNLRs such as Ls124041DV. If there is no top level treatment, use a character or string easily identifiable as such in your file name. For example “None” or “-“.
On the ImageQuant PC, save images in the S: drive (IFS folder), in your dedicated folder. It is advisable to save all image folders generated for a single experiment in a “parent folder”. Using IFS, transfer this parent folder to your own PC. To avoid issues with overly long path names, temporarily saving on Desktop is recommended.
Open ImageJ / Fiji. Use “Plugins > Macros > Run…” to run the macro script “Move_image_files.ijm” to move greyscale signal intensity files to a new folder for image processing.
-	The script will first prompt you to navigate to and select the parent folder containing images.
 

-	Next, the script will prompt the user for the filetype they would like to process. The default (currently best option for highlighting cell death) is the “IRlong” channel. If you would prefer to use an alternative channel, enter the name in the text box (e.g “Cy3” or “UV”).
 
-	This script is hardcoded to generate an output folder within the selected parent folder. This folder will be named based on the channel selected to extract images for, e.g. “IRlong_files”.
 
-	This folder should contain all the selected channel files for this experiment. This is important for downstream scripts, which will loop over these files.
 

Flip images of leaf undersides [optional]

If the underside of the leaf has been imaged, these images may be flipped horizontally (to ensure treatments are correctly matched to leaf patches) using the “Flip_rev_images.ijm” macro script, again using ImageJ.
Take HR measurements
Once all the selected channel files have been grouped into a single folder, the ImageJ macro “Get_HR_score.ijm” may be run, to collect quantitative HR data.
-	Select the folder containing your images to analyse, e.g. “IRlong_files”
 

-	The first image will be opened and a prompt will ask for the number of infiltration patches in the image (e.g. the leaf in the below image has five infiltration patches). Click “OK” to continue.
 
-	You will also be prompted to select the number of replicate measurements you would like to take for each patch. The default is 3. Press “OK” to continue.
 
-	Before measuring the infiltration patches, a baseline measurement of the uninfiltrated leaf must be taken. Click on an uninfiltrated portion of the leaf and click “OK” to continue. Select three uninfiltrated areas in total, to generate an averaged baseline for uninfiltrated leaf. 
 
-	The script will now prompt you to measure the first patch. Begin from the top left infiltration zone. Click on part of this patch and click “OK” to continue. Repeat this process for this patch x times, depending on the number of reps selected above.
 
-	Once you have taken the appropriate number of reps for this patch, move on to the second patch. Be sure to measure patches in the same order in which the patches were listed in the file name above.
 

-	Note: if you lose track of how many measurements you have taken, check the “Log” window. This will also display the total number of measurements to take for this image (e.g. 5 patches x 3 reps  = 15 measurements).
 
-	Continue taking measurements. Once the final measurement has been recorded. The image will automatically be closed and the next image opened. Again, the user will be prompted for the number of patches in the image and the number of reps.
-	When the measurements have been taken for all images in the folder, the message “All files processed!” will e displayed in the Log.
-	Check the files folder. For each of the selected channel .tif images, there should be two .csv files present: one for the “zero” measurements (background leaf) and another for the patch HR scores.
Adding treatment data to HR score files
Each of the HR score csv files contains the following data for each zone selected:
•	The measurement number
•	The mean signal intensity score for the area measured
•	The X and Y coordinates for the measurement
To R script “Add_treatment_data.R” can be used to add treatment metadata to these dataframes, using the information in the file names. 
Open the file in RStudio. The Source window should display the full script:
 
-	Edit the “setwd” command, to reflect the location of the .tif and .csv files from the previous stage.
-	If necessary, change the number of reps to reflect the number used .
-	Run the script. For each file processed, the Console window should display in the output:
o	Whether the top-level treatment is composed of one or more treatments
o	The name of the output .csv file with the treatment metadata included.
-	These “_ann.csv” files should be located in the “IRlong_files” destination folder, along with the raw data .csv files and the .tif files.
 
When opening the resulting dataframes in Excel, the “Treatment” column is interpreted as a formula. Excel generates the error message “#NAME?”, but the treatment name is unaffected.
Generate annotated images
In order to confirm that the treatment metadata added to the dataframes is correct, a series of annotated image files can be generated and checked manually to confirm:
•	That measurements were taken in the correct positions, within patches.
•	The treatment metadata associated with those measurements.
To generate annotated images, open ImageJ / Fiji and run the “Annotate_image.ijm” macro.
-	Select the folder containing the files for annotation.
 
-	The script should run automatically, opening files, adding the annotations of measurement location (X and Y axes) and treatment data, saving the annotated image file as “…_ann.tif”, closing the image and opening the next image in the folder.
 

Check through the annotated images, to confirm that the treatment annotations are as expected for each patch.

The annotated dataframes (“…_ann.csv” files) can now be combined and plots of the data generated…
