module ChecksHelper

  def is_button_enabled?(aButton)
    to_boolean(query("button marked:'#{aButton}'", "isEnabled"));
  end

  def isShown?(queryString)
    element_exists(queryString) 
  end

  def isNotShown?(queryString)
    not isShown?(queryString)
  end

  def checkShown(queryString)
    check_element_exists(queryString) 
  end

  def checkNotShown(queryString)
    check_element_does_not_exist(queryString) 
  end

  def checkElementsShown(queriesHash)
    queriesHash.each_key do | currentKey |
      checkShown queriesHash[currentKey]
    end
  end
  
  def waitForShown(queryString, waitTime = 5)
    aWait ||= waitTime;
    wait_for(:timeout => aWait) { isShown?(queryString); }    
  end

  def waitForNotShown(queryString, waitTime = 5)
    aWait ||= waitTime;
    wait_for(:timeout => aWait) { isNotShown?(queryString); }    
  end

  def isEnabled?(queryString)
    checkShown queryString
    return isShown?("#{queryString} isEnabled:1") && isNotShown?("#{queryString} isEnabled:0")
  end

  def isDisabled?(queryString)
    return !isEnabled?(queryString)
  end

  def waitForEnabled(queryString)
    checkShown queryString
    return waitForShown("#{queryString} isEnabled:1")
  end

  def waitForDisabled(queryString)
    checkShown queryString    
    return waitForShown("#{queryString} isEnabled:0")
  end

  def isFirstResponder?(queryString)
    query("#{queryString} isFirstResponder:1").empty?
  end

  def alert_view_visible?()
    return (not query("alertView").empty?());
  end

  def search_bar_visible?()
    return (not query("searchBarTextField").empty?());
  end

  def deprecatedWarningMessage()
    puts "Please don't use anymore - it's here for backwards compatibility"
  end

end

World(ChecksHelper)