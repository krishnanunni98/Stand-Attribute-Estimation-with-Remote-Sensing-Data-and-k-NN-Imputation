# Stand Attribute Estimation with Remote Sensing Data and k-NN Imputation

## Project Overview

This exercise uses k-nearest-neighbour (k-NN) imputation to estimate stand height and volume from LiDAR-derived metrics and aerial-image texture variables. The workflow compares different predictor subsets, distance metrics, and neighbour sizes using separate training and validation data. 

## Objectives

- Estimate stand height (hgm) and volume using k-NN.
- Compare best-selection predictors against all predictors.
- Test LiDAR-only and aerial-image-only predictor sets.
- Compare Euclidean and MSN distance methods.
- Evaluate model accuracy using RMSE, bias, and scatter plots. 

## Data

- `yai_data.txt`
- 300 plots total
- 200 plots for training
- 100 plots for validation
- Response variables: `hgm`, `v`
- Predictors: LiDAR percentiles/proportions and Haralick texture variables 

## Methodology

### Model Training
- Fitted k-NN models with the `yaImpute` package.
- Used `dstWeighted` for imputation/prediction.
- Main case: `k = 5`.
- Also tested `k = 3` and `k = 1`. 

### Predictor Comparison
- Best selection: `f_h80`, `f_veg`, `savg_1`
- All predictors
- Only LiDAR variables
- Only aerial-image variables 

### Validation
- Applied the fitted model to the independent validation set.
- Evaluated RMSE and bias.
- Produced observed-vs-predicted scatter plots for both training and validation. 

## Main Outputs

- Scatter plots for hgm and volume
- RMSE and bias tables
- Comparison of Euclidean vs MSN methods
- Validation diagnostics for multiple predictor sets 

## Key Result

The diary indicates that the MSN method was preferable for height prediction and showed strong validation performance, while for volume the Euclidean method performed better in training and MSN performed better in validation. :contentReference[oaicite:16]{index=16}
