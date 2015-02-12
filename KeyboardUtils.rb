module KeyboardUtils
#    def keyboard_type_text(aField, aValue, aFieldTypeToClear = nil)
#      keyboardTypeText(aFieldTypeToClear, aField, aValue)
#    end

#    def keyboard_clear_text(aField, aFieldType = nil)
#      keyboardClearText(aFieldType, aField)
#    end

    # to align with other functions specifying field type as first and also to accomodate symbols as variables
    def fieldSetText(queryString, text)
        fieldClearText(queryString)
        fieldAppendText(queryString, text)
        query(queryString, :text).first == text
    end

    def fieldAppendText(queryString, text)
        selectFieldAndWaitForKeyboard(queryString)
        keyboard_enter_text(text)
    end

    # to align with other functions specifying field type as first and also to accomodate symbols as variables
    def fieldClearText(queryString)
      selectFieldAndWaitForKeyboard(queryString)
      return if query(queryString, :text).first.length == 0 
      while query(queryString, :text).first.length > 0
        keyboard_enter_char("Delete")
      end
    end

    def selectFieldAndWaitForKeyboard(queryString)
        checkShown queryString
        touch(queryString)
        waitKeyboardVisible?
    end

    def keyboardVisible?()
      return (not query("view:'UIKeyboardAutomatic'").empty?());
    end

    def waitKeyboardVisible?()
      wait_for(:timeout => 10) do
        keyboardVisible?()
      end
    end

    def keyboardCheck(aVisible)
        case aVisible.to_sym
        when :displayed
          checkShown("UIKeyboardAutomatic")
        when :dismissed
          checkNotShown("UIKeyboardAutomatic")
        end
    end
end

World(KeyboardUtils)
