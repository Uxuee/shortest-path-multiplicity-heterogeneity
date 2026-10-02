(* ::Package:: *)

(*
  PathAnisotropyCurvature / CurvatureEstimator.wl

  Clean core code for shortest-path anisotropy curvature diagnostics.

  Main idea:
    For each vertex p, look at the graph-distance shell S_rg(p), count the
    number of shortest paths from p to each shell vertex q, and measure the
    shell anisotropy of log shortest-path counts.

  Main estimator:
    LogCMD = cubic mean deviation of Log[N_geo(p,q)] over q in S_rg(p).

  Notes:
    - This file is intentionally code-only. Put exploratory notebook cells,
      one-off plots, and failed experiments in notebooks/ or docs/ instead.
    - The estimator is a curvature-sensitive diagnostic, not a discrete
      Kretschmann scalar.
*)

BeginPackage["PathAnisotropyCurvature`"];

rankData::usage = "rankData[x] returns average ranks, with ties assigned their mean rank.";
spearmanCorr::usage = "spearmanCorr[x, y] computes a Spearman rank correlation with basic validity checks.";
safeCorrelation::usage = "safeCorrelation[x, y] computes Pearson correlation after removing invalid numeric pairs.";
cubicMeanDeviation::usage = "cubicMeanDeviation[x] computes (Mean[Abs[x-Mean[x]]^3])^(1/3).";
safeStd::usage = "safeStd[x] returns StandardDeviation[x], or 0 for fewer than two values.";
validRealNumberQ::usage = "validRealNumberQ[x] returns True when x is a finite real numeric value.";

makeKNNGraph::usage = "makeKNNGraph[points, k] builds an unweighted k-nearest-neighbor graph from point coordinates.";
flatDiskPoints::usage = "flatDiskPoints[n] samples n points in a flat disk or annulus.";
hyperboloidPoints::usage = "hyperboloidPoints[n] samples n points on a simple hyperboloid-like surface.";
flammPoints::usage = "flammPoints[n, M] samples n points on a Flamm paraboloid z = 2 Sqrt[2 M (r - 2 M)].";

buildFlatDataset::usage = "buildFlatDataset[n, k] builds a flat control dataset association.";
buildHyperboloidDataset::usage = "buildHyperboloidDataset[n, k] builds a hyperboloid benchmark dataset association.";
buildFlammDataset::usage = "buildFlammDataset[n, M, k] builds a Flamm/Schwarzschild benchmark dataset association.";
buildMatchedFlatFromFlamm3::usage = "buildMatchedFlatFromFlamm3[flammData, k] makes a matched-flat control by removing the Flamm height coordinate.";

plotDataset2D::usage = "plotDataset2D[data, label] plots the first two coordinates of a dataset.";
plotDataset3D::usage = "plotDataset3D[data, label] plots the first three coordinates of a dataset.";
shellAndBallVertices::usage = "shellAndBallVertices[data, center, radius] returns center, shell, and ball vertex sets.";
plotGeometryShell2D::usage = "plotGeometryShell2D[data, center, radius, label] colors center, ball, and shell vertices in 2D.";
plotGeometryShell3D::usage = "plotGeometryShell3D[data, center, radius, label] colors center, ball, and shell vertices in 3D.";
coloredGeometryPlot::usage = "coloredGeometryPlot[data, center, radius, label] chooses a 2D or 3D colored shell/ball plot automatically.";

schwarzschildK::usage = "schwarzschildK[r, M] gives 48 M^2/r^6.";
precomputeAdjacency::usage = "precomputeAdjacency[g] returns an Association vertex -> adjacency list.";
shortestPathCountsFromAdj::usage = "shortestPathCountsFromAdj[adj, source] returns graph distances and shortest-path counts from source.";
pathAnisotropyEstimator::usage = "pathAnisotropyEstimator[g, p, radius] evaluates shortest-path anisotropy around vertex p.";
evaluateDataset::usage = "evaluateDataset[data, radius] evaluates the estimator for every vertex in a dataset.";
cleanRows::usage = "cleanRows[res, estimator] converts Dataset/list rows into clean associations with valid estimator and TargetK values.";
estimatorStats::usage = "estimatorStats[res, estimator] computes Pearson and Spearman statistics against TargetK.";

radiusScan::usage = "radiusScan[data, radii] evaluates estimatorStats for each graph radius.";
fastRadiusScan::usage = "fastRadiusScan[data, radii] is an alias of radiusScan.";
multiSeedRadiusScan::usage = "multiSeedRadiusScan[n, seeds, radii, k] runs Flamm benchmark scans across random seeds.";
summarizeSeedScan::usage = "summarizeSeedScan[scan] summarizes multi-seed scan results by graph radius.";

binnedFlammComparison::usage = "binnedFlammComparison[data, res, estimator, nbins] bins Flamm results radially and averages K and estimator values.";
radialBinComparisonFast2::usage = "radialBinComparisonFast2[data, res, estimator, nbins] bins generic results radially using cleaned rows.";
radialBinComparisonNoClean::usage = "radialBinComparisonNoClean[data, res, estimator, nbins] bins generic results radially without requiring TargetK.";
corrFromBinned::usage = "corrFromBinned[binned] computes Corr(rMean, EstimatorMean).";
matchedFlatFlammSeedScan::usage = "matchedFlatFlammSeedScan[n, seeds, k, radius, nbins] compares matched-flat and Flamm radial trends across seeds.";
matchedFlatFlammKScan::usage = "matchedFlatFlammKScan[n, seeds, ks, radius, nbins] repeats matched-flat/Flamm seed scans across k values.";
summarizeMatchedFlatKScan::usage = "summarizeMatchedFlatKScan[scan] summarizes matched-flat/Flamm correlations by k.";

ensureDirectory::usage = "ensureDirectory[path] creates a directory if it does not exist.";
exportDatasetCSV::usage = "exportDatasetCSV[path, data] exports Dataset/list-of-associations data as CSV.";

Begin["`Private`"];

(* ================================================================ *)
(* Basic numerical helpers                                           *)
(* ================================================================ *)

ClearAll[validRealNumberQ, safeStd, safeCorrelation, rankData, spearmanCorr, cubicMeanDeviation];

validRealNumberQ[x_] :=
 Module[{y = Quiet[N[x]]},
  NumberQ[y] &&
   FreeQ[y, _Complex | Indeterminate | ComplexInfinity | DirectedInfinity[_]]
 ];

safeStd[x_List] :=
 Module[{vals = Select[N[x], validRealNumberQ]},
  If[Length[vals] < 2, 0, StandardDeviation[vals]]
 ];

safeCorrelation[x_List, y_List] :=
 Module[{pairs, xx, yy},
  pairs = Select[Transpose[{x, y}], validRealNumberQ[#[[1]]] && validRealNumberQ[#[[2]]] &];
  If[Length[pairs] < 3, Return[Missing["InsufficientData"]]];
  xx = N[pairs[[All, 1]]];
  yy = N[pairs[[All, 2]]];
  If[safeStd[xx] == 0 || safeStd[yy] == 0, Return[Missing["ZeroVariance"]]];
  Correlation[xx, yy]
 ];

rankData[x_List] :=
 Module[{pairs, groups, ranks, pos = 1, inds, r},
  pairs = SortBy[Transpose[{N[x], Range[Length[x]]}], First];
  groups = SplitBy[pairs, First];
  ranks = ConstantArray[0., Length[x]];
  Do[
   inds = group[[All, 2]];
   r = Mean[Range[pos, pos + Length[group] - 1]];
   ranks[[inds]] = r;
   pos += Length[group],
   {group, groups}
  ];
  ranks
 ];

spearmanCorr[x_List, y_List] :=
 Module[{pairs},
  pairs = Select[Transpose[{x, y}], validRealNumberQ[#[[1]]] && validRealNumberQ[#[[2]]] &];
  If[Length[pairs] < 3, Return[Missing["InsufficientData"]]];
  safeCorrelation[rankData[pairs[[All, 1]]], rankData[pairs[[All, 2]]]]
 ];

cubicMeanDeviation[x_List] :=
 Module[{vals = Select[N[x], validRealNumberQ], mu},
  If[Length[vals] < 2, Return[0.]];
  mu = Mean[vals];
  N[(Mean[Abs[vals - mu]^3])^(1/3)]
 ];

(* ================================================================ *)
(* Geometry and graph construction                                  *)
(* ================================================================ *)

ClearAll[makeKNNGraph, flatDiskPoints, hyperboloidPoints, flammPoints];

Options[makeKNNGraph] = {"VertexCoordinates" -> Automatic};

makeKNNGraph[points_?MatrixQ, k_Integer?Positive, OptionsPattern[]] :=
 Module[{n, nearest, edges, coords},
  n = Length[points];
  nearest = Nearest[points -> Range[n]];
  edges =
   DeleteDuplicates[
    Flatten[
     Table[
      (UndirectedEdge @@ Sort[{i, #}]) & /@ DeleteCases[nearest[points[[i]], k + 1], i],
      {i, n}
     ],
     1
    ]
   ];
  coords = OptionValue["VertexCoordinates"];
  If[coords === Automatic,
   coords = If[Length[points[[1]]] >= 2, points[[All, 1 ;; 2]], Automatic]
  ];
  Graph[Range[n], edges, VertexCoordinates -> coords]
 ];

Options[flatDiskPoints] = {"RMin" -> 0.15, "RMax" -> 5.0};

flatDiskPoints[n_Integer?Positive, OptionsPattern[]] :=
 Module[{rmin, rmax, r, theta},
  rmin = OptionValue["RMin"];
  rmax = OptionValue["RMax"];
  r = Sqrt[RandomReal[{rmin^2, rmax^2}, n]];
  theta = RandomReal[{0, 2 Pi}, n];
  Transpose[{r Cos[theta], r Sin[theta]}]
 ];

Options[hyperboloidPoints] = {"RMin" -> 0.15, "RMax" -> 5.0, "HeightScale" -> 1.0};

hyperboloidPoints[n_Integer?Positive, OptionsPattern[]] :=
 Module[{rmin, rmax, scale, r, theta, z},
  rmin = OptionValue["RMin"];
  rmax = OptionValue["RMax"];
  scale = OptionValue["HeightScale"];
  r = Sqrt[RandomReal[{rmin^2, rmax^2}, n]];
  theta = RandomReal[{0, 2 Pi}, n];
  z = scale Sqrt[1 + r^2];
  Transpose[{r Cos[theta], r Sin[theta], z}]
 ];

Options[flammPoints] = {"RMin" -> Automatic, "RMax" -> 5.0};

flammPoints[n_Integer?Positive, M_: 1/2, OptionsPattern[]] :=
 Module[{rmin, rmax, r, theta, z},
  rmin = OptionValue["RMin"];
  rmax = OptionValue["RMax"];
  If[rmin === Automatic, rmin = 2 M + 0.2];
  r = Sqrt[RandomReal[{rmin^2, rmax^2}, n]];
  theta = RandomReal[{0, 2 Pi}, n];
  z = 2 Sqrt[2 M (r - 2 M)];
  Transpose[{r Cos[theta], r Sin[theta], z}]
 ];

ClearAll[schwarzschildK, buildFlatDataset, buildHyperboloidDataset, buildFlammDataset];

schwarzschildK[r_, M_: 1/2] := 48 M^2/r^6;

Options[buildFlatDataset] = {"RMin" -> 0.15, "RMax" -> 5.0};

buildFlatDataset[n_Integer?Positive, k_Integer?Positive, OptionsPattern[]] :=
 Module[{pts, r, g},
  pts = flatDiskPoints[n, "RMin" -> OptionValue["RMin"], "RMax" -> OptionValue["RMax"]];
  r = Norm /@ pts;
  g = makeKNNGraph[pts, k];
  <|
   "Type" -> "Flat",
   "Label" -> "Flat control",
   "N" -> n,
   "k" -> k,
   "Points" -> pts,
   "r" -> r,
   "Graph" -> g,
   "TargetK" -> ConstantArray[0., n]
  |>
 ];

Options[buildHyperboloidDataset] = {"RMin" -> 0.15, "RMax" -> 5.0, "HeightScale" -> 1.0};

buildHyperboloidDataset[n_Integer?Positive, k_Integer?Positive, OptionsPattern[]] :=
 Module[{pts, r, g},
  pts = hyperboloidPoints[
    n,
    "RMin" -> OptionValue["RMin"],
    "RMax" -> OptionValue["RMax"],
    "HeightScale" -> OptionValue["HeightScale"]
    ];
  r = Norm /@ pts[[All, 1 ;; 2]];
  g = makeKNNGraph[pts, k];
  <|
   "Type" -> "Hyperboloid",
   "Label" -> "Hyperboloid-like benchmark",
   "N" -> n,
   "k" -> k,
   "Points" -> pts,
   "r" -> r,
   "Graph" -> g
  |>
 ];

Options[buildFlammDataset] = {"RMin" -> Automatic, "RMax" -> 5.0};

buildFlammDataset[n_Integer?Positive, M_: 1/2, k_Integer?Positive, OptionsPattern[]] :=
 Module[{pts, r, targetK, g},
  pts = flammPoints[n, M, "RMin" -> OptionValue["RMin"], "RMax" -> OptionValue["RMax"]];
  r = Norm /@ pts[[All, 1 ;; 2]];
  targetK = schwarzschildK[#, M] & /@ r;
  g = makeKNNGraph[pts, k];
  <|
   "Type" -> "Flamm",
   "Label" -> "Flamm / Schwarzschild",
   "N" -> n,
   "k" -> k,
   "M" -> M,
   "Points" -> pts,
   "r" -> r,
   "TargetK" -> targetK,
   "Graph" -> g
  |>
 ];

ClearAll[getKeySafe, getPointsSafe, getRadialCoordinates, getTargetKValues];

getKeySafe[data_, key_String, default_: Missing["KeyAbsent", key]] :=
 Module[{a = If[AssociationQ[data], data, Association[Normal[data]]], sym = ToExpression[key]},
  Which[
   AssociationQ[a] && KeyExistsQ[a, key], a[key],
   AssociationQ[a] && KeyExistsQ[a, sym], a[sym],
   True, default
  ]
 ];

getPointsSafe[data_] := getKeySafe[data, "Points", $Failed];
getRadialCoordinates[data_] := getKeySafe[data, "r", $Failed];
getTargetKValues[data_] := getKeySafe[data, "TargetK", $Failed];

buildMatchedFlatFromFlamm3[flammData_, k_Integer?Positive] :=
 Module[{pts3, xy, r, theta, pts, g},
  pts3 = getPointsSafe[flammData];
  If[pts3 === $Failed, Return[$Failed]];
  xy = pts3[[All, 1 ;; 2]];
  r = Norm /@ xy;
  theta = ArcTan @@@ xy;
  pts = Transpose[{r Cos[theta], r Sin[theta]}];
  g = makeKNNGraph[pts, k];
  <|
   "Type" -> "MatchedFlat",
   "Label" -> "Matched flat control",
   "N" -> Length[pts],
   "k" -> k,
   "Points" -> pts,
   "r" -> r,
   "Graph" -> g,
   "TargetK" -> ConstantArray[0., Length[pts]]
  |>
 ];

(* ================================================================ *)
(* Plotting utilities, including colored geometry points             *)
(* ================================================================ *)

ClearAll[plotDataset2D, plotDataset3D, shellAndBallVertices, plotGeometryShell2D, plotGeometryShell3D, coloredGeometryPlot];

Options[plotDataset2D] = {"HighlightedVertices" -> {}, "PointSize" -> 0.010, "HighlightPointSize" -> 0.020};

plotDataset2D[data_, label_: Automatic, OptionsPattern[]] :=
 Module[{pts, hl, normal, title},
  pts = getPointsSafe[data];
  If[pts === $Failed, Return[$Failed]];
  pts = pts[[All, 1 ;; 2]];
  hl = OptionValue["HighlightedVertices"];
  normal = Complement[Range[Length[pts]], hl];
  title = If[label === Automatic, getKeySafe[data, "Label", "Dataset"], label];
  Show[
   ListPlot[
    pts[[normal]],
    AspectRatio -> 1,
    PlotStyle -> Directive[GrayLevel[0.55], PointSize[OptionValue["PointSize"]]],
    Frame -> True,
    Axes -> False,
    ImageSize -> Medium,
    PlotLabel -> title
    ],
   If[Length[hl] > 0,
    ListPlot[
     pts[[hl]],
     AspectRatio -> 1,
     PlotStyle -> Directive[Red, PointSize[OptionValue["HighlightPointSize"]]]
     ],
    Graphics[{}]
    ]
   ]
 ];

Options[plotDataset3D] = {"HighlightedVertices" -> {}, "PointSize" -> 0.010, "HighlightPointSize" -> 0.025};

plotDataset3D[data_, label_: Automatic, OptionsPattern[]] :=
 Module[{pts, hl, normal, title},
  pts = getPointsSafe[data];
  If[pts === $Failed, Return[$Failed]];
  If[Length[pts[[1]]] < 3, Return[plotDataset2D[data, label]]];
  hl = OptionValue["HighlightedVertices"];
  normal = Complement[Range[Length[pts]], hl];
  title = If[label === Automatic, getKeySafe[data, "Label", "Dataset"], label];
  Show[
   ListPointPlot3D[
    pts[[normal]],
    PlotStyle -> Directive[GrayLevel[0.55], PointSize[OptionValue["PointSize"]]],
    BoxRatios -> Automatic,
    Axes -> True,
    ImageSize -> Medium,
    PlotLabel -> title
    ],
   If[Length[hl] > 0,
    ListPointPlot3D[
     pts[[hl]],
     PlotStyle -> Directive[Red, PointSize[OptionValue["HighlightPointSize"]]]
     ],
    Graphics3D[{}]
    ]
   ]
 ];

shellAndBallVertices[data_, center_Integer, radius_Integer?Positive] :=
 Module[{g, verts, dist},
  g = getKeySafe[data, "Graph", $Failed];
  If[g === $Failed, Return[$Failed]];
  verts = VertexList[g];
  dist = AssociationThread[verts -> (GraphDistance[g, center, #] & /@ verts)];
  <|
   "Center" -> {center},
   "Ball" -> Select[verts, validRealNumberQ[dist[#]] && dist[#] <= radius &],
   "Shell" -> Select[verts, validRealNumberQ[dist[#]] && dist[#] == radius &]
  |>
 ];

plotGeometryShell2D[data_, center_Integer, radius_Integer?Positive, label_: Automatic] :=
 Module[{pts, sets, centerPts, shellPts, ballInteriorPts, otherPts, title},
  pts = getPointsSafe[data];
  If[pts === $Failed, Return[$Failed]];
  pts = pts[[All, 1 ;; 2]];
  sets = shellAndBallVertices[data, center, radius];
  If[sets === $Failed, Return[$Failed]];
  centerPts = sets["Center"];
  shellPts = Complement[sets["Shell"], centerPts];
  ballInteriorPts = Complement[sets["Ball"], shellPts, centerPts];
  otherPts = Complement[Range[Length[pts]], sets["Ball"]];
  title = If[label === Automatic, getKeySafe[data, "Label", "Dataset"], label];
  Show[
   ListPlot[pts[[otherPts]], PlotStyle -> Directive[GrayLevel[0.75], PointSize[0.008]]],
   ListPlot[pts[[ballInteriorPts]], PlotStyle -> Directive[LightBlue, PointSize[0.012]]],
   ListPlot[pts[[shellPts]], PlotStyle -> Directive[Orange, PointSize[0.016]]],
   ListPlot[pts[[centerPts]], PlotStyle -> Directive[Red, PointSize[0.025]]],
   Frame -> True,
   Axes -> False,
   AspectRatio -> 1,
   ImageSize -> Medium,
   PlotLabel -> title
   ]
 ];

plotGeometryShell3D[data_, center_Integer, radius_Integer?Positive, label_: Automatic] :=
 Module[{pts, sets, centerPts, shellPts, ballInteriorPts, otherPts, title},
  pts = getPointsSafe[data];
  If[pts === $Failed, Return[$Failed]];
  If[Length[pts[[1]]] < 3, Return[plotGeometryShell2D[data, center, radius, label]]];
  sets = shellAndBallVertices[data, center, radius];
  If[sets === $Failed, Return[$Failed]];
  centerPts = sets["Center"];
  shellPts = Complement[sets["Shell"], centerPts];
  ballInteriorPts = Complement[sets["Ball"], shellPts, centerPts];
  otherPts = Complement[Range[Length[pts]], sets["Ball"]];
  title = If[label === Automatic, getKeySafe[data, "Label", "Dataset"], label];
  Show[
   ListPointPlot3D[pts[[otherPts]], PlotStyle -> Directive[GrayLevel[0.75], PointSize[0.008]]],
   ListPointPlot3D[pts[[ballInteriorPts]], PlotStyle -> Directive[LightBlue, PointSize[0.012]]],
   ListPointPlot3D[pts[[shellPts]], PlotStyle -> Directive[Orange, PointSize[0.016]]],
   ListPointPlot3D[pts[[centerPts]], PlotStyle -> Directive[Red, PointSize[0.030]]],
   BoxRatios -> Automatic,
   ImageSize -> Medium,
   PlotLabel -> title
   ]
 ];

coloredGeometryPlot[data_, center_Integer, radius_Integer?Positive, label_: Automatic] :=
 Module[{pts = getPointsSafe[data]},
  If[pts === $Failed, Return[$Failed]];
  If[Length[pts[[1]]] >= 3,
   plotGeometryShell3D[data, center, radius, label],
   plotGeometryShell2D[data, center, radius, label]
  ]
 ];

(* ================================================================ *)
(* Shortest-path anisotropy estimator                               *)
(* ================================================================ *)

ClearAll[precomputeAdjacency, shortestPathCountsFromAdj, pathAnisotropyEstimator];

precomputeAdjacency[g_Graph] :=
 AssociationThread[VertexList[g] -> (AdjacencyList[g, #] & /@ VertexList[g])];

shortestPathCountsFromAdj[adj_Association, source_] :=
 Module[{verts, dist, counts, queue, v, nbrs},
  verts = Keys[adj];
  dist = AssociationThread[verts -> ConstantArray[Infinity, Length[verts]]];
  counts = AssociationThread[verts -> ConstantArray[0, Length[verts]]];
  dist[source] = 0;
  counts[source] = 1;
  queue = {source};
  While[Length[queue] > 0,
   v = First[queue];
   queue = Rest[queue];
   nbrs = adj[v];
   Do[
    Which[
     dist[u] === Infinity,
     dist[u] = dist[v] + 1;
     counts[u] = counts[v];
     queue = Append[queue, u],

     dist[u] == dist[v] + 1,
     counts[u] = counts[u] + counts[v]
     ],
    {u, nbrs}
    ];
   ];
  <|"Distance" -> dist, "Counts" -> counts|>
 ];

pathAnisotropyEstimator[g_Graph, p_Integer, radius_Integer?Positive, adj_: Automatic] :=
 Module[{adjacency, bfs, dist, counts, shell, countVals, logVals},
  adjacency = If[adj === Automatic, precomputeAdjacency[g], adj];
  bfs = shortestPathCountsFromAdj[adjacency, p];
  dist = bfs["Distance"];
  counts = bfs["Counts"];
  shell = Select[Keys[dist], dist[#] == radius &];
  If[Length[shell] < 2,
   Return[
    <|
     "Vertex" -> p,
     "Radius" -> radius,
     "ShellSize" -> Length[shell],
     "MeanCount" -> Missing["InsufficientShell"],
     "CMD" -> Missing["InsufficientShell"],
     "LogCMD" -> Missing["InsufficientShell"]
    |>
   ]
  ];
  countVals = N[Lookup[counts, shell]];
  logVals = Log[countVals];
  <|
   "Vertex" -> p,
   "Radius" -> radius,
   "ShellSize" -> Length[shell],
   "MeanCount" -> Mean[countVals],
   "CMD" -> cubicMeanDeviation[countVals],
   "LogCMD" -> cubicMeanDeviation[logVals]
  |>
 ];

ClearAll[evaluateDataset];

Options[evaluateDataset] = {"Vertices" -> Automatic};

evaluateDataset[data_Association, radius_Integer?Positive, OptionsPattern[]] :=
 Module[{g, verts, adj, rvals, kvals, rows},
  g = getKeySafe[data, "Graph", $Failed];
  If[g === $Failed, Return[$Failed]];
  verts = OptionValue["Vertices"];
  If[verts === Automatic, verts = VertexList[g]];
  adj = precomputeAdjacency[g];
  rvals = getRadialCoordinates[data];
  kvals = getTargetKValues[data];
  rows = Table[
    Module[{row = pathAnisotropyEstimator[g, v, radius, adj], extra = <||>},
     If[ListQ[rvals] && 1 <= v <= Length[rvals], extra = Join[extra, <|"r" -> rvals[[v]]|>]];
     If[ListQ[kvals] && 1 <= v <= Length[kvals], extra = Join[extra, <|"TargetK" -> kvals[[v]]|>]];
     Join[row, extra]
    ],
    {v, verts}
    ];
  Dataset[rows]
 ];

(* ================================================================ *)
(* Row cleaning and estimator statistics                             *)
(* ================================================================ *)

ClearAll[rowAssoc, getRowValue, cleanRows, estimatorStats];

rowAssoc[row_] :=
 Module[{n = Normal[row]},
  Which[
   AssociationQ[row], row,
   AssociationQ[n], n,
   ListQ[n] && AllTrue[n, MatchQ[#, _Rule] &], Association[n],
   True, <||>
  ]
 ];

getRowValue[row_, key_String] :=
 Module[{a = rowAssoc[row], sym = ToExpression[key]},
  Which[
   KeyExistsQ[a, key], a[key],
   KeyExistsQ[a, sym], a[sym],
   True, Missing["KeyAbsent", key]
  ]
 ];

cleanRows[res_, estimator_: "LogCMD"] :=
 Module[{rows = Normal[res]},
  Reap[
    Do[
     Module[{v, rad, e, k, r, shell},
      v = getRowValue[row, "Vertex"];
      rad = getRowValue[row, "Radius"];
      e = Quiet[N[getRowValue[row, estimator]]];
      k = Quiet[N[getRowValue[row, "TargetK"]]];
      r = Quiet[N[getRowValue[row, "r"]]];
      shell = getRowValue[row, "ShellSize"];
      If[validRealNumberQ[e] && validRealNumberQ[k],
       Sow[
        <|
         "Vertex" -> v,
         "Radius" -> rad,
         "ShellSize" -> shell,
         "r" -> r,
         "Estimator" -> N[e],
         "TargetK" -> N[k]
        |>
       ]
      ]
     ],
     {row, rows}
    ]
   ][[2]] /. {} -> {{} } // First
 ];

estimatorStats[res_, estimator_: "LogCMD"] :=
 Module[{rows, e, k},
  rows = cleanRows[res, estimator];
  If[Length[rows] < 3, Return[<|"Rows" -> Length[rows], "Pearson" -> Missing["InsufficientData"], "Spearman" -> Missing["InsufficientData"]|>]];
  e = Lookup[rows, "Estimator"];
  k = Lookup[rows, "TargetK"];
  <|
   "Rows" -> Length[rows],
   "Pearson" -> safeCorrelation[e, k],
   "Spearman" -> spearmanCorr[e, k]
  |>
 ];

(* ================================================================ *)
(* Radius scans and multi-seed scans                                 *)
(* ================================================================ *)

ClearAll[radiusScan, fastRadiusScan, multiSeedRadiusScan, summarizeSeedScan];

radiusScan[data_Association, radii_List, estimator_: "LogCMD"] :=
 Dataset[
  Table[
   Module[{res, stats},
    res = evaluateDataset[data, radius];
    stats = estimatorStats[res, estimator];
    Join[
     <|
      "Type" -> getKeySafe[data, "Type", Missing["Type"]],
      "N" -> getKeySafe[data, "N", Missing["N"]],
      "k" -> getKeySafe[data, "k", Missing["k"]],
      "Radius" -> radius
     |>,
     stats
    ]
   ],
   {radius, radii}
  ]
 ];

fastRadiusScan[data_Association, radii_List, estimator_: "LogCMD"] := radiusScan[data, radii, estimator];

multiSeedRadiusScan[n_Integer?Positive, seeds_List, radii_List, k_Integer?Positive, M_: 1/2, estimator_: "LogCMD"] :=
 Dataset[
  Flatten[
   Table[
    Module[{data, scan},
     SeedRandom[seed];
     data = buildFlammDataset[n, M, k];
     scan = Normal[radiusScan[data, radii, estimator]];
     Map[Join[<|"Seed" -> seed|>, #] &, scan]
    ],
    {seed, seeds}
   ],
   1
  ]
 ];

summarizeSeedScan[scan_] :=
 Module[{rows, groups},
  rows = Normal[scan];
  groups = GroupBy[rows, {#["N"] &, #["k"] &, #["Radius"] &}];
  Dataset[
   KeyValueMap[
    Function[{key, vals},
     <|
      "N" -> key[[1]],
      "k" -> key[[2]],
      "Radius" -> key[[3]],
      "MeanPearson" -> Mean[Select[Lookup[vals, "Pearson"], validRealNumberQ]],
      "MeanSpearman" -> Mean[Select[Lookup[vals, "Spearman"], validRealNumberQ]],
      "StdSpearman" -> safeStd[Lookup[vals, "Spearman"]],
      "MeanRows" -> Mean[Lookup[vals, "Rows"]],
      "Seeds" -> Length[vals]
     |>
    ],
    groups
   ]
  ]
 ];

(* ================================================================ *)
(* Radial binning                                                    *)
(* ================================================================ *)

ClearAll[assignRadialBins, radialBinComparisonNoClean, radialBinComparisonFast2, binnedFlammComparison, corrFromBinned];

assignRadialBins[rows_List, nbins_Integer?Positive] :=
 Module[{rmin, rmax},
  If[Length[rows] == 0, Return[{}]];
  rmin = Min[Lookup[rows, "r"]];
  rmax = Max[Lookup[rows, "r"]];
  If[rmax == rmin, Return[Map[Join[#, <|"Bin" -> 1|>] &, rows]]];
  Map[
   Function[row,
    Join[
     row,
     <|
      "Bin" -> Min[nbins, Max[1, 1 + Floor[nbins (row["r"] - rmin)/(rmax - rmin)]]]
     |>
    ]
   ],
   rows
  ]
 ];

radialBinComparisonNoClean[data_, res_, estimator_: "LogCMD", nbins_Integer?Positive] :=
 Module[{rawRows, rvals, rows, withBins, grouped, bins},
  rawRows = Normal[res];
  rvals = getRadialCoordinates[data];
  If[rvals === $Failed, Return[$Failed]];
  rows =
   Reap[
     Do[
      Module[{v, e},
       v = getRowValue[row, "Vertex"];
       e = Quiet[N[getRowValue[row, estimator]]];
       If[IntegerQ[v] && 1 <= v <= Length[rvals] && validRealNumberQ[e],
        Sow[<|"Vertex" -> v, "r" -> N[rvals[[v]]], "Estimator" -> N[e]|>]
       ]
      ],
      {row, rawRows}
     ]
    ][[2]] /. {} -> {{} } // First;
  If[Length[rows] == 0, Return[{}]];
  withBins = assignRadialBins[rows, nbins];
  grouped = GroupBy[withBins, #["Bin"] &];
  bins = Sort[Keys[grouped]];
  Table[
   <|
    "Bin" -> b,
    "rMean" -> Mean[Lookup[grouped[b], "r"]],
    "EstimatorMean" -> Mean[Lookup[grouped[b], "Estimator"]],
    "EstimatorStd" -> safeStd[Lookup[grouped[b], "Estimator"]],
    "Count" -> Length[grouped[b]]
   |>,
   {b, bins}
  ]
 ];

radialBinComparisonFast2[data_, res_, estimator_: "LogCMD", nbins_Integer?Positive] :=
 Module[{rows, withBins, grouped, bins},
  rows = cleanRows[res, estimator];
  rows = Select[rows, validRealNumberQ[#["r"]] && validRealNumberQ[#["Estimator"]] &];
  If[Length[rows] == 0, Return[{}]];
  withBins = assignRadialBins[rows, nbins];
  grouped = GroupBy[withBins, #["Bin"] &];
  bins = Sort[Keys[grouped]];
  Table[
   <|
    "Bin" -> b,
    "rMean" -> Mean[Lookup[grouped[b], "r"]],
    "EstimatorMean" -> Mean[Lookup[grouped[b], "Estimator"]],
    "EstimatorStd" -> safeStd[Lookup[grouped[b], "Estimator"]],
    "Count" -> Length[grouped[b]]
   |>,
   {b, bins}
  ]
 ];

binnedFlammComparison[data_, res_, estimator_: "LogCMD", nbins_Integer?Positive] :=
 Module[{rows, withBins, grouped, bins},
  rows = cleanRows[res, estimator];
  rows = Select[rows, validRealNumberQ[#["r"]] && validRealNumberQ[#["Estimator"]] && validRealNumberQ[#["TargetK"]] &];
  If[Length[rows] == 0, Return[{}]];
  withBins = assignRadialBins[rows, nbins];
  grouped = GroupBy[withBins, #["Bin"] &];
  bins = Sort[Keys[grouped]];
  Table[
   <|
    "Bin" -> b,
    "rMean" -> Mean[Lookup[grouped[b], "r"]],
    "KMean" -> Mean[Lookup[grouped[b], "TargetK"]],
    "EstimatorMean" -> Mean[Lookup[grouped[b], "Estimator"]],
    "EstimatorStd" -> safeStd[Lookup[grouped[b], "Estimator"]],
    "Count" -> Length[grouped[b]]
   |>,
   {b, bins}
  ]
 ];

corrFromBinned[binned_List] := safeCorrelation[Lookup[binned, "rMean"], Lookup[binned, "EstimatorMean"]];

(* ================================================================ *)
(* Matched-flat controls                                             *)
(* ================================================================ *)

ClearAll[matchedFlatFlammSeedScan, matchedFlatFlammKScan, summarizeMatchedFlatKScan];

matchedFlatFlammSeedScan[n_Integer?Positive, seeds_List, k_Integer?Positive, radius_Integer?Positive, nbins_Integer?Positive, M_: 1/2] :=
 Table[
  Module[{flamm, matchedFlat, resFlamm, resMatched, binnedFlamm, binnedMatched, corrFlamm, corrMatched},
   SeedRandom[seed];
   flamm = buildFlammDataset[n, M, k];
   matchedFlat = buildMatchedFlatFromFlamm3[flamm, k];
   resFlamm = evaluateDataset[flamm, radius];
   resMatched = evaluateDataset[matchedFlat, radius];
   binnedFlamm = radialBinComparisonNoClean[flamm, resFlamm, "LogCMD", nbins];
   binnedMatched = radialBinComparisonNoClean[matchedFlat, resMatched, "LogCMD", nbins];
   corrFlamm = corrFromBinned[binnedFlamm];
   corrMatched = corrFromBinned[binnedMatched];
   <|
    "Seed" -> seed,
    "N" -> n,
    "k" -> k,
    "Radius" -> radius,
    "Bins" -> nbins,
    "MatchedFlatCorrRLogCMD" -> N[corrMatched],
    "FlammCorrRLogCMD" -> N[corrFlamm],
    "Difference" -> N[corrFlamm - corrMatched]
   |>
  ],
  {seed, seeds}
 ];

matchedFlatFlammKScan[n_Integer?Positive, seeds_List, ks_List, radius_Integer?Positive, nbins_Integer?Positive, M_: 1/2] :=
 Flatten[
  Table[
   matchedFlatFlammSeedScan[n, seeds, k, radius, nbins, M],
   {k, ks}
  ],
  1
 ];

summarizeMatchedFlatKScan[scan_List] :=
 Module[{ks = Sort[DeleteDuplicates[Lookup[scan, "k"]]]},
  Table[
   Module[{rows, mf, fl},
    rows = Select[scan, #["k"] == k &];
    mf = Lookup[rows, "MatchedFlatCorrRLogCMD"];
    fl = Lookup[rows, "FlammCorrRLogCMD"];
    <|
     "k" -> k,
     "MatchedFlatMean" -> Mean[mf],
     "MatchedFlatStd" -> safeStd[mf],
     "FlammMean" -> Mean[fl],
     "FlammStd" -> safeStd[fl]
    |>
   ],
   {k, ks}
  ]
 ];

(* ================================================================ *)
(* Export helpers                                                    *)
(* ================================================================ *)

ClearAll[ensureDirectory, exportDatasetCSV];

ensureDirectory[path_String] := If[! DirectoryQ[path], CreateDirectory[path, CreateIntermediateDirectories -> True]];

exportDatasetCSV[path_String, data_] :=
 Module[{dir = DirectoryName[path], rows = Normal[data]},
  If[StringQ[dir] && dir =!= "", ensureDirectory[dir]];
  Export[path, rows]
 ];

End[];
EndPackage[];
