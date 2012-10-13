class RefineEntry < TableEntry
    attr_accessor :bonus
    attr_accessor :basefactor

    def initialize(csv_row)
        super(csv_row)
        @bonus = BonusStuff.new(csv_row)
        @basefactor = csv_row['exeqpowerrate'].to_i
    end

    def SkipThisItem?
        return false
    end

    def ExportDesc(data)
        @bonus.ExportDesc(data)
        data.push( "base")
    end

    def ExportData(data)
        @bonus.ExportData(data)
        data.push(@basefactor)
    end
end


class Refines < Table
    FILENAME = "eqrefineabilityobject"

    def initialize()
        super(RefineEntry, FILENAME)
    end
end