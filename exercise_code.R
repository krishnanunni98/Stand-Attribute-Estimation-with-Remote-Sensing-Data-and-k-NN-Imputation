##NONPARAMETRIC K-NN ESTIMATION

###############################################################################

##########################
# LOAD PACKAGES & RUN FUNCTIONS
##########################
rm(list = ls()) #Clear the memory

input_path <- "C:/Users/downloads" # change the path to the folder you have the data

dir.create(paste(input_path, "/plots", sep="")) # This creates a "plots" subfolder to your input folder; you can block this line after first run to avoid 'already exists' warning message 

#If the external libraries are not found, install them from the Packages menu
install.packages(pkgs="yaImpute", repos = "http://cran.r-project.org")
install.packages("gower") # there may come an error later saying this package was missing
require(yaImpute);

# these funtions we make ourselves to compute accuracy easily
rmse<-function(pred,obs){ sqrt(sum((pred-obs)^2)/length(obs))} #RMSE function
bias<-function(pred,obs){ sum(obs-pred)/length(obs)} # bias function

##########################
#LOAD INPUT DATA
##########################
# Add here the path where the input data is located in your own computer. Examples:
data <- read.table(paste(input_path, "/yai_data.txt", sep=""), sep="\t", header=T )

# the dimensions of the dataset
dim(data)
# 300 rows (plots) and 17 columns (variables)
names(data)
# first 2 columns are the dependent (y) variables
# response measured in the field: height of basal area median tree (hgm) and volume (v)
yvar<-c("hgm","v")
# remaining columns are the independent (x) variables
# predictors measured with remote sensing methods: percentiles (h) and proportions (p) of first (f) lidar returns...contrast (cont), correlation (corr),  average (avg) and variance (var) of aerial image Haralick texture 

# Alternatives:
# use a selection of the best ones
xvar<- c("f_h80","f_veg","savg_1")
xvar_plot_description <- "selection of best ones"
xvar_file_description <- "best"

# ...or use all predictors
#xvar<- 3:17
#xvar_plot_description <- "all predictors"
#xvar_file_description <- "all"

# ...or use only lidar variables
#xvar <- 3:13
#xvar_plot_description <- "Only lidar variables"
#xvar_file_description <- "lidar"

# ...or use only aerial image variables
#xvar <- 14:17
#xvar_plot_description <- "only aerial image variables"
#xvar_file_description <- "aerial"

# Rows 1-200 contain the training observations.
train <- 1:200
# Rows 201-300 are used for validation.
validation <- 201:300

####################
### PREPARE DATA ###
####################
#The data will be split into training and validation datasets
#yaImpute needs 3 different data frames:

#1. One with y-variables for training data
y.train <- data[train,yvar]

#2. One with x-variables for training data
x.train <- data[train,xvar]

#3. One with validation plots only
valid <- data[validation,]

########################
### kNN. Model Training
########################
yai_method <- "euclidean" # try also "msn"
your_k <- 5 # try also 3 and 1 (note: impute and predict functions will give a warning message if k = 1, but it still works)

# Function yai creates an object called knn, which contains the neighbor data
# Use only training observations
knn <- yai(y=y.train, x=x.train, method = yai_method, k=your_k)

#Apply the model for prediction (over the same training data)
t.pred <- impute(knn, k=your_k, method="dstWeighted")
names(t.pred)
#Columns inside the result object. .o = observed values, other columns = imputed values

# ACCURACY ASSESMENT: internal accuracy of the model (tested with the same data as the model was trained)

#Scatter plot for height
jpeg(paste(input_path, "/plots/Training_hgm_k", your_k, "_", yai_method, "_", xvar_file_description, ".jpg", sep=""), units="cm", width=22, height=22, res=600)
plot(t.pred$hgm.o, t.pred$hgm, xlab="Observed hgm (m)", ylab="Predicted hgm (m)", main=paste("Model training: hgm, k =", your_k, ", method = ", yai_method, ", xvar = ", xvar_plot_description, sep=""), xlim=c(5,32), ylim=c(5,32)); abline(0,1,col="red")
dev.off()
# RMSE and bias for height
rmse(t.pred$hgm, t.pred$hgm.o)
bias(t.pred$hgm, t.pred$hgm.o)

#Scatter plot for volume
jpeg(paste(input_path, "/plots/Training_v_k", your_k, "_", yai_method, "_", xvar_file_description, ".jpg", sep=""), units="cm", width=22, height=22, res=600)
par(mar=c(5,5,3,0.1)) # only to make the y-axis label completely visible
plot(t.pred$v.o, t.pred$v, xlab=expression(paste("Observed v (m"^"3", "ha"^"-1", ")")), ylab=expression(paste("Predicted v (m"^"3", "ha"^"-1", ")")), main=paste("Model training: v, k =", your_k, ", method = ", yai_method, ", xvar = ", xvar_plot_description, sep=""), xlim=c(0,500), ylim=c(0,500)); abline(0,1,col="red")
dev.off()
# RMSE and bias for volume
rmse(t.pred$v.o,t.pred$v)
bias(t.pred$v.o,t.pred$v)

#####################################
### kNN. Model Validation
#####################################
# Now the model is employed to compute a prediction over a separate dataset (validation)
v.pred <- predict(knn, newdata=valid, k=your_k, method="dstWeighted", observed=FALSE)

# ACCURACY ASSESMENT: real accuracy of the method (tested with an independent dataset)

#Scatter plot for height 
jpeg(paste(input_path, "/plots/Validation_hgm_k", your_k, "_", yai_method, "_", xvar_file_description, ".jpg", sep=""), units="cm", width=22, height=22, res=600)
plot(valid$hgm, v.pred$hgm, xlab="Observed hgm (m)", ylab="Predicted hgm (m)", main=paste("Model validation: hgm, k = ", your_k, ", method = ", yai_method, ", xvar = ", xvar_plot_description, sep=""), xlim=c(5,32), ylim=c(5,32)); abline(0,1,col="red")
dev.off()
# RMSE and bias for height
rmse(v.pred$hgm,valid$hgm)
bias(v.pred$hgm,valid$hgm)

#Scatter plot for volume
jpeg(paste(input_path, "/plots/Validation_v_k", your_k, "_", yai_method, "_", xvar_file_description, ".jpg", sep=""), units="cm", width=23, height=23, res=600)
par(mar=c(5,5,3,0.1)) # only to make the y-axis label completely visible
plot(valid$v, v.pred$v, xlab=expression(paste("Observed v (m"^"3", "ha"^"-1", ")")), ylab=expression(paste("Predicted v (m"^"3", "ha"^"-1", ")")), main=paste("Model validation: v, k = ", your_k, ", method = ", yai_method, ", xvar = ", xvar_plot_description, sep=""), xlim=c(0,500), ylim=c(0,500)); abline(0,1,col="red")
dev.off()
# RMSE and bias for volume
rmse(v.pred$v,valid$v)
bias(v.pred$v,valid$v)

# End of R-script