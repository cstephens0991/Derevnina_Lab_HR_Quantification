// Batch mode: suppress prompts, speed up processing
setBatchMode(true);

sourceFolder = getDirectory("Select folder with images & .csv files");
fileList = getFileList(sourceFolder);

for (f = 0; f < fileList.length; f++) {
    fileName = fileList[f];
    
    if (endsWith(fileName, ".tif")) {
        filePath = sourceFolder + fileName;
        print("Processing file: " + fileName);
        open(filePath);

        // Check if "_rev" appears anywhere in the filename
        if (indexOf(fileName, "_rev") != -1) {
            print("Flipping horizontally:", fileName);
            run("Flip Horizontally");
            saveAs("Tiff", filePath);  // overwrite
        } else {
            print("Skipping:", fileName);
        }

        close("*"); // force close
    }
}

setBatchMode(false);
print("Done!");