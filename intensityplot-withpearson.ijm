directory=getDirectory("Choose a Directory");
name=File.getName(directory);
list=getFileList(directory);
//updateResults();
//setBatchMode(true);
//savedirectory="C2P2C-Coloc";
//if (File.exists(directory+savedirectory)==0){
//	File.makeDirectory(directory+savedirectory);
//}

///analysis parameters
//linewidth definition may not work. manually set linewidth in imagej.
linewidth=50;
bin=10;

///prepare result window;
run("Clear Results");

setResult("Pearson' R-Global", 0,"Pearson's R");
setResult("Pearson's r-Line", 0,"Pearson's r");
setResult("Distribution C1", 0,"");
for(i=0;i<bin;i++){
setResult("C1-"+i+1, 0,d2s((i+1)*100/bin,0)+"%");
}
setResult("Distribution C2", 0,"");
for(i=0;i<bin;i++){
setResult("C2-"+i+1, 0,d2s((i+1)*100/bin,0)+"%");
}
setResult("Line-Coloc", 0,"");
for(i=0;i<bin;i++){
setResult("C1&C2-"+i+1, 0,d2s((i+1)*100/bin,0)+"%");
}
setResult("Line-Coloc-Norm", 0,"");
for(i=0;i<bin;i++){
setResult("C1&C2N-"+i+1, 0,d2s((i+1)*100/bin,0)+"%");
}

///prepare ROI
///image files need to be a name.tif
/// roi name should be name-line.roi
for (k=0;k<list.length;k++){
	if (File.isDirectory(directory+list[k])==0 && endsWith(list[k], '.tif')==1 ){
		open(directory+list[k]);
		img=getTitle();
		basename=File.nameWithoutExtension;
		row=nResults;
		
		if (File.exists(directory+basename+"-line.roi")==1){		
		
		setResult("Distribution C1", row,img);
		open(directory+basename+"-line.roi");
		//channel 1
		selectWindow(img);
		Stack.setChannel(1);
		a=getProfile();
		n=a.length;
		b=Array.resample(a,bin);
	
		sum=0; 
		for (i=0;i<b.length;i++){ 
		 sum=sum+b[i]; 
		} 
		c=b;
		for (i=0;i<b.length;i++){ 
		 c[i]=b[i]/sum; 
		 setResult("C1-"+i+1,row,c[i]);}


		 //channel 1
		selectWindow(img);
		Stack.setChannel(2);
		a=getProfile();
		n=a.length;
		b=Array.resample(a,bin);
	
		sum=0; 
		for (i=0;i<b.length;i++){ 
		 sum=sum+b[i]; 
		} 
		c=b;
		for (i=0;i<b.length;i++){ 
		 c[i]=b[i]/sum; 
		 setResult("C2-"+i+1,row,c[i]);} 
		 
//////////////////////////////////Part 1: calculate pearson's r on all images

		selectWindow(img);
		run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
		run("Split Channels");
		
		selectWindow("C1-"+img);
		rename("C1");
		//run("Subtract...", "value="+mean1);
		
		selectWindow("C2-"+img);
		rename("C2");
		//run("Subtract...", "value="+mean2);
		
		imageCalculator("Multiply create 32-bit", "C1","C2");
		rename("1X2");
		
		selectWindow("C1");	
		open(directory+basename+".roi");
		getStatistics(area1, mean1, min1, max1, std1, histogram1);
		selectWindow("C2");
		run("Restore Selection");
		getStatistics(area2, mean2, min2, max2, std2, histogram2);
		selectWindow("1X2");
		run("Restore Selection");
		getStatistics(area3, mean3, min3, max3, std3, histogram3);


		// R= Cov(X,Y)/(stdx*stdy) = E[(X-ux)(Y-uy)]/(stdx*stdy)
		//  = [1/n*sum(xi * yi) - yxuy]/(stdx*stdy)
		R= (mean3-mean1*mean2)/(std1*std2);
		setResult("Pearson' R-Global",row,R);

//////////////////////////////////Part 2: Pearson's r along line	

		selectWindow("C1");
		open(directory+basename+"-line.roi");
		Roi.getCoordinates(xpoints, ypoints);
		x0=xpoints[0];xf=xpoints[1];
		y0=ypoints[0];yf=ypoints[1];

		getStatistics(area1, mean1, min1, max1, std1, histogram1);
		
		selectWindow("C2");
		run("Restore Selection");
		getStatistics(area2, mean2, min2, max2, std2, histogram2);
		selectWindow("1X2");
		run("Restore Selection");
		getStatistics(area3, mean3, min3, max3, std3, histogram3);

		sum1=area1*mean1;
		sum2=area2*mean2;
		mu1=mean1;
		mu2=mean2;
		rho1=std1;
		rho2=std2;
		linearea=area1;
		
		rline= (mean3-mu1*mu2)/(rho1*rho2);
		setResult("Pearson's r-Line",row,rline);
		
		////calculate coordinates of each box

		xlist=newArray(bin+1);
		xlist[0]=x0;
		xlist[bin]=xf;
		for (i=1;i<bin;i++){
			xlist[i]=x0+i*(xf-x0)/bin;
			}

		ylist=newArray(bin+1);
		ylist[0]=y0;
		ylist[bin]=yf;
		for (i=1;i<bin;i++){
			ylist[i]=y0+i*(yf-y0)/bin;
			}
		
			//create boxes and make measurement
			
			
			for (i=0;i<bin;i++){
			selectWindow("C1");
			makeLine(xlist[i], ylist[i], xlist[i+1], ylist[i+1],linewidth);
			getStatistics(area1, mean1, min1, max1, std1, histogram1);
			selectWindow("C2");
			makeLine(xlist[i], ylist[i], xlist[i+1], ylist[i+1],linewidth);
			getStatistics(area2, mean2, min2, max2, std2, histogram2);
			selectWindow("1X2");
			makeLine(xlist[i], ylist[i], xlist[i+1], ylist[i+1],linewidth);
			getStatistics(area3, mean3, min3, max3, std3, histogram3);
			//print(area3);

			/////Pearson's r aling line

			rbox= (mean3-mean1*mean2)/(std1*std2);
			setResult("C1&C2-"+i+1,row,rbox);

			/////noemalized r to line's r
			// R= Cov(X,Y)/(stdx*stdy) = E[(X-ux)(Y-uy)]/(stdx*stdy)
			//  = [1/n*sum(xi * yi) - yxuy]/(stdx*stdy)
			rboxn= (area1/linearea)*((mean3-mu1*mu2)/(rho1*rho2)-rbox);
			
			setResult("C1&C2N-"+i+1,row,rboxn);

			}//end r line
			
		}//end if line.roi exist
		
	run("Close All");	
	}//end if file .tif

}//files loop
saveAs("Results", directory+name+"-C2P2C-Pearson.txt");
//setBatchMode(false);