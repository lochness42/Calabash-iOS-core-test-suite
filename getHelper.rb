module GetHelper
  def getText(queryString)
    return query(queryString, :value).first if getTypeFromQuery(queryString).to_sym == :TextViewControl
    return query(queryString, :text).first
  end

  def getAlertText
    return query("view:'_UIAlertControllerShadowedScrollView'", :delegate, :message).first
  end

  def getActiveResponder()
    FIRSTRESPONDERSUPPORTED.each { |ui_class|
    res = query("#{ui_class} isFirstResponder:1")
      @responder << res.first unless res.empty?
    }
    return @responder
  end

  def getSpecificHashParameterValue(aWhich, from)
    result = [from, nil]
    return result if from.is_a?(Array) && from.length == 0
    aWhich = aWhich.to_sym if !aWhich.is_a?(Symbol)
    from = normalizeInputArray(from)
    from.each{ |parameter|
      if parameter.is_a?(Hash) then
        if parameter.has_key?(aWhich) then
          searchedValue = parameter.fetch(aWhich)
          parameter.delete(aWhich)
          from.delete(parameter) if parameter.length == 0
          result = [from, searchedValue]
          break
        end
      end
    }
    return result
  end

  # method to retrieve specific info about chosen view (or rather first occurence of view)
  def getViewInfo(queryString, aWhat)
    checkShown(queryString)
    getObjectInfo(query(queryString)[0], aWhat)
  end

  def getPickerValues()
    fail("Picker not shown") if query("pickerView").empty?
    res = []
    index = 0
    while true
      currentValue = query("pickerView",:delegate, [{pickerView:nil},{titleForRow:index},{forComponent:0}]).first
      return res if currentValue.nil?
      res << currentValue
      index += 1
    end
  end

  def getContentScrollInfo(queryString)
    string = query(queryString).first
    return if string.nil?
    string = string["description"]
    offset = {}

    contentOffset = string.scan(/(contentOffset: {(-?\d+(\.\d+)?, -?\d+(\.\d+)?)})/).first.first
    contentOffset = contentOffset.scan(/(-?\d+(\.\d+)?, -?\d+(\.\d+)?)/).first.first.split(", ")
    offset[:x] = contentOffset.first.to_f
    offset[:y] = contentOffset.last.to_f

    size = {}
    contentSize = string.scan(/(contentSize: {(-?\d+(\.\d+)?, -?\d+(\.\d+)?)})/).first.first
    contentSize = contentSize.scan(/(-?\d+(\.\d+)?, -?\d+(\.\d+)?)/).first.first.split(", ")
    size[:x] = contentSize.first.to_f
    size[:y] = contentSize.last.to_f
    return {offset: offset, size: size}
  end


  def getInfo(queryString, specificInfo = nil)
    toReturn = query(queryString).first
    if !specificInfo.nil? then
      specificInfo = specificInfo.join(">") if specificInfo.is_a?(Array)
      toReturn = getObjectInfo(toReturn, specificInfo)
    end 
    return toReturn
  end

  #   Call to find out size of screen
  def getDeviceScreenDimensions()
    deviceScreenInfo = uia("target.rect();")["value"]["size"]
    return {width: deviceScreenInfo["width"], height: deviceScreenInfo["height"]}
  end

  def deprecatedWarningMessage()
    puts "Please don't use anymore - it's here for backwards compatibility"
  end

end

World(GetHelper)