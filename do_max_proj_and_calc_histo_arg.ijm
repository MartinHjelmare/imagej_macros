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
dirChosen = getArgument()+"/";
topDir = dirChosen;

pathMaxProjs = topDir+"maxprojs/";
File.makeDirectory(pathMaxProjs);

fileArray = newArray();
fileArray = listFiles(dirChosen, topDir, ".+\.tif$", fileArray);

while (fileArray.length != 0) {
	
	channelIndex = lastIndexOf(fileArray[0], "--C");
	channelString = substring(fileArray[0], channelIndex+3, channelIndex+5);
	wellXIndex = lastIndexOf(fileArray[0], "--U");
	wellX = substring(fileArray[0], wellXIndex+3, wellXIndex+5);
	wellYIndex = lastIndexOf(fileArray[0], "--V");
	wellY = substring(fileArray[0], wellYIndex+3, wellYIndex+5);

	imagesToStack = newArray();
	newFileArray = newArray();
	//testing
	print("Empty newFileArray");
	print(newFileArray.length);

	for (i = 0; i < fileArray.length; i++) {
		if (matches(fileArray[i], ".+--U"+wellX+".+--V"+wellY+".+--C"+
				channelString+".+\.tif$")) {
			imagesToStack = addToArray(fileArray[i], imagesToStack,
			                (imagesToStack.length));
		} else {
			newFileArray = addToArray(fileArray[i], newFileArray,
			                (newFileArray.length));
		}
	}
	//testing
	print("Filling newFileArray");
	print(newFileArray.length);

	fileArray = newFileArray;

	for (i = 0; i < imagesToStack.length; i++) {
		open(imagesToStack[i]);
		if ((512 != getWidth()) || (512 != getHeight())) {
			close();
		}
	}
	run("Images to Stack", "name=Stack title=[] use");
	run("Z Project...", "projection=[Max Intensity]");
    pathProjImage = pathMaxProjs+"U"+wellX+"--V"+wellY+"--C"+channelString+".tif";
	saveAs("Tiff", pathProjImage);
    nBins = 256;
	getHistogram(values, counts, nBins);
	d=File.open(pathMaxProjs+"U"+wellX+"--V"+wellY+"--C"+channelString+".ome.csv");
	print(d, "bin,count"); 
	for (k=0; k<nBins; k++) { 
		print(d, k+","+counts[k]); 
	}
	File.close(d);
	close("*");
    err=File.rename(pathProjImage, pathProjImage+".bak");
    for (i = 0; i < imagesToStack.length; i++) {
        err=File.rename(imagesToStack[i], imagesToStack[i]+".bak");
	}
}
print("Analysis finished!");
