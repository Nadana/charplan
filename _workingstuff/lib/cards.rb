class CardEntry < TableEntry

    attr_accessor :cardaddpower

    def initialize(csv_row)
        super(csv_row)
        @cardaddpower = csv_row['cardaddpower'].to_i
    end

    def IsValid?
        if @cardaddpower==0 then
            $log.info("#{@id} Card has no bonus")
            return false
        end
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