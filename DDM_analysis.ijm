// This is a FIJI/ImageJ macro that runs the DDM algorithm on an .h5 video file.
// The output is a stack of unprocessed Fourier difference images.

RawImagesTitle = getTitle();
numFrames = nSlices();

// Generates an array of <=numPoints unique log-spaced integers
function getIntegerLogRange(range, numPoints) {
   logSpacing = Math.log10(range) / numPoints;
   intArray = Array.getSequence(numPoints);
   for (i=0; i<numPoints; i++) {
      intArray[i] = Math.floor(Math.pow(10, intArray[i] * logSpacing));
   }
   uniqueCount = 0;
   uniqueArray = Array.getSequence(numPoints);
   for (i=0; i<numPoints-1; i++) {
      if (intArray[i] != intArray[i+1]) {
         uniqueArray[uniqueCount] = intArray[i];
         uniqueCount++;
      }
   }
   uniqueArray[uniqueCount] = intArray[intArray.length-1];
   return Array.trim(uniqueArray, uniqueCount + 1);
}

// Generates array of >=numLags unique log-spaced integers
// The length should be as close as possible to numLags
function logSpacedLags(numFrames, numLags) {
    arrayLength = 0;
    numPoints = numLags;
    while (arrayLength < numLags) {
        candidateLags = getIntegerLogRange(numFrames, numPoints);
        numPoints++;
        arrayLength = candidateLags.length;
    }
    return candidateLags;
}

// get log-spaced frame lags
numLags = 50;
frameLags = logSpacedLags(numFrames,numLags);
//Array.print(frameLags);

for (lag=0; lag<numLags; lag+=1) {
	frameLag = frameLags[lag];
	//reductionFactor = 1; // This uses the maximum number of difference images
	reductionFactor = (numFrames-frameLag)/10; // Reduce difference image stacks to make computation faster

	setBatchMode(true);
	// get stack of Image 1
	selectWindow(RawImagesTitle);
	duplicaterange1 = "1-"+toString(numFrames-frameLag);
	run("Duplicate...","title=stack1 duplicate range="+duplicaterange1);
	if (nSlices>1){
		run("Reduce...","reduction="+toString(reductionFactor));
	}

	// get stack of Image 2
	selectWindow(RawImagesTitle);
	duplicaterange2 = toString(frameLag+1)+"-"+toString(numFrames);
	run("Duplicate...","title=stack2 duplicate range="+duplicaterange2);
	if (nSlices>1){
		run("Reduce...","reduction="+toString(reductionFactor));
	}

	// do subtraction to get difference image stack
	imageCalculator("Subtract create 32-bit stack", "stack2", "stack1");
	close("stack1");
	close("stack2");
	setBatchMode(false);
	DiffImagesTitle = "Stack of difference images for frame lag = " + toString(frameLag);
	rename(DiffImagesTitle);

	// loop over all difference images taking FFTs
	selectImage(DiffImagesTitle);
	numDiffIms = nSlices;
	for (i=0; i<numDiffIms; i+=1) {
		selectImage(DiffImagesTitle);
		setSlice(i+1);
		setBatchMode(true);
		run("FFT Options...", "raw do");
	  FFTDiffImagesTitle = "FFT of Difference Image " + toString(i+1);
	  rename(FFTDiffImagesTitle);
	}

	if (numDiffIms>1) {
		run("Images to Stack","title=FFT of Difference Image");
		run("Z Project...","Start slice=1 Stop slice="+toString(nSlices)+" projection=[Average Intensity]");
	}
	rename("Average Fourier difference image for frame lag = "+toString(frameLag));
	close("Stack");
	close(DiffImagesTitle);
	setBatchMode(false);
}

run("Images to Stack","title=Average Fourier difference image for frame lag = ");
rename("DDM Fourier Images");
