require 'fileutils'
require 'set'
require 'csv'
require 'logger'

require_relative 'rom_utilities'


$log = Logger.new(open('logfile.txt', File::WRONLY | File::CREAT))
$log.level = Logger::WARN
#$log.level = Logger::INFO
$log.formatter = proc { |severity, datetime, progname, msg|  "#{severity}: #{msg}\n" }

MAX_LEVEL = 80
MAX_RARE = [0,1,2,3,4,5,8]
$log << "FILTER RULES:\n"
$log << "max level is: #{MAX_LEVEL}\n"
$log << "max rariry is: #{MAX_RARE.to_s}\n"
$log << "\n"

$STATLIST={# SYS_WEAREQTYPE_xxx
    0 => "Keine Wirkung.",
    1 => "Haltbarkeit",
    2 => "Stärke",
    3 => "Ausdauer",
    4 => "Intelligenz",
    5 => "Weisheit",
    6 => "Geschicklichkeit",
    7 => "Alle Attribute",
    8 => "Maximale LP",
    9 => "Maximale MP",
    10 => "LP-Erholung",
    11 => "MP-Erholungsrate",
    12 => "Physischer Angriff",
    13 => "Verteidigung",
    14 => "Magische Verteidigung",
    15 => "Magischer Angriff",
    16 => "Präzision",
    17 => "Ausweichrate",
    18 => "Physische kritische Trefferrate",
    19 => "% Kritischer Schaden",
    20 => "Magische kritische Trefferrate",
    21 => "% Kritischer magischer Schaden",
    22 => "Parieren",
    23 => "% Angriffsgeschwindigkeit",
    24 => "% Bewegungsgeschwindigkeit",
    25 => "Schaden",
    26 => "Alle Widerstandskräfte",
    27 => "Erd-Widerstandskraft",
    28 => "Wasser-Widerstandskraft",
    29 => "Feuer-Widerstandskraft",
    30 => "Wind-Widerstandskraft",
    31 => "Licht-Widerstandskraft",
    32 => "Dunkelheits-Widerstandskraft",
    33 => "% verringerter MP-Verbrauch",
    34 => "% Erfahrungsrate",
    35 => "% Droprate",
    36 => "% Nebenhand-Präzision",
    37 => "% Nebenhand-Schadensrate",
    38 => "% Rüstungsschutz-Bonus",
    39 => "% Kettenschutz-Bonus",
    40 => "% Lederschutz-Bonus",
    41 => "% Stoffschutz-Bonus",
    42 => "% Robenschutz-Bonus",
    43 => "% Schildschutz-Bonus",
    44 => "% Magiekraft",
    45 => "% Erdmagiekraft",
    46 => "% Wassermagiekraft",
    47 => "% Feuermagiekraft",
    48 => "% Windmagiekraft",
    49 => "% Lichtmagiekraft",
    50 => "% Dunkelheitsmagiekraft",
    51 => "% Zauberverzögerung",
    52 => "% Fernkampfwaffen-Schadensrate",
    53 => "% Bogen-Schadensrate",
    54 => "% Armbrust-Schadensrate",
    55 => "% Feuerwaffen-Schadensrate",
    56 => "% Nahkampfwaffen-Schadensrate",
    57 => "% Waffenlos-Schadensrate",
    58 => "% Schwert-Schadensrate",
    59 => "% Dolch-Schadensrate",
    60 => "% Stab-Schadensrate",
    61 => "% Axt-Schadensrate",
    62 => "% Einhandhammer-Schadensrate",
    63 => "% Zweihandschwert-Schadensrate",
    64 => "% Zweihandstab-Schadensrate",
    65 => "% Zweihandaxt-Schadensrate",
    66 => "% 'Beidhändiger Hammer'-Schadensrate",
    67 => "% Feuerwaffen-Schadensrate",
    68 => "% Fernangriffsverzögerung",
    69 => "% Bogen-Angriffsverzögerung",
    70 => "% Armbrust-Angriffsverzögerung",
    71 => "% Feuerwaffen-Angriffsverzögerung",
    72 => "% Nahkampf-Angriffsverzögerung",
    73 => "% Waffenlos-Angriffsverzögerung",
    74 => "% Schwert-Angriffsverzögerung",
    75 => "% Dolch-Angriffsverzögerung",
    76 => "% Stab-Angriffsverzögerung",
    77 => "% Axt-Angriffsverzögerung",
    78 => "% Einhandhammer\n-Angriffsverzögerung",
    79 => "% Zweihandschwert-Angriffsverzögerung",
    80 => "% Zweihandstab-Angriffsverzögerung",
    81 => "% Zweihandaxt-Angriffsverzögerung",
    82 => "% 'Beidhändiger Hammer'-Angriffsverzögerung",
    83 => "% Feuerwaffen-Angriffsverzögerung",
    84 => "Fähigkeit: Waffenlos",
    85 => "Fähigkeit: Schwert",
    86 => "Fähigkeit: Dolch",
    87 => "Fähigkeit: Stab",
    88 => "Fähigkeit: Axt",
    89 => "Fähigkeit: Einhandhammer",
    90 => "Fähigkeit: Zweihandschwert",
    91 => "Fähigkeit: Zweihandstab",
    92 => "Fähigkeit: Zweihandaxt",
    93 => "Fähigkeit: Beidhändiger Hammer",
    94 => "Fähigkeit: Feuerwaffe",
    95 => "Fähigkeit: Bogen",
    96 => "Fähigkeit: Armbrust",
    97 => "Fähigkeit: Feuerwaffe",
    98 => "Fähigkeit: Wurfwaffen",
    99 => "Fähigkeit: Platte",
    100 => "Fähigkeit: Kettenrüstung",
    101 => "Fähigkeit: Leder",
    102 => "Fähigkeit: Kleidung",
    103 => "Fähigkeit: Robe",
    104 => "Fähigkeit: Schild",
    105 => "Fähigkeit: Talisman",
    106 => "Fähigkeit: Zweihandwaffe",
    107 => "Waffenlos-Fertigkeit",
    108 => "Schwert-Fertigkeit",
    109 => "Dolch-Fertigkeit",
    110 => "Stab-Fertigkeit",
    111 => "Axt-Fertigkeit",
    112 => "Hammer-Fertigkeitssteigerung",
    113 => "Zweihandschwert-Fertigkeit",
    114 => "Stab-Fertigkeit",
    115 => "Zweihandaxt-Fertigkeit",
    116 => "Zweihandhammer-Fertigkeit",
    117 => "Feuerwaffen-Fertigkeit",
    118 => "Bogen-Fertigkeit",
    119 => "Armbrust-Fertigkeit",
    120 => "Feuerwaffen",
    121 => "Verteidigung",
    122 => "Schmiedehandwerk",
    123 => "Schreinerhandwerk",
    124 => "Rüstungsherstellung",
    125 => "Schneiderhandwerk",
    126 => "Kochfertigkeit",
    127 => "Alchemie",
    128 => "% Schmiede-Erfolgsrate",
    129 => "% Schreinerei-Erfolgsrate",
    130 => "% Rüstungsschmied-Erfolgsrate",
    131 => "% Schneiderei-Erfolgsrate",
    132 => "% Koch-Erfolgsrate",
    133 => "% Alchemie-Erfolgsrate",
    134 => "% physische Angriffe",
    135 => "% Verteidigung",
    136 => "% Stehlen",
    137 => "% Gold-Beute",
    138 => "% Aggro",
    139 => "% Zornerholung",
    140 => "% Fokuserholung",
    141 => "% Energieerholung",
    142 => "% Magieabsorption",
    143 => "% Verteidigungsabsorption",
    144 => "% Heilungsabsorption",
    145 => "Magieabsorption",
    146 => "Verteidigungsabsorption",
    147 => "Heilungsabsorption",
    148 => "Magischer Schaden",
    149 => "% Heilung",
    150 => "Heilung",
    151 => "Fernkampfwaffen-Reichweite",
    152 => "Holzfällerfertigkeit",
    153 => "Kräutersammelfertigkeit",
    154 => "Bergbaufertigkeit",
    155 => "Fischereifertigkeit",
    156 => "Holzfäller-Beuterate",
    157 => "Kräutersammel-Beuterate",
    158 => "Bergbau-Beuterate",
    159 => "Angel-Beuterate",
    160 => "Sammel-Erfolgsrate",
    161 => "% Stärke",
    162 => "% Ausdauer",
    163 => "% Intelligenz",
    164 => "% Weisheit",
    165 => "% Geschicklichkeit",
    166 => "% Alle Hauptattribute",
    167 => "% LP-Maximums",
    168 => "% MP-Maximums",
    169 => "% Reitgeschwindigkeit",
    170 => "% Magische Verteidigung",
    171 => "% Magische Angriffskraft",
    172 => "Schildblockrate",
    173 => "% Schaden",
    174 => "Sekundärklassenerfahrung",
    175 => "% TP-Erfahrung",
    176 => "% Holzfäller-Erfolgsrate",
    177 => "% Kräutersammel-Erfolgsrate",
    178 => "% Bergbau-Erfolgsrate",
    179 => "% Fischerei-Erfolgsrate",
    181 => "% Chance auf zusätzliche Attacke",
    182 => "Physischer kritischer Widerstand",
    183 => "Magischer kritischer Widerstand",
    184 => "Erdschaden",
    185 => "Wasserschaden",
    186 => "Feuerschaden",
    187 => "Windschaden",
    188 => "Lichtschaden",
    189 => "Dunkler Schaden",
    190 => "Sprung-Fähigkeit",
    191 => "Magieschadenspunkte",
    192 => "% magische Schadensrate",
    193 => "Schildblock überwinden",
    194 => "Parieren überwinden",
    195 => "Magische Präzision",
    196 => "Magie-Resistenz",
    197 => "% Präzision bei physischen Angriffen",
    198 => "Ausweichrate",
    199 => "% Magische Präzision",
    200 => "Magische Widerstandsrate",
    201 => "Sammelmenge",
    202 => "Sammelgeschwindigkeit",
    203 => "Sammelerfahrung",
    204 => "Schaden gegen Spieler und Begleiter",
    205 => "Schaden gegen NPCs",
    206 => "% Schaden von Spielern",
    207 => "% Schaden von Monstern",
    208 => "Angriffskraft von Flächenzaubern",
    209 => "Widerstand gegen AC-Zauber",
    210 => "Herstellungsgeschwindigkeit",
    211 => "Herstellungserfahrung",
    212 => "Erhöhung der EP nach Spielerfolg",
    213 => "Erhöhung der TP nach Spielerfolg",
}




class Images

    # Options
    CHECK_IF_FILE_EXISTS = false
    BASE_ICON_PATH = "interface/icons/"

    attr_accessor :list
    attr_accessor :used

    def Load
        base_dir = TempPath()
        base_dir = Extract("data\\","imageobject.db",{:fdb_filter=>"data.fdb"})  unless File.exists?(base_dir+"imageobject.db.csv")

        if CHECK_IF_FILE_EXISTS then
            p "Extracting Icons"
            Extract("interface\\icons\\","",{:fdb_filter=>"interface.fdb"})
        end

        images_csv = CSV.read(base_dir+'imageobject.db.csv', {:col_sep=>";", :headers=>true})

        @list = Hash.new("")
        images_csv.each { |row|
            id = row['guid'].to_i
            filename = row['actfield']
            if not filename.nil? then
                filename.tr!('\\','\/')  # replace slash
                filename.gsub!(/^\//,'') # remove leading slash
                filename.downcase!       # using lower case to minimize mem usage

                filename.gsub!(/\..+$/,'') # remove extention

                next if filename=~/\/$/ # rom bug? icon is a directory

                if CHECK_IF_FILE_EXISTS then
                    if not ImageExists?(TempPath()+filename) then
                        $log << "Image #{id}: file not exists: #{filename}\n"
                        # p "file not exists: "+filename
                        next
                    end
                end

                @list[id] = filename
            end
        }

        @used = Set.new()
    end

    def ImageExists?(fname)
        return File.exists?(fname+".dds")
    end

    def ImageUsed(id)
        raise "unknown image: "+id.to_s unless @list.key?(id)
        @used.add(id)
    end

    def WriteLUATable(outf)
        outf.write("-- base-path: #{BASE_ICON_PATH}\n")
        outf.write("return {\n")

        @used.each { |id|
            filename = @list[id]

            raise "image not on base path: "+filename unless filename=~/^#{Regexp.escape(BASE_ICON_PATH)}/
            filename = filename.gsub(/^#{Regexp.escape(BASE_ICON_PATH)}/,'')

            outf.write( "  [%i]=\"%s\",\n" % [id, filename] )
        }

        outf.write("}\n")
    end
end

class BonusStuff
    attr_accessor :eqtypes, :eqvalues

    def initialize(csv_row, max_bonus=10)
        raise "db-format changed (updated fdbex?)" unless csv_row.header?('eqtype1')

        @eqtypes=[]
        @eqvalues=[]
        for i in 1..max_bonus
            type = csv_row['eqtype'+i.to_s].to_i
            value = csv_row['eqtypevalue'+i.to_s].to_i

            if type>0 and (i<3 or value!=0) then
                @eqtypes.push(type)
                @eqvalues.push(value)

                @unknown_stat = type if not $STATLIST.key?(type)
            end
        end
    end

    def HasInvalidStat?
        return  @unknown_stat
    end

    def HasStats?
        return  @eqtypes.size>0
    end

    def SameEffects?(bonus)
        @eqtypes.each { |v| return false unless bonus.eqtypes.find_index(v)}
        bonus.eqtypes.each { |v| return false unless @eqtypes.find_index(v)}
        return true
    end

    def ExportDesc(data)
        data.push( "<effect>")
    end

    def ExportString()
        if @eqtypes.size==0 then
            return "nil"
        else
            res = []
            for i in 0..(@eqtypes.size-1)
                res.push(@eqtypes[i])
                res.push(@eqvalues[i])
            end
            return res.join(",")
        end
    end

    def ExportData(data)
        data.push("{#{ExportString()}}")
    end

    def ExportDataPlain(data)
        data.push(ExportString())
    end
end


class StatsStuff
    attr_accessor :stats
    attr_accessor :has_randoms

    def initialize(csv_row)
        @stats=[]
        for i in 1..6

            type = csv_row['dropability'+i.to_s].to_i
            value = csv_row['dropabilityrate'+i.to_s].to_i / 1000

            if value>=100then
                if type > 599999 then
                    @has_randoms = true
                else
                    @stats.push(type)
                end
            end
        end
    end

    def HasStats?
        return  ((@stats.size>0) or (@has_randoms))
    end

    def ExportDesc(data)
        data.push( "<stats>")
    end

    def ExportData(data)
        if @stats.size==0 then
            data.push("nil")
        else
            data.push("{#{@stats.join(",")}}")
        end
    end

end



class Table
    attr_accessor :id
    attr_accessor :unused

    def initialize(csv_row)
        @id = csv_row['guid'].to_i
        @unused = false
    end

    def SkipThisItem?
        return @unused
    end

    def Used()
        @unused = false
    end

    def NotUsed()
        @unused = true
    end

    def Table.MarkAllUnused(db)
        db.each { |id, data| data.unused=true }
    end

    def Table.Load(filename=nil, update=true)
        items=Hash.new
        filename = self::FILENAME if filename.nil?

        if update
            base_dir = TempPath()+"data\\"
            base_dir = Extract("data\\","#{filename}.db",{:fdb_filter=>"data.fdb"})  unless File.exists?(base_dir+"#{filename}.db.csv")
        else
            base_dir = ''
        end

        csv = CSV.read(base_dir+"#{filename}.db.csv", {:col_sep=>";", :headers=>true, :converters => :numeric})

        csv.each { |row|
            r = self.new(row)
            next if r.SkipThisItem?
            items[r.id]= r
        }

        AfterLoad(items)

        return items
    end

    def Table.AfterLoad(db)
    end

    def Table.Export(filename, db)

        desc = Hash.new()
        db.each { |id, data|
            if not desc.has_key?(data.class) then
                line_data = []
                data.ExportDesc(line_data)
                desc[data.class] = line_data.join(",")
            end
        }

        File.open(filename, 'wt') { |outf|
            desc.each { |cl,d|
                outf.write( "-- %s: %s\n" % [cl.to_s,d])
                }

            outf.write("return {\n")
            db.each { |id, data|
                next if data.SkipThisItem?

                line_data = []
                data.ExportData(line_data)

                while not line_data.empty? and (line_data.last=="nil" or line_data.last.to_s.empty?) do line_data.pop end

                outf.write( "  [%s]={%s},\n" % [id, line_data.join(",")])
                }
            outf.write("}\n")
        }
    end
end

class ItemEntry < Table

    attr_accessor :image_id, :min_level, :set
    attr_accessor :bonus
    attr_accessor :base_stats
    attr_accessor :refineid
    attr_accessor :durable, :isfixdurable
    attr_accessor :runeslots, :runeminlvl

    def initialize(csv_row)
        super(csv_row)
        @id = csv_row['guid'].to_i
        @image_id = csv_row['imageid'].to_i
        @level = csv_row['limitlv'].to_i
        @set = csv_row['suitid'].to_i
        @refineid = csv_row['refinetableid'].to_i
        @durable = csv_row['durable'].to_i
        @isfixdurable = csv_row['isfixdurable'].to_i
        @runeslots = csv_row['holebase'].to_i      #### looks like max holes?
        @runeminlvl = csv_row['runelimetlv'].to_i  #### minimum rune level ?
        @rare = csv_row['rare'].to_i

        @bonus = BonusStuff.new(csv_row)
        @base_stats = StatsStuff.new(csv_row)
    end

    def SkipThisItem?
        if @bonus.HasInvalidStat? then
            $log << "Item #{@id}: has invalid bonus #{@bonus.HasInvalidStat?}\n"
            return true
        end

        if @level>MAX_LEVEL then
            $log.info("Item #{@id}: is above max level #{@level}")
            return true
        end

        name = $de[@id]
        if name==nil then
            $log.info("Item #{@id}: has no name")
            return true
        end

        if MAX_RARE.index(@rare).nil? then
            $log.info("Item #{@id}: has rarity #{@rare}")
            return true
        end

        return false
    end


    def ExportDesc(data)
        data.push( "level")
        data.push( "icon")
        data.push( "refine")
        data.push( "dura")
        #data.push( "runes=%i" % @runeslots) if @runeslots>0
        bonus.ExportDesc(data)
        base_stats.ExportDesc(data)
        data.push( "<set>")
    end

    def ExportData(data)
        data.push( @level)
        data.push( @image_id)
        data.push( @refineid)
        if @isfixdurable==0 then
            data.push( @durable)
        else
            data.push( -@durable)
        end
        #data.push( "runes=%i" % @runeslots) if @runeslots>0
        bonus.ExportData(data)
        base_stats.ExportData(data)

        if not @set.nil? and @set>0 then
            data.push( @set)
        else
            data.push( "nil")
        end
    end

end

class ArmorEntry < ItemEntry

    FILENAME = "armorobject"
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

    def SkipThisItem?
        if not IsTypeValid? then
            $log.warn("item has wrong typ-> id:#{@id} - pos:#{@inv_pos} type:#{@armor_typ}")
            return true
        end
        res = super
        return res || @inv_pos==12
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


class WeaponEntry < ItemEntry

    FILENAME = "weaponobject"
    attr_accessor :weapon
    attr_accessor :weapontype
    attr_accessor :attackspeed


    def initialize(csv_row)
        super(csv_row)
        @weaponpos = csv_row['weaponpos'].to_i # 0-6 -> 0-Haupthand; 1-Nebenhand; 2-Einhand; 3-Zweihand; 4-Munition; 5-Fernkampf; 6-Fertigungswerkzeuge
        @weapontype = csv_row['weapontype'].to_i # 0-20 -> 1-Schwert; 2-Dolch; 6-Zweihandschwert; 11-Bogen
        @attackspeed = csv_row['attackspeed'].to_i

        raise "unkown weapon_pos:"+@weaponpos.to_s if @weaponpos<0 || @weaponpos>6
# TODO: check supported @weapontype s
        #raise "stop2" if @bonus.eqtypes[1]!=25
    end

    def SkipThisItem?
        not_a_weapon = (@weaponpos==4 || @weaponpos==6)
        strange_type = (@weapontype==10 || @weaponpos==15)
        return super() || not_a_weapon || strange_type
    end

    def ExportDesc(data)
        data.push( "slot")
        data.push( "type")
        super(data)
        data.push( "attackspeed")
    end

    def ExportData(data)
        data.push(32+@weaponpos)
        data.push(8+@weapontype)
        super(data)
        data.push(@attackspeed)
    end
end

class FoodEntry < Table

    FILENAME = "itemobject"
    attr_accessor :type
    attr_accessor :spell


    def initialize(csv_row)
        super(csv_row)
        @type = csv_row['itemtype'].to_i
        @spell = csv_row['incmagic_onuse'].to_i
    end

    def SkipThisItem?
        return true if not [2,3,4].include?(@type)  # 2="Nahrung";3="Nachspeise";4="Trank"

        return super() || (@spell==0)
    end

    def ExportDesc(data)
        data.push("magic")
    end

    def ExportData(data)
        data.push(@spell)
    end

    def FoodEntry.MarkSpells(db,spells)
        db.each { |id, data|
            if not data.SkipThisItem? then
                if spells.include?(data.spell)
                    spells[data.spell].Used
                else
                    data.NotUsed
                end
            end
        }
    end

    # no more additional data
    def FoodEntry.Export(filename, db)
        File.open(filename, 'wt') { |outf|
            outf.write("return {\n")
            db.each { |id, data|
                outf.write( "  [%i]=%i,\n" % [id, data.spell])
                }
            outf.write("}\n")
        }
    end
end

class AddPowerEntry < Table

    FILENAME = "addpowerobject"
    attr_accessor :bonus
    attr_accessor :group

    def initialize(csv_row)
        super(csv_row)
        @bonus = BonusStuff.new(csv_row)

        raise "unknown bonus stat" if @bonus.HasInvalidStat?
        $log.info("addpower #{@id} has no name") if $de[@id].nil?
    end

    def SkipThisItem?
        return @bonus.HasInvalidStat? || (not @bonus.HasStats?)
    end

    def AddPowerEntry.AfterLoad(db)

        groups = Hash.new
        grp_idx = 1
        db.each { |id,r|

            name = $de[id]
            next if name.nil?
            matchdata = /^(.+)\s+(\w+)$/.match(name)
            name = matchdata[1] if not matchdata.nil?

            if groups.key?(name) then
                found = nil
                groups[name].each { |gid,boni|
                    found = gid if boni.SameEffects?(r.bonus)
                }
                if found then
                    r.group = found
                else
                    groups[name][grp_idx] = r.bonus
                    r.group = grp_idx
                    grp_idx += 1
                end
            else
                groups[name] = {[grp_idx] => r.bonus}
                r.group = grp_idx
                grp_idx += 1
            end
        }
    end

    def ExportDesc(data)
        @bonus.ExportDesc(data)
        data.push( "grp")
    end

    def ExportData(data)
        @bonus.ExportData(data)
        data.push(@group)  if @group
    end
end

class RunesEntry < Table

    FILENAME = "runeobject"
    attr_accessor :bonus
    attr_accessor :level, :group

    def initialize(csv_row)
        super(csv_row)
        @bonus = BonusStuff.new(csv_row)
        @group = 10000+csv_row['runegroup'].to_i

        raise "unknown bonus stat" if @bonus.HasInvalidStat?
        $log.info("rune #{@id} has no name") if $de[@id].nil?
    end

   def RunesEntry.AfterLoad(db)

        groups = Hash.new
        db.each { |id,r|

            name = $de[id]
            matchdata = /^(.+)\s+(\w+)$/.match(name)

            if groups.key?(r.group) then
                raise "different bonis in group #{r.group}" unless r.bonus.SameEffects?(groups[r.group][:boni])
                raise "name differs" if matchdata[1] != groups[r.group][:name]
            else
                groups[r.group] ={:boni => r.bonus, :name=>matchdata[1] }
            end
        }
    end


    def SkipThisItem?
        return @bonus.HasInvalidStat? || (not @bonus.HasStats?) || $de[@id].nil?
    end

    def ExportDesc(data)
        @bonus.ExportDesc(data)
        data.push( "grp")
    end

    def ExportData(data)
        @bonus.ExportData(data)
        data.push(@group) if @group
    end
end

class SuitEntry < Table

    FILENAME = "suitobject"

    attr_accessor :totalcount
    attr_accessor :set_items
    #attr_accessor :bonis

    def initialize(csv_row)
        super(csv_row)
        @totalcount = csv_row['totalcount'].to_i

        @set_items=[]
        for i in 1..10

            item = csv_row['suitlist'+i.to_s].to_i

            if item>0 then
                @set_items.push(item)
            end
        end

        $log << "set #{id} -> count #{@totalcount} not equal item list:#{@set_items.size}\n" if @totalcount != @set_items.size
        #p "#{id} -> more items #{@set_items.size} in set as possible #{@totalcount}" if @totalcount != @set_items.size


        @bonis=[]
        for b in 1..9
            @bonis[b] = []
            for i in 1..3
                type = csv_row["basetype#{b}_#{i}"].to_i
                value = csv_row["basetypevalue#{b}_#{i}"].to_i

                if type>0 and value>0 then
                    @bonis[b].push(type,value)

                    $log << "set #{id} -> unknown stat #{type}\n" if not $STATLIST.key?(type)
                    @has_unknown_stat=type if not $STATLIST.key?(type)
                end
            end
        end

        #~ max =0
        #~ for b in 1..9
            #~ max = b if @bonis[b][:eff].size>0
        #~ end

        #~ raise "#{id} -> more bonuses #{max+1} in set as possible #{@totalcount}" if @totalcount != max+1
    end

    def HasBonis?
        for b in 1..9
            return true if @bonis[b].size>0
        end
        return false
    end

    def SkipThisItem?
        name = $de[@id]

        $log << "set #{id} -> without set items\n" if @totalcount==0

        return  (@has_unknown_stat or @totalcount==0 or
                (not HasBonis?) or
                 name.nil? )
    end

    def ExportDesc(data)
        for b in 1..9
            data.push( "[count]={effect}")
        end
    end

    def ExportData(data)
        for b in 1..9
            if @bonis[b].size>0 then
                data.push("[#{b}]={#{@bonis[b].join(",")}}")
            end
        end
    end

end


class RefineEntry < Table

    FILENAME = "eqrefineabilityobject"
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

class MagicCollectionEntry < Table

    FILENAME = "magiccollectobject"
    attr_accessor :magics
    attr_accessor :effecttype

    def initialize(csv_row)
        super(csv_row)
        @magics=[]
        for i in 1..12
            magic = csv_row['magicbaseid'+i.to_s].to_i
            @magics.push(magic) if magic>0
        end

        @effecttype = csv_row['effecttype'].to_i
    end

    def SkipThisItem?
        return true if @effecttype!=2  # passive spells only
        return true if @magics.size==0
    end

    def ExportDesc(data)
        data.push( "{magics}")
    end

    def ExportData(data)
        @magics.each {|d|
            data.push(d)
        }
    end

    def MagicCollectionEntry.MarkSpells(db,spells)
        db.each { |id, data|
            if not data.SkipThisItem? then
                undefined = []
                data.magics.each {|d|
                    if spells.include?(d)
                        spells[d].Used
                    else
                        undefined.push(d)
                    end
                }
                data.magics = data.magics-undefined
            end
        }
    end

end

class MagicObjectEntry < Table

    FILENAME = "magicobject"
    attr_accessor :bonus
    attr_accessor :skilllvarg


    def initialize(csv_row)
        super(csv_row)
        @bonus = BonusStuff.new(csv_row)
        @skilllvarg = csv_row['ability_skilllvarg'].to_f
    end

    def SkipThisItem?
        return super() || (not @bonus.HasStats?)
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

class CardEntry < Table

    FILENAME = "cardobject"
    attr_accessor :cardaddpower

    def initialize(csv_row)
        super(csv_row)
        @cardaddpower = csv_row['cardaddpower'].to_i
    end

    def SkipThisItem?
        if @cardaddpower==0 then
            $log.info("#{@id} Card has no bonus")
            return true
        end
        return false
    end

    def ExportDesc(data)
    end

    def CardEntry.Export(filename, db)
        File.open(filename, 'wt') { |outf|
            outf.write("return {\n")
            db.each { |id, data|
                outf.write( "  [%i]=%i,\n" % [id, data.cardaddpower])
                }
            outf.write("}\n")
        }
    end
end

class TitleEntry < Table

    FILENAME = "titleobject"
    attr_accessor :bonus

    def initialize(csv_row)
        super(csv_row)
        @bonus = BonusStuff.new(csv_row)
    end

    def SkipThisItem?
        return (not @bonus.HasStats?)
    end

    def ExportDesc(data)
        @bonus.ExportDesc(data)
    end

    def ExportData(data)
        @bonus.ExportDataPlain(data)
    end
end

class VocTable < Table

    FILENAME = "voctable"
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

    def SkipThisItem?
        return @id.nil?
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
				#print("%d: str+ %f, sta+ %f, wis %f\n" % [@row['GUID'], @row['STR_ADD'],@row['STA_ADD'], @row['MDEF_WIS_FAKTOR'] ])
    end
end

class FullDB

    attr_accessor :images
    attr_accessor :items
    attr_accessor :addpower, :suits
    attr_accessor :refines, :cards
    attr_accessor :skills, :spells
    attr_accessor :food
    attr_accessor :title
    attr_accessor :Vocs

    def Load

        p "Load Strings"
        $de = Locales.new("de")

        p "Load Images"
        @images = Images.new()
        @images.Load()

        p "Load Armor"
        @items = ArmorEntry.Load()

        p "Load Weapons"
        weapons= WeaponEntry.Load()
        @items.merge!(weapons)

        p "Load Bonuses"
        @addpower= AddPowerEntry.Load()
        runes = RunesEntry.Load()
        @addpower.merge!(runes)

        p "Load Sets"
        @suits = SuitEntry.Load()

        p "Load Refines"
        @refines = RefineEntry.Load()

        p "Load Spells"
        @spells = MagicObjectEntry.Load()
        @skills = MagicCollectionEntry.Load()

        p "Load Food"
        @food = FoodEntry.Load()

        p "Load Cards"
        @cards = CardEntry.Load()

        p "Load Archievements"
        @title = TitleEntry.Load()

        p "Load VocTable"
        @Vocs = VocTable.Load()

    end

    def Export
        p "writting"
        File.open("../item_data/images.lua", 'wt') {|outf| @images.WriteLUATable(outf) }

        Table.Export("../item_data/sets.lua", @suits)
        Table.Export("../item_data/refines.lua", @refines)
        Table.Export("../item_data/addpower.lua", @addpower)
        Table.Export("../item_data/archievements.lua", @title)

        CardEntry.Export("../item_data/cards.lua", @cards)
        ArmorEntry.Export("../item_data/items.lua", @items)

        MagicCollectionEntry.Export("../item_data/skills.lua", @skills)
        MagicObjectEntry.Export("../item_data/spells.lua", @spells)

        FoodEntry.Export("../item_data/food.lua", @food)

        VocTable.Export("../item_data/classes.lua", @Vocs)

        #ArmorEntry.TestWrite(armor)
    end


    def Check
        p "Checking & cleanup"
        CheckSetItems(@suits, @items)
        CheckImages(@items, @images)
        FilterSpells()
    end

    def FilterSpells
        Table.MarkAllUnused(@spells)
        MagicCollectionEntry.MarkSpells(@skills,@spells)
        FoodEntry.MarkSpells(@food,@spells)
    end

    def CheckImages(items, images)
        items.each { |id,r|
            begin
                images.ImageUsed(r.image_id)
            rescue
                $log.warn("Item #{r.id} removed 'cause image is invalid/unknown (#{r.image_id})")
                items.delete(r)
            end
        }
    end

    def CheckSetItems(sets, items)

        sets.each { |id,s|
            s.set_items.each { |i|
                if (items.has_key?(i)) then
                    if items[i].set!=id then
                        $log << "Item #{i} is listed for different set: #{items[i].set} (should be #{id})\n"
                        #raise "mismatch"
                    end
                else
                    $log << "set #{id} has unknown item: #{i}\n"
                    #raise "set #{id} has unknown item: #{i}"
                end
            }
        }

        #~ armor.each { |id,data|
            #~ raise "set not exists" unless sets.key?(data.set)

            #~ found = false
                #~ sets[data.set].set_items.each { |i|
                    #~ found = true if i==id
                #~ }

            #~ raise "not found in set" unless found
        #~ }
    end
end


######################################
CheckTempPath()


db = FullDB.new
db.Load
db.Check
db.Export
