require_relative 'table'

class MagicObjectEntry < TableEntry
    attr_accessor :bonus
    attr_accessor :skilllvarg
    attr_accessor :atk_varg
    attr_accessor :atk_dmg
    attr_accessor :atk_dmg_fix
    attr_accessor :time
    attr_accessor :time_varg


    def initialize(csv_row)
        super(csv_row)
        @bonus = BonusStuff.new(csv_row)
        @skilllvarg = csv_row['ability_skilllvarg'].to_f

        @atk_varg = csv_row['dmgpower_skilllvarg'].to_f
        @atk_dmg = csv_row['atk_dmgpower'].to_f
        @atk_dmg_fix = csv_row['atk_fixvalue'].to_f
        @time = csv_row['effecttime'].to_f
        @time_varg = csv_row['effecttime_skilllvarg'].to_f
    end

    #~ def IsValid?
        #~ return (super() and @bonus.HasStats?)
    #~ end

    def ExportDesc(data)
        data.push("skilllvarg")
        @bonus.ExportDesc(data)
        data.push("time")
        data.push("time_varg")
        data.push("atk_dmg")
        data.push("atk_varg")
        data.push("atk_dmg_fix")
    end

    def ExportData(data)
        data.push(@skilllvarg)
        @bonus.ExportData(data)
        @time!=0 ? data.push(@time) : data.push("nil")
        (@time!=0 and @time_varg!=0) ? data.push(@time_varg) : data.push("nil")
        @atk_dmg!=0 ? data.push(@atk_dmg) : data.push("nil")
        (@atk_varg!=0 and @atk_dmg!=0) ? data.push(@atk_varg) : data.push("nil")
        @atk_dmg_fix!=0 ? data.push(@atk_dmg_fix) : data.push("nil")
    end
end


class Magics < Table
    FILENAME = "magicobject"

    def initialize()
        super(MagicObjectEntry, FILENAME)
    end
end