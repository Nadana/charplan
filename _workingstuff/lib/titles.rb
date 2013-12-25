class TitleEntry < TableEntry

    attr_accessor :bonus
    attr_accessor :image_id

    def initialize(csv_row)
        super(csv_row)
        @bonus = BonusStuff.new(csv_row)
        @image_id = csv_row['imageid'].to_i
    end

    #~ def IsValid?
        #~ return @bonus.HasStats?
    #~ end

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