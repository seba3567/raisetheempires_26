package core.managers
{
   import Engine.Classes.SocialNetworkUser;
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import core.gamemode.battle.Battle;
   import core.gamemode.battle.BattleHost;
   import core.gameobjects.Fleet;
   import core.managers.domination.DominationModeManager;
   import core.managers.questManager.ZGameQuestManager;
   import core.player.Player;
   import core.ui.UIManager;
   import core.ui.menuitem.FriendsBarUIItem;
   import dispatchers.MessageDispatcher;
   import dispatchers.UIDispatcher;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.alliancePopup.AllianceBattleWaveIntro;
   import displays.popups.alliancePopup.AllianceBattleWaveVictory;
   import displays.popups.alliancePopup.AllianceCrownNotifyPopup;
   import displays.popups.genericPopup.ModalPopup;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   import transactions.clans.TGetClanInfo;
   import transactions.clans.TLoadAllianceBattle;
   import transactions.clans.TProcessMemberQueue;
   import transactions.clans.TUpdateClanName;
   import transactions.clans.TUpdateCrest;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class AlliancesManager extends EventDispatcher
   {
      
      public static const ALLIANCE_EXPERIMENT_NAME:String = "empire_alliances_master";
      
      public static const ALLIANCE_EXPERIMENT_VARIANT:int = 3;
      
      public static const ALLIANCE_EXPERIMENT_PHASE4:String = "empire_alliances_phase_4";
      
      public static const ALLIANCE_EXPERIMENT_PHASE4_VARIANT:int = 3;
      
      public static const EMPIRE_ALLIANCES_QUEST_POWER:String = "empire_alliances_quest_power";
      
      public static const EMPIRE_ALLIANCES_QUEST_POWER_VARIANT:int = 3;
      
      public static const EMPIRE_ALLIANCES_QUEST_CONNECTIONS:String = "empire_alliances_quest_connections";
      
      public static const EMPIRE_ALLIANCES_QUEST_CONNECTIONS_VARIANT:int = 3;
      
      public static const EXPERIMENT_ALLIANCES_HEALTH_PRICING:String = "empire_alliances_health_pricing";
      
      public static const ALLIANCE_PLAYER_FLEET:String = "fleet_domination_alliance_player";
      
      public static const ALLIANCE_ENEMY_FLEET:String = "fleet_domination_alliance_enemy";
      
      public static const ALLIANCE_MIN_LEVEL:int = 25;
      
      public static const ALLIANCE_HEALTH_DEDUCT:int = 5;
      
      public static const ALLIANCE_HEALTH_GAIN:int = 10;
      
      public static const UPDATE_CREST_ICON:String = "alliances_update_crest_icon";
      
      public static const CLANS_ZLINGSHOT_MSG:String = "clans_zlingshot_msg";
      
      public static const UPDATE_HEALTH_TO_MAX:String = "alliances_update_health_to_max";
      
      public static const SHOW_ALLIANCES_NOTIFICATION:String = "show_alliances_notification";
      
      public static const HIDE_ALLIANCES_NOTIFICATION:String = "hide_alliances_notification";
      
      public static const REFRESH_ALLIANCE_SLOT:String = "refresh_alliance_slot";
      
      public static const FB_GROUP_CREATED:String = "fb_group_created";
      
      public static const ALLIANCE_MEMBER_LIMIT:int = 10;
      
      public static const ATTACK_HEALTH_THRESHOLD:int = 0;
      
      public static const HEALTH_BUY_THRESHOLD:Number = 0.75;
      
      public static const CROWN_DOMINATION_POINTS:int = 1000;
      
      public static const RIVAL_WAIT_PERIOD:int = 86400;
      
      public static const HEALTH_PRICES:Array = [5,10,15,20,25,30,35,40,45,50];
      
      public static const REVENGE_BONUS:int = 50;
      
      public static const ADD_SLOT_PRICE:int = 20;
      
      public static const ALLIANCE_SEEN_FLAG:String = "alliances_crest_clicked";
      
      private static var m_instance:AlliancesManager = null;
      
      private var m_clanid:String;
      
      private var m_clanName:String;
      
      private var m_clanHealth:int;
      
      private var m_members:Array;
      
      private var m_maxMembers:int;
      
      private var m_leaderId:String;
      
      private var m_crestId:int;
      
      private var m_fbGroupID:String = "";
      
      private var m_fbGroupCreated:Boolean = false;
      
      private var m_unlockedCrest:Array;
      
      private var m_membersInfo:Object;
      
      private var m_memberData:Object;
      
      private var m_joinRequests:Dictionary;
      
      private var m_numCrowns:int;
      
      private var m_cycleStartTime:Number;
      
      private var m_cycleDuration:Number;
      
      private var m_tauntViewTime:Number = 0;
      
      private var m_hasNewRival:Boolean = false;
      
      private var m_quests:Object;
      
      private var m_setup:Boolean;
      
      private var m_initialised:Boolean = false;
      
      private var m_crestUrl:String;
      
      private var m_rawXml:XML;
      
      private var m_xml:XMLList;
      
      private var m_itemsXML:XMLList = null;
      
      private var m_data:XML;
      
      private var m_allianceBattle:Boolean;
      
      private var m_allianceBattleMember:String;
      
      private var m_allianceBattleName:String;
      
      private var m_allianceData:Dictionary;
      
      private var m_activeBattleData:Dictionary;
      
      private var m_loadingScreen:ModalPopup;
      
      private var m_firstLeader:String;
      
      public var m_motdActive:Boolean = false;
      
      public function AlliancesManager(param1:IEventDispatcher = null)
      {
         super(param1);
         this.m_clanName = "";
         this.m_crestId = 0;
         this.m_allianceBattle = false;
         this.m_allianceBattleName = null;
         this.m_allianceData = new Dictionary();
         this.m_joinRequests = new Dictionary();
         this.m_activeBattleData = null;
         this.m_loadingScreen = null;
         MessageDispatcher.instance.addEventListener(CLANS_ZLINGSHOT_MSG,this.onZlingshotMessage);
      }
      
      public static function get instance() : AlliancesManager
      {
         if(!m_instance)
         {
            m_instance = new AlliancesManager();
         }
         return m_instance;
      }
      
      public static function isValid() : Boolean
      {
         return isExperimentEnabled() && isLevelOk();
      }
      
      public static function isExperimentEnabled() : Boolean
      {
         return ExperimentsManager.instance.getExperimentVariant(AlliancesManager.ALLIANCE_EXPERIMENT_NAME) >= AlliancesManager.ALLIANCE_EXPERIMENT_VARIANT;
      }
      
      public static function isPhase4Enabled() : Boolean
      {
         return ExperimentsManager.instance.getExperimentVariant(AlliancesManager.ALLIANCE_EXPERIMENT_PHASE4) >= AlliancesManager.ALLIANCE_EXPERIMENT_PHASE4_VARIANT && AlliancesManager.isExperimentEnabled();
      }
      
      public static function isLevelOk() : Boolean
      {
         return ZGlobal.player.level >= AlliancesManager.ALLIANCE_MIN_LEVEL;
      }
      
      public static function hasAlliance() : Boolean
      {
         return false;
      }
      
      public static function isQuestExperimentEnabled(param1:int) : Boolean
      {
         switch(param1)
         {
            case 1:
               return ExperimentsManager.instance.getExperimentVariant(ALLIANCE_EXPERIMENT_NAME) == ALLIANCE_EXPERIMENT_VARIANT;
            case 2:
               return ExperimentsManager.instance.getExperimentVariant(EMPIRE_ALLIANCES_QUEST_POWER) == EMPIRE_ALLIANCES_QUEST_POWER_VARIANT;
            case 3:
               return ExperimentsManager.instance.getExperimentVariant(EMPIRE_ALLIANCES_QUEST_CONNECTIONS) == EMPIRE_ALLIANCES_QUEST_CONNECTIONS_VARIANT;
            default:
               return false;
         }
      }
      
      public function getCrestCost(param1:int) : int
      {
         this.m_data = ZGlobal.gameSettings.getCrest("" + param1);
         if(this.m_data.@cost.toString().length > 0)
         {
            return this.m_data.@cost;
         }
         return 0;
      }
      
      private function onZlingshotMessage(param1:WorldEvent) : void
      {
         var _loc3_:Transaction = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc2_:Object = param1.eventData;
         if(!_loc2_ || !_loc2_.id)
         {
            return;
         }
         if(_loc2_.clanId)
         {
            if(_loc2_.clanId != this.m_clanid)
            {
               return;
            }
         }
         if(_loc2_.id == "clan.updateName")
         {
            if(_loc2_.clanName)
            {
               _loc4_ = _loc2_.clanName as String;
               if(_loc4_ != null)
               {
                  m_instance.m_clanName = _loc4_;
                  this.dispatchEvent(new WorldEvent(CLANS_ZLINGSHOT_MSG,_loc2_.id));
               }
            }
         }
         else if(_loc2_.id == "clan.updateCrest")
         {
            if(_loc2_.crestId)
            {
               _loc5_ = int(_loc2_.crestId);
               this.m_crestId = _loc5_;
               UIDispatcher.instance.dispatchEvent(new Event(UPDATE_CREST_ICON));
               this.dispatchEvent(new WorldEvent(CLANS_ZLINGSHOT_MSG,_loc2_.id));
            }
         }
         else if(_loc2_.id == "clan.gotKicked")
         {
            DominationModeManager.instance.dispatchEvent(new Event(DominationModeManager.FIGHT_LIST_TARGET_SELECTED));
            DominationModeManager.instance.clearAllianceList();
            DominationModeManager.instance.clearAllianceRivalsList();
            _loc6_ = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_A2U_Exit_desc",{"Aname":this.m_clanName});
            PopupManager.instance.push(new GenericPopup(_loc6_,GenericPopup.TYPE_OK));
            this.deinit();
            this.dispatchEvent(new WorldEvent(CLANS_ZLINGSHOT_MSG,_loc2_.id));
         }
         else if(_loc2_.id == "clan.memberAbandon")
         {
            if(_loc2_.zid)
            {
               this.removeMember(new String(_loc2_.zid));
            }
            if(_loc2_.leader)
            {
               this.m_leaderId = new String(_loc2_.leader);
            }
            this.dispatchEvent(new WorldEvent(CLANS_ZLINGSHOT_MSG,_loc2_.id));
         }
         else if(_loc2_.id == "clan.memberUpdate")
         {
            if(_loc2_.zid)
            {
               _loc3_ = new TGetClanInfo(_loc2_.id);
               TransactionManager.addTransaction(_loc3_,true);
            }
         }
         else if(_loc2_.id == "clan.healthUpdate")
         {
            _loc7_ = int(_loc2_.health);
            if(_loc7_ <= this.maxHealth)
            {
               this.m_clanHealth = _loc7_;
            }
            else
            {
               this.m_clanHealth = this.maxHealth;
               _loc3_ = new TGetClanInfo();
               TransactionManager.addTransaction(_loc3_,true);
            }
            this.dispatchEvent(new WorldEvent(CLANS_ZLINGSHOT_MSG,_loc2_.id));
         }
         else if(_loc2_.id == "clan.gotCrown")
         {
            PopupManager.instance.push(new AllianceCrownNotifyPopup());
         }
         else if(_loc2_.id == "clan.showNotification")
         {
            this.showAllianceNotification();
            this.m_hasNewRival = true;
         }
         else if(_loc2_.id == "clan.update")
         {
            _loc3_ = new TGetClanInfo();
            TransactionManager.addTransaction(_loc3_,true);
         }
      }
      
      public function getPath(param1:int, param2:int) : String
      {
         var _loc3_:String = null;
         this.m_data = ZGlobal.gameSettings.getCrest("" + param1);
         _loc3_ = "";
         switch(param2)
         {
            case 48:
               if(this.m_data.@path48.toString().length > 0)
               {
                  _loc3_ = this.m_data.@path48.toString();
               }
               else
               {
                  _loc3_ = "";
               }
               break;
            case 64:
               if(this.m_data.@path64.toString().length > 0)
               {
                  _loc3_ = this.m_data.@path64.toString();
               }
               else
               {
                  _loc3_ = "";
               }
               break;
            case 96:
               if(this.m_data.@path96.toString().length > 0)
               {
                  _loc3_ = this.m_data.@path96.toString();
               }
               else
               {
                  _loc3_ = "";
               }
               break;
            case 150:
               if(this.m_data.@path150.toString().length > 0)
               {
                  _loc3_ = this.m_data.@path150.toString();
               }
               else
               {
                  _loc3_ = "";
               }
               break;
            default:
               _loc3_ = "";
         }
         return _loc3_;
      }
      
      public function enableSetup() : void
      {
         this.m_setup = true;
      }
      
      public function disableSetup() : void
      {
         this.m_setup = false;
      }
      
      public function init(param1:Object) : void
      {
         var _loc2_:FriendsBarUIItem = null;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:Number = NaN;
         var _loc6_:Transaction = null;
         if(!ZGlobal.player.getSeenFlag(ALLIANCE_SEEN_FLAG) && isValid())
         {
            _loc2_ = UIManager.instance.getMenuItemByName(FriendsBarUIItem.ITEM_ID) as FriendsBarUIItem;
            if(_loc2_ != null)
            {
               _loc2_.startAllianceAnimation();
            }
         }
         if(param1 == null)
         {
            return;
         }
         if(param1.id)
         {
            this.m_clanid = param1.id;
         }
         if(param1.name)
         {
            this.m_clanName = param1.name;
         }
         if(param1.health)
         {
            this.m_clanHealth = param1.health;
         }
         if(param1.leader)
         {
            this.m_leaderId = param1.leader;
         }
         if(param1.firstLeader)
         {
            this.m_firstLeader = param1.firstLeader;
         }
         if(param1.crestId)
         {
            this.m_crestId = param1.crestId;
         }
         if(Boolean(param1.members) && Boolean(param1.members as Array))
         {
            this.m_members = param1.members;
            _loc3_ = 0;
            while(_loc3_ < this.m_members.length)
            {
               _loc4_ = String(this.m_members[_loc3_]);
               if(_loc4_)
               {
                  this.m_members[_loc3_] = _loc4_;
               }
               _loc3_++;
            }
         }
         if(param1.memberslimit)
         {
            this.m_maxMembers = param1.memberslimit;
         }
         if(param1.unlockedCrest)
         {
            this.m_unlockedCrest = param1.unlockedCrest;
         }
         if(param1.membersInfo)
         {
            this.m_membersInfo = param1.membersInfo;
         }
         if(param1.memberData)
         {
            this.m_memberData = param1.memberData;
         }
         if(param1.numCrowns)
         {
            this.m_numCrowns = param1.numCrowns;
         }
         if(param1.quests)
         {
            this.m_quests = param1.quests;
         }
         if(Boolean(param1.fbGroupID) && param1.fbGroup != "")
         {
            this.m_fbGroupID = param1.fbGroupID;
            this.m_fbGroupCreated = true;
         }
         if(Boolean(param1.memberData) && Boolean(param1.memberData["zid" + ZGlobal.player.uid]))
         {
            _loc5_ = Number(param1.memberData["zid" + ZGlobal.player.uid].tauntViewTime);
            this.m_tauntViewTime = Math.max(this.m_tauntViewTime,_loc5_);
            if(param1.memberData["zid" + ZGlobal.player.uid].msgQueue.length > 0)
            {
               _loc6_ = new TProcessMemberQueue();
               TransactionManager.addTransaction(_loc6_,true);
            }
         }
         if(param1.newNotification)
         {
            this.showAllianceNotification();
            this.m_hasNewRival = true;
         }
         UIDispatcher.instance.dispatchEvent(new Event(UPDATE_CREST_ICON));
         this.m_initialised = true;
      }
      
      public function get clanId() : String
      {
         return this.m_clanid;
      }
      
      public function deinit() : void
      {
         this.m_clanName = "";
         this.m_clanid = "";
         this.m_quests = null;
         this.m_crestId = 9999;
         this.m_initialised = false;
         UIDispatcher.instance.dispatchEvent(new Event(UPDATE_CREST_ICON));
      }
      
      public function isInitialised() : Boolean
      {
         return this.m_initialised;
      }
      
      public function getMembersQuestCount(param1:String) : Dictionary
      {
         var _loc4_:String = null;
         var _loc2_:Dictionary = new Dictionary();
         _loc2_["members"] = new Array();
         var _loc3_:int = 0;
         if(this.m_quests[param1])
         {
            for(_loc4_ in this.m_members)
            {
               if(this.m_quests[param1]["zid" + this.m_members[_loc4_]])
               {
                  _loc2_["zid" + this.m_members[_loc4_]] = this.m_quests[param1]["zid" + this.m_members[_loc4_]];
                  _loc2_["members"].push(this.m_members[_loc4_]);
                  _loc3_ += 1;
               }
            }
         }
         _loc2_["total"] = _loc3_;
         return _loc2_;
      }
      
      public function isLeader() : Boolean
      {
         if(this.m_leaderId == ZGlobal.player.uid)
         {
            return true;
         }
         return false;
      }
      
      public function get crestId() : int
      {
         return this.m_crestId;
      }
      
      public function set fbGroupID(param1:String) : void
      {
         this.m_fbGroupID = param1;
      }
      
      public function set fbGroupCreated(param1:Boolean) : void
      {
         this.m_fbGroupCreated = param1;
      }
      
      public function get fbGroupID() : String
      {
         return this.m_fbGroupID;
      }
      
      public function get fbGroupCreated() : Boolean
      {
         return this.m_fbGroupCreated;
      }
      
      public function set currentHealth(param1:int) : void
      {
         if(param1 > this.maxHealth)
         {
            this.giveMaxHealth();
         }
         else
         {
            this.m_clanHealth = param1;
         }
      }
      
      public function get currentHealth() : int
      {
         return this.m_clanHealth;
      }
      
      public function acceptedQuest(param1:String) : Boolean
      {
         if(Boolean(this.m_quests) && Boolean(this.m_quests[param1]) && Boolean(this.m_quests[param1]["zid" + ZGlobal.player.uid]))
         {
            return true;
         }
         return false;
      }
      
      public function setAcceptedQuest(param1:String) : void
      {
         if(!this.m_initialised)
         {
            return;
         }
         if(!this.m_quests)
         {
            this.m_quests = new Object();
         }
         if(!this.m_quests[param1])
         {
            this.m_quests[param1] = new Object();
         }
         if(!this.m_quests[param1]["zid" + ZGlobal.player.uid])
         {
            this.m_quests[param1]["zid" + ZGlobal.player.uid] = new Object();
         }
      }
      
      public function updateHealth(param1:int) : void
      {
         if(this.currentHealth + param1 > this.maxHealth)
         {
            this.giveMaxHealth();
         }
         else if(this.currentHealth + param1 < 0)
         {
            this.currentHealth = 0;
         }
         else
         {
            this.currentHealth += param1;
         }
      }
      
      public function checkHealth(param1:int) : int
      {
         if(this.currentHealth + param1 > this.maxHealth)
         {
            return this.maxHealth;
         }
         if(this.currentHealth + param1 < 0)
         {
            return 0;
         }
         return this.currentHealth + param1;
      }
      
      public function get currentMemberSize() : int
      {
         return this.m_members.length;
      }
      
      public function get totalMemberSize() : int
      {
         return this.m_maxMembers;
      }
      
      public function increaseTotalMemberSize() : void
      {
         this.m_maxMembers += 1;
         ZGlobal.player.cash -= ADD_SLOT_PRICE;
      }
      
      public function set crestId(param1:int) : void
      {
         var _loc2_:TUpdateCrest = null;
         this.m_crestId = param1;
         if(this.isInitialised() && !this.m_setup)
         {
            _loc2_ = new TUpdateCrest(param1);
            TransactionManager.addTransaction(_loc2_);
            this.m_unlockedCrest.push(this.m_crestId);
         }
         UIDispatcher.instance.dispatchEvent(new Event(UPDATE_CREST_ICON));
      }
      
      public function isCrestBought(param1:int) : Boolean
      {
         var _loc2_:int = 0;
         if(this.m_unlockedCrest)
         {
            _loc2_ = 0;
            while(_loc2_ < this.m_unlockedCrest.length)
            {
               if(param1 == this.m_unlockedCrest[_loc2_])
               {
                  return true;
               }
               _loc2_++;
            }
            return false;
         }
         return false;
      }
      
      public function get clanName() : String
      {
         return this.m_clanName;
      }
      
      public function set clanName(param1:String) : void
      {
         var _loc2_:TUpdateClanName = null;
         this.m_clanName = param1;
         if(this.isInitialised() && !this.m_setup)
         {
            _loc2_ = new TUpdateClanName(param1);
            TransactionManager.addTransaction(_loc2_);
         }
      }
      
      public function setClanName(param1:String) : void
      {
         this.m_clanName = param1;
      }
      
      public function setFBGroupID(param1:String) : void
      {
         this.m_fbGroupID = param1;
         this.m_fbGroupCreated = true;
         UIDispatcher.instance.dispatchEvent(new Event(FB_GROUP_CREATED));
      }
      
      public function get membersInfo() : Object
      {
         return this.m_membersInfo;
      }
      
      public function get members() : Array
      {
         return this.m_members;
      }
      
      public function canShowInvite() : Boolean
      {
         if(!this.m_members)
         {
            return true;
         }
         return this.m_members.length < this.totalMemberSize;
      }
      
      public function isValidNeighbor(param1:Object) : Boolean
      {
         return param1.level >= AlliancesManager.ALLIANCE_MIN_LEVEL;
      }
      
      public function showConfirmationPopup() : void
      {
         var _loc1_:String = null;
         var _loc3_:GenericPopup2B = null;
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","AllianceAcceptTitle");
         switch(ZGlobal.player.clanStatus)
         {
            case "key_invalid":
               _loc1_ = ZGameUtils.ZlocT("Dialogs","AllianceAccept_Invalid",{
                  "player":ZGlobal.player.name,
                  "allianceName":AlliancesManager.instance.clanName
               });
               break;
            case "key_member_invalid":
               _loc1_ = ZGameUtils.ZlocT("Dialogs","AllianceAccept_Already",{
                  "player":ZGlobal.player.name,
                  "allianceName":AlliancesManager.instance.clanName
               });
               break;
            case "key_lowlevel_invalid":
               _loc1_ = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Low_desc",{
                  "name":ZGlobal.player.name,
                  "allianceName":AlliancesManager.instance.clanName,
                  "x":ALLIANCE_MIN_LEVEL
               });
               break;
            case "key_full_invalid":
               _loc1_ = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Full_desc",{"Aname":AlliancesManager.instance.clanName});
               break;
            case "success":
               _loc1_ = ZGameUtils.ZlocT("Dialogs","AllianceAccept_Success",{
                  "name":ZGlobal.player.name,
                  "allianceName":AlliancesManager.instance.clanName
               });
         }
         if(ZGlobal.player.clanStatus)
         {
            _loc3_ = new GenericPopup2B(_loc1_,_loc2_,GenericPopup.TYPE_OK,null);
            if(ZGlobal.player.clanStatus != "success")
            {
               _loc3_.setAdvisorMood(GenericPopup.MOOD_SURPRISED);
            }
            else
            {
               _loc3_.setAdvisorMood(GenericPopup.MOOD_HAPPY);
            }
            PopupManager.instance.push(_loc3_);
         }
      }
      
      public function clearQuests() : void
      {
         var _loc1_:String = null;
         for each(_loc1_ in new Array("QALL0","QALL1","QALL1_5","QALL2","QALL2_5","QALL3"))
         {
            ZGameQuestManager.instance.resetQuest(_loc1_);
         }
         ZGameQuestManager.instance.clientActivateQuest("QALL1");
      }
      
      public function removeMember(param1:String) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc2_:int = this.m_members.indexOf(param1);
         if(_loc2_ > -1)
         {
            this.m_members.splice(_loc2_,1);
         }
         this.currentHealth = Math.min(this.currentHealth,this.maxHealth);
      }
      
      public function memberInfo(param1:String) : Object
      {
         var _loc2_:Object = null;
         if(Boolean(this.m_membersInfo) && Boolean(this.m_membersInfo["zid" + param1]))
         {
            _loc2_ = this.m_membersInfo["zid" + param1];
         }
         else if(ZGlobal.player.neighbors[param1])
         {
            _loc2_ = ZGlobal.player.neighbors[param1];
         }
         return _loc2_;
      }
      
      public function neighborInfo(param1:String) : Object
      {
         var _loc2_:Object = this.memberInfo(param1);
         if(Boolean(_loc2_) && Boolean(_loc2_.clanId))
         {
            return _loc2_;
         }
         return null;
      }
      
      public function isAllianceMember(param1:String) : Object
      {
         if(Boolean(this.m_members) && this.m_members.length > 0)
         {
            if(this.m_membersInfo["zid" + param1])
            {
               return this.m_membersInfo["zid" + param1];
            }
         }
         return null;
      }
      
      public function getPlayerObject(param1:Object) : Player
      {
         var _loc3_:SocialNetworkUser = null;
         var _loc2_:Object = Boolean(param1) && Boolean(ZGlobal.player.neighbors[param1.uid]) ? ZGlobal.player.neighbors[param1.uid] : this.m_membersInfo["zid" + param1.uid];
         _loc3_ = new SocialNetworkUser(param1.uid);
         _loc3_.name = _loc3_.firstName = param1.name;
         if(_loc2_)
         {
            _loc3_.picture = _loc2_.image;
            _loc3_.gender = _loc2_.gender;
         }
         return new Player(_loc3_);
      }
      
      public function getCrestIcon(param1:int) : String
      {
         var _loc2_:String = AlliancesManager.instance.getPath(param1,96);
         if(_loc2_)
         {
            _loc2_ = ZGlobal.getAssetURL(_loc2_);
         }
         return _loc2_;
      }
      
      public function getAllianceName(param1:Object) : String
      {
         var _loc2_:String = "";
         if(param1.clanId == this.m_clanid)
         {
            _loc2_ = this.m_clanName;
         }
         else if(param1.clanName)
         {
            _loc2_ = param1.clanName;
         }
         return ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Member_title",{"Aname":_loc2_});
      }
      
      public function addJoinRequest(param1:String) : void
      {
         if(this.m_joinRequests)
         {
            this.m_joinRequests[param1] = 1;
         }
         else
         {
            this.m_joinRequests = new Dictionary();
         }
      }
      
      public function updateJoinRequest(param1:Array) : void
      {
         var _loc2_:String = null;
         for each(_loc2_ in param1)
         {
            if(Boolean(this.m_joinRequests) && Boolean(this.m_joinRequests[_loc2_]))
            {
               this.m_joinRequests[_loc2_] = 2;
            }
         }
      }
      
      public function isJoinRequestSent(param1:String) : Boolean
      {
         if(Boolean(this.m_joinRequests) && this.m_joinRequests[param1] == 2)
         {
            return true;
         }
         return false;
      }
      
      public function populateAllianceData(param1:Object) : void
      {
         var _loc2_:String = null;
         if(!this.m_allianceData)
         {
            this.m_allianceData = new Dictionary();
         }
         for(_loc2_ in param1)
         {
            if(Boolean(param1[_loc2_]) && Boolean(_loc2_))
            {
               this.m_allianceData[_loc2_] = param1[_loc2_];
            }
         }
      }
      
      public function getAllianceMembers(param1:String) : Array
      {
         if(Boolean(param1) && Boolean(this.m_allianceData))
         {
            if(this.m_allianceData[param1])
            {
               return this.m_allianceData[param1];
            }
         }
         return null;
      }
      
      public function loadNextMember(param1:String = null, param2:String = null) : String
      {
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc3_:String = null;
         if(Boolean(this.m_activeBattleData) && Boolean(param1))
         {
            if(Boolean(this.m_activeBattleData["allianceName"]) && Boolean(this.m_activeBattleData["allianceName"] == param2) && Boolean(this.m_activeBattleData["inProgress"]) && this.m_activeBattleData["inProgress"] == param1)
            {
               _loc5_ = this.m_activeBattleData["next"] as Array;
               if((Boolean(_loc5_)) && _loc5_.length > 0)
               {
                  return _loc5_[0];
               }
               return null;
            }
         }
         if(!param1 && Boolean(param2))
         {
            _loc4_ = this.m_allianceData[param2];
            if((Boolean(_loc4_)) && _loc4_.length > 0)
            {
               if(param1)
               {
                  _loc6_ = _loc4_.indexOf(param1);
                  if(_loc6_ > -1 && _loc6_ < _loc4_.length)
                  {
                     return _loc4_[_loc6_ + 1];
                  }
                  return null;
               }
               return _loc4_[0];
            }
         }
         return _loc3_;
      }
      
      public function get allianceBattleMember() : String
      {
         return this.m_allianceBattleMember;
      }
      
      public function set allianceBattleMember(param1:String) : void
      {
         this.m_allianceBattleMember = param1;
      }
      
      public function loadBattle(param1:String = null, param2:String = null, param3:String = null, param4:Boolean = false) : void
      {
         TransactionManager.addTransaction(new TLoadAllianceBattle(param1,param2,param3,param4));
      }
      
      public function nextAllianceBattle(param1:int, param2:Dictionary, param3:Array, param4:String, param5:String = null) : void
      {
         var _loc6_:Array = null;
         if(param1 == Battle.BATTLE_RESULT_WON)
         {
            if(param4)
            {
               this.loadBattle(param5,param4,AlliancesManager.instance.battleAllianceName);
               if(this.m_activeBattleData)
               {
                  this.m_activeBattleData["won"].concat(this.m_activeBattleData["inProgress"]);
                  this.m_activeBattleData["inProgress"] = param4;
                  _loc6_ = this.m_activeBattleData["next"] as Array;
                  _loc6_.splice(0,1);
                  this.m_activeBattleData["next"] = _loc6_;
               }
            }
         }
      }
      
      public function completeAllianceWave(param1:BattleHost, param2:String = null) : void
      {
         var _loc6_:Object = null;
         var _loc3_:Object = new Object();
         _loc3_.attackBonus = 0;
         _loc3_.revengeBonus = 0;
         var _loc4_:Boolean = false;
         var _loc5_:Object = DominationModeManager.instance.getAllianceInfo(this.m_activeBattleData["allianceName"]);
         if(this.m_allianceBattleMember)
         {
            _loc3_ = DominationModeManager.instance.getDominationInfo(this.m_allianceBattleMember);
         }
         if(param1.playerFleet.hasStatus(Fleet.DOMINATION_RETAL) || Boolean(_loc5_.int))
         {
            _loc4_ = true;
         }
         DominationModeManager.instance.updateAllianceWaveWonScore(param1,_loc3_,_loc4_);
         if(param1.battleResult == Battle.BATTLE_RESULT_WON)
         {
            this.updateHealth(AlliancesManager.ALLIANCE_HEALTH_GAIN);
         }
         if(_loc5_.health - AlliancesManager.ALLIANCE_HEALTH_DEDUCT < 0)
         {
            _loc5_.health = 0;
         }
         else
         {
            _loc5_.health -= AlliancesManager.ALLIANCE_HEALTH_DEDUCT;
         }
         if(param2 != null)
         {
            _loc3_ = DominationModeManager.instance.getDominationInfo(param2);
            _loc6_ = this.getBattleDominationScore(_loc5_.members.length,_loc5_.health,_loc5_.max_health,_loc3_.scInc);
            if(Boolean(_loc3_) && _loc3_.attackBonus != _loc6_.attack)
            {
               _loc3_.attackBonus = _loc6_.attack;
            }
         }
      }
      
      public function updateAllianceBattleBonus(param1:BattleHost) : void
      {
         var _loc5_:Object = null;
         var _loc2_:Boolean = false;
         var _loc3_:Object = DominationModeManager.instance.getAllianceInfo(this.m_activeBattleData["allianceName"]);
         _loc3_.attackBonus = 0;
         _loc3_.revengeBonus = 0;
         var _loc4_:int = 0;
         if(Boolean(param1) && Boolean(_loc3_.totalBonus))
         {
            _loc5_ = _loc3_.totalBonus;
            if(_loc5_["totalBonus"])
            {
               _loc4_ += int(_loc5_["totalBonus"]);
            }
            DominationModeManager.instance.dominance += _loc4_;
         }
      }
      
      public function activeVictoryMessage() : Boolean
      {
         var _loc1_:String = AlliancesManager.instance.allianceBattleMember;
         var _loc2_:String = AlliancesManager.instance.battleAllianceName;
         if(!AlliancesManager.instance.loadNextMember(_loc1_,_loc2_) || Boolean(this.m_loadingScreen))
         {
            return true;
         }
         return false;
      }
      
      public function battleWaveVictory(param1:Boolean = false) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc5_:Boolean = false;
         if(!this.m_loadingScreen)
         {
            _loc2_ = AlliancesManager.instance.allianceBattleMember;
            _loc3_ = AlliancesManager.instance.battleAllianceName;
            if(AlliancesManager.instance.loadNextMember(_loc2_,_loc3_))
            {
               _loc4_ = DominationModeManager.instance.getAllianceInfo(_loc3_);
               _loc5_ = false;
               if(Boolean(_loc4_) && Boolean(_loc4_.int))
               {
                  _loc5_ = true;
               }
            }
            this.m_loadingScreen = new AllianceBattleWaveVictory(this.m_allianceBattleName,this.m_allianceBattleMember,_loc5_);
            PopupManager.instance.push(this.m_loadingScreen,0,false);
         }
         else
         {
            this.closeWaveLoadingScreen();
         }
      }
      
      public function battleWaveIntro(param1:Boolean = false) : void
      {
         if(this.m_loadingScreen)
         {
            this.closeWaveLoadingScreen();
         }
         if(!this.m_loadingScreen)
         {
            this.m_loadingScreen = new AllianceBattleWaveIntro(this.m_allianceBattleName,this.m_allianceBattleMember,true);
            WindowManager.instance.push(this.m_loadingScreen,0,false,true);
         }
      }
      
      public function closeWaveLoadingScreen(param1:Boolean = false) : void
      {
         if(this.m_loadingScreen)
         {
            this.m_loadingScreen.pop();
            this.m_loadingScreen = null;
         }
      }
      
      public function get allianceBattle() : Boolean
      {
         return this.m_allianceBattle;
      }
      
      public function set allianceBattle(param1:Boolean) : void
      {
         this.m_allianceBattle = param1;
      }
      
      public function set battleAllianceName(param1:String) : void
      {
         this.m_allianceBattleName = param1;
      }
      
      public function get battleAllianceName() : String
      {
         if(this.m_allianceBattleName)
         {
            return this.m_allianceBattleName;
         }
         return "";
      }
      
      public function get continuePurchaseCost() : int
      {
         return 5;
      }
      
      public function get battleScores() : Object
      {
         var _loc1_:Object = new Object();
         var _loc2_:Object = new Object();
         var _loc3_:Object = new Object();
         if(!this.m_allianceBattleMember)
         {
            return null;
         }
         var _loc4_:Object = DominationModeManager.instance.getDominationInfo(this.m_allianceBattleMember);
         _loc2_.health = -1 * AlliancesManager.ALLIANCE_HEALTH_DEDUCT;
         _loc2_.domPoints = -1 * _loc4_.scDec;
         _loc1_.loser = _loc2_;
         _loc3_.health = AlliancesManager.ALLIANCE_HEALTH_GAIN;
         _loc3_.domPoints = _loc4_.scInc;
         _loc3_.attackBonus = _loc4_.attackBonus;
         _loc3_.revengeBonus = _loc4_.revengeBonus;
         _loc1_.winner = _loc3_;
         return _loc1_;
      }
      
      public function initBattleData(param1:Boolean = false) : void
      {
         var _loc3_:String = null;
         if(Boolean(this.m_activeBattleData) && !param1)
         {
            return;
         }
         this.m_activeBattleData = new Dictionary();
         var _loc2_:Object = ZGlobal.player.allianceStorage;
         for(_loc3_ in _loc2_)
         {
            this.m_activeBattleData[_loc3_] = _loc2_[_loc3_];
            if(_loc3_ == "inProgress")
            {
               this.m_allianceBattleMember = _loc2_[_loc3_];
            }
            else if(_loc3_ == "next")
            {
               this.m_activeBattleData[_loc3_] = _loc2_[_loc3_] as Array;
            }
            if(_loc3_ == "members")
            {
               this.m_allianceData[this.m_allianceBattleName] = _loc2_[_loc3_] as Array;
            }
         }
      }
      
      public function allianceBattleInProgress() : String
      {
         if(this.m_activeBattleData)
         {
            if(Boolean(this.m_activeBattleData["allianceName"]) && Boolean(this.m_activeBattleData["inProgress"]))
            {
               if(!this.m_activeBattleData["newBattle"] && !this.m_activeBattleData["lost"])
               {
                  return this.m_activeBattleData["allianceName"];
               }
            }
         }
         return null;
      }
      
      public function lostAllianceBattle() : void
      {
         if(this.m_activeBattleData)
         {
            if(Boolean(this.m_activeBattleData["allianceName"]) && Boolean(this.m_activeBattleData["inProgress"]))
            {
               this.m_activeBattleData["lost"] = 1;
            }
         }
      }
      
      public function isLostAllianceBattle() : Boolean
      {
         if(this.m_activeBattleData)
         {
            if(Boolean(this.m_activeBattleData["allianceName"]) && Boolean(this.m_activeBattleData["inProgress"]))
            {
               if(this.m_activeBattleData["lost"])
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function resetLostBattleData() : void
      {
         if(this.m_activeBattleData)
         {
            if(Boolean(this.m_activeBattleData["allianceName"]) && Boolean(this.m_activeBattleData["inProgress"]))
            {
               if(this.m_activeBattleData["lost"])
               {
                  delete this.m_activeBattleData["lost"];
               }
            }
         }
      }
      
      public function resetAllianceBattleData(param1:Boolean = false) : void
      {
         if(param1)
         {
            this.updateAllianceList();
         }
         if(this.m_activeBattleData)
         {
            this.m_activeBattleData = null;
            ZGlobal.player.allianceStorage = null;
         }
         this.m_allianceBattle = false;
         this.m_allianceBattleMember = null;
         this.m_allianceBattleName = null;
      }
      
      public function updateAllianceList() : void
      {
         if(this.m_allianceBattleName)
         {
            DominationModeManager.instance.updateAllianceList(this.m_allianceBattleName);
         }
      }
      
      public function get leaderId() : String
      {
         return this.m_leaderId;
      }
      
      public function get firstLeader() : String
      {
         return this.m_firstLeader;
      }
      
      public function get numCrowns() : int
      {
         return this.m_numCrowns;
      }
      
      public function giveMaxHealth() : void
      {
         this.m_clanHealth = this.maxHealth;
      }
      
      public function get maxHealth() : int
      {
         return this.m_members.length * 100;
      }
      
      public function getAllianceInfo() : Object
      {
         var _loc1_:Object = new Object();
         _loc1_["id"] = this.clanId;
         _loc1_["name"] = this.clanName;
         _loc1_["health"] = this.currentHealth;
         _loc1_["leader"] = this.leaderId;
         _loc1_["crestId"] = this.crestId;
         _loc1_["numCrowns"] = this.numCrowns;
         _loc1_["members"] = this.members;
         _loc1_["max_health"] = this.maxHealth;
         return _loc1_;
      }
      
      public function allianceBattleData(param1:Object) : void
      {
         ZGlobal.player.allianceStorage = param1;
         this.initBattleData(true);
      }
      
      public function allianceBattleScores(param1:Object) : void
      {
         if(!this.m_activeBattleData)
         {
            return;
         }
         this.m_activeBattleData["scores"] = param1;
      }
      
      public function getBattleDominationScore(param1:int, param2:int, param3:int, param4:int = 0) : Object
      {
         var _loc5_:Object = new Object();
         _loc5_["attack"] = 0;
         _loc5_["revenge"] = 0;
         _loc5_["totalBonus"] = 0;
         _loc5_["totalRevengeBonus"] = 0;
         if(param1 <= 0 || param2 <= 0 || param3 <= 0)
         {
            return _loc5_;
         }
         _loc5_["totalBonus"] = Math.floor(param1 * 25 + param1 * (param2 / param3 * 125));
         _loc5_["totalRevengeBonus"] = Math.floor(_loc5_["totalBonus"] + 50 * param1);
         _loc5_["attack"] = Math.floor(param4 / 100 * (param2 / param3 * 100));
         _loc5_["revenge"] = 50;
         return _loc5_;
      }
      
      public function get cycleStartTime() : int
      {
         return this.m_cycleStartTime;
      }
      
      public function get cycleDuration() : int
      {
         return this.m_cycleDuration;
      }
      
      public function getAllianceMemberPlayerObject(param1:Object) : Player
      {
         var _loc3_:SocialNetworkUser = null;
         if(!param1)
         {
            return null;
         }
         var _loc2_:Object = Boolean(param1) && Boolean(ZGlobal.player.neighbors[param1.uid]) ? ZGlobal.player.neighbors[param1.uid] : param1;
         _loc3_ = new SocialNetworkUser(param1.uid);
         _loc3_.name = _loc3_.firstName = param1.name;
         if(_loc2_)
         {
            _loc3_.picture = _loc2_.image;
            _loc3_.gender = _loc2_.gender;
         }
         return new Player(_loc3_);
      }
      
      public function getAllianceMemberLegionNum(param1:String = null, param2:String = null) : int
      {
         if(!this.m_allianceBattleName || !this.m_allianceBattleMember || !this.m_activeBattleData)
         {
            return -1;
         }
         if(!param1)
         {
            param1 = this.m_allianceBattleName;
         }
         if(!param2)
         {
            param2 = this.m_allianceBattleMember;
         }
         var _loc3_:int = -1;
         if(Boolean(this.m_activeBattleData["members"]) && this.m_activeBattleData["members"].length > 0)
         {
            _loc3_ = int(this.m_activeBattleData["members"].indexOf(param2));
         }
         else
         {
            _loc3_ = int(this.m_allianceData[param1].indexOf(param2));
         }
         return _loc3_ + 1;
      }
      
      public function getAllianceMemberTotal(param1:String = null) : int
      {
         if(!this.m_allianceBattleName || !this.m_activeBattleData)
         {
            return -1;
         }
         if(!param1)
         {
            param1 = this.m_allianceBattleName;
         }
         var _loc2_:int = 0;
         if(Boolean(this.m_activeBattleData["members"]) && this.m_activeBattleData["members"].length > 0)
         {
            _loc2_ = int(this.m_activeBattleData["members"].length);
         }
         else
         {
            _loc2_ = int(this.m_allianceData[param1].length);
         }
         return _loc2_;
      }
      
      public function updateTimestamp(param1:Number, param2:Number) : void
      {
         this.m_cycleStartTime = param1;
         this.m_cycleDuration = param2;
      }
      
      public function updateTauntViewTime() : void
      {
         this.m_tauntViewTime = int(GlobalEngine.serverTime / 1000);
      }
      
      public function get tauntViewTime() : Number
      {
         return this.m_tauntViewTime;
      }
      
      public function healthPrice() : int
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(EXPERIMENT_ALLIANCES_HEALTH_PRICING);
         var _loc2_:int = 0;
         switch(_loc1_)
         {
            case 0:
            case 1:
            case 2:
               _loc2_ = 0;
               break;
            case 3:
               _loc2_ = 20;
               break;
            case 4:
               _loc2_ = 40;
               break;
            case 5:
               _loc2_ = 60;
               break;
            default:
               _loc2_ = 0;
         }
         var _loc3_:Number = Number(HEALTH_PRICES[this.m_members.length - 1]);
         if(_loc2_ != 0)
         {
            _loc3_ -= 1 * _loc3_ * _loc2_ / 100;
            _loc3_ = Math.ceil(_loc3_);
         }
         return _loc3_;
      }
      
      public function healthBelowThreshold() : Boolean
      {
         return this.currentHealth < this.maxHealth * HEALTH_BUY_THRESHOLD;
      }
      
      private function showAllianceNotification() : void
      {
         UIDispatcher.instance.dispatchEvent(new Event(SHOW_ALLIANCES_NOTIFICATION));
      }
      
      public function refreshAllianceInfo() : void
      {
         TransactionManager.addTransaction(new TGetClanInfo(),true);
      }
      
      public function isAllianceBattleEnabled() : Boolean
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant("empire_alliances_phase_4");
         if(_loc1_ == 3)
         {
            return true;
         }
         return false;
      }
      
      public function hasNewRival() : Boolean
      {
         return this.m_hasNewRival;
      }
      
      public function clearNewRival() : void
      {
         this.m_hasNewRival = false;
      }
   }
}

