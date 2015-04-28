# ShapeImporter
A SketchUp plugin built in Ruby. It enables the user to import shapefiles into SketchUp.

#Installing
1. Download plugin and place in your SketchUp's extension directory.
   Please see Step 2.
     http://www.sketchup.com/intl/en/developer/docs/tutorial_helloworld
2. Restart SketchUp.

#Running the program
####Using the Geo-Code Option
1. Please make sure your shapefile is in WGS 1984 Geographic Coordinate System.
2. Add a Geo-location to your model.
3. Extensions -> ShapeImporter Geo-Located
4. Select File.
####Using the Non Geo-Code Option
1. Please make sure your shapefile's linear units are in feet or meters.
2. Extensions -> ShapeImporter Non-Geo-Located
3. Select File.

#**Important Notes**
ShapeImporter only works with points and polylines. 3D polyline support will be coming soon.
