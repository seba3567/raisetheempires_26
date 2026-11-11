package displays.screens
{
   import core.ZGlobal;
   import core.gameobjects.CrewTemplateWrapper;
   import core.managers.CrewManager;
   import core.managers.ExperimentsManager;
   import core.managers.viralsManager.ViralsManager;
   import core.player.Player;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class CrewGatherSlot extends Sprite
   {
      
      protected static var ACTION_NONE:int = 0;
      
      protected static var ACTION_REMIND:int = 1;
      
      protected static var ACTION_INVITE:int = 2;
      
      protected static var ACTION_BUY:int = 3;
      
      private static var SLOT_STATE_EMPTY:int = 0;
      
      private static var SLOT_STATE_NPC:int = 1;
      
      private static var SLOT_STATE_PC:int = 2;
      
      public static const CREW_ACTION_MODE_REPLACE:String = "CREW_ACTION_MODE_REPLACE";
      
      protected var m_dispatcher:EventDispatcher;
      
      protected var m_index:int;
      
      protected var m_wrapper:CrewTemplateWrapper;
      
      protected var m_slot:MovieClip;
      
      protected var m_imageLoader:ImageLoader;
      
      protected var m_actionButton:ZGameButton;
      
      protected var m_action:int = ACTION_NONE;
      
      protected var m_player:Player;
      
      private var m_listenersAdded:Boolean = false;
      
      private var m_crewActionMode:String = "";
      
      private var m_replaceCrewFilter:GlowFilter;
      
      public function CrewGatherSlot(param1:EventDispatcher, param2:Class, param3:int, param4:CrewTemplateWrapper)
      {
         super();
         this.m_dispatcher = param1;
         this.m_index = param3;
         this.m_wrapper = param4;
         this.m_slot = new param2();
         if(this.m_slot.invite_bt)
         {
            this.m_slot.invite_bt.visible = false;
         }
         if(this.m_slot.orange_bt)
         {
            this.m_slot.orange_bt.visible = false;
         }
         if(this.m_slot.green_bt)
         {
            this.m_slot.green_bt.visible = false;
         }
         if(this.m_slot.finish_bt)
         {
            this.m_slot.finish_bt.visible = false;
         }
         if(this.m_slot.visit_counter_mc)
         {
            this.m_slot.visit_counter_mc.visible = false;
            this.m_slot.visit_counter_mc.mouseChildren = false;
            this.m_slot.visit_counter_mc.mouseEnabled = false;
         }
         if(this.m_slot.star_mc)
         {
            this.m_slot.star_mc.visible = false;
            this.m_slot.star_mc.mouseChildren = false;
            this.m_slot.star_mc.mouseEnabled = false;
         }
         addChild(this.m_slot);
      }
      
      public function get owner() : IEntity
      {
         var _loc1_:CrewGather = this.m_dispatcher as CrewGather;
         if(_loc1_)
         {
            return _loc1_.owner;
         }
         return null;
      }
      
      public function update(param1:String, param2:ButtonMouseEventSoundContainer) : void
      {
         var _loc3_:String = null;
         var _loc7_:String = null;
         this.m_slot.profileloader_mc.mouseEnabled = false;
         this.m_slot.profileloader_mc.mouseChildren = false;
         var _loc4_:String = this.m_wrapper.getPositionName(this.m_index);
         var _loc5_:Player = ZGlobal.player.findFriendById(param1);
         var _loc6_:Object = ZGlobal.player.findNonFriendById(param1);
         if(_loc5_)
         {
            _loc3_ = this.initCardWithPlayerInfo(_loc5_.snUser.picture,_loc5_.firstName,_loc5_.snUser.gender,_loc4_);
         }
         else if(_loc6_)
         {
            _loc3_ = this.initCardWithPlayerInfo(_loc6_.pic,_loc6_.first_name,_loc6_.sex,_loc4_);
         }
         else
         {
            this.clearCardPortrait();
            if(ZGlobal.isVisiting() && CrewManager.canPlayerJoinCrew(this.owner,ZGlobal.player.uid))
            {
               _loc7_ = ZGameUtils.ZlocT("Dialogs","CrewDialogFillPositionSubtitle");
               TextFieldUtil.compactTextField(this.m_slot.fillPosition_mc.count_tf,_loc7_);
               this.m_slot.fillPosition_mc.count_tf.visible = true;
            }
            else
            {
               this.m_slot.fillPosition_mc.count_tf.visible = false;
            }
            _loc3_ = this.getPositionFriendlyName(_loc4_);
         }
         if(_loc3_)
         {
            TextFieldUtil.compactTextField(this.m_slot.itemName_tf,_loc3_,{"minScale":0.6});
         }
         else
         {
            TextFieldUtil.compactTextField(this.m_slot.itemName_tf,_loc4_ + "_friendlyName",{"minScale":0.6});
         }
         this.updateContextSensitiveElements(_loc5_,param2);
         this.updatePortrait(_loc5_);
      }
      
      protected function getPositionFriendlyName(param1:String) : String
      {
         return ZGameUtils.ZlocT("Crews",param1 + "_menuName",{"user":ZGameUtils.ZlocTn("",ZGlobal.localizer.MASC)});
      }
      
      protected function getPositionFilledFriendlyName(param1:String, param2:String) : String
      {
         return ZGameUtils.ZlocT("Crews",param1 + "_menuName",{"user":ZGameUtils.ZlocTn("",param2 == "F" ? ZGlobal.localizer.FEM : ZGlobal.localizer.MASC)});
      }
      
      public function get cash() : int
      {
         return this.m_wrapper.price;
      }
      
      public function get positionName() : String
      {
         return this.m_wrapper.getPositionName(this.m_index);
      }
      
      public function dispose() : void
      {
         this.removePortraitEventListeners();
         this.disposeActionButton();
         if(Boolean(this.m_slot) && Boolean(this.m_slot.parent))
         {
            this.m_slot.parent.removeChild(this.m_slot);
         }
         this.m_slot = null;
         this.disposeImageLoader();
      }
      
      protected function get portraitMC() : MovieClip
      {
         return this.m_slot.fillPosition_mc;
      }
      
      private function removePortraitEventListeners() : void
      {
         this.portraitMC.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this.portraitMC.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         this.portraitMC.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         this.portraitMC.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         this.m_listenersAdded = false;
         this.portraitMC.buttonMode = false;
      }
      
      private function addPortraitEventListeners() : void
      {
         this.portraitMC.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         this.portraitMC.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         this.portraitMC.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         this.portraitMC.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
         this.m_listenersAdded = true;
         this.portraitMC.buttonMode = true;
      }
      
      public function setButtonReplaceMode() : void
      {
         this.m_crewActionMode = CREW_ACTION_MODE_REPLACE;
         Tooltip.unsubscribe(this);
         Tooltip.subscribe(this,ZGameUtils.ZlocT("Main","ReplaceCrewMember_Tooltip"));
      }
      
      public function setButtonResendReplaceMode() : void
      {
         this.m_crewActionMode = CREW_ACTION_MODE_REPLACE;
         Tooltip.unsubscribe(this);
         Tooltip.subscribe(this,ZGameUtils.ZlocT("Main","PendingReplaceCrewMember_Tooltip"));
      }
      
      private function addReplaceFilter(param1:uint) : void
      {
         var _loc2_:Array = null;
         this.m_replaceCrewFilter = new GlowFilter(param1);
         _loc2_ = [];
         _loc2_ = _loc2_.concat(filters);
         _loc2_.push(this.m_replaceCrewFilter);
         filters = _loc2_;
      }
      
      protected function updatePortrait(param1:Player) : void
      {
         var _loc2_:Boolean = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REPLACE_CREW) == ExperimentsManager.VARIANT_VALUE_REPLACE_CREW_ON;
         this.m_player = param1;
         if(Boolean(this.m_player && this.m_player.uid != Player.FAKE_PLAYER_ID && this.enableReplaceableTooltip()) && Boolean(_loc2_) || !this.m_player && this.enablePortraits())
         {
            if(this.m_listenersAdded)
            {
               this.removePortraitEventListeners();
            }
            this.addPortraitEventListeners();
         }
         else if(this.m_listenersAdded)
         {
            this.removePortraitEventListeners();
         }
      }
      
      protected function overrideActionButtonDisplay() : Boolean
      {
         return false;
      }
      
      protected function shouldShowActionButton() : Boolean
      {
         return this.m_action != ACTION_NONE;
      }
      
      private function getButtonText() : String
      {
         if(this.m_action == ACTION_INVITE)
         {
            return ZGameUtils.ZlocT("Crews","AddNeighbor");
         }
         if(this.m_action == ACTION_BUY)
         {
            return ZGameUtils.ZlocT("Dialogs","CrewDialogBuyButtonText",{"cash":this.cash});
         }
         if(this.m_action == ACTION_REMIND)
         {
            return ZGameUtils.ZlocT("Dialogs","RemindButton");
         }
         return "";
      }
      
      protected function get actionButtonMC() : MovieClip
      {
         switch(this.m_action)
         {
            case ACTION_BUY:
               return this.m_slot.finish_bt;
            case ACTION_INVITE:
               return this.m_slot.invite_bt;
            default:
               return this.m_slot.green_bt;
         }
      }
      
      protected function get compactText() : Boolean
      {
         return this.m_action == ACTION_INVITE;
      }
      
      protected function initActionButton(param1:ButtonMouseEventSoundContainer) : void
      {
         var _loc2_:MovieClip = this.actionButtonMC;
         _loc2_.visible = true;
         this.m_actionButton = new ZGameButton(_loc2_,this.onActionButtonClicked);
         this.m_actionButton.buttonValue = String(this.m_index);
         if(this.compactText)
         {
            this.m_actionButton.compactText(this.getButtonText(),{
               "maxLines":2,
               "minScale":0.5,
               "onFail":"return"
            });
         }
         else
         {
            this.m_actionButton.text = this.getButtonText();
         }
         param1.addButton(this.m_actionButton.m_overlay,ButtonSound.DEFAULT);
      }
      
      private function disposeActionButton() : void
      {
         if(this.m_actionButton)
         {
            this.m_actionButton.dispose();
            this.m_actionButton = null;
         }
      }
      
      protected function updateAction() : void
      {
      }
      
      protected function updateContextSensitiveElements(param1:Player, param2:ButtonMouseEventSoundContainer) : void
      {
         var _loc3_:Boolean = false;
         this.updateAction();
         if(this.overrideActionButtonDisplay())
         {
            _loc3_ = this.shouldShowActionButton();
            if(_loc3_ && !this.m_actionButton)
            {
               this.initActionButton(param2);
            }
            else if(!_loc3_)
            {
               this.disposeActionButton();
            }
         }
         else if(param1)
         {
            this.disposeActionButton();
            this.actionButtonMC.visible = false;
         }
         else if(!param1 && !this.m_actionButton)
         {
            if(this.shouldShowActionButton())
            {
               this.initActionButton(param2);
            }
         }
         else if(this.m_actionButton)
         {
            this.actionButtonMC.visible = true;
            param2.addButton(this.m_actionButton.m_overlay,ButtonSound.DEFAULT);
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         this.portraitMC.gotoAndStop("2");
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         this.portraitMC.gotoAndStop("1");
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         this.portraitMC.gotoAndStop("3");
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         var _loc2_:WorldEvent = null;
         this.portraitMC.gotoAndStop("2");
         if(this.m_player)
         {
            _loc2_ = new WorldEvent(CrewResizablePopUp.SLOT_FULL_CLICKED,{
               "crewMember":this.m_player,
               "slot":this
            });
            this.m_dispatcher.dispatchEvent(_loc2_);
         }
         else
         {
            this.m_dispatcher.dispatchEvent(new Event(CrewResizablePopUp.SLOT_CLICKED));
         }
      }
      
      protected function enablePortraits() : Boolean
      {
         return true;
      }
      
      public function enableReplaceableTooltip() : Boolean
      {
         return false;
      }
      
      protected function onActionButtonClicked(param1:MouseEvent) : void
      {
      }
      
      protected function getPlayerInSlot(param1:int) : Player
      {
         var _loc2_:CrewResizablePopUp = this.m_dispatcher as CrewResizablePopUp;
         if(_loc2_)
         {
            return _loc2_.getPlayerInSlot(param1);
         }
         return null;
      }
      
      protected function playerInSlotInvitable() : Boolean
      {
         var _loc1_:Object = CrewManager.getPlayerIDByCrewIndex(this.owner,this.m_index);
         if(_loc1_.success)
         {
            if(_loc1_.id != Player.FAKE_PLAYER_ID)
            {
               if(_loc1_.id != ZGlobal.player.uid)
               {
                  if(!ZGlobal.player.neighbors[_loc1_.id])
                  {
                     if(ZGlobal.player.findFriendById(_loc1_.id))
                     {
                        return true;
                     }
                  }
               }
            }
         }
         return false;
      }
      
      protected function inviteSlotPlayer() : void
      {
         var _loc1_:Object = null;
         if(this.owner)
         {
            if(this.m_action == CrewGatherSlot.ACTION_INVITE)
            {
               _loc1_ = CrewManager.getPlayerIDByCrewIndex(this.owner,this.m_index);
               if(Boolean(_loc1_.success) && _loc1_.id != Player.FAKE_PLAYER_ID)
               {
                  ViralsManager.instance.sendInviteRequest(ViralsManager.INVITE_REQUEST_SOURCE_CREW_GATHER_SLOT,null,null,[_loc1_.id]);
               }
            }
         }
      }
      
      protected function initCardWithPlayerInfo(param1:String, param2:String, param3:String, param4:String) : String
      {
         this.disposeImageLoader();
         if(param1)
         {
            this.m_imageLoader = ImageLoaderFactory.CreateImageLoader(param1,this.m_slot.profileloader_mc);
            this.m_slot.profileloader_mc.visible = true;
         }
         else
         {
            this.m_slot.profileloader_mc.visible = false;
         }
         this.m_slot.fillPosition_mc.count_tf.visible = true;
         TextFieldUtil.processTextField(this.m_slot.fillPosition_mc.count_tf,param2);
         return this.getPositionFilledFriendlyName(param4,param3);
      }
      
      protected function clearCardPortrait() : void
      {
         this.disposeImageLoader();
         this.m_slot.profileloader_mc.visible = false;
      }
      
      private function disposeImageLoader() : void
      {
         if(this.m_imageLoader)
         {
            this.m_imageLoader.destroy();
            this.m_imageLoader = null;
         }
      }
      
      public function get crewActionMode() : String
      {
         return this.m_crewActionMode;
      }
   }
}

