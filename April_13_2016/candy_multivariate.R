#Load in ggplot2 for making graphs
library(ggplot2)

#If needed, install.packages("ggrepel")
#Load in ggrepel, for making labels on your ggplots
library(ggrepel)

#If needed, install.packages("ggdendro")
#Load in ggdendro, for making nice dendrograms out of your hierarchical clustering results
library(ggdendro)

#If needed, install.packages("ape")
#Load in ape, for making nice dendrograms out of your hierarchical clustering results
library(ape)

########
#Principal Component Analysis (PCA)
########

#Let's read in the dataset for the nutrition labels for our 75 candy types to learn how to do Principal Component Analysis (PCA) in R
data <- read.table("./candy_nutrition.txt", header=TRUE)

#Check the names of our data
names(data)

#The dataset includes names of the candies, the company that made them, their general class, calories, serving size, and a number of nutritional values, in addition to primary ingredient

#Let's first normalize the nutritional values by dividing them by "serving_size_g". We'll create new variables

data$total_fat_per_serv <- data$total_fat_g/data$serving_size_g
data$saturated_fat_per_serv <- data$saturated_fat_g/data$serving_size_g
data$cholesterol_per_serv <- data$cholesterol_mg/data$serving_size_g
data$sodium_per_serv <- data$sodium_mg/data$serving_size_g
data$total_carb_per_serv <- data$total_carb_g/data$serving_size_g
data$dietary_fiber_per_serv <- data$dietary_fiber_g/data$serving_size_g
data$sugars_per_serv <- data$sugars_g/data$serving_size_g
data$protein_per_serv <- data$protein_g/data$serving_size_g

#Now, let's perform a PCA using the prcomp() function. PCA is a dimension-reduction technique that reorients the axes of your data so that they explain the maximum amount of variance in the fewest number of dimensions. One way to think about PCAs is that if you measure your data using variables x, y, z in 3D, then imagine reorienting the angle of a camera to take a 2D photo that maximizes the viewable variance in the photo (that is, 2D). PCA is a lot like this, except often it is performed on much higher dimensional data than just 3 dimensions. To get a feeling for how PCAs work, try rotaing the 3D dataset in this example to see how the data remains fundamentally the same, but is now described by axes that explain greater amounts of variance: http://setosa.io/ev/principal-component-analysis/

#Let's now perform a PCA using the prcomp function. Check out ?prcomp. prcomp requires input data, but also the variables center and scale. to be specified. Let's set cetner to TRUE and scale. to TRUE as well. This is because the nutritional information is collected in different units 

#N.B.: You could manually scale your data if you wanted to. For example, you could use the scale() function, which sets the mean of a data column to 0 and the variance to 1. You would create an object, scaled_data <- scale(data[17:24]) and could use that as the input into the PCA as well.

#Make sure that the column numbers correspond to the new normalized traits we created! This should be columns 17-24
?prcomp
pca <- prcomp(data[17:24], center=TRUE, scale.=TRUE)

#Now that we've done our PCA, let's look at some of the outputs, which you can look up with ?prcomp

#But first, let's do a summary to see the percent variance explained by each PC

summary(pca)

#Nice! The first four PCs explain >90% of variance in our data. PCs 1 and 2 explain >75%!

#What do these PCs mean? What combination of our variables consitute each of the PCs? To figure this out, we look at the loadings, which you can find using the rotation output

pca$rotation

#The contribution of a variable to a PC is proportional to the absolute value of the loading, and positively or negatively contributes towards the PC based on its sign. For example, total_fat_per_serv is negatively associated with PC1 and total_carb_per_serv is postively associated

#Now, let's get the PC scores
scores <- as.data.frame(pca$x)
head(scores)

#That's nice, but it would be better if the scores also had the associated data from the original dataset linked to the PC scores. Let's use cbind() to combine these columns into a single dataset

pca_scores <- cbind(data, scores)
head(pca_scores)

#That's better. Now we can visualize our PCA results to see how it separates different candy types by their nutritional lable information

p <- ggplot(pca_scores, aes(PC1, PC2, colour=class))
p + geom_point(size=5, alpha=0.6) + geom_text(data=pca_scores, aes(x=PC1, y=PC2, label=name)) + scale_colour_brewer(type="qual", palette=2)

#The overlap of the labels with the data isn't good, so let's use ggrepel to fix that

p <- ggplot(pca_scores, aes(PC1, PC2, colour=class))
p + geom_point(size=5, alpha=0.6) + geom_text_repel(data=pca_scores, aes(x=PC1, y=PC2, label=name)) + scale_colour_brewer(type="qual", palette=2)

#Nice! The PCA does a good job of separating by groups we know to exist, like chocolate, peanut butter, gummi, helly bean, liquorice, sour, and sugar candies.

#We can also see what PC3 and PC4 look like too

p <- ggplot(pca_scores, aes(PC3, PC4, colour=class))
p + geom_point(size=5, alpha=0.6) + geom_text_repel(data=pca_scores, aes(x=PC3, y=PC4, label=name)) + scale_colour_brewer(type="qual", palette=2)

########
#Hierarchical Clustering
########

#As mentioned above, it is important to scale our data (column means=0 and variance=1) so that scaling effects are not detected, just patterns of variance between variables. Let's use the scale function here to scale our data before performing hierarchical clustering. The column names in the object data currently correspond to nutrition information. So, the samples to be clustered will be the nutrition informtion itself. But after scaling the nutrition information, let's transpose that dataset and analyze a scaled matrix where the candies are the columns, so that we will cluster by candy type. We will analyze the two datasets, "scaled_nutrition" and "scaled_candies" in parallel.


scaled_nutrition <- scale(data[17:24])
scaled_candies <- scale(t(scaled_nutrition))
colnames(scaled_candies) <- as.matrix(data[2])

head(scaled_nutrition)
head(scaled_candies)

#The way similarity between variables is calculated is through correlation. Let's use the cor function to create a pairwise correlation matirx for our data, the correlation of all variable to each other. Let's be conservative and instead of using a parametric correlation parameter like "pearson", we'll use a non-parametric one, like "spearman", which makes no assumptions about the distributions of our data

corell_nutrition <- cor(scaled_nutrition, method="spearman")
corell_candies <- cor(scaled_candies, method="spearman")

head(corell_nutrition)
head(corell_candies)

#Next, let's create a distance matrix using the as.dist funciton, which assigns distances between our samples using the correlation matrix we just calculated. There are many different methods to calculate distance, and the default is Eucledian, which we'll be using. We will take the absolute value of the correlation matirx (because strong negative as well as positive correlations indicate similarity) and also subtract that value from 1, as strong correlation (e.g., rho=1) means a closer distance (e.g., 0)

dist_nutrition <- as.dist(1-abs(corell_nutrition))
dist_candies <- as.dist(1-abs(corell_candies))

#Finally, using our distance matrix, let's convert it to a dendrogram using the hclust function. Check out ?hclust, as there are many different methods by which to cluster your results. For this example, we'll start by using the method "ward.D"

hc_nutrition <- hclust(dist_nutrition, method="ward.D2")
hc_candies <- hclust(dist_candies, method="ward.D2")

#Let's plot out our dendrograms!

plot(hc_nutrition, cex=0.8)
plot(hc_candies, cex=0.8)

#Using the packages ggdendro and ape you can plot out nicer looking dendrograms if you like. Use the "cex" option to change the size of the text if you need to

plot(as.phylo(hc_nutrition), type="cladogram", label.offset=0.01)
plot(as.phylo(hc_candies), type="cladogram", label.offset=0.01, cex=0.5)

########
#Shape descriptors and allometry
########

#Let's read in a datafile with basic shape information about individual candy pieces

shape_desc <- read.table("./shape_descriptors.txt", header=TRUE)
names(shape_desc)
head(shape_desc)

#The variables in this dataset are:
#label: the name of the file measured
#id: the candy ID
#candy_no: for a given candy ID, the individual candy piece in question
#area: area in pixels
#cm2: area in cm^2
#circ: circularity, which is 4pi(area/perimeter^2). More lanky, jagged things have smaller circ values. More smoother, rounder things have higher circ values
#ar: aspect ratio. The ratio of the major to minor axes of the best fitted ellipse. Longer things have higher aspect ratios
#round: inversely related to ar
#solidity: the ratio of the area to convex area. More jagged things have lower solidity values

#Let's first look at the distribution of cm2 values using a histogram

p <- ggplot(shape_desc, aes(x=cm2))
p + geom_histogram()

#As is typical for area, the distribution is skewed. Let's create a transformed value for area by taking the square root and see how that looks

shape_desc$sqrt_cm2 <- sqrt(shape_desc$cm2)

p <- ggplot(shape_desc, aes(x=sqrt_cm2))
p + geom_histogram()

#That's a little more normal looking, assuming discrete populations in our data (which there are). Let's use this square root value in the future.

#Let's get an idea for how our data looks and plot aspect ratio vs. circularity, making the size of the points sqrt_cm2

p <- ggplot(shape_desc, aes(x=circ, y=ar, size=sqrt_cm2))
p + geom_point(alpha=0.2)

#Interesting! Let's get a little more separation and transform our variables. I tried squaring circ and taking the log of ar, but you can try your own transformations!

p <- ggplot(shape_desc, aes(x=circ^2, y=log(ar), size=sqrt_cm2))
p + geom_point(alpha=0.2)

#Wouldn't it be nice if we had the other information for the candies associated with this dataset? Let's use the merge function to merge our nutritional label dataset with the shape descriptor dataset

#Check out ?merge

#But the gist is that you input an "x" dataset that will be merged with a "y" dataset. Using by.x and by.y you can specify the columns by which to merge in each dataset. all.x or all.y or all set to TRUE will insure that every row specifed by "all" is included in the merge, even if there is no corresponding data in the other dataset to merge with. Let's merge our shape descriptor individual candy dataset "shape_desc" with the nutritional information for each of our candy types, "data"

mdata <- merge(x=shape_desc, y=data, by.x="id", by.y="id", all.x=TRUE)
summary(mdata)

#Using summary, it seems that our merge was successful. However, you will notice that there are some NAs. It is important we deal with these for subsequent analyses, because some methods, like PCA, can't handle missing data this way. Let's get rid of the NAs using na.omit

nonas_mdata <- na.omit(mdata)
summary(nonas_mdata)

#Great! All the NAs are gone. Let's look at our graph of aspect ratio, circularity, and sqrt_cm2 again, this time by candy class

p <- ggplot(nonas_mdata, aes(x=circ^2, y=log(ar), size=sqrt_cm2, colour=class))
p + geom_point(alpha=0.5) + scale_colour_brewer(type="qual", palette=2) + theme_bw() + ggtitle(label="log(Aspect Ratio) vs. Circularity^2, \nwith size = sqrt(cm^2) and colored by candy class")

#ggsave("all_candies.jpg")

#To get a feel for the shapes of the candies, let's take averages by candy type and replot this graph with labels

averaged <- aggregate(nonas_mdata[c(4:10,11,13,14:33)], by=list(nonas_mdata$name, nonas_mdata$class), FUN=mean)

#Now let's plot the averaged shape descriptor values and label by candy type and class

p <- ggplot(averaged, aes(x=circ^2, y=log(ar), colour=Group.2))
p + geom_point(alpha=1, size=4) + scale_colour_brewer(type="qual", palette=2) + geom_text_repel(data=averaged, aes(x=circ^2, y=log(ar), label=Group.1)) + scale_colour_brewer(type="qual", palette=2, guide=guide_legend(title="class")) + theme_bw() + ggtitle(label="Averaged log(Aspect Ratio) vs. Circularity^2, \nlabeled by candy type and colored by candy class") 

#ggsave("averaged_candies.jpg")

########
#Final project
########

#Previously, you should have isolated the RGB values per each candy piece. Your final project is to consider all the candy data as a whole. The three main datasets are:

#1) Nutrition label information and candy class for each of the 75 candy types

#2) Shape descriptor information and area for each of ~980 individual candy pieces

#3) RGB color information for ~980 individual candy pieces (you should be in possession of this data)

#You should first merge the three datasets together.

#Then, considering data formating (NAs!) and scaling and centering of data as we discussed, use PCA and hierarchical clustering and provide commentary and notes on the results to discern patterns of relatedness of the candies. Please save both your code and commentary for the final project.

#Provide ample data visualization to convey your results and make them understandable to others. Be sure to title and label your graphs too.

#Additionally: because you have color information, in all your graphs (PCAs, scatterplots of individual variables) consider coloring your datapoints by the actual color of the individual candies. To do this, consider the following example data:

sample_colors <- read.table("./sample_colors.txt", header=TRUE)

p <- ggplot(sample_colors, aes(x,y, colour=rgb(r,g,b, maxColorValue=255)))
p + geom_point(size=46) + scale_colour_identity()

#Coloring your data by actual candy piece rgb values should make for a striking graph!

#Have fun, apply what you've learned, and analyze the multivariate data you worked so hard to collect!!! Email Dan your scripts, including commentary, no later than 5pm pon Thursday. Provide lots of analyses and data visualization, as well as explanation, for what you think is going on with your data!!!




