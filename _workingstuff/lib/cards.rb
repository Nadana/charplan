require_relative 'table'
require_relative 'items'

class CardEntry < ItemsEntry

    attr_accessor :cardaddpower

    def initialize(csv_row)
        super(csv_row)
        @cardaddpower = csv_row['cardaddpower'].to_i
    end

    def IsValid?
 # replace by:  MarkUnusedIf (|d| d.cardaddpower==0 }
        #~ if @cardaddpower==0 then
            #~ $log.info { "#{@id} Card has no bonus" } if $log
            #~ return false
        #~ end
        return true
    end

    def ExportDesc(data)
        data.push("addpower")
    end

    def ExportData(data)
        data.push(cardaddpower)
    end
end


class Cards < Table
    FILENAME = "cardobject"

    def initialize()
        super(CardEntry, FILENAME)
    end
end