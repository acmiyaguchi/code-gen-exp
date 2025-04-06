# K-means Clustering Visualization

An interactive 2D data visualization that demonstrates K-means clustering on randomly generated Gaussian data clusters.

## Features

- Generate random data points in clustered Gaussian distributions
- Implement and visualize K-means clustering algorithm
- Color-coded visualization of clusters
- Voronoi cell visualization for cluster boundaries
- Adjustable number of clusters (K) via slider or keyboard
- Customizable number of Gaussian clusters and points per cluster

## Controls

- **Space**: Run one iteration of K-means algorithm
- **R**: Regenerate Gaussian clusters
- **V**: Toggle Voronoi cell visualization
- **Up/Down arrows**: Increase/decrease K value
- **Enter**: Regenerate data with current settings
- **Escape**: Quit application

## Interface Elements

- **Regenerate Data button**: Creates new Gaussian clusters
- **Reset K-means button**: Reinitializes K-means algorithm
- **Toggle Voronoi button**: Shows/hides Voronoi cells
- **K-means clusters slider**: Adjusts the number of K-means clusters
- **Gaussian clusters slider**: Adjusts the number of Gaussian distributions
- **Points per cluster slider**: Adjusts the number of points per Gaussian distribution

## Implementation Details

- Pure Love2D implementation with no external dependencies
- Gaussian random number generation using Box-Muller transform
- K-means clustering with automatic convergence detection
- Dynamic visualization that updates in real-time
- Semi-transparent UI for better visualization

## Requirements

- LÖVE 11.0 or higher (https://love2d.org/)

## Running the Application

```
love /path/to/021-kmeans-clustering
```