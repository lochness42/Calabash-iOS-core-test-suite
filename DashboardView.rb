require_relative 'BaseView.rb'

class DashboardView < Base
  STATIC = { 
    view: "button marked:'createEIRF'",
    create_eIRF: "button marked:'createEIRF'",
  }

  DYNAMIC = {
  }

  def initialize(aWorld)
    super(aWorld, (class << self; self end), STATIC, DYNAMIC)
  end

  def checkStaticObjects()
    outputString = ""
    STATIC.each_key { |staticObject|
      checkShown self.send(staticObject)
    }
  end

end