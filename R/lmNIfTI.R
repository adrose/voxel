#' Wrapper to run a model on a NIfTI image and output parametric maps
#'
#' This function is able to run a Linear Model using the stats package.
#' The analysis will run in all voxels in in the mask and will return parametric coefficients. 
#' The function will create parametric maps according to the model selected. 
#' The function will return a p-map, t-map, z-map, p-adjusted-map for parametric terms and p-map, z-map, p-adjusted-map for smooth terms.
#' You can select which type of p-value correction you want done on the map. 
#' 
#' @param image Input image of type 'nifti' or vector of path(s) to images. If multiple paths, the script will call mergeNifti() and merge across time.
#' @param mask Input mask of type 'nifti' or path to mask. Must be a binary mask
#' @param fourdOut To be passed to mergeNifti, This is the path and file name without the suffix to save the fourd file. Default (NULL) means script won't write out 4D image.
#' @param formula Must be a formula passed to lm()
#' @param subjData Dataframe containing all the covariates used for the analysis
#' @param mc.preschedule Argument to be passed to mclapply, whether or not to preschedule the jobs. More info in parallel::mclapply
#' @param ncores Number of cores to use
#' @param method which method of correction for multiple comparisons (default is none)
#' @param outDir Path to the folder where to output parametric maps (Default is Null, only change if you want to write maps out)
#' @param ... Additional arguments passed to lm()
#' 
#' @return Return parametric maps of the fitted models
#' 
#' @export
#' @examples
#' image <- oro.nifti::nifti(img = array(1:1600, dim =c(4,4,4,25)))
#' mask <- oro.nifti::nifti(img = array(0:1, dim = c(4,4,4,1)))
#' set.seed(1)
#' covs <- data.frame(x = runif(25), y = runif(25))
#' fm1 <- "~ x + y"
#' Maps <- lmNIfTI(image=image, mask=mask, 
#'               formula=fm1, subjData=covs, ncores = 1, method="fdr")

lmNIfTI <- function(image, mask , fourdOut = NULL, formula, subjData, mc.preschedule = TRUE, ncores = 1, method="none", outDir = NULL, ...) {
  
  if (missing(image)) { stop("image is missing")}
  if (missing(mask)) { stop("mask is missing")}
  if (missing(formula)) { stop("formula is missing")}
  if (missing(subjData)) { stop("subjData is missing")}
  
  if (class(formula) != "character") { stop("formula class must be character")}
  
  models <- vlmParam(image, mask , fourdOut = fourdOut, 
                      formula = formula, subjData = subjData, 
                      mc.preschedule = mc.preschedule, ncores = ncores, ...)
  
  print("Creating parametric maps")
  
  return(parMap(parameters = models, mask = mask, method=method, outDir = outDir))
  
}