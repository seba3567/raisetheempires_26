package core.entities.components
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.gameobjects.GameItem;
   import core.managers.CrewManager;
   import core.managers.MatchMakingManager;
   import core.managers.WorldResourceManager;
   import core.player.IPVPPlayer;
   import core.ui.ZGameButton;
   import core.ui.components.PortraitSlidePick.PortraitSlidePick;
   import dispatchers.UIDispatcher;
   import displays.ImageLoaderFactory;
   import displays.screens.CrewResizablePopUp;
   import displays.screens.MatchMakingScreen;
   import entity.GameDataComponent;
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.entity.IEntity;
   
   public class ParliamentPick extends PortraitSlidePick
   {
      
      protected var m_pickClass:Class;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var pickPlayerInfo:Object;
      
      private var m_window:PopUpBase;
      
      private var m_button:ZGameButton;
      
      public function ParliamentPick(param1:Number, param2:Class)
      {
         this.m_pickClass = param2;
         super(null,param1);
      }
      
      override protected function getPickClass() : Class
      {
         return this.m_pickClass;
      }
      
      override protected function onCreatePickAsset(param1:IPVPPlayer) : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:ZGameButton = null;
         var _loc2_:MovieClip = m_pick.card_mc;
         TextFieldUtil.compactTextField(_loc2_.title_tf,ZGameUtils.ZlocT("Items","WorldParliamentLabel"));
         TextFieldUtil.compactTextField(_loc2_.body01_tf,ZGameUtils.ZlocT("Main","LevelLabel"));
         TextFieldUtil.compactTextField(_loc2_.body02_tf,ZGameUtils.ZlocT("Main","MinesLabel"));
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         _loc3_ = _loc2_.green_btn;
         _loc4_ = new ZGameButton(_loc3_,this.onAddMe);
         this.m_button = _loc4_;
         _loc4_.sounds = ButtonSound.DEFAULT;
         TextFieldUtil.compactTextField(_loc3_.generic_tf,ZGameUtils.ZlocT("Dialogs","AddMeButton"));
         this.m_buttonSounds.addButton(_loc3_,ButtonSound.DEFAULT);
         if(!MatchMakingManager.instance.optIn)
         {
            _loc4_.disable_visual(true);
            UIDispatcher.instance.addEventListener(MatchMakingManager.MATCHMAKING_OPTIN,this.onOptIn,false,0,true);
         }
         _loc3_ = _loc2_.orange_btn;
         _loc4_ = new ZGameButton(_loc3_,this.onSeeMore);
         _loc4_.sounds = ButtonSound.DEFAULT;
         TextFieldUtil.compactTextField(_loc3_.generic_tf,ZGameUtils.ZlocT("Dialogs","SeeMoreButton"));
         this.m_buttonSounds.addButton(_loc3_,ButtonSound.DEFAULT);
         this.UpdatePickPlayer();
      }
      
      private function onOptIn(param1:Event) : void
      {
         if(this.m_button)
         {
            this.m_button.enable();
         }
         UIDispatcher.instance.removeEventListener(MatchMakingManager.MATCHMAKING_OPTIN,this.onOptIn);
      }
      
      private function GetUninvitedMMPlayerInfo() : Object
      {
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:Boolean = false;
         var _loc1_:Array = new Array();
         var _loc2_:Array = ZGlobal.player.matchmakingFriends;
         var _loc4_:int = int(_loc2_.length);
         var _loc6_:int = int(ZGlobal.player.pendingNeighbors.length);
         _loc3_ = 0;
         while(_loc3_ < _loc4_)
         {
            _loc7_ = false;
            _loc5_ = 0;
            while(_loc5_ < _loc6_)
            {
               if(_loc2_[_loc3_] == ZGlobal.player.pendingNeighbors[_loc5_])
               {
                  break;
               }
               _loc5_++;
            }
            if(_loc5_ == _loc6_)
            {
               return MatchMakingManager.instance.getMMFriendInfo(_loc2_[_loc3_]);
            }
            _loc3_++;
         }
         return null;
      }
      
      public function UpdatePickPlayer() : void
      {
         this.pickPlayerInfo = this.GetUninvitedMMPlayerInfo();
         if(this.pickPlayerInfo == null)
         {
            MatchMakingManager.instance.HidePick();
            return;
         }
         var _loc1_:MovieClip = m_pick.bubble;
         TextFieldUtil.compactTextField(_loc1_.generic_tf,this.pickPlayerInfo.name);
         var _loc2_:MovieClip = m_pick.card_mc;
         TextFieldUtil.compactTextField(_loc2_.profilelevel_tf,this.pickPlayerInfo.level);
         var _loc3_:String = this.pickPlayerInfo.country ? this.pickPlayerInfo.country : ZGameUtils.ZlocT("Dialogs","Unknown");
         var _loc4_:String = this.GetEngagementTextKey(this.pickPlayerInfo.engagement_7day);
         var _loc5_:String = ZGameUtils.ZlocT("Dialogs",_loc4_,{"country":_loc3_});
         TextFieldUtil.compactTextField(_loc2_.body03_tf,_loc5_,{"minScale":0.6});
         var _loc6_:String = WorldResourceManager.instance.getResourceImageURL(this.pickPlayerInfo.resource,WorldResourceManager.XTRA_SMALL_ICON);
         ImageLoaderFactory.CreateImageLoader(_loc6_,_loc2_.ore_mc);
         UpdatePotraitPicture();
      }
      
      private function GetEngagementTextKey(param1:Number) : String
      {
         if(param1 == 7)
         {
            return "MMEngagement7";
         }
         if(param1 == 6)
         {
            return "MMEngagement6";
         }
         if(param1 >= 4)
         {
            return "MMEngagement4_5";
         }
         return "MMEngagement1_3";
      }
      
      private function onAddMe(param1:MouseEvent) : void
      {
         super.hide();
         StatsManager.count("MatchMaking","shuck","Friend_Request");
         MatchMakingManager.instance.addNeighbor(this.pickPlayerInfo.uid);
      }
      
      private function onSeeMore(param1:MouseEvent) : void
      {
         var _loc2_:IEntity = ZGameUtils.getBuildingByCode("CA2");
         var _loc3_:GameItem = ZGlobal.gameSettings.getItemByCode("CA2",GameItem) as GameItem;
         var _loc4_:GameDataComponent = GameDataComponent(_loc2_.lookupComponentByType(GameDataComponent));
         var _loc5_:Object = _loc4_.userData;
         this.m_window = MatchMakingScreen.display(_loc2_,_loc3_,_loc5_);
         this.m_window.addEventListener(CrewResizablePopUp.BUILT,this.onBuilt,false,0,true);
      }
      
      public function onBuilt(param1:Event) : void
      {
         var _loc3_:BuildingFSMComponent = null;
         var _loc4_:BehaviorStateMachine = null;
         var _loc2_:IEntity = ZGameUtils.getBuildingByCode("CA2");
         if(Boolean(_loc2_) && CrewManager.isCrewBuildingFull(_loc2_))
         {
            this.m_window.removeEventListener(CrewResizablePopUp.BUILT,this.onBuilt);
            _loc3_ = BuildingFSMComponent(_loc2_.lookupComponentByType(BuildingFSMComponent));
            _loc4_ = BehaviorStateMachine(_loc3_.stateMachine);
            BehaviorState(_loc4_.currentState).clickNextState();
         }
      }
      
      override protected function getPortraitURL(param1:IPVPPlayer) : String
      {
         return this.pickPlayerInfo ? this.pickPlayerInfo.picture_url : "";
      }
      
      override protected function get neighborID() : String
      {
         return "0";
      }
      
      override protected function get portraitUILoader() : UILoader
      {
         return portraitBubble.player.portrait_mc;
      }
      
      override protected function get xOffset() : int
      {
         return 30;
      }
      
      override protected function get yOffset() : int
      {
         return -170;
      }
      
      override protected function onDispose() : void
      {
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         m_pick.card_mc.green_btn.removeEventListener(MouseEvent.CLICK,this.onAddMe);
         m_pick.card_mc.orange_btn.removeEventListener(MouseEvent.CLICK,this.onSeeMore);
      }
   }
}

