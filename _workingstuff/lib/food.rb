class FoodEntry < TableEntry

    attr_accessor :type
    attr_accessor :spell


    def initialize(csv_row)
        super(csv_row)
        @type = csv_row['itemtype'].to_i
        @spell = csv_row['incmagic_onuse'].to_i
    end

    def IsValid?
        return false if not [2,3,4].include?(@type)  # 2="Nahrung";3="Nachspeise";4="Trank"

        return (super() and @spell!=0)
    end

    def ExportDesc(data)
        data.push("magic")
    end

    def ExportData(data)
        data.push(@spell)
    end
end


class Food < Table
    FILENAME = "itemobject"

    def initialize()
        super(FoodEntry, FILENAME)
    end

    def MarkSpellsUsed(spells)
        each { |data|
            if spells.db.include?(data.spell)
                spells.Used(data.spell)
            else
                data.NotUsed
            end
        }
    end

end