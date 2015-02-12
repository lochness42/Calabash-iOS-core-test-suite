require 'calabash-cucumber/operations'

class Base


    def initialize(aWorld, child, static, dynamic)
        @world = aWorld;
        labels = static.merge(dynamic)
        #Generates methods for all label queries
        labels.each_key do |objectName|
            child.send(:define_method, objectName.id2name) do
                return labels.fetch(objectName)
            end
        end

        #generate method to check all static elements on current page
        child.send(:define_method, :checkStaticElements) do
            checkElementsShown static
        end        
    end

    # specifically for actions that require query in format action("view marked:'something'")
    # first two parameters have to be symbol, accessibility label
    # example wantTo(:touch, :view, "testLabel")
    def wantTo(whatAction, queryString)
        if whatAction.is_a?(Symbol)
            test = query(queryString)
            flash queryString if $debug_flash
            @world.printd("#{whatAction}(\"#{queryString}\")", whatAction)
            checkShown(queryString) if whatAction == :touch            
            @world.send(whatAction, queryString)
        else
            @world.fail("action or element type wasn't of type Symbol")
        end
    end

    def getWorld()
        return @world
    end

    def method_missing(method_name, *args, &block)
        @world.send(method_name, *args, &block)
    end
end

