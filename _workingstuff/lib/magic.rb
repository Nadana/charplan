class MagicObjectEntry < TableEntry
    attr_accessor :bonus
    attr_accessor :skilllvarg


    def initialize(csv_row)
        super(csv_row)
        @bonus = BonusStuff.new(csv_row)
        @skilllvarg = csv_row['ability_skilllvarg'].to_f
    end

    def IsValid?
        return (super() and @bonus.HasStats?)
    end

    def ExportDesc(data)
        data.push( "skilllvarg")
        @bonus.ExportDesc(data)
    end

    def ExportData(data)
        data.push(@skilllvarg)
        @bonus.ExportData(data)
    end
end


class Magics < Table
    FILENAME = "magicobject"

    def initialize()
        super(MagicObjectEntry, FILENAME)
    end
end