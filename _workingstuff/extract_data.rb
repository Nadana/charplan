require 'fileutils'
require 'set'
require 'csv'
require 'logger'

require_relative 'lib/all'


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

        @spell_collection.Export("../item_data/skills.lua")
        @spells.Export("../item_data/spells.lua")

        @food.Export("../item_data/food.lua")

        @vocs.Export("../item_data/classes.lua")

        #ArmorEntry.TestWrite(armor)
    end


    def Check
        p "Checking & cleanup"
        #CheckSetItems(@suits, @items)
        @items.MarkUnusedIfNameInvalid($de)
        @suits.MarkUnusedIfNameInvalid($de)
        CheckImages(@items, @images)
        FilterSpells()
    end

    def FilterSpells
        @spells.MarkAllUnused
        @spell_collection.MarkSpellsUsed(@spells)
        @food.MarkSpellsUsed(@spell_collection)
    end

    def CheckImages(items, images)
        images.MarkAllUnused()
        items.each { |r|
            begin
                images.Used(r.image_id)
            rescue
                $log.warn { "Item #{r.id} removed 'cause image is invalid/unknown (#{r.image_id})" }
                items.NotUsed(r.id)
            end
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
end


######################################
CheckTempPath()


db = FullDB.new
db.Load
db.Check
db.Export
