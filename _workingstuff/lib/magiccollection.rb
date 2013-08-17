require_relative 'table'

class MagicCollectionEntry < TableEntry
    attr_accessor :magics
    attr_accessor :image_id
    attr_accessor :effecttype
    attr_accessor :maxskill
    attr_accessor :tp_cost_rate

    def initialize(csv_row)
        super(csv_row)
        @magics=[]
        for i in 1..12
            magic = csv_row['magicbaseid'+i.to_s].to_i
            magic==0 ? @magics.push("nil") : @magics.push(magic)
        end

        @effecttype = csv_row['effecttype'].to_i
        @image_id = csv_row['imageid'].to_i
        @maxskill = csv_row['maxskilllv'].to_i
        @tp_cost_rate = csv_row['exptablerate'].to_i
    end

    #~ def IsValid?
        #~ return super()
    #~ end

    def ExportDesc(data)
        data.push( "effecttype")
        data.push( "image_id")
        data.push( "{magics}")
        data.push( "maxskill")
        data.push( "tprate")
    end

    def ExportData(data)
        data.push(@effecttype)
        data.push(@image_id)
        data.push(FormatArray(@magics, true))
        data.push(@maxskill)
        data.push(@tp_cost_rate)
    end

    def is_buff?(spell_book)
        @magics.each {|x|
            next if not spell_book.include? x
            return true if spell_book[x].is_buff?
        }
        return false
    end

end


class MagicCollection < Table
    FILENAME = "magiccollectobject"

    def initialize()
        super(MagicCollectionEntry, FILENAME)
    end

    def MarkSpellsUsed(spells)
        each { | data|
            undefined = []
            data.magics.each {|d|
                if d!="nil" then
                    if spells.index.include?(d)
                        spells.Used(d)
                    else
                        undefined.push(d)
                    end
                end
            }
            data.magics = data.magics-undefined
        }
    end

    def ClearUnskillable(learnmagic)
        not_skill = @index

        learnmagic.guids.each { |guid|
            if learnmagic.base.has_key? guid then
                learnmagic.base[guid].each {|x|  not_skill.delete(x.skill) }
            end

            if learnmagic.spec.has_key? guid then
                learnmagic.spec[guid].each {|x|  not_skill.delete(x.skill) }
            end
        }

        not_skill.each { |x,y|
                @db[y].maxskill="nil"
                @db[y].tp_cost_rate="nil"
        }
    end
end