require 'fileutils'
require 'set'
require 'csv'
require 'logger'

# use path_settings.rb to setup correct path for:
#  $fdb_ex="bin/FDB_ex2.exe"
load "path_settings.rb"

require_relative 'lib/all'


$log = Logger.new(open('logfile.txt', File::WRONLY | File::CREAT))
$log.level = Logger::WARN
#$log.level = Logger::INFO
$log.formatter = proc { |severity, datetime, progname, msg|  "#{severity}: #{msg}\n" }

MAX_LEVEL = 83
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

    def Load
        p "Load tables"
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

    def Export
        p "writting"
        @images.Export("../item_data/images.lua")
        @suits.Export("../item_data/sets.lua")
        @refines.Export("../item_data/refines.lua")
        @addpower.Export("../item_data/addpower.lua")
        @titles.Export("../item_data/archievements.lua")
        @cards.Export("../item_data/cards.lua")
        @items.Export("../item_data/items.lua")
        @spell_collection.Export("../item_data/spells.lua")
        @spells.Export("../item_data/spell_effects.lua")
        @food.Export("../item_data/food.lua")
        @vocs.Export("../item_data/classes.lua")
        @learnmagic.Export("../item_data/skills.lua")
        @recipes.ExportReverseIndex("../item_data/recipe_items.lua")

        ExportTPCosts()
    end


    def Check
        p "Checking & cleanup"
        #CheckSetItems(@suits, @items)
        if EXCLUDE_UNNAMED
        	@items.MarkUnusedIfNameInvalid($de)
        	@suits.MarkUnusedIfNameInvalid($de)
      	end
        CheckImages(@images, [@items, @spell_collection])
        FilterSpells()

        @spell_collection.ClearUnskillable(@learnmagic)
    end

    def FilterSpells
        #@spell_collection.MarkAllUnused
        #@food.MarkSpellsUsed(@spell_collection)
        #@learnmagic.MarkSpellsUsed(@spell_collection)

        @spells.MarkAllUnused
        @spell_collection.MarkSpellsUsed(@spells)
        raise "missing spell" if not @spell_collection[490142].Export?
    end

    def CheckImages(images, tables)
        images.MarkAllUnused()
        tables.each { |tab|
            tab.each { |r|
                begin
                    images.Used(r.image_id)
                rescue
                    $log.warn { "Item #{r.id} removed 'cause image is invalid/unknown (#{r.image_id})" }
                    tab.NotUsed(r.id)
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
db.Load
db.Check
db.Export
