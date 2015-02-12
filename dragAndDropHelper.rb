#{x: value, y: value, dragToDuration: value}
#{wait: value}
#dragAndDrop([{x: 1004, y: 88},{x: 10, y: 100, dragToDuration: 2},{wait:3},{x: 500, y: 200, dragToDuration: 5},{x: 200, y: 500, dragToDuration: 1}])

module DragAndDropHelper

	#   Method to pull item to some direction with option to define speed and distance
	#   example: pull("someLabel", direction: :left, distance: 60)
	#   not defining distance results in using :short option and for speed :quick option defined in global constants
	def pull(fromWhere, pullParameters)
		direction = pullParameters.fetch(:direction)
		distance = pullParameters.fetch(:distance, :short)
		speed = pullParameters.fetch(:speed, :quick)


		distance = DISTANCE[distance] if distance.is_a?(Symbol)
		speed = SPEED[speed] if speed.is_a?(Symbol)

		offsetToApply = createOffset(direction, distance)

		startingPoint = {specType: :query, specification: {elementType: :view, query: fromWhere}}
		endingPoint = {specType: :offset, specification: offsetToApply, duration: speed}
		dragAndDrop([startingPoint, endingPoint])
	end

	def createOffset(direction, distance)
		resultOffset = {x: distance * DIRECTIONS[direction][:x], y: distance * DIRECTIONS[direction][:y]}
	end

	#Example of imput for dragAndDrop function
	#commandArray = [
	#	{specType: :query, specification: {elementType: :view, query:"Video Search tool"}, duration: 1},
	#	{specType: :coordinates, specification: {x: 50, y: 250}, duration: 2},
	#	{specType: :wait, duration: 1},
	#	{specType: :offset, specification: {x: 50, y: -350}, duration: 3},
	#]

	def dragAndDrop(coordArray)
		commands = []
		fail(msg="Error: not enough points defined for drag and drop") if coordArray.length < 2
		lastCoord = getCoordsFor(coordArray[0][:specType], coordArray[0][:specification])
		i = 1
		bound = coordArray.length
		while i < bound
			currentSpecType = coordArray[i][:specType]
			currentDuration = coordArray[i][:duration]
			if currentSpecType == :wait then
				currentCoord = lastCoord
			elsif currentSpecType == :offset
				currentCoord = applyOffset(lastCoord, coordArray[i][:specification])
			else	
				currentCoord = getCoordsFor(coordArray[i][:specType], coordArray[i][:specification])			
			end
			commands << transformDragCoordToCommandString(lastCoord, currentCoord, coordArray[i][:duration])
			lastCoord = currentCoord
			i+=1
		end
		uia("#{commands.join}")
	end

	#   Method to perform drag and drop based purely on array fo coordinates
	def coordDragAndDrop(coordArray)
		commands = []
		i = 1
		bound = coordArray.length
		while i < bound
			if coordArray[i].has_key?(:wait) then
				commands << transformDragCoordToCommandString(coordArray[i-1], coordArray[i-1], coordArray[i][:wait])
				coordArray[i] = coordArray[i-1]			
			else
				commands << transformDragCoordToCommandString(coordArray[i-1], coordArray[i])
			end
			i+=1
		end
		uia("#{commands.join}")
	end

	#   Method to generate javascript string for doing drag and drop from coordianates
	def transformDragCoordToCommandString(coord1, coord2, wait=nil)
		x1 = coord1.fetch(:x)
		y1 = coord1.fetch(:y)
		x2 = coord2.fetch(:x)
		y2 = coord2.fetch(:y)
		if wait.nil? then
			duration = coord2.fetch(:dragToDuration, 1)		
		else
			duration = wait
		end	
		return "target.dragFromToForDuration({x: #{x1}, y: #{y1}}, {x: #{x2}, y: #{y2}}, #{duration});"
	end

	#	Method to retrieve coordinates based on type of specification
	def getCoordsFor(specType, specification)
		if specType == :query then
			fixRotationCoords(getObjectCoords(symbolQuery(specification[:elementType], specification[:query], specification.fetch(:extraParameters, nil))[0]))
		elsif specType == :offset then
			objectCoords = getObjectCoords(createQueryFromSymbols(specification[:elementType], specification[:query], specification.fetch(:extraParameters, nil)))
			resultCoords = applyOffset(objectCoords, specification[:offset])
			return nil if !isInScreen(resultCoords)
		elsif specType == :coordinates then
			return {x: specification[:x], y: specification[:y]}
		else
			fail(msg="Error. specification type \"#{specType}\" is undefined")
		end
	end

	#   Method to compute new point from previous one by using offset info
	def applyOffset(coords, offset)
		translatedOffset = offsetTranslate(offset)
		{x: (coords[:x]+translatedOffset[:x]), y: (coords[:y]+translatedOffset[:y])}
	end

	#   helper method to alter coordinates based on device rotation
	def fixRotationCoords(coords)
		return coords if uia("target.deviceOrientation()") == 3
		deviceBounds = getDeviceScreenDimensions()
		return {x: (deviceBounds[:width] - coords[:x]), y: (deviceBounds[:height] - coords[:y])}
	end

	#   method to retrieve center of object from description
	def getObjectCoords(object)
		{x: getObjectInfo(object, "rect>center_y"), y: getObjectInfo(object, "rect>center_x")}
	end

	#   Checker function to find out if chosen point is within screen of device
	def isInScreen?(coords)
		screenWidth = getDeviceScreenDimensions()[:width]
		screenHeight = getDeviceScreenDimensions()[:height]
		return coords[:x] >= 0 && coords[:x] <= screenWidth && coords[:y] >= 0 && coords[:y] <= screenHeight
	end

	#   fixing y coordinate to do it more natural
	def offsetTranslate(coords)
		x = coords.fetch(:x, 0)
		y = coords.fetch(:y, 0)
		return {x: x, y: -y}
	end
end

World(DragAndDropHelper)