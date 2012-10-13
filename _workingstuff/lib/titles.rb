class TitleEntry < TableEntry

    attr_accessor :bonus

    def initialize(csv_row)
        super(csv_row)
        @bonus = BonusStuff.new(csv_row)
    end

    def IsValid?
        return @bonus.HasStats?
    end

    def ExportDesc(data)
        @bonus.ExportDesc(data)
    end

    def ExportData(data)
        @bonus.ExportData(data)
    end
end


class Titles < Table
    FILENAME = "titleobject"

    def initialize()
        super(TitleEntry, FILENAME)
    end
end