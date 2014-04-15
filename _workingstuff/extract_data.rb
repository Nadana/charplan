require 'fileutils'
require 'set'
require 'csv'
require 'logger'

# use path_settings.rb to setup correct path for:
#  $fdb_ex="bin/FDB_ex2.exe"
#  $lua="e:/Tools/luarocks/2.1/lua5.1.exe"

load "path_settings.rb"

require_relative 'lib/all'


$log = Logger.new(open('logfile.txt', File::WRONLY | File::CREAT))
$log.level = Logger::WARN
#$log.level = Logger::INFO
$log.formatter = proc { |severity, datetime, progname, msg|  "#{severity}: #{msg}\n" }

MAX_LEVEL = 93
MAX_RARE = [0,1,2,3,4,5,8]
EXCLUDE_UNNAMED = true
$log << "FILTER RULES:\n"
$log << "max level is: #{MAX_LEVEL}\n"
$log << "max rariry is: #{MAX_RARE.to_s}\n"
$log << "\n"

class FullDB

    attr_accessor :images
    attr_accessor :items
    attr_accessor :addpower, :suits
    attr_accessor :refines, :cards
    attr_accessor :spell_collection, :spells
    attr_accessor :food
    attr_accessor :title
    attr_accessor :vocs

    def load
        puts "Load tables"
        $de = Locales.new("de")

        @images = Images.new()

        @items = Armor.new()
        weapons= Weapons.new()
        @items.merge!(weapons)

        @addpower= AddPower.new()
        @addpower.AssignGroup($de)
        runes = Runes.new()
        runes.AssignGroup($de)
        @addpower.merge!(runes)

        @suits = Suits.new()
        @refines = Refines.new()
        @spells = Magics.new()
        @spell_collection = MagicCollection.new()
        @food = Food.new()
        @cards = Cards.new()
        @titles = Titles.new()
        @vocs = Voc.new()
        @learnmagic = Learnmagic.new()
        @recipes = Recipes.new()
    end

    def export(dir)
        puts "writting"
        @images.Export(dir+"images.lua")
        @suits.Export(dir+"sets.lua")
        @refines.Export(dir+"refines.lua")
        @addpower.Export(dir+"addpower.lua")
        @titles.Export(dir+"archievements.lua")
        @cards.Export(dir+"cards.lua")
        @items.Export(dir+"items.lua")
        @spell_collection.Export(dir+"spells.lua")
        @spells.Export(dir+"spell_effects.lua")
        @food.Export(dir+"food.lua")
        @vocs.Export(dir+"classes.lua")
        @learnmagic.Export(dir+"skills.lua")
        @recipes.ExportReverseIndex(dir+"recipe_items.lua")

        ExportTPCosts()
        @suits.exportSkillList(dir+"set_skills.lua")

        compile(dir)
    end

    def compile(dir)
        Dir[dir+"*.lua"].each {|p| LUA_Compile(p) }
    end

    def check
        puts "Checking & cleanup"
        #CheckSetItems(@suits, @items)
        if EXCLUDE_UNNAMED
        	@items.MarkUnusedIfNameInvalid($de)
        	@suits.MarkUnusedIfNameInvalid($de)
        end

        @cards.MarkUnusedIf {|d| d.cardaddpower==0 }

        str = $STATLIST.key("Stärke")
        @items.MarkUnusedIf { |item| item.bonus.Value(str)>20000 }

        findUnusedRefines(@items)
        findUnusedImages(@images, [@items, @spell_collection])
        #findUnusedSpells()

        @spell_collection.ClearUnskillable(@learnmagic)
    end

    def findUnusedRefines(items)
        @refines.MarkAllUnused
        @items.each { |i|
            if i.refineid>0 then
                (0..19).each {|plus|
                    @refines.Used(i.refineid+plus)
                }
            end
        }
    end

    def findUnusedSpells
        raise "missing spell2" if not @spell_collection[493298].Export?

        #@spell_collection.MarkAllUnused
        #@food.MarkSpellsUsed(@spell_collection)
        #@learnmagic.MarkSpellsUsed(@spell_collection)

        @spells.MarkAllUnused
        @spell_collection.MarkSpellsUsed(@spells)
        raise "missing spell1" if not @spell_collection[490142].Export?
        raise "missing spell2" if not @spell_collection[493298].Export? # was remove 'cause invalid image
        #raise "missing spell" if not @spells[623034].Export? # used in tooltip but not in spell
    end

    def findUnusedImages(images, tables)
        images.MarkAllUnused()
        tables.each { |tab|
            tab.each { |r|
                begin
                    images.Used(r.image_id)
                rescue
                    if tab == @spell_collection then
                        $log.info { "Spell_Collection #{r.id} has invalid/unknown image: (#{r.image_id})" }
                        #tab.NotUsed(r.id)
                    else
                        $log.warn { "Item #{r.id} removed 'cause invalid/unknown image: (#{r.image_id})" }
                        tab.NotUsed(r.id)
                    end
                end
            }
        }
    end

    def CheckSetItems(sets, items)

        sets.each { |id,s|
            s.set_items.each { |i|
                if (items.include?(i)) then
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

    def ExportTPCosts()

        xp = Table_EXP.new()

        out=[]
        for i in 1..100
            out.push(xp[i]["skill_cost"])
        end

        File.open("../item_data/tpcost.lua", 'wt') { |outf|
            outf.write("return {\n")
            outf.write( out.join(",") )
            outf.write("\n}\n")
        }
    end
end


######################################
CheckTempPath()

db = FullDB.new
db.load
db.check
db.export "../item_data/"
