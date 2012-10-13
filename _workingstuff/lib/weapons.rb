require_relative 'item_base'

class WeaponEntry < ItemEntry
    attr_accessor :weapon
    attr_accessor :weapontype


    def initialize(csv_row)
        super(csv_row)
        @weaponpos = csv_row['weaponpos'].to_i # 0-6 -> 0-Haupthand; 1-Nebenhand; 2-Einhand; 3-Zweihand; 4-Munition; 5-Fernkampf; 6-Fertigungswerkzeuge
        @weapontype = csv_row['weapontype'].to_i # 0-20 -> 1-Schwert; 2-Dolch; 6-Zweihandschwert; 11-Bogen

        raise "unkown weapon_pos:"+@weaponpos.to_s if @weaponpos<0 || @weaponpos>6
# TODO: check supported @weapontype s
        #raise "stop2" if @bonus.eqtypes[1]!=25
    end

    def IsValid?
        not_a_weapon = (@weaponpos==4 || @weaponpos==6)
        strange_type = (@weapontype==10 || @weaponpos==15)
        return (super() and not not_a_weapon and not strange_type)
    end

    def ExportDesc(data)
        data.push( "slot")
        data.push( "type")
        super(data)
    end

    def ExportData(data)
        data.push(32+@weaponpos)
        data.push(8+@weapontype)
        super(data)
    end
end


class Weapons < Table
    FILENAME = "weaponobject"

    def initialize()
        super(WeaponEntry, FILENAME)
    end
end

