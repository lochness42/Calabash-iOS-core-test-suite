module SetHelper
  def selectPickerValue(value)
    pickerValues = getPickerValues
    index = pickerValues.index(value)
    fail("Value #{value} not found in picker list #{pickerValues}") if index.nil?

    query("UIPickerView", :delegate, [{:pickerView => :__self__}, {:didSelectRow => index}, {:inComponent => 0}])
    query("UIPickerView", [{:selectRow => index}, {:inComponent => 0}, {:animated => 1}])
    wait_for_none_animating(:timeout=>2)
  end

  #=======================================================================
  # Date and Time pickers - reusing code from calabash
  #=======================================================================
  def setTime(time_str)
    target_time = Time.parse(time_str)
    current_date = date_time_from_picker()
    current_date = DateTime.new(current_date.year,
                                current_date.mon,
                                current_date.day,
                                target_time.hour,
                                target_time.min,
                                0,
                                target_time.gmt_offset)
    picker_set_date_time current_date
    #sleep(STEP_PAUSE)
  end

  def setDate(date_str)
    target_date = Date.parse(date_str)
    current_time = date_time_from_picker()
    date_time = DateTime.new(target_date.year,
                             target_date.mon,
                             target_date.day,
                             current_time.hour,
                             current_time.min,
                             0,
                             Time.now.sec,
                             current_time.offset)
    picker_set_date_time date_time
    #sleep(STEP_PAUSE)
  end
  
  def scrollView(queryString, direction)
    scrollInfo = getContentScrollInfo(queryString)
    return false if scrollInfo.nil?
    scrollOffset = scrollInfo[:offset]
    scrollSize = scrollInfo[:size]
    viewDimensions = getViewInfo(queryString, "rect")
    # beginning of the scrollview no need to scroll further
    return false if direction == :right && scrollOffset[:x] + viewDimensions["width"] >= scrollSize[:x]
    return false if direction == :down && scrollOffset[:y] + viewDimensions["height"] >= scrollSize[:y]

    # end of the scrollview no need to scroll further
    return false if direction == :left && scrollOffset[:x] <= 0
    return false if direction == :up && scrollOffset[:y] <= 0

    scroll(queryString, direction)
    return true
  end

  def scrollViewTo(queryString, direction, what)
    if what == :beginning || what == :end
      if direction == :horizontal
        direction = :left if what == :beginning
        direction = :right if what == :end
      else
        direction = :up if what == :beginning
        direction = :down if what == :end
      end

      while scrollView(queryString, direction)
        sleep 1
      end
      return true
    end

    if (direction == :horizontal || direction == :vertical)
      if direction == :horizontal
        scrollViewTo(queryString, :horizontal, :beginning)
        direction = :right
      else
        scrollViewTo(queryString, :vertical, :beginning)
        direction = :down
      end
      if what.is_a?(String)
        while isNotShown?(what) && scrollView(queryString, direction)
          sleep 1
        end
        return isShown?(what)
      else
        while isNotShown?(what) && scrollView(queryString, direction)
          sleep 1
        end
        return isShown?(what)       
      end
    end

    fail "#{what} with #{direction} is not supported"
  end

  def setTo(queryString, value)
    type = queryString.split(' ').first.to_sym
    if [:textView, :textField, :searchBar,].include?(type)
      fieldSetText(queryString, value)
    elsif [:TextFieldControl, :TextViewControl, :TFLTextField].include?(type)
      fieldAppendText(queryString, value)
    elsif [:pickerView, :ComboBoxFieldControl].include?(type)
      selectPickerValue(value)
    elsif [:datePicker,].include?(type)
      res = Date.parse(value) rescue nil
      if res
        setDate(value)
      else
        setTime(value)
      end
    else
      raise("#{__method__} not defined for #{type}")
    end
  end

  def selectRadioButton(queryString, value)
    accessibilityLabel = queryString.split("'").last
    replaceALWith = "#{accessibilityLabel}#{value.to_s}"
    queryString.sub!(accessibilityLabel, replaceALWith)
    touch queryString
  end

  def deprecatedWarningMessage()
    puts "Please don't use anymore - it's here for backwards compatibility"
  end

end

World(SetHelper)