package core.entities.components
{
   import as3isolib.geom.Pt;
   import core.gamemode.GameModeManager;
   import core.managers.RaffleManager;
   import core.ui.PickManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import displays.popups.MOTDCountdownClock;
   import events.IsoViewEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.rendering.renderingISO.IsoSpriteComponent;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   
   public class RafflePick extends EventDispatcher
   {
      
      protected var m_clock:MOTDCountdownClock;
      
      protected var m_isRaffleDay:Boolean;
      
      protected var m_owner:IEntity;
      
      private var m_pick:MovieClip;
      
      public function RafflePick(param1:IEntity, param2:Class, param3:Boolean)
      {
         super();
         this.m_isRaffleDay = param3;
         this.m_owner = param1;
         this.createPickAsset(param2);
         param1.eventDispatcher.addEventListener(IsoSpriteComponent.UPDATE_SPRITE,this.onUpdateSprite,false,0,true);
      }
      
      private function onUpdateSprite(param1:Event = null) : void
      {
         this.updatePosition();
      }
      
      public function updatePosition() : void
      {
         var _loc1_:BuildingSpatialComponent = BuildingSpatialComponent(this.m_owner.lookupComponentByType(BuildingSpatialComponent));
         var _loc2_:Pt = Pt.toPt(_loc1_.position);
         var _loc3_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         _loc3_.isoView.isoToLocal(_loc2_);
         this.position = _loc2_;
      }
      
      public function set position(param1:Pt) : void
      {
         this.m_pick.x = param1.x;
         this.m_pick.y = param1.y + this.yOffset;
      }
      
      protected function get yOffset() : int
      {
         return -100;
      }
      
      public function get mc() : MovieClip
      {
         return this.m_pick;
      }
      
      private function createPickAsset(param1:Class) : void
      {
         this.m_pick = new param1();
         if(this.m_isRaffleDay)
         {
            this.m_pick.ticketInnards_mc.clock_mc.visible = false;
            this.m_pick.ticketInnards_mc.generic_tf.visible = false;
            TextFieldUtil.compactTextField(this.m_pick.ticketInnards_mc.raffleDay_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Pick_2"));
            this.m_pick.ticketInnards_mc.raffleDay_tf.visible = true;
         }
         else
         {
            this.m_pick.ticketInnards_mc.raffleDay_tf.visible = false;
            this.m_pick.ticketInnards_mc.clock_mc.visible = true;
            this.m_clock = new MOTDCountdownClock(this.m_pick.ticketInnards_mc.clock_mc,RaffleManager.instance.collectDateRange,true,false,false,86400);
            TextFieldUtil.compactTextField(this.m_pick.ticketInnards_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","Raffle_Pick_1"));
            this.m_pick.ticketInnards_mc.generic_tf.visible = true;
         }
         if(Boolean(this.m_pick.player) && Boolean(this.m_pick.player.mindControlSwirl_mc))
         {
            this.m_pick.player.mindControlSwirl_mc.visible = false;
         }
         var _loc2_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         this.setPickZoom(_loc2_.isoView.currentZoom);
         GameModeManager.instance.addEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onZoom,false,0,true);
         this.m_pick.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
         PickManager.instance.addEventListener(PickManager.PICKS_ACTIVE_UPDATED,this.onPicksActiveUpdated,false,0,true);
      }
      
      private function onZoom(param1:IsoViewEvent) : void
      {
         this.setPickZoom(param1.value);
      }
      
      private function setPickZoom(param1:Number) : void
      {
         var _loc2_:Number = 1 / param1;
         this.m_pick.scaleX = this.m_pick.scaleY = _loc2_;
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         this.bringToFront();
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
      
      private function onPicksActiveUpdated(param1:Event = null) : void
      {
         if(PickManager.enabled)
         {
            this.mc.mouseEnabled = true;
            this.mc.mouseChildren = true;
            this.mc.alpha = 1;
         }
         else
         {
            this.mc.mouseEnabled = false;
            this.mc.mouseChildren = false;
            this.mc.alpha = 0.15;
         }
      }
      
      public function dispose() : void
      {
         GameModeManager.instance.removeEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onZoom);
         this.m_pick.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.m_owner.eventDispatcher.removeEventListener(IsoSpriteComponent.UPDATE_SPRITE,this.onUpdateSprite);
         if(this.m_pick)
         {
            if(this.m_pick.parent)
            {
               this.m_pick.parent.removeChild(this.m_pick);
            }
            this.m_pick = null;
         }
         PickManager.instance.removeEventListener(PickManager.PICKS_ACTIVE_UPDATED,this.onPicksActiveUpdated);
      }
   }
}

