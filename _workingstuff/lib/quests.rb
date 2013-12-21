require_relative 'table'

class QuestEntry < TableEntry

# icheck_class_type	(0=all 1=schurke, 4=ritter, 2=<unused>)
# icheck_title (0= 1= 2=)
# iquest_type (0,1,2,3)	(1-3-> most have no name/text
# iaccept_itemid1..5 iaccept_itemval1..5

# ireward_spell1	ireward_spell2	ireward_spell3	ireward_spell4	ireward_spell5	ireward_money	ireward_exp	ireward_repgroup1	ireward_repgroup2	ireward_rep1	ireward_rep2	icomplete_showquest	icomplete_flagon1	icomplete_flagon2	icomplete_flagon3	icomplete_flagoff1	icomplete_flagoff2	icomplete_flagoff3	szscript_onbegin	szscript_onaccept	szscript_oncomplete	szscript_onclickobjbegin	szscript_onclickobjend	iquestgroup	icontroltype	irequest_itemstr1	irequest_itemstr2	irequest_itemstr3	irequest_itemstr4	irequest_itemstr5	irequest_itemstr6	irequest_itemstr7	irequest_itemstr8	irequest_itemstr9	irequest_itemstr10	irequest_killstr1	irequest_killstr2	irequest_killstr3	irequest_killstr4	irequest_killstr5	iquestgrouplv	ireward_honor	ireward_tp	iquest_starter1	iquest_starter2	iquest_starter3	iquest_starter4	iquest_starter5	ideletequestitem1	ideletequestitem2	ideletequestitem3	ideletequestitem4	ideletequestitem5	ideletequestitemcount1	ideletequestitemcount2	ideletequestitemcount3	ideletequestitemcount4	ideletequestitemcount5	iquestlinknpc1	iquestlinknpc2	iquestlinknpc3	iquestlinknpc4	iquestlinknpc5	szscript_ondelete	icheck_objstatus1	icheck_objstatus2	icheck_objstatus3	icheck_objstatus4	icheck_objstatus5	bdisableteam	szscript_requeststring	ireward_cointype	ireward_specialcoin	irequest_cointype	irequest_specialcoin

    ALL_FIELDS = [  "level","level_min","level_max","catalog","zone",
                    "reward_exp","reward_money",
                    "start_npcs",
                    "goal_prefix_text","goal_id","goal_count",
                    "pre_quest","post_quest",
                    "reward_items","reward_item_count",
                    "reward_npc",
                    "loopable","related_mobs","related_items",
                    "pre_flags",

                ]

    attr_accessor :rawdata
    attr_accessor :start_npcs
    attr_accessor :post_quest
    attr_accessor :perquisite
    attr_accessor :requests
    attr_accessor :reward
    attr_accessor :related_items_hash
    attr_accessor :related_mobs_hash

    attr_accessor :related_items
    attr_accessor :related_mobs
    attr_accessor :reward_exp
    attr_accessor :reward_money
    attr_accessor :pre_quest
    attr_accessor :pre_flags
    attr_reader :zone

    def initialize(row)
        super(row)
        @rawdata=row

        @post_quest=[]
        @perquisite=[]
        for n in ("icheck_objid1".."icheck_objid5")
            qid = row[n].to_i
            @perquisite.push(qid) if qid>0
            # note: there are 2 cases where "icheck_objval1" is >1 .. i believe it's a bug and ignoring it
        end

        @start_npcs=[]
        for i in ("iquest_starter1".."iquest_starter5")
            n_id=row[i].to_i
            @start_npcs.push(n_id) if n_id>100
        end

        GetRequests(row)
        GetReward(row)
        @related_items_hash = GetRelatedItemsAndMobs(row, "iprocess_click")
        @related_mobs_hash = GetRelatedItemsAndMobs(row, "iprocess_kill")

    end

    def IsValid?
        return super()
    end

    def GetRequests(csv)
        @requests=[]
        for i in 1..10
            item = csv['irequest_itemid'+i.to_s].to_i
            if item>0 then
                prefix =csv['irequest_itemstr'+i.to_s].to_i
                count = csv['irequest_itemval'+i.to_s].to_i
                @requests.push( {:prefix=>prefix,:item=>item,:count=>count} )
            end
        end

        for i in 1..10
            item = csv['irequest_killid'+i.to_s].to_i
            if item>0 then
                prefix =csv['irequest_killstr'+i.to_s].to_i+16
                count = csv['irequest_killval'+i.to_s].to_i
                @requests.push( {:prefix=>prefix,:item=>item,:count=>count} )
            end
        end
    end

    def GetRelatedItemsAndMobs(csv, prefix)

        result = []

        for i in 1..10

            useitem = csv[prefix+'togetitem_objid'+i.to_s].to_i
            percent = csv[prefix+'togetitem_procpercent'+i.to_s].to_i
            item = csv[prefix+'togetitem_getitem'+i.to_s].to_i
            count = csv[prefix+'togetitem_getitemval'+i.to_s].to_i

            if useitem>0 and percent>0 and item>0 and count>0 then
                result.push( {use: useitem, percent: percent, item: item, count: count} )
            end
        end

        return result
    end

    def GetReward(csv)
        @reward=[]

        for i in 1..5
            item = csv['ireward_choiceid'+i.to_s].to_i
            count= csv['ireward_choiceval'+i.to_s].to_i
            if item>0 and count>0 then
                @reward.push( {:item=>item,:count=>-count} )
            end
        end

        for i in 1..5
            item = csv['ireward_itemid'+i.to_s].to_i
            count= csv['ireward_itemval'+i.to_s].to_i
            if item>0 and count>0 then
                @reward.push( {:item=>item,:count=>count} )
            end
        end
    end

    def SetAsFollowerOf(qid)
        @post_quest.push(qid)
    end

    def level
        @rawdata["icheck_lv"].to_i
    end

    def level_min
        @rawdata["icheck_lowerlv"]
    end

    def level_max
        @rawdata["icheck_higherlv"]
    end

    def IsLoopable?
        @rawdata["icheck_loop"].to_i>0
    end

    def loopable
        IsLoopable?
    end

    def reward_npc
        npc = @rawdata["irequest_questid"].to_i
        return npc if npc>100
    end

    def reward_exp_calc(exp_vals)
        return (@rawdata["ireward_exp"].to_i * exp_vals["quest_xp_base"].to_i )  /  100
    end

    def reward_money_calc(exp_vals)
        return (@rawdata["ireward_money"].to_i * exp_vals["quest_money_base"].to_i ) / 100
    end

    def reward_items
        FormatArray(@reward.collect {|p| p[:item]},true)
    end

    def reward_item_count
        FormatArray(@reward.collect {|p| p[:count]},true)
    end

    def goal_prefix_text
        FormatArray(@requests.collect {|p| p[:prefix]},true)
    end

    def goal_id
        FormatArray(@requests.collect {|p| p[:item]},true)
    end

    def goal_count
        FormatArray(@requests.collect {|p| p[:count]},true)
    end

    def related_items
        FormatArray(@related_items_hash.collect {|p| p.values})
    end
    def related_mobs
        FormatArray(@related_mobs_hash.collect {|p| p.values})
    end

    def catalog
        @rawdata["iquest_catalog"]
    end

    def PrepareExport(table_quest, args)
        raise "arg1 muste be Table_EXP" unless args[0].is_a? Table_EXP # or args[0].nil?

        table_xp = args[0]
        cats2zone = args[1]
        @zone = (cats2zone[catalog] or 0 ) unless cats2zone.nil?

        @pre_quest = []
        @pre_flags = []
        @perquisite.each do |pq|
            if table_quest.include?(pq) then
                @pre_quest.push(pq)
            else
                @pre_flags.push(pq)
            end
        end

        if not table_xp.nil? then
            @reward_exp = 0
            @reward_money = 0
            exp_vals = table_xp[level]
            if not exp_vals.nil? then
                @reward_exp = (@rawdata["ireward_exp"].to_i * exp_vals["quest_xp_base"].to_i )  /  100
                @reward_money = (@rawdata["ireward_money"].to_i * exp_vals["quest_money_base"].to_i ) / 100
            end
        end
    end


    def HasPreQuest?(table_quest,qid)
        return true if @perquisite.include? qid

        @perquisite.each { |q|
            n = table_quest[q]
            next if n.nil?
            return true if n.HasPreQuest?(table_quest,qid)
        }
        return false
    end

    def HasPreQuestCached?(table_quest,qid)
        return true if @perquisite.include? qid

        if not @perquisite_cache then
            @perquisite_cache=[]
            @perquisite.each { |q|
                n = table_quest[q]
                @perquisite_cache.push(n) unless n.nil?
            }
        end

        @perquisite_cache.each { |q|
            return true if q.HasPreQuest?(table_quest,qid)
        }
        return false
    end
end

class Quests < Table
    FILENAME = "questdetailobject"

    def initialize()
        super(QuestEntry, FILENAME)
    end

    def AfterLoad()
        each { |q|
            q.perquisite.each do |pq|
                @db[pq].post_quest.push(q.id) if exists?(pq)
            end
            }
    end


    def RemoveUnusedPostQuests()
        @db.each do |id,q|
            to_delete=[]
            q.post_quest.each { |qid|
                if not @db.include? qid then
                    to_delete.push(qid)
                end
            }

            q.post_quest -= to_delete
        end
    end

    def CheckDependingQuests()
        @db.each { |id,q|
            begin
                repeatit=false
                q.perquisite.each { |qid1|
                    q_qid1 = @db[qid1]
                    next if q_qid1.nil?

                    q.perquisite.each { |qid2|
                        next if qid1==qid2 or not @db.include? qid2

                        if q_qid1.HasPreQuest?(@db,qid2) then
                            # puts "Quest #{q.id} double depend on #{qid2}. see #{qid1}"
                            q.perquisite.delete(qid2)
                            repeatit=true
                        end
                    }
                }
            end while repeatit
        }
    end

    def doCleanUps()
        RemoveUnusedPostQuests()
        CheckDependingQuests()
    end

    def LoadCat2ZoneFromQH(luafile=nil)
        require 'rlua'

        if not luafile then
            dir = ".."
            while not File.Exists(dir + "/QuestHelper/data/mapcoords.lua")
                dir = "../"+dir
                raise "not found" if dir.size>16
            end
        end



        state = Lua::State.new
        state.__load_stdlib :all
        mapdata = state.__eval("return dofile('#{luafile}')")
        raise "loading error" if mapdata.nil?

        cats2zone = Hash.new()

        mapdata.each { |zone, zdata|
            zdata.zones.each { |cat,cpos|
                cats2zone[cat.to_i]=zone.to_i
            }
        }

        return cats2zone
    end

end






