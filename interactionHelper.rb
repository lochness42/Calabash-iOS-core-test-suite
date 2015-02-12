module InteractionHelper

  def dragNdrop(aWhat, aToWhere, aDuration = 2)
    pan aWhat, aToWhere, aDuration
  end

  def touchObject(queryString, waitTime=1)
    waitForShown(queryString)
    sleep(waitTime)
    touch(queryString);
  end  

  def swipe_element(aElement, aDirection, aLandscapeFix=nil)
    sleep(3);
    direction = nil;
    useLandscapeFix = to_boolean(aLandscapeFix);
    case aDirection
      when :right
        direction = useLandscapeFix ? "up" : "right";
      when :left
        direction = useLandscapeFix ? "down" : "left";
      when :up
        direction = useLandscapeFix ? "left" : "up";
      when :down
        direction = useLandscapeFix ? "right" : "down";
      else
        raise "#{aDirection} direction NOT IMPLEMENTED!!";
    end

    swipe(direction, aElement);
  end

  def swipe_to_side(aDirection) #LENGTHWAYS
    swipe(aDirection, {:"swipe-delta" => {:horizontal => {:dx=> 384, :dy=> 0}}})
  end

  def scrollElement(queryString, aDirection)
    scroll(queryString, aDirection)
  end

  def refresh
 #   sleep 5
    send_uia_command command: "target.deactivateAppForDuration(0)"
  end

end

World(InteractionHelper)
