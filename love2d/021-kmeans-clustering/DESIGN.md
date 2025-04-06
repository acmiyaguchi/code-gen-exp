# K-means Clustering Visualization

## Overview
An interactive 2D data visualization application that generates Gaussian clusters and applies K-means clustering. Users can interact with the visualization by adjusting parameters and directly manipulating clusters.

## Features
1. Generate random data points in clustered Gaussian distributions
2. Implement K-means clustering algorithm
3. Visualize data points with colors based on cluster assignment
4. Display Voronoi cells for each cluster
5. Allow adjustment of K (number of clusters)
6. Enable interactive manipulation of clusters via mouse
7. Provide regeneration of Gaussian data points

## Technical Specifications

### Data Generation
- Create 4-8 distinct Gaussian clusters
- Each cluster will have configurable parameters:
  - Center point (x, y)
  - Standard deviation
  - Number of points
- Total points: 500-1000 across all clusters

### K-means Algorithm
- Initialize K cluster centers randomly or using K-means++ approach
- Assign points to nearest cluster center
- Recalculate cluster centers
- Repeat until convergence or max iterations
- Track history of cluster centers for visualization

### Visualization
- Scatter plot of all data points
- Color coding based on cluster assignment
- Display cluster centers with distinct markers
- Render Voronoi cells as boundaries between clusters
- Show algorithm statistics (iterations, convergence)

### User Interface
- Slider or +/- buttons to adjust K value (2-10)
- Button to regenerate Gaussian clusters
- Button to reset/restart K-means algorithm
- Mouse interaction to select and move cluster centers

### Interaction
- Left-click on cluster center to select it
- Drag selected center to new location
- Real-time update of cluster assignments and Voronoi cells
- Keyboard shortcuts for common operations

## Implementation Details

### Data Structures
- Points: Array of {x, y} coordinates
- Clusters: Array of {centerX, centerY, points[], color}
- ClusterAssignments: Array mapping point index to cluster index
- VoronoiCells: Calculated boundaries between clusters

### Core Functions
- `generateGaussianClusters(numClusters, pointsPerCluster)`
- `initializeKMeans(k)`
- `assignPointsToClusters()`
- `updateClusterCenters()`
- `runKMeansIteration()`
- `calculateVoronoiCells()`
- `drawPoints()`
- `drawClusterCenters()`
- `drawVoronoiCells()`
- `handleMouseInteraction()`

### Love2D Implementation
- Use built-in Love2D functions for drawing and interaction
- Leverage Love2D's update/draw loop for algorithm animation
- Use Love2D's graphics capabilities for rendering
- Implement UI elements using Love2D primitives

## States
1. Data Generation - Creating initial Gaussian clusters
2. K-means Initialization - Setting up initial cluster centers
3. K-means Iteration - Running algorithm steps
4. Interactive - Allowing user manipulation
5. Reset - Preparing for regeneration or parameter changes

## Success Criteria
- Clear visual distinction between different clusters
- Accurate implementation of K-means algorithm
- Responsive user interface
- Smooth interaction when manipulating clusters
- Correct Voronoi cell visualization
- Performance capable of handling 1000+ points