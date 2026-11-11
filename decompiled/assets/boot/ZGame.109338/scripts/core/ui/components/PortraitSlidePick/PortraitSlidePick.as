package core.ui.components.PortraitSlidePick
{
   import as3isolib.geom.Pt;
   import com.greensock.TweenLite;
   import com.greensock.easing.Sine;
   import core.gamemode.GameModeManager;
   import core.gamemode.GridPointer;
   import core.managers.tutorialManager.TutorialManager;
   import core.player.IPVPPlayer;
   import core.ui.PickManager;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import events.IsoViewEvent;
   import fl.containers.UILoader;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import sound.SoundEvent;
   import zgame.assets.ui.NeighborPick;
   import zlabs.Zlab;
   import zlabs.core.InputManager;
   import zlabs.events.WorldEvent;
   
   public class PortraitSlidePick extends EventDispatcher
   {
      
      protected static const PICK_STATUS_HIDDEN:int = 0;
      
      protected static const PICK_STATUS_TWEENSHOW:int = 1;
      
      protected static const PICK_STATUS_SHOWING:int = 2;
      
      protected static const PICK_STATUS_TWEENHIDE:int = 3;
      
      protected static const PICK_STATUS_REJECTED:int = 4;
      
      private static const SLIDE_TWEEN_SECONDS:Number = 0.15;
      
      private static var m_overlappingNeighborPicks:Dictionary = new Dictionary();
      
      public static var ACCEPTED:String = "accepted";
      
      public static var REJECTED:String = "rejected";
      
      public static var PICK_ENTERED:String = "pickEntered";
      
      public static var PICK_EXITED:String = "pickExited";
      
      public static var UPDATE_CHANGES:String = "update_changes";
      
      private var m_status:int;
      
      private var m_cardPosXHidden:Number;
      
      private var m_cardPosXShowing:Number;
      
      private var m_ignoreMousePermanent:Boolean;
      
      protected var m_pick:MovieClip = null;
      
      protected var m_neighbor:IPVPPlayer;
      
      private var m_imageLoader:ImageLoader;
      
      public function PortraitSlidePick(param1:IPVPPlayer, param2:Number)
      {
         super();
         this.m_neighbor = param1;
         this.createPickAsset(param1,param2);
         PickManager.instance.addEventListener(PickManager.PICKS_ACTIVE_UPDATED,this.onPicksActiveUpdated,false,0,true);
         PickManager.instance.addEventListener(PickManager.SELECT_PICKS_UPDATED,this.onPicksActiveUpdated,false,0,true);
      }
      
      public function dispose() : void
      {
         Zlab.processManager.removeScheduledObject(this);
         this.pickExited();
         this.removeMouseEventListeners();
         GameModeManager.instance.removeEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onZoom);
         PickManager.instance.removeEventListener(PickManager.PICKS_ACTIVE_UPDATED,this.onPicksActiveUpdated);
         PickManager.instance.removeEventListener(PickManager.SELECT_PICKS_UPDATED,this.onPicksActiveUpdated);
         TweenLite.killTweensOf(this.slideCard);
         this.onDispose();
         if(this.m_pick)
         {
            if(this.m_pick.parent)
            {
               this.m_pick.parent.removeChild(this.m_pick);
            }
            this.m_pick = null;
         }
      }
      
      public function set position(param1:Pt) : void
      {
         this.m_pick.x = param1.x + this.xOffset;
         this.m_pick.y = param1.y + this.yOffset;
      }
      
      public function get mc() : MovieClip
      {
         return this.m_pick;
      }
      
      public function ignoreMouseInput() : void
      {
         this.m_ignoreMousePermanent = true;
         this.removeMouseEventListeners();
      }
      
      protected function get ignoringMouseInput() : Boolean
      {
         return this.m_ignoreMousePermanent;
      }
      
      public function bringToFront() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(Boolean(this.m_pick) && Boolean(this.m_pick.parent))
         {
            _loc1_ = this.m_pick.parent.numChildren;
            if(_loc1_ > 1)
            {
               _loc2_ = _loc1_ - 1;
               this.m_pick.parent.setChildIndex(this.m_pick,_loc2_);
            }
         }
      }
      
      protected function setPickZoom(param1:Number) : void
      {
         var _loc2_:Number = 1 / param1;
         this.m_pick.scaleX = this.m_pick.scaleY = _loc2_;
      }
      
      protected function getPickClass() : Class
      {
         return NeighborPick;
      }
      
      protected function get slideCard() : MovieClip
      {
         return this.mc.card_mc;
      }
      
      protected function get portraitBubble() : MovieClip
      {
         return this.mc.bubble;
      }
      
      protected function get xOffset() : int
      {
         return 0;
      }
      
      protected function get yOffset() : int
      {
         return -60;
      }
      
      protected function onDispose() : void
      {
      }
      
      protected function onCreatePickAsset(param1:IPVPPlayer) : void
      {
      }
      
      protected function get portraitUILoader() : UILoader
      {
         return this.portraitBubble.portrait_mc;
      }
      
      protected function hidePick(param1:Event) : void
      {
         this.onStopPropagation(param1);
         this.ignoreMouseInput();
         this.pickExited();
      }
      
      protected function hide() : void
      {
         TweenLite.to(this.slideCard,SLIDE_TWEEN_SECONDS,{
            "x":this.m_cardPosXHidden,
            "ease":Sine.easeInOut,
            "onComplete":this.cardTweenComplete
         });
         if(this.m_status == PICK_STATUS_SHOWING)
         {
            this.slideCard.mouseEnabled = false;
         }
         this.m_status = PICK_STATUS_TWEENHIDE;
         SoundEvent.getSoundEvent("windowClose").play();
      }
      
      protected function get status() : int
      {
         return this.m_status;
      }
      
      protected function set status(param1:int) : void
      {
         this.m_status = param1;
      }
      
      protected function getPortraitURL(param1:IPVPPlayer) : String
      {
         return param1 ? param1.portraitURL : "";
      }
      
      private function createPickAsset(param1:IPVPPlayer, param2:Number) : void
      {
         var _loc3_:Class = this.getPickClass();
         this.m_pick = new _loc3_();
         this.hideStrikeTeamAssets();
         this.m_status = PICK_STATUS_HIDDEN;
         this.m_cardPosXShowing = this.slideCard.x;
         this.m_cardPosXHidden = this.m_cardPosXShowing - this.slideCard.width;
         this.slideCard.visible = false;
         this.slideCard.x = this.m_cardPosXHidden;
         this.slideCard.mouseEnabled = false;
         this.onCreatePickAsset(param1);
         this.setPickZoom(param2);
         this.UpdatePotraitPicture();
         TutorialManager.instance.registerUIItem(this.portraitBubble,"PVPPortrait");
         this.onPicksActiveUpdated();
         GameModeManager.instance.addEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onZoom,false,0,true);
      }
      
      protected function UpdatePotraitPicture() : void
      {
         this.DisposeImageLoader();
         this.m_imageLoader = ImageLoaderFactory.CreateImageLoader(this.getPortraitURL(this.m_neighbor),this.portraitUILoader,this.onPortraitLoaded);
      }
      
      private function DisposeImageLoader() : void
      {
         if(this.m_imageLoader)
         {
            this.m_imageLoader.destroy();
            this.m_imageLoader = null;
         }
      }
      
      protected function hasStrikeTeamAssets() : Boolean
      {
         if(Boolean(this.m_pick && this.m_pick.bubble && this.m_pick.bubble.deploy_btn) && Boolean(this.slideCard) && Boolean(this.slideCard.missionTab_mc))
         {
            return true;
         }
         return false;
      }
      
      private function hideStrikeTeamAssets() : void
      {
         if(this.m_pick.bubble)
         {
            if(this.m_pick.bubble.deploy_btn)
            {
               this.m_pick.bubble.deploy_btn.visible = false;
            }
            if(this.m_pick.bubble.pickGlow)
            {
               this.m_pick.bubble.pickGlow.visible = false;
            }
            if(this.m_pick.bubble.bulletHoles_mc)
            {
               this.m_pick.bubble.bulletHoles_mc.visible = false;
            }
            if(this.m_pick.bubble.player)
            {
               if(this.m_pick.bubble.player.mindControlSwirl_mc)
               {
                  this.m_pick.bubble.player.mindControlSwirl_mc.visible = false;
               }
            }
         }
         if(this.slideCard.missionTab_mc)
         {
            this.slideCard.missionTab_mc.visible = false;
         }
      }
      
      private function addMouseEventListeners() : void
      {
         this.portraitBubble.addEventListener(MouseEvent.MOUSE_DOWN,this.onStopPropagation,false,0,true);
         this.portraitBubble.addEventListener(MouseEvent.MOUSE_UP,this.onStopPropagation,false,0,true);
         this.portraitBubble.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
         this.portraitBubble.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
         this.portraitBubble.addEventListener(MouseEvent.MOUSE_MOVE,this.onStopPropagation,false,0,true);
         this.portraitBubble.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         this.slideCard.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
         this.slideCard.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
         this.slideCard.addEventListener(MouseEvent.MOUSE_MOVE,this.onStopPropagation,false,0,true);
      }
      
      private function pickEntered() : void
      {
         if(this.neighborID == null)
         {
            return;
         }
         if(!m_overlappingNeighborPicks[this.neighborID])
         {
            m_overlappingNeighborPicks[this.neighborID] = true;
            InputManager.disableButtonInput();
            GridPointer.instance.hide = true;
            dispatchEvent(new WorldEvent(PICK_ENTERED));
         }
      }
      
      protected function pickExited() : void
      {
         if(this.neighborID == null)
         {
            return;
         }
         if(m_overlappingNeighborPicks[this.neighborID])
         {
            delete m_overlappingNeighborPicks[this.neighborID];
            InputManager.enableButtonInput();
            GridPointer.instance.hide = false;
            dispatchEvent(new WorldEvent(PICK_EXITED));
         }
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         if(PickManager.selectPicks)
         {
            return;
         }
         Zlab.processManager.removeScheduledObject(this);
         GameModeManager.instance.getTopGameMode().deselect();
         if(this.m_status == PICK_STATUS_HIDDEN || this.m_status == PICK_STATUS_TWEENHIDE)
         {
            this.bringToFront();
            this.show();
         }
         this.pickEntered();
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         if(this.m_status == PICK_STATUS_SHOWING || this.m_status == PICK_STATUS_TWEENSHOW)
         {
            Zlab.processManager.schedule(100,this,this.onMouseLeft);
         }
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         if(PickManager.selectPicks)
         {
            this.onPickClicked();
         }
      }
      
      protected function onPickClicked() : void
      {
      }
      
      private function onMouseLeft() : void
      {
         this.hide();
         this.pickExited();
      }
      
      protected function removeMouseEventListeners() : void
      {
         this.portraitBubble.removeEventListener(MouseEvent.MOUSE_DOWN,this.onStopPropagation);
         this.portraitBubble.removeEventListener(MouseEvent.MOUSE_UP,this.onStopPropagation);
         this.portraitBubble.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.portraitBubble.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.portraitBubble.removeEventListener(MouseEvent.MOUSE_MOVE,this.onStopPropagation);
         this.slideCard.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.slideCard.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.slideCard.removeEventListener(MouseEvent.MOUSE_MOVE,this.onStopPropagation);
      }
      
      protected function onStopPropagation(param1:Event) : void
      {
         param1.stopPropagation();
         param1.stopImmediatePropagation();
      }
      
      private function show() : void
      {
         this.slideCard.visible = true;
         TweenLite.to(this.slideCard,SLIDE_TWEEN_SECONDS,{
            "x":this.m_cardPosXShowing,
            "ease":Sine.easeInOut,
            "onComplete":this.cardTweenComplete
         });
         this.m_status = PICK_STATUS_TWEENSHOW;
         SoundEvent.getSoundEvent("windowOpen").play();
      }
      
      private function cardTweenComplete() : void
      {
         if(this.m_status == PICK_STATUS_TWEENSHOW)
         {
            this.m_status = PICK_STATUS_SHOWING;
            this.slideCard.mouseEnabled = true;
         }
         else if(this.m_status == PICK_STATUS_TWEENHIDE)
         {
            this.m_status = PICK_STATUS_HIDDEN;
            this.slideCard.visible = false;
         }
      }
      
      private function onZoom(param1:IsoViewEvent) : void
      {
         this.setPickZoom(param1.value);
      }
      
      protected function get neighborID() : String
      {
         return this.m_neighbor ? this.m_neighbor.uid : "";
      }
      
      private function onPortraitLoaded(param1:String, param2:BitmapData) : void
      {
         if(TutorialManager.instance.active && TutorialManager.instance.pvpTutorialMode)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.PVP_MARKER_LOADED));
         }
      }
      
      protected function enableChanges() : void
      {
      }
      
      private function onPicksActiveUpdated(param1:Event = null) : void
      {
         if(PickManager.enabled)
         {
            if(!this.m_ignoreMousePermanent)
            {
               this.addMouseEventListeners();
            }
            this.enableChanges();
            this.mc.alpha = 1;
         }
         else
         {
            this.removeMouseEventListeners();
            this.mc.alpha = 0.15;
         }
      }
   }
}

