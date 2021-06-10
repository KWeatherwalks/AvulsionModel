*********************************************************************
*                 Avulsion Model version 3.0                        *
*                       created by                                  *
*                    Kevin Weatherwalks                             *
*                Montclair State University                         *
*                                                                   *
*********************************************************************

  This set of files is an example of a discrete model for fluvial avulsion.

  The class AvulsionModel provides an implementation of an avulsion model 
and a host of routines which simulate the processes of fluvial aggradation,
floodplain sedimentation, steepest descent, and avulsion.

  A live script (TESTMODELREPORT.mlx) has been provided to demonstrate some 
features of the model. 

1/18/2017
- migrating to AModelv1.0 (Avulsion model version 1.0)

2/15/2017
- migrating to AModelv1.1 (Avulsion model version 1.1)
	* debugging code (TopoLow = TopoHigh issue)
    # issue resolved (obj.topographyHigh being set to topographyLow in SD)

2/23/2017
- migrating to AModelv1.2 (Avulsion model version 1.2)
- option to compile movies added to TESTCLASSMODELV2.m

3/17/2017
- Attempting to fix indexing error by creating a structure each cell of 
	a 39x39 cell array.

6/01/2017
- migrating to AModelv2.0 (Avulsion model version 2.0)

6/07/2017
- Adjusting AvulsionModel to track 3 rows of stratigraphy (rows 10, 20 and 30)
- Adjusting AvulsionModel to store noise matrix in order to better visualize the final topography.

6/08/2017
- Adjusted stratigraphy data to only add new channel bodies when appropriate.

6/23/2017
- showRiverPlot.m is now plotRiver.m
- strat2Points.m created to convert stratigraphy data to matrix of centroids with weights.
- plotStratasPoints.m created to convert and display stratigraphy as weighted centroids.
- progressBar added to plotStratigraphy.m
- generateRiverMovie.m created to construct .avi movies of planview evolution
- generateTopographyMovie.m created to construct .avi movies of topography evolution.

- getKstat method created for clustering analysis

7/13/2017
- Beta version initiated
  * This version features methods for gathering and displaying stratigraphy
    as well as reoccupation of channel cells via avulseToNewChannel.m
  * Other changes:
    ~ avulsion location is entirely determined by the most upstream cell 
      which triggers the avulsion. Previously, this was chosen randomly out
      of all potential avulsion locations.
    ~ plotStratigraphy.m runs much faster
