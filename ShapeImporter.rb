#S. D. G.
#Function for processing the shapefile
def processShapefile()
	#Create a new file object
	$shapefile = File.new($filePath,"rb")
	#Create a SketchUp model object
	model = Sketchup.active_model

	#Process Shapefile header information
	#Verify the file type
	fileCode = $shapefile.read(4).unpack("l>")
	#Shapefile code is 9994. Checking for the match
	if fileCode[0]!=9994 then
		abort("The specified file is not a Shapefile.")
	end
	#Ignore the next 20 bytes they are unused
	$shapefile.read(20)
	#Get the file length. Important for record processing.
	fileLength = $shapefile.read(4).unpack("l>")
	#Next four bytes are the version. We won't be using this.
	$shapefile.read(4)
	#The next four bytes are the shape type. Important for record processing.
	shapeType = $shapefile.read(4).unpack("l<")
	#Rule out certain shape types. More types will be added as time goes on.
	if shapeType[0]!=1 and shapeType[0]!=3 then
		abort("This type of shapefile is not supported.")
	end
	#Read the next 64 bytes. They won't be used in our program for now.
	$shapefile.read(64)
	
	
	#Begin record procesing
	#Option for point shapefile
	if shapeType[0]==1 then
		#Try grabbing the first record
		begin
			recordNumber = $shapefile.read(4).unpack("l>")
		rescue #Exit if the shapefile is empty
			abort("There are no records in this shapefile.")
		end
		#Let the user know the process has begun
		puts("Processing shapefile...")
		#Process all records until the end
		while recordNumber!=nil
			recordLength = $shapefile.read(4).unpack("l>")
			recordType = $shapefile.read(4).unpack("l<")
			#If it is a null shape, we will ignore it
			#Process remaining record contents
			if recordType[0]==1
				#Read the coordinates
				pointX = $shapefile.read(8).unpack("E")
				pointY = $shapefile.read(8).unpack("E")
				#Add the point to the model
				model.entities.add_cpoint model.latlong_to_point([pointX[0],pointY[0]])
			end
			#Try reading the next record. Prepare for possible error.
			begin
				recordNumber = $shapefile.read(4).unpack("l>")
			rescue #If we need to rescue, we are at the end of the shapefile.
				puts("Shapefile has been processed.")
				break
			end
		end
	#Option for polyline shapefile
	elsif shapeType[0]==3
		#Try grabbing the first record
		begin
			recordNumber = $shapefile.read(4).unpack("l>")
		rescue
			abort("There are no records in the shapefile.")
		end
		puts("Processing Shapefile...")
		#Process each record
		while recordNumber!=nil
			recordLength = $shapefile.read(4).unpack("l>")
			recordType = $shapefile.read(4).unpack("l<")
			#Process polyline shape types
			if recordType[0]==3
				recordBox = $shapefile.read(32) #We will read this, but we don't need it
				#Get part and point counts
				recordPartCount = $shapefile.read(4).unpack("l<")
				recordPointCount = $shapefile.read(4).unpack("l<")
				#Create an index array
				index = []
				#Populate the index array
				for recordPoint in (0..recordPartCount[0]-1) do
					index.push($shapefile.read(4).unpack("l<"))
				end
				#Loop through all parts for this record
				for partNum in (0..recordPartCount[0]-1) do
					#Generate the loop count
					loopCount = nil
					if index[partNum+1]==nil #Figure out how many point to count
						loopCount = recordPointCount[0] - index[partNum][0]
					else
						loopCount = index[partNum+1][0]-index[partNum][0]
					end
					#Loop through all lat,long values for this part.
					pointsArray = []
					#Generate array of points
					for i in (1..loopCount) do
						pointX = $shapefile.read(8).unpack("E")
						pointY = $shapefile.read(8).unpack("E")
						pointsArray.push(model.latlong_to_point([pointX[0],pointY[0]])) #Convert lon/lat to x,y and add to array
					end
					#Add line to the model
					model.entities.add_edges pointsArray
				end
				#Try and process next record. Prepare for possible error.
				begin
					recordNumber = $shapefile.read(4).unpack("l>")
				rescue
					puts("Shapefile has been processed.")
					break
				end
			end
		end	
	else #Condition for shape types that are not able to be processed.
		puts("Shapefile type is currently not supported.")
	end
end




#Add the plugin to the menu
UI.menu("Plugins").add_item("ShapeImporter"){
	#Show the SketchUp Console
	SKETCHUP_CONSOLE.show
	#Generate a message box to inform the user before the program starts
	UI.messagebox("Please make sure that your shapefile is in Geogracphic Coordinates (WGS 1984) and that you have added a geo-location to this model.", MB_OK)
	
	
	#Get the shapefile from the user
	$filePath = UI.openpanel("Please select a shapefile","C:",".shp|*.shp")
	puts($filePath)
	#Check to make sure a shapefile was selected
	if $filePath!=nil then
		processShapefile() #Process the shapefile
	else
		SKETCHUP_CONSOLE.hide #Hide the console if no shapefile was selected
	end
}
