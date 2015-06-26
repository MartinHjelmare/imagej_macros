setBatchMode(true)

// From OpenSeriesUsingFilter.txt
// Recursive file listing.
count = 1;
function listFiles(dir, rootDir, search, array) {
	fileList = getFileList(dir);
	for (i=0; i<fileList.length; i++) {
		if (endsWith(fileList[i], "/")) {
			array = listFiles(""+dir+fileList[i], rootDir, search, array);
		} else {
			if (filter(i, fileList[i], search)) {
				pathToString = dir + fileList[i];
				array = addToArray(pathToString, array, array.length);
				//testing
				print((count++) + ": " + array[array.length-1]);
			}
		}
	}
	return array;
}

// From OpenSeriesUsingFilter.txt
// Filter files in chosen directory and sub-directories to use for analysis,
// by conditions set below.
function filter(i, name, search) {
	// is directory?
	if (endsWith(name, File.separator)) return false;
	
	// does name match regex search?
	if (matches(name, search) != true) return false;

	// open only first 10 images
	// if (i >= 10) return false;

	return true;
}

// From Array_Tools.ijm.
// Adds the value to the array at the specified position,
// expanding if necessary. Returns the modified array.
function addToArray(value, array, position) {
	if (position<lengthOf(array)) {
		array[position]=value;
    	} else {
    		temparray=newArray(position+1);
        	for (i=0; i<lengthOf(array); i++) {
        		temparray[i]=array[i];
        	}
        	temparray[position]=value;
        	array=temparray;
    	}
    	return array;
}

// Set path to image directory.
dirChosen = getDirectory("Choose a Directory ");
topDir = dirChosen;

pathLUTs = topDir+"pngs/";
File.makeDirectory(pathLUTs);

fileArray = newArray();
fileArray = listFiles(dirChosen, topDir, ".+\.tif$", fileArray);

for (i = 0; i < fileArray.length; i++) {

	//print(fileArray[i]);
	open(fileArray[i]);
	imTIFName = getInfo("image.filename");
	imPNGName = replace(imTIFName, "tif", "png");

	if ((2048 != getWidth()) || (2048 != getHeight())) {
		close();
	} else {

		run("8-bit");

		if (matches(fileArray[i], ".+C00.+\.tif$")) {
			run("Green");
		} else if (matches(fileArray[i], ".+C01.+\.tif$")) {
			run("Blue");
		} else if (matches(fileArray[i], ".+C02.+\.tif$")) {
			run("Yellow");
		} else if (matches(fileArray[i], ".+C03.+\.tif$")) {
			run("Red");
		}
	
	
		print(pathLUTs+imPNGName);
		saveAs("PNG", pathLUTs+imPNGName);
		close("*");
	}
}
print("Analysis finished!");