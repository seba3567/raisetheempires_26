package entity
{
   import core.ZGameManager;
   import core.ZGlobal;
   import core.entities.components.BuildingSpatialComponent;
   import core.entities.components.behaviors.states.PurchaseState;
   import core.gameobjects.CrewTemplateWrapper;
   import core.gameobjects.GameItem;
   import core.managers.CrewManager;
   import core.managers.RaffleManager;
   import core.managers.decorationsManager.DecorationsManager;
   import core.player.Player;
   import core.ui.PlayerFeedbackManager;
   import core.worlds.islandworld.IslandWorld;
   import dispatchers.UIDispatcher;
   import events.UnitEvent;
   import flash.events.Event;
   import flash.geom.Vector3D;
   import utils.TileUtil;
   import utils.ZGameUtils;
   import zlabs.core.PBGroup;
   import zlabs.entity.EntityComponent;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.renderingISO.IsoSpriteComponent;
   
   public class GameDataComponent extends EntityComponent
   {
      
      public static const ZLINGSHOT_CREW_ADDED:String = "messagecrew";
      
      public static var CREW_UPDATED:String = "crewUpdated";
      
      public static var ID_SET:String = "idSet";
      
      public static var DECO_CREWCOUNT_QUERY:String = "decoCrewQuery";
      
      public var gameData:GameItem;
      
      public var userData:Object;
      
      private var m_state:int;
      
      private var m_direction:int = 0;
      
      private var m_id:int = 0;
      
      private var m_actionActive:Boolean = false;
      
      private var m_inWater:Boolean = false;
      
      public function GameDataComponent(param1:EntityInit, param2:IEntity)
      {
         var _loc3_:Array = null;
         super();
         this.gameData = param1.m_item as GameItem;
         this.userData = param1.m_object;
         if(this.userData)
         {
            this.m_id = this.userData.id;
            if(param1.m_object.position)
            {
               _loc3_ = param1.m_object.position.split(",");
               this.m_direction = _loc3_[2];
            }
         }
         else
         {
            if(param1.m_generateId)
            {
               this.setIDFromWorld();
            }
            else if(param1.m_delayId)
            {
               param2.eventDispatcher.addEventListener(PurchaseState.PURCHASED,this.onPurchased);
            }
            if(param1.m_position)
            {
               this.m_direction = param1.m_position.z;
            }
         }
         param2.eventDispatcher.addEventListener(UnitEvent.ACTION_STARTED,this.onActionStarted);
         param2.eventDispatcher.addEventListener(UnitEvent.ACTION_ENDED,this.onActionEnded);
      }
      
      public static function getGameDataComponent(param1:IEntity) : GameDataComponent
      {
         return param1.lookupComponentByType(GameDataComponent) as GameDataComponent;
      }
      
      override protected function onAdd() : void
      {
         var _loc1_:String = null;
         var _loc2_:PBGroup = null;
         super.onAdd();
         UIDispatcher.instance.addEventListener("ISOdebugDisplay",this.onDebugEvent,false,0,true);
         if(this.gameData.isRaffleBuilding())
         {
            RaffleManager.instance.addEventListener(RaffleManager.NEW_TICKET,this.onTicketAdded,false,0,true);
         }
         if(this.gameData.getCrewTemplateName())
         {
            CrewManager.instance.addEventListener(ZLINGSHOT_CREW_ADDED,this.onCrewAdded,false,0,true);
            if(this.gameData.isDecorationSource)
            {
               CrewManager.instance.addEventListener(DECO_CREWCOUNT_QUERY,this.onDecoCrewCountQuery,false,0,true);
            }
         }
         if(Boolean(this.userData) && this.userData.data != null)
         {
            if(null != this.userData.data.group)
            {
               _loc1_ = this.userData.data.group as String;
               if(null == _loc1_)
               {
                  _loc1_ = this.userData.data.group.toString();
               }
               _loc2_ = ZGlobal.game.getObjectGroup(_loc1_);
               owner.owningGroup = _loc2_;
            }
         }
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         UIDispatcher.instance.removeEventListener("ISOdebugDisplay",this.onDebugEvent);
         owner.eventDispatcher.removeEventListener(PurchaseState.PURCHASED,this.onPurchased);
         owner.eventDispatcher.removeEventListener(UnitEvent.ACTION_STARTED,this.onActionStarted);
         owner.eventDispatcher.removeEventListener(UnitEvent.ACTION_ENDED,this.onActionEnded);
         if(this.gameData.isRaffleBuilding())
         {
            RaffleManager.instance.removeEventListener(RaffleManager.NEW_TICKET,this.onTicketAdded);
         }
         CrewManager.instance.removeEventListener(ZLINGSHOT_CREW_ADDED,this.onCrewAdded);
         CrewManager.instance.removeEventListener(DECO_CREWCOUNT_QUERY,this.onDecoCrewCountQuery);
         this.gameData = null;
         this.userData = null;
      }
      
      public function buyPermanentCrew() : void
      {
         var _loc3_:int = 0;
         delete this.userData.removeCrewTS;
         this.userData.buyOnceEnabled = true;
         var _loc1_:String = this.gameData.getCrewTemplateName();
         var _loc2_:CrewTemplateWrapper = ZGlobal.gameSettings.getCrewTemplateWrapper(_loc1_);
         if(Boolean(_loc2_) && Boolean(_loc2_.numPositions))
         {
            this.userData.crewInfo = [];
            while(_loc3_ < _loc2_.numPositions)
            {
               this.userData.crewInfo.push(Player.FAKE_PLAYER_ID);
               _loc3_++;
            }
         }
         this.dispatchCrewChangedEvent();
         DecorationsManager.instance.crewBuyOnce(owner);
      }
      
      public function initCrew() : void
      {
         if(this.userData)
         {
            if(!this.userData.crewInfo)
            {
               this.userData.crewInfo = [];
            }
         }
      }
      
      public function buyCrewSlot(param1:int, param2:int) : void
      {
         var _loc3_:int = 0;
         if(!this.userData.crewInfo)
         {
            this.userData.crewInfo = [];
         }
         this.userData.crewInfo.push(Player.FAKE_PLAYER_ID);
         if(this.userData.crewInfo.length == 1)
         {
            _loc3_ = CrewManager.instance.getCrewRemoveDuration(this.gameData);
            if(_loc3_)
            {
               this.userData.removeCrewTS = GlobalEngine.serverTime / 1000 + _loc3_;
            }
         }
         this.dispatchCrewChangedEvent();
      }
      
      public function clearLocalCrew() : void
      {
         this.userData.crewInfo = [];
         this.dispatchCrewChangedEvent();
      }
      
      private function onDecoCrewCountQuery(param1:WorldEvent) : void
      {
         if(param1.eventData.id == this.id)
         {
            param1.eventData.crewCount = this.crewCount;
         }
      }
      
      private function onCrewAdded(param1:WorldEvent) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         if(param1.eventData.object_id == this.id)
         {
            if(!this.userData || !(this.userData.crewInfo as Array) || !this.userData.crewInfo.length)
            {
               this.userData.crewInfo = [];
            }
            _loc3_ = uint(this.userData.crewInfo.length);
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(null == this.userData.crewInfo[_loc4_])
               {
                  this.userData.crewInfo[_loc4_] = param1.eventData.staffer;
                  _loc2_ = true;
                  break;
               }
               _loc4_++;
            }
            if(!_loc2_)
            {
               this.userData.crewInfo.push(param1.eventData.staffer);
            }
            this.notifyPlayerOfUpdate(param1.eventData.staffer);
            this.dispatchCrewChangedEvent();
         }
      }
      
      private function dispatchCrewChangedEvent() : void
      {
         owner.eventDispatcher.dispatchEvent(new WorldEvent(CREW_UPDATED,{"crew":this.userData.crewInfo}));
      }
      
      private function notifyPlayerOfUpdate(param1:String) : void
      {
         var _loc2_:Player = ZGlobal.player.findFriendById(param1);
         if(_loc2_)
         {
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackCrewReceived",{
               "crew":_loc2_.firstName,
               "item":this.gameData.getSentenceNameLocalizationObject()
            }),null,null,_loc2_.uid);
         }
      }
      
      private function onDebugEvent(param1:Event) : void
      {
         var _loc2_:IsoSpriteComponent = owner.lookupComponentByType(IsoSpriteComponent) as IsoSpriteComponent;
         if(_loc2_)
         {
            _loc2_.displayDebugVolume();
         }
      }
      
      public function get direction() : int
      {
         return this.m_direction;
      }
      
      public function set direction(param1:int) : void
      {
         this.m_direction = param1;
      }
      
      public function get state() : int
      {
         if(ZGlobal.isVisiting() && this.userData.visitorState != null)
         {
            this.m_state = this.userData.visitorState;
         }
         else
         {
            this.m_state = this.userData.state;
         }
         return this.m_state;
      }
      
      public function set state(param1:int) : void
      {
         this.m_state = param1;
      }
      
      public function get objectName() : String
      {
         return this.gameData.name;
      }
      
      public function get objectFriendlyName() : String
      {
         return this.gameData.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
      }
      
      public function getCursor() : Class
      {
         return null;
      }
      
      public function get id() : int
      {
         return this.m_id;
      }
      
      public function get actionActive() : Boolean
      {
         return this.m_actionActive;
      }
      
      public function get inWater() : Boolean
      {
         return this.m_inWater;
      }
      
      public function set inWater(param1:Boolean) : void
      {
         this.m_inWater = param1;
      }
      
      public function getSaveObject() : Object
      {
         var _loc1_:BuildingSpatialComponent = BuildingSpatialComponent(owner.lookupComponentByType(BuildingSpatialComponent));
         var _loc2_:Object = new Object();
         _loc2_.id = this.m_id;
         var _loc3_:Vector3D = TileUtil.worldToTile(_loc1_.position,true);
         _loc2_.position = _loc3_.x + "," + _loc3_.y + "," + this.m_direction;
         _loc2_.itemName = this.gameData.name;
         if(owner.owningGroup.name != "RootGroup" && owner.owningGroup.name != ZGameManager.WORLD_OBJECT_GROUP_NAME && owner.owningGroup.name != "views")
         {
            _loc2_.group = owner.owningGroup.name;
         }
         return _loc2_;
      }
      
      public function get crewBuyOnceEnabled() : Boolean
      {
         return Boolean(this.userData) && Boolean(this.userData.buyOnceEnabled);
      }
      
      public function updateCrew(param1:Boolean = true) : void
      {
         var _loc4_:int = 0;
         var _loc2_:int = int(this.userData.removeCrewTS);
         var _loc3_:int = GlobalEngine.serverTime / 1000;
         if(Boolean(_loc2_) && _loc3_ >= _loc2_)
         {
            if(Boolean(this.userData.crewInfo) && Boolean(this.userData.crewInfo as Array) && Boolean(this.userData.crewInfo.length))
            {
               this.userData.crewInfo.splice(0,1);
               if(!this.userData.crewInfo.length)
               {
                  delete this.userData.crewInfo;
               }
               if(param1)
               {
                  this.dispatchCrewChangedEvent();
               }
            }
            _loc4_ = CrewManager.instance.getCrewRemoveDuration(this.gameData);
            if((Boolean(_loc4_)) && Boolean(this.userData.crewInfo as Array) && Boolean(this.userData.crewInfo.length))
            {
               this.userData.removeCrewTS += _loc4_;
            }
            else
            {
               delete this.userData.removeCrewTS;
            }
         }
      }
      
      public function get filledCrewCount() : int
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         if(Boolean(this.userData) && Boolean(this.userData.crewInfo) && Boolean(this.userData.crewInfo as Array))
         {
            _loc2_ = 0;
            while(_loc2_ < this.userData.crewInfo.length)
            {
               if(this.userData.crewInfo[_loc2_] != null)
               {
                  _loc1_++;
               }
               _loc2_++;
            }
         }
         return _loc1_;
      }
      
      public function get crewCount() : int
      {
         if(Boolean(this.userData) && Boolean(this.userData.crewInfo) && Boolean(this.userData.crewInfo as Array))
         {
            return this.userData.crewInfo.length;
         }
         return 0;
      }
      
      private function onTicketAdded(param1:WorldEvent) : void
      {
         var _loc3_:Boolean = false;
         if(!this.userData || !(this.userData.tickets as Array) || !this.userData.tickets.length)
         {
            this.userData.tickets = [];
         }
         var _loc2_:Object = {
            "SNID":param1.eventData.SNID,
            "number":param1.eventData.number,
            "day":param1.eventData.day
         };
         var _loc4_:uint = uint(this.userData.tickets.length);
         var _loc5_:uint = 0;
         while(_loc5_ < _loc4_)
         {
            if(null == this.userData.tickets[_loc5_])
            {
               this.userData.tickets[_loc5_] = _loc2_;
               _loc3_ = true;
               break;
            }
            _loc5_++;
         }
         if(!_loc3_)
         {
            this.userData.tickets.push(_loc2_);
         }
         var _loc6_:Player = ZGlobal.player.findFriendById(param1.eventData.SNID);
         if(_loc6_)
         {
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackRaffleTicketReceived",{"sender":_loc6_.firstName}),null,null,_loc6_.uid);
         }
         RaffleManager.instance.dispatchEvent(new Event(RaffleManager.RE_DRAW));
      }
      
      private function setIDFromWorld() : void
      {
         var _loc1_:int = this.userData ? int(this.userData.id) : 0;
         var _loc2_:IslandWorld = ZGlobal.game.getWorld(IslandWorld.ID) as IslandWorld;
         this.m_id = _loc2_.getUniqueID();
         if(!this.userData)
         {
            this.userData = new Object();
         }
         this.userData.id = this.m_id;
         owner.eventDispatcher.dispatchEvent(new WorldEvent(ID_SET,{
            "oldID":_loc1_,
            "newID":this.m_id
         }));
      }
      
      private function onPurchased(param1:Event) : void
      {
         owner.eventDispatcher.removeEventListener(PurchaseState.PURCHASED,this.onPurchased);
         this.setIDFromWorld();
      }
      
      private function onActionStarted(param1:Event) : void
      {
         this.m_actionActive = true;
      }
      
      private function onActionEnded(param1:Event) : void
      {
         this.m_actionActive = false;
      }
   }
}

