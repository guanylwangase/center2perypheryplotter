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

setResult("Distribution C1", 0,"");
for(i=0;i<bin;i++){
setResult("C1-"+i+1, 0,d2s((i+1)*100/bin,0)+"%");
}
setResult("Distribution C2", 0,"");
for(i=0;i<bin;i++){
setResult("C2-"+i+1, 0,d2s((i+1)*100/bin,0)+"%");
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

		}//end if roi exist
		
	run("Close All");	
	}//end if file .tif

}//files loop
saveAs("Results", directory+name+"-C2P2C-Profile.txt");
//setBatchMode(false);