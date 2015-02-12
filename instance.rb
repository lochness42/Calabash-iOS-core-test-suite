module Instance

  INSTANCES = [
    :dashboardView,
    :errorModalView,

    :generalInfoFormView,
    :descriptionFormView,
  ]

  INSTANCES.each do |classname|
    cname = classname.id2name
    define_method("#{cname}") do
      eval("@#{cname} ||= #{stringToClassFormat(cname)}.new(self)")    
    end
  end

  def global()
    @global ||= @World
  end

  def instance(aElement)
    inst = method(aElement);
    inst.call();
  end
end

World(Instance)
