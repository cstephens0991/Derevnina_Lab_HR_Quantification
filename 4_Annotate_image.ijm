// Ask the user for the folder containing images & CSVs
sourceFolder = getDirectory("Select folder with images & .csv files");

// Get list of all files in the folder
fileList = getFileList(sourceFolder);

// --- Set drawing parameters ---
circleRadius = 30; // radius of circle around each point
charWidth = 35;    // approximate width of a character in pixels
setFont("SansSerif", 44, "bold");
setColor("red");   // color for circles and text

// Loop through each file
for (f = 0; f < fileList.length; f++) {
    fileName = fileList[f];

    // Only process .tif images
    if (endsWith(fileName, ".tif")) {

        filePath = sourceFolder + fileName;
        print("Processing file: " + fileName);
        open(filePath);
        imageID = getImageID(); // store image ID

        // Get base name for CSV and output
        dotIndex = lastIndexOf(fileName, ".");
        if (dotIndex != -1) {
            baseName = substring(fileName, 0, dotIndex);
        } else {
            baseName = fileName;
        }

        // Read CSV content into memory
        csvFile = sourceFolder + baseName + "_ann.csv";
        csvText = File.openAsString(csvFile);
        csvLines = split(csvText, "\n");

        // Find column indices from header
        header = split(csvLines[0], ",");
 
        xCol = -1;
        yCol = -1;
        treatCol = -1;
        for (i = 0; i < lengthOf(header); i++) {
            colName = header[i];
            // Strip any " from column name
            colName = replace(colName, "\"", "");
            if (colName == "X") xCol = i;
            if (colName == "Y") yCol = i;
            if (colName == "Treatment") treatCol = i;
        }
        if (xCol == -1 || yCol == -1 || treatCol == -1)
            exit("CSV must contain columns: X, Y, Treatment");

        // Make sure original image is active
        selectImage(imageID);

        // --- Annotate each row ---
        for (r = 1; r < lengthOf(csvLines); r++) { // skip header
            line = csvLines[r];
            if (line == "") continue; // skip empty lines
            fields = split(line, ",");
            x = parseFloat(fields[xCol]);
            y = parseFloat(fields[yCol]);
            text = fields[treatCol];

            // Draw circle around point
            makeOval(x - circleRadius, y - circleRadius, 2*circleRadius, 2*circleRadius);
            run("Draw");

            // Draw centered text above circle
            drawString(text, x - (lengthOf(text) * charWidth)/2, y - circleRadius - 2);
        }
        wait(500);
        // Flatten drawing into image pixels
        run("Flatten");
        wait(500);
        // Save annotated image
        savePath = sourceFolder + baseName + "_ann.tif";
        saveAs("Tiff", savePath);
        print("Annotated image saved as: " + savePath);

        // Close image for next iteration
        close("*");
    }
}

// Refresh display
resetMinAndMax();
print("All images processed!");
