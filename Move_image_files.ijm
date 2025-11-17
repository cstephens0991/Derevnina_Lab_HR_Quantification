// Ask user for the parent folder containing subfolders
sourceParent = getDirectory("Select the parent folder containing subfolders");

// Ask user for the filetype they would like to process (e.g. Cy3, UV, IRlong)
suffix = getString("Enter the filetype to process", "IRlong");
targetEnding = "_" + suffix + ".tif";

// Extract the parent folder name (last part of the path)
parentName = File.getName(File.getParent(sourceParent + "dummy")); // hack to get folder name

// Clean parent folder name for use in filename
illegalChars = "<>:\"/\\|?*";
for (k = 0; k < lengthOf(illegalChars); k++) {
    char = substring(illegalChars, k, k+1);
    parentName = replace(parentName, char, "_");
}

// Hard-coded output folder name
outputFolderName = suffix + "_" + "files";

// Create destination folder inside parent folder
destFolder = sourceParent + outputFolderName + File.separator;
File.makeDirectory(destFolder);

// Normalize destFolder for comparison
destFolderNorm = toLowerCase(destFolder);
// Ensure destFolderNorm variable ends with file separator (for detecting destination folder among subfolders)
if (!endsWith(destFolderNorm, File.separator))
    destFolderNorm = destFolderNorm + File.separator;

// Get list of subfolders
subfolders = getFileList(sourceParent);

// Loop over each subfolder
for (i = 0; i < subfolders.length; i++) {

    // Skip the Output folder [NOTE: This may not work for Mac??]
    subName = subfolders[i];
    if (subName == outputFolderName + File.separator ||
        subName == outputFolderName ||
        subName == outputFolderName + "/")
        continue;

    subfolderPath = sourceParent + subfolders[i];

    // Only process if it’s a folder
    if (!File.isDirectory(sourceParent + subfolders[i]))
        continue;

    // Clean subfolder name to remove final file separator and illegal characters
    folderName = subfolders[i];
    if (endsWith(folderName, "/") || endsWith(folderName, "\\"))
        folderName = substring(folderName, 0, lengthOf(folderName) - 1);

    for (k = 0; k < lengthOf(illegalChars); k++) {
        c = substring(illegalChars, k, k+1);
        folderName = replace(folderName, c, "_");
    }
    files = getFileList(sourceParent + subfolders[i]);
    
    // Loop over files
    for (j = 0; j < files.length; j++) {
        fileName = files[j];
        
        // Skip directories inside folders
        if (endsWith(fileName, "/") || endsWith(fileName, "\\"))
            continue;

        srcPath = sourceParent + subfolders[i] + fileName;

        // Check if file matches the user-defined suffix + .tif
        if (endsWith(fileName, targetEnding)) {
          
            // Build destination path on Desktop
            destPath = destFolder + folderName + "_" + suffix + ".tif";
            
            // Copy file
            File.copy(srcPath, destPath);
            print("Copied: " + srcPath + " -> " + destPath);
        }
    }
}
