require_relative 'table'

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

# no Names
    #~ 180 => "??",

    #~ 214 => "??",
    #~ 215 => "??",
    #~ 216 => "??",
    #~ 217 => "??",
    #~ 218 => "??",
    #~ 219 => "??",
    #~ 220 => "??",
    #~ 221 => "??",
    #~ 222 => "??",
    #~ 223 => "??",
    #~ 224 => "??",
    #~ 225 => "??",
    #~ 226 => "??",
    #~ 227 => "??",
    #~ 228 => "??",
    #~ 229 => "??",
}

class BonusStuff
    attr_accessor :eqtypes, :eqvalues

    def initialize(csv_row, max_bonus=10)
        raise "db-format changed (updated fdbex?)" unless csv_row.header?('eqtype1')

        @eqtypes=[]
        @eqvalues=[]
        @unknown_stat = false
        for i in 1..max_bonus
            type = csv_row['eqtype'+i.to_s].to_i
            value = csv_row['eqtypevalue'+i.to_s].to_i

            if type>0 and (i<3 or value!=0) then
                @eqtypes.push(type)
                @eqvalues.push(value)

                @unknown_stat = type if not $STATLIST.key?(type)
                $log.error "bonus: #{@unknown_stat} used" if @unknown_stat
            end
        end
    end

    def Value(id)
        n = @eqtypes.find_index(id)
        return @eqvalues[n] unless n.nil?
        return 0
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
        if @eqtypes.size==0 then
            data.push("nil")
        else
            data.push("{#{ExportString()}}")
        end
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


class ItemEntry < TableEntry

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

    def IsValid?
        if @bonus.HasInvalidStat? then
            $log << "Item #{@id}: has invalid bonus #{@bonus.HasInvalidStat?}\n"
            return false
        end

        if @level>MAX_LEVEL then
            $log.info("Item #{@id}: is above max level #{@level}")
            return false
        end

        if MAX_RARE.index(@rare).nil? then
            $log.info("Item #{@id}: has rarity #{@rare}")
            return false
        end

        return super()
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

