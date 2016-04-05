


#Introduction to image analysis in ImageJ  

Chris Topp, Donald Danforth Plant Science Center  
BIS5702: Current Approaches in Plant Research  
Washington University in St. Louis

*Links to course materials:*

* The ImageJ [User Guide](http://rsbweb.nih.gov/ij/docs/guide/146.html)
* Dr. Topp's [presentation](http://www.slideshare.net/ChristopherTopp1/2016-bio4025-lecture1-final) accompanying this tutorial

___
####Rule #1: 
MAKE A DUPLICATE BEFORE EACH AND EVERY IMAGE MANIPULATION  

####Rule #2: 
CHECK HISTOGRAM BEFORE MEASURING INTENSITIES___##I. Basics

1.	Explore the ‘Image’ bar2.	Start w/ opening an image → ‘clown.jpg’3.	Save a copy in folder “Raw” folder | **Make a duplicate**4.	Zoom in and out5.	Cursor information (XY and intensity) 6.	Scale7.	Crop8.	Image Info and Properties9.	Analyze > Histogram OR ColorHistogram10.	Image → Type → ‘RGB color’

##II. Examples	**A.	Blobs.gif [BINARY IMAGE]** 
 
1. SEGMENTATION = Defining Regions of Interest (ROI)  
	a. Measurement v Analyze Particles**B. Dot_blot.jpg [8-bit/ 256 value GREYSCALE]**

1.	Analyze > Histogram (check for saturated pixels)  	a.	“Live” Histogram > List2.	Look Up Tables (LUTs)  	a.	Image Adjust  	* DO NOT USE “APPLY” FOR QUANT INFO3.	Analyze dots  	a.	Image > Adjust > Threshold  	b.	Process > Binary > ”Watershed” > ”FillHoles”  	c.	Analyze particles [Add to ROI Manager]  
	d.	Click on original gel image 	* → from ROI manager “Measure”	* OR “Overlay” Add Selection/ from ROI manager**C.	Leaf.jpg [8-bit RGB IMAGE]**
1.	Zoom in to ruler – generate a real-world to pixel correspondence2.	Separate and stack color channels  	a.	Contrast and Brightness  	b.	RGB to stack, to 32 and 16 bit gray (see intensities)3.	Make a stack, montage, animated gif4.	Practice Thresholding and Analyze Particles  a.	Use HSB color space (hint try Brightness)  b.	*in Analyze Particles → Set Measurements, click on ‘limit to threshold’  5.	Using Overlays as Masks: outlines-and-masks.png  a.	Analyze particles in thresholded image   b.	 Process > Binary > “Fill holes”  c.	Add to ROI Manager  d.	Remove unwanted ROI  e.	Analyze > Overlay  	* Add from ROI manager	* Measure	* Analyze Color Histogram v Original Leaf Image.
	* List/ Copy  
	f.	Results → (right click) Summarize and Distribution 

