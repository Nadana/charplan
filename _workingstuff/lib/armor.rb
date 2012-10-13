require_relative 'item_base'

class ArmorEntry < ItemEntry

    attr_accessor :inv_pos
    attr_accessor :armor_typ, :unk1, :unk2

    def initialize(csv_row)
        super(csv_row)
        @inv_pos = csv_row['armorpos'].to_i

        @inv_pos = 21 if @inv_pos==13
        @inv_pos = 16 if @inv_pos==11
        @inv_pos = 13 if @inv_pos==10
        @inv_pos = 11 if @inv_pos==9

        @armor_typ = csv_row['armortype'].to_i
        @unk1 = csv_row['unk124'].to_i
        @unk2 = csv_row['unk128'].to_i

        raise "illegal pos:"+@inv_pos.to_s if @inv_pos>21

# TODO: check supported @armor_typ s

        #raise "stop2: #{@id}" if @bonus.eqtypes.size()>1 and (@bonus.eqtypes[1]!=13 or @bonus.eqtypes[2]!=14)
    end

    def IsTypeValid?
        case @inv_pos
            when 0,1,2,3,4,6,7  # nrl armor
                result = (0..3).include?(@armor_typ)
                return result

            when 8,11,13 # schmuck
                return (@armor_typ==7)

            when 21 # rücken
                return true

            when 10 # fernkampf
                return (@armor_typ==5)

            when 15,16 # waffen
                return true

            when 12 # amulet
                return true

            when 5 # Umhang
                return (@armor_typ==3)
        else
            raise "illegal pos: #{@inv_pos} - #{@id}"
        end
    end

    def IsValid?
        if not IsTypeValid? then
            $log.warn("item has wrong typ-> id:#{@id} - pos:#{@inv_pos} type:#{@armor_typ}")
            return false
        end

        return (super() and @inv_pos!=12)
    end

    def ExportDesc(data)
        data.push( "slot")
        data.push( "type")
        super(data)
    end

    def ExportData(data)
        data.push(@inv_pos)
        data.push(@armor_typ)
        super(data)
    end

    def ArmorEntry.TestWrite(db)

        File.open("armor.html", 'wt') { |outf|
            outf.write("<html><head>\n")
            outf.write('<META HTTP-EQUIV="content-type" CONTENT="text/html; charset=utf-8">')
            outf.write("\n</head/><body>\n")

            names = {
                0=> "Helm", 1=>"Hand", 2=>"Fuß", 3=>"Oberkörper", 4=>"Hose", 5=>"Umhang",
                6=>"Gürtel", 7=>"Schulter", 8=>"Kette", 9=>"", 10=>"",
                11=>"Ring", 12=>"Amulet", 13=>"Ohrring", 14=>"", 15=>"",
                16=>"Schild", 17=>"", 18=>"",19=>"",20=>"", 21=>"Rücken"
                }

            for pos in 0..21
                found = false
                db.each { |id, data|
                        found = true if data.inv_pos==pos
                    }

                outf.write("<a href=\"##{pos}\">Pos #{pos} #{names[pos]}</a><br>\n") if found
            end

            for pos in 0..21
                outf.write("<a name=\"#{pos}\"><h1>Pos: #{pos} #{names[pos]}</h1></a>\n")

                db.each { |id, data|

                    if data.inv_pos==pos then
                        name = $de.get_value("\"Sys#{id}_name\"")
                        outf.write("<a href=\"http://de.runesdatabase.com/item/#{id}\">")
                        outf.write("#{data.armor_typ} - #{data.unk1} - #{data.unk2} -> #{id} #{name}</a><br>\n")
                    end
                    }

            end

            outf.write("</body></html>\n")
        }
    end
end


class Armor < Table
    FILENAME = "armorobject"

    def initialize()
        super(ArmorEntry, FILENAME)
    end
end