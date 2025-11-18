// Ask the user for the folder containing images
sourceFolder = getDirectory("Select folder with images");

// Get list of image files in the folder
fileList = getFileList(sourceFolder);

// set point tool for measurements
setTool("point"); 
// Set Measurement to record only Mean and X / Y values
run("Set Measurements...", "mean decimal=3");

// Loop through each file
for (f = 0; f < fileList.length; f++) {
    fileName = fileList[f];

    // Only process .tif files
    if (endsWith(fileName, ".tif")) {
        filePath = sourceFolder + fileName;
        print("Processing file: " + fileName);
        open(filePath);

        // Clear previous selections
        run("Select None");
        run("Clear Results"); // clear Results table

        // Ask number of patches and replicates per image
        patches = getNumber("Please enter the number of patches in the image: " + fileName, 5);
        reps = getNumber("Please enter the number of replicates per patch: " + fileName, 3);
        iterations = patches * reps;
        print("Measurements for this image: " + iterations);

        // Set zero score on uninfiltrated patch of leaf
        for (i = 0; i < 3; i++) {
            waitForUser("Click on uninfiltrated leaf to set zero score");
            // Get pixel coordinates of the click
            getSelectionCoordinates(xpoints, ypoints);

            // Draw the measurement oval
            makeOval(xpoints[0]-18, ypoints[0]-18, 36, 36);

            // Measure mean intensity inside the oval
            run("Measure");

            // Overwrite X and Y columns in Results table with exact click coordinates
            setResult("X", i, xpoints[0]);
            setResult("Y", i, ypoints[0]);
            }

        // Prepare CSV filename - remove ".tif" suffix
        dotIndex = lastIndexOf(fileName, ".");
        if (dotIndex != -1) {
            baseName = substring(fileName, 0, dotIndex);
        } else {
            baseName = fileName;
        }

        // Clean illegal Windows filename characters
        illegalChars = "<>:\"/\\|?*";
        for (k = 0; k < lengthOf(illegalChars); k++) {
            char = substring(illegalChars, k, k+1);
            baseName = replace(baseName, char, "_");
        }

        // Save CSV with zero values in same folder as the image
        csvFile = sourceFolder + baseName + "_zero.csv";
        saveAs("Results", csvFile);
        print("Saved CSV: " + csvFile);

        // Close image for next file
        run("Clear Results");


        // Measurement loop for this image file
        for (i = 0; i < iterations; i++) {
            waitForUser("Click on patch to take measurement");

            // Get pixel coordinates of the click
            getSelectionCoordinates(xpoints, ypoints);

            // Draw the measurement oval
            makeOval(xpoints[0]-18, ypoints[0]-18, 36, 36);

            // Measure mean intensity inside the oval
            run("Measure");

            // Overwrite X and Y columns in Results table with exact click coordinates
            setResult("X", i, xpoints[0]);
            setResult("Y", i, ypoints[0]);

            // Print iteration number
            print("Measurement " + (i+1) + " taken.");
        }

        // Save CSV in same folder as the image
        csvFile = sourceFolder + baseName + ".csv";
        saveAs("Results", csvFile);
        print("Saved CSV: " + csvFile);

        // Close image for next file
        close();
        run("Clear Results");
    }
}

print("All files processed!");
