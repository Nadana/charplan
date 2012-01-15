require 'fileutils'
require 'set'
require 'csv'
require 'logger'

require_relative 'rom_utilities'


$log = Logger.new(open('logfile.txt', File::WRONLY | File::CREAT))
$log.level = Logger::INFO # WARN
$log.formatter = proc { |severity, datetime, progname, msg|  "#{severity}: #{msg}\n" }


# Pathes
$temp_path="e:/Temp/ro/"  # will be deleted !

MAX_LEVEL = 70


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
        base_dir = $temp_path+"data/"
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
                    if not ImageExists?($temp_path+filename) then
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

    def initialize(csv_row)
        @eqtypes=[]
        @eqvalues=[]
        for i in 1..10

            type = csv_row['eqtype'+i.to_s].to_i
            value = csv_row['eqtypevalue'+i.to_s].to_i

            if type>0 and value>0 then
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

     def WriteLUAData(outf)
        if @eqtypes.size>0 then
            outf << "efftype={#{@eqtypes.join(",")}},"
            outf << "effvalue={#{@eqvalues.join(",")}}"
        end
    end

end


class Table
    attr_accessor :id

    def initialize(csv_row)
        @id = csv_row['guid'].to_i
    end

    def Table.Load(filename=nil)
        items = Hash.new()
        filename = self::FILENAME if filename.nil?

        base_dir = $temp_path+"data\\"
        base_dir = Extract("data\\","#{filename}.db",{:fdb_filter=>"data.fdb"})  unless File.exists?(base_dir+"#{filename}.db.csv")

        csv = CSV.read(base_dir+"#{filename}.db.csv", {:col_sep=>";", :headers=>true})

        csv.each { |row|
            r = self.new(row)
            next if r.SkipThisItem?
            items[r.id]= r
        }
        return items
    end

    def Table.Export(filename, db)
        File.open(filename, 'wt') { |outf|
            outf.write("return {\n")
            db.each { |id, data| data.WriteLUA(outf)  }
            outf.write("}\n")
        }
    end
end

class ItemEntry < Table

    attr_accessor :image_id, :min_level, :set
    attr_accessor :bonus
    attr_accessor :refineid

    def initialize(csv_row)
        super(csv_row)
        @id = csv_row['guid'].to_i
        @image_id = csv_row['imageid'].to_i
        @min_level = csv_row['limitlv'].to_i
        @set = csv_row['suitid'].to_i
        @refineid = csv_row['refinetableid'].to_i

        @bonus = BonusStuff.new(csv_row)
    end

    def SkipThisItem?
        if @bonus.HasInvalidStat? then
            $log << "Item #{@id}: has invalid bonus #{@bonus.HasInvalidStat?}\n"
            return true
        end

        if @min_level>MAX_LEVEL then
            $log.info("Item #{@id}: is above max level #{@min_level}")
            return true
        end

        name = $de.get_value("\"Sys#{@id}_name\"")
        if (name=="" or name==nil or name=~/^Sys\d+_name$/) then
            $log.info("Item #{@id}: has no name")
            return true
        end

        return false
    end

    def WriteLUAData(outf)
        outf.write( "min_level=%i" % @min_level)
        outf.write( ",icon=%i" % @image_id)
        outf.write( ",refine=%i" % @refineid)
        outf.write( ",set=%i" % @set) if @set>0
        if @bonus.HasStats? then
            outf << ","
            bonus.WriteLUAData(outf)
        end
    end

    def WriteLUA(outf)
        outf.write( "  [%i]={" % id)
        WriteLUAData(outf)
        outf.write( "},\n")
    end
end

class ArmorEntry < ItemEntry

    FILENAME = "armorobject"
    attr_accessor :inv_pos
    attr_accessor :armror_typ, :unk1, :unk2

    def initialize(csv_row)
        super(csv_row)
        @inv_pos = csv_row['armorpos'].to_i

        @inv_pos = 21 if @inv_pos==13
        @inv_pos = 16 if @inv_pos==11
        @inv_pos = 13 if @inv_pos==10
        @inv_pos = 11 if @inv_pos==9

        @armror_typ = csv_row['armortype'].to_i
        @unk1 = csv_row['unk124'].to_i
        @unk2 = csv_row['unk128'].to_i

        raise "illegal pos:"+@inv_pos.to_s if @inv_pos>21
    end

    def WriteLUAData(outf)
        super(outf)
        #outf.write( ",pos=%i" % [inv_pos])
    end

    def SkipThisItem?
        res = super
        return res || @inv_pos==12
    end

    def ArmorEntry.ExportLUA(filename, db)

        File.open(filename, 'wt') { |outf|
            outf.write("return {\n")

            for pos in 0..21
                outf.write("[%i]={\n" % pos)
                db.each { |id, data|
                    raise "stop" if id==220738
                    data.WriteLUA(outf)  if data.inv_pos==pos
                    }
                outf.write("},\n")
            end

            outf.write("}\n")
        }
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
                        outf.write("#{data.armror_typ} - #{data.unk1} - #{data.unk2} -> #{id} #{name}</a><br>\n")
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


    def initialize(csv_row)
        super(csv_row)
        @weaponpos = csv_row['weaponpos'].to_i # 0-6 -> 0-Haupthand; 1-Nebenhand; 2-Einhand; 3-Zweihand; 4-Munition; 5-Fernkampf; 6-Fertigungswerkzeuge
        @weapontype = csv_row['weapontype'].to_i # 0-20 -> 0-munition?; 1-Schwert; 2-Dolch; 6-Zweihandschwert; 11-Bogen

        raise "unkown weapon_pos:"+@weaponpos.to_s if @weaponpos<0 || @weaponpos>6
    end

    def SkipThisItem?
        not_a_weapon = (@weaponpos==4 || @weaponpos==6)
        return super() || not_a_weapon
    end


    def WriteLUAData(outf)
        super(outf)
        outf.write( ",weaponpos=%i" % [@weaponpos])
        outf.write( ",weapontype=%i" % [@weapontype])
    end

    def WeaponEntry.ExportLUA(filename, db)
        File.open(filename, 'wt') { |outf|
            outf.write("return {\n")
            db.each { |id, data| data.WriteLUA(outf)  }
            outf.write("}\n")
        }
    end

end


class PowerEntry < Table

    attr_accessor :bonus

    def initialize(csv_row)
        super(csv_row)
        @bonus = BonusStuff.new(csv_row)
        raise "unknown bonus stat" if @bonus.HasInvalidStat?
    end

    def SkipThisItem?
        return @bonus.HasInvalidStat? || (not @bonus.HasStats?)
    end

    def WriteLUAData(outf)
        @bonus.WriteLUAData(outf)
    end

    def WriteLUA(outf)
        outf.write( "  [%i]={" % id)
        WriteLUAData(outf)
        outf.write( "},\n")
    end
end

class SuitEntry < Table

    FILENAME = "suitobject"

    attr_accessor :totalcount
    attr_accessor :set_items
    attr_accessor :bonis

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
            @bonis[b] = {:eff=>[], :value=>[]}
            for i in 1..3
                type = csv_row["basetype#{b}_#{i}"].to_i
                value = csv_row["basetypevalue#{b}_#{i}"].to_i

                if type>0 and value>0 then
                    @bonis[b][:eff].push(type)
                    @bonis[b][:value].push(value)

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

    def SkipThisItem?
        name = $de.get_value("\"Sys#{@id}_name\"")

        $log << "set #{id} -> without set items\n" if @totalcount==0

        return  (@has_unknown_stat or @totalcount==0 or
                (name=="" or name==nil or name=~/^Sys\d+_name$/) )
    end

    def WriteLUAData(outf)
        #@bonus.WriteLUAData(outf)
    end

    def WriteLUA(outf)
        outf.write( "  [%i]={" % id)
        WriteLUAData(outf)
        outf.write( "},\n")
    end
end


class RefineEntry < Table

    FILENAME = "eqrefineabilityobject"
    attr_accessor :bonus

    def initialize(csv_row)
        super(csv_row)
        @bonus = BonusStuff.new(csv_row)
    end

    def SkipThisItem?
        return false
    end

    def WriteLUAData(outf)
        @bonus.WriteLUAData(outf)
    end

    def WriteLUA(outf)
        outf.write( "  [%i]={" % id)
        WriteLUAData(outf)
        outf.write( "},\n")
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

    def WriteLUAData(outf)
    end

    def WriteLUA(outf)
        outf.write( "  [%i]=%i,\n" % [id, @cardaddpower])
    end
end

class FullDB

    attr_accessor :images
    attr_accessor :armor , :weapons
    attr_accessor :addpower, :runes, :suits
    attr_accessor :refines, :cards

    def Load
        p "Load Strings"
        $de = GetStringList("de")

        p "Load Images"
        @images = Images.new()
        @images.Load()

        p "Load Armor"
        @armor = ArmorEntry.Load()

        p "Load Weapons"
        @weapons= WeaponEntry.Load()

        p "Load Bonuses"
        @addpower= PowerEntry.Load("addpowerobject")
        @runes= PowerEntry.Load("runeobject")
        #~ Dump_Bonis(@addpower)
        #~ Dump_Bonis(@runes)
        #~ raise "stop"


        p "Load Sets"
        @suits = SuitEntry.Load()

        p "Load Refines"
        @refines = RefineEntry.Load()

        p "Load Cards"
        @cards = CardEntry.Load()

    end

    def Dump_Bonis(db)
        bonis = Set.new
        db.each { |id,r|
                name = $de.get_value("\"Sys#{id}_name\"")
                p name
                next
                next if name.nil? or name =~/^Sys\d{6}_name$/
                key=nil
                if name =~ /^(?<key>.+)\s+\w+$/ then
                    bonis.add(key)
                else
                    bonis.add(name)
                end
            }

        bonis.each { |v| p v }
    end

    def Export
        p "writting"
        File.open("../item_data/images.lua", 'wt') {|outf| @images.WriteLUATable(outf) }

        Table.Export("../item_data/sets.lua", @suits)
        Table.Export("../item_data/refines.lua", @refines)
        Table.Export("../item_data/cards.lua", @cards)

        File.open("../item_data/addpower.lua", 'wt') { |outf|
            outf.write("return {\n")
            @addpower.each { |id, data| data.WriteLUA(outf)  }
            @runes.each { |id, data| data.WriteLUA(outf)  }
            outf.write("}\n")
        }

        #ArmorEntry.TestWrite(armor)
        ArmorEntry.ExportLUA("../item_data/armor.lua", @armor)
        WeaponEntry.ExportLUA("../item_data/weapons.lua", @weapons)
    end


    def Check
        p "Checking & cleanup"
        CheckSetItems(@suits, @armor, @weapons)
        CheckImages(@armor, @images)
        CheckImages(@weapons, @images)
    end


    def CheckImages(items, images)
        items.each { |id,r|
            begin
                images.ImageUsed(r.image_id)
            rescue
                $log << "Item #{r.id} removed 'cause image is invalid/unknown (#{r.image_id})"
                items.delete(r)
            end
        }
    end

    def CheckSetItems(sets, armor, weapons)

        sets.each { |id,s|
            s.set_items.each { |i|
                if (armor.has_key?(i)) then
                    if armor[i].set!=id then
                        $log << "Item #{i} is listed for different set: #{armor[i].set} (should be #{id})\n"
                        #raise "mismatch"
                    end
                elsif (weapons.has_key?(i)) then
                    if weapons[i].set!=id then
                        $log << "Item #{i} is listed for different set: #{weapons[i].set} (should be #{id})\n"
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
