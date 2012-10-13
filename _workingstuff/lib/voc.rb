class VocTable < TableEntry

    CLASSES = { 301003=>"WARRIOR",301005=>"RANGER", 301007=>"THIEF", 301009=>"MAGE",
                301011=>"AUGUR", 301013=>"KNIGHT", 301015=>"WARDEN", 301017=>"DRUID",
                301019=>"HARPSYN", 301021=>"PSYRON"
                }

    def initialize(csv_row)
        super(csv_row)
        @id = CLASSES[csv_row['GUID'].to_i]
        @id = '"'+@id+'"' unless @id.nil?
        @row = csv_row
    end

    def IsValid?
        return (not @id.nil?)
    end

    def ExportDesc(data)
    end

    def ExportData(data)
        data.push(@row['STR']) #1
        data.push(@row['STA'])
        data.push(@row['INT'])
        data.push(@row['WIS'])
        data.push(@row['DEX'])
        data.push(@row['hp_base'])
        data.push(@row['mp_base'])
        data.push(@row['STR_ADD']) #8
        data.push(@row['STA_ADD'])
        data.push(@row['INT_ADD'])
        data.push(@row['WIS_ADD'])
        data.push(@row['DEX_ADD'])
        data.push(@row['HP_ADD'])
        data.push(@row['MP_ADD'])
        data.push(@row['STR_MUL']) # 15
        data.push(@row['STA_MUL'])
        data.push(@row['INT_MUL'])
        data.push(@row['WIS_MUL'])
        data.push(@row['DEX_MUL'])
        data.push(@row['HP_MUL'])
        data.push(@row['MP_MUL'])

        data.push(@row['PATK_STR_FAKTOR'])
        data.push(@row['PATK_INT_FAKTOR'])
        data.push(@row['PATK_DEX_FAKTOR'])
        data.push(@row['PDEF_STA_FAKTOR'])
        data.push(@row['MDEF_WIS_FAKTOR'])
    end
end


class Voc < Table
    FILENAME = "voctable"

    def initialize()
        super(VocTable, FILENAME)
    end
end