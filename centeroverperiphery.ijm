run("Close All");
directory=getDirectory("Choose a Directory");
list=getFileList(directory);
batchlist=newArray();
for (i=0;i<list.length;i++){
	if(endsWith(list[i], '.tif')==1 || endsWith(list[i], '.tiff')==1){
	batchlist=Array.concat(batchlist,list[i]);}
}

Ch1=newArray();
Ch2=newArray();


for(imgi=0;imgi<batchlist.length;imgi++){
	open(directory+batchlist[imgi]);
	Stack.getDimensions(width, height, channels, slices, frames);
	if(frames>1){
		Stack.setChannel(1);
		run("Enhance Contrast", "saturated=0.35");
		Stack.setChannel(2);
		run("Enhance Contrast", "saturated=0.35");
		Stack.setChannel(1);
		
		getStatistics(nPixels, mean, min, max); 
	    run("Find Maxima...", "noise="+max+" output=[Point Selection]"); 
	    getSelectionBounds(x, y, w, h); 
		
		waitForUser("Are You Happy With This Image? If not, close it.");
		
		if(isOpen(batchlist[imgi])==1){
			img=getTitle();
			getSelectionBounds(x, y, w, h); 
			
			c1=newArray(9);
			c2=newArray(9);
			cn1=newArray(9);
			cn2=newArray(9);
			
			
			c1[0]=img;
			c2[0]=img;

			x1=x;
			y1=y;
			x2=x;
			y2=y;
					
			for(i=0;i<frames;i++){
			   	Stack.setFrame(i+1);
			
			   	/////////Channel 1
			   	Stack.setChannel(1);
				CVP=getCVP(x1,y1,0);
			    c1[i+1]=d2s(CVP[0],4);
			    x1=CVP[1];
			    y1=CVP[2];
			    //c1[i+1]=d2s(p,3)/c1[1];	    
				/////////Channel 2
				Stack.setChannel(2);
				CVP=getCVP(x2,y2,0);
			    c2[i+1]=d2s(CVP[0],4);
			    x2=CVP[1];
			    y2=CVP[2];
				
			    		    
			}
			
			//Array.print(c1);
			//Array.print(c2);
			
			////////Normalize
			cn1[0]=c1[0];
			cn2[0]=c1[0];			
			for(i=1;i<9;i++){
				//print(d2s(c1[i]/c1[1],4));
				cn1[i]=d2s(c1[i]/c1[1],4);
				//print(d2s(c2[i]/c2[1],4));
				cn2[i]=d2s(c2[i]/c2[1],4);
			}
			//Array.print(cn1);
			//Array.print(cn2);
			
			waitForUser("Are You Happy With This Image? If not, close it.");
			
			if(isOpen(img)==1){
				Ch1=Array.concat(Ch1,cn1);
				Ch2=Array.concat(Ch2,cn2);
				selectWindow(img);
				close();
			}
		}	
	}
	else{
		close();
		}

	//////////////////////////////////////Output//////
	//Array.print(Ch1);
	//Array.print(Ch2);
	nj=Ch1.length/9;
	run("Clear Results");
	for (j=0;j<nj;j++){
	setResult("C1-Image",j,Ch1[j*9+0]);
	setResult("C1:-1min",j,Ch1[j*9+1]);
	setResult("C1:0min",j,Ch1[j*9+2]);
	setResult("C1:5min",j,Ch1[j*9+3]);
	setResult("C1:15min",j,Ch1[j*9+4]);
	setResult("C1:30min",j,Ch1[j*9+5]);
	setResult("C1:60min",j,Ch1[j*9+6]);
	setResult("C1:90min",j,Ch1[j*9+7]);
	setResult("C1:120min",j,Ch1[j*9+8]);
	setResult("C2-Image",j,Ch2[j*9+0]);
	setResult("C2:-1min",j,Ch2[j*9+1]);
	setResult("C2:0min",j,Ch2[j*9+2]);
	setResult("C2:5min",j,Ch2[j*9+3]);
	setResult("C2:15min",j,Ch2[j*9+4]);
	setResult("C2:30min",j,Ch2[j*9+5]);
	setResult("C2:60min",j,Ch2[j*9+6]);
	setResult("C2:90min",j,Ch2[j*9+7]);
	setResult("C2:120min",j,Ch2[j*9+8]);
	}
	
	saveAs("Results", directory+"CvP-log.txt");
		
}



function getCVP(x,y,draw){
	run("Set Measurements...", "area min center integrated redirect=None decimal=3");
    d=75;
    makeOval(x-d, y-d, d*2, d*2);
    run("Measure");
	n=nResults-1;
	xmass=getResult("XM",n);
	ymass=getResult("YM",n);
	
    d=50;
    makeOval(xmass-d, ymass-d, d*2, d*2);
    run("Measure");
	n=nResults-1;
	xmass=getResult("XM",n);
	ymass=getResult("YM",n);

	makeOval(xmass-d, ymass-d, d*2, d*2);
	run("Measure");
	n=nResults-1;
	IntDenC=getResult("RawIntDen",n);
	if (draw==0){
	setForegroundColor(255, 255, 255);
	run("Draw", "slice");}

	run("Select None");
	run("Measure");
	n=nResults-1;
	IntDenA=getResult("RawIntDen",n);
	
    p=IntDenC/(IntDenA-IntDenC);

    CVP=newArray(3);
    CVP[0]=p;
    CVP[1]=xmass;
    CVP[2]=ymass;
    return CVP;
}