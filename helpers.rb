module DataTypeHelper
  def to_boolean(aValue, aNilValue=false)
    value = aValue.class == String ? aValue.downcase : aValue;
    case value
    when "no", "false", false, "0", 0, ["0"], :hide
      false
    when "yes", "true", true, "1", 1, ["1"], :show
      true
    when nil
      aNilValue
    else
      false
    end
  end
end

module CommonHelper
  def fail(string)
    screenshot_and_raise(string)
  end

  def alertExists?
    return query("view:'_UIAlertControllerShadowedScrollView'").empty?
  end

  def touchAlertButton(button_title)
    touch("view marked:'#{button_title}' parent view:'_UIAlertControllerCollectionViewCell'") if alertExists?
  end



  # checker method to make sure that some timestamp was created within certain threshold from 
  # current time
  def timeDiffToNowSmallerThen?(aTime, aThreshold)
    return (Time.now.to_i - aTime.to_i) < aThreshold
  end

  # method that will try to arrange objects first in rows from top to bottom from left to right
  def sortActivitiesByScreenPosition(aActivityObjects)
    aActivityObjects = aActivityObjects.sort_by do |object|
      [object.fetch("rect").fetch("center_x"), -object.fetch("rect").fetch("center_y")]
    end
    return aActivityObjects
  end

  def stringToClassFormat(aString)
    aString[0] = aString[0].to_s.capitalize
    return aString.delete(' ')
  end

  def stringToInstanceFormat(aString)
    aString[0] = aString[0].to_s.downcase
    return aString.delete(' ')
  end

  # query which can filter results based on regular expression matching specific attribute, 
  # default is "id"
  def regexLQuery(aRegex, aWhichAttribute=:id)
    aWhichAttribute = aWhichAttribute.id2name if aWhichAttribute.is_a? Symbol
    keepObjectsWhere(query("*"), aWhichAttribute, aRegex, true)
  end

  # method to retrieve attribute of query object (or any hash to be brutally honest)
  # aWhat is in format level>sublevel1>sublevel2... to be able to get into nested hashes
  def getObjectInfo(object, aWhat)
    resultInfo = object
    if aWhat.is_a?(Symbol) then
      aWhat = aWhat.id2name
    end
    levels = aWhat.split(">")
    levels.each { |tempWhat|
      if resultInfo.has_key?(tempWhat)
        resultInfo = resultInfo.fetch(tempWhat)
      else
        fail("#{tempWhat} from #{aWhat} not found in object's properties")
      end
    }
    return resultInfo
  end

  def hasObjectInfo?(object, aWhat)
    resultInfo = object
    levels = aWhat.split(">")
    levels.each { |tempWhat|
      if resultInfo.has_key?(tempWhat)
        resultInfo = resultInfo.fetch(tempWhat)
      else
        return false
      end
    }
    return true
  end

 

  # method to filter out elements in array that aren't satisfying condition
  def keepObjectsWhere(objects, aWhat, aValue, aRegex=false)
    result = objects.select{ |currentObject|
      if aRegex then
        # could be that we got object which can't be converted to string
        if !getObjectInfo(currentObject, aWhat).nil? then
          if !(String.try_convert(getObjectInfo(currentObject, aWhat)).nil?) then
            /#{aValue}/ =~ getObjectInfo(currentObject, aWhat)
          else
          print("Objects can't be checked with regular expression (#{getObjectInfo(currentObject, aWhat)})\n")
            end
        end
      else
        getObjectInfo(currentObject, aWhat) == aValue
      end
    }
    return result
  end

  # method that will return specific piece of info from inputed array of objects
  def retrieveParam(objects, aWhat)
    # result is nil as we couldn't fetch any relevant info
    return nil if objects.nil?
    # if we pass input just single object - we will convert it to array
    objects = [objects] if !(objects.is_a?(Array))
    return nil if !(hasObjectInfo?(objects.first, aWhat))
    # result is just single element - no need for array
    return getObjectInfo(queriedObjects.first, aWhat) if objects.length == 0
    # result is going to be an array for sure - we will create it
    resArray = Array.new()
    objects.each{ |currentObject| 
      resArray.push(getObjectInfo(queryResultObject, aWhat))
    }
    return resArray
  end

  def closestToCentre(objects, viewCenterX, whichDirection=:right)
    if whichDirection == :next then
      whichDirection = :right
    elsif whichDirection == :previous then
      whichDirection = :left
    else
      fail("Unrecognised direction")
    end
    closestToCentreDistance = 9999
    closestToCentreLabel = nil

    objects.each{ |currentObject|
      currentX = getObjectInfo(currentObject, "rect>center_y")
      currentDistance = viewCenterX - currentX
      currentDistance*=-1 if whichDirection == :left
      # current distance to accomodate small differences off centre (placeholders are 206 pix wide)
      if (currentDistance > 50) && (currentDistance < closestToCentreDistance) then
        closestToCentreDistance = currentDistance
        closestToCentreLabel = getObjectInfo(currentObject, "label")
      end
    }
    return closestToCentreLabel
  end

  def printl(what)
    print "#{what}\n"
  end

  def printd(what, extraInfo = nil)
    print "Debug(#{extraInfo}): #{what}\n" if $debug_messages
  end

  def getAccessibilityLabel(queryLabel)
    queryLabel.split("'").last
  end

  def getTypeFromQuery(queryString)
    queryString.split(" ").first
  end


end

World(DataTypeHelper, CommonHelper)
