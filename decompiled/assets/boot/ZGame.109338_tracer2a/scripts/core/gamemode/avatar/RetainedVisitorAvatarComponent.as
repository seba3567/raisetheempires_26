package core.gamemode.avatar
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import as3isolib.display.IsoView;
   import as3isolib.geom.Pt;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.entities.components.BuildingSpatialComponent;
   import core.gameobjects.GameItem;
   import core.managers.PVPManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.visitorManager.VisitorManager;
   import core.player.Player;
   import core.ui.components.PortraitSlidePick.PortraitRetainedSlidePick;
   import core.ui.components.PortraitSlidePick.PortraitRetainedSlidePickTending;
   import core.ui.components.PortraitSlidePick.PortraitSlidePick;
   import flash.events.Event;
   import transactions.TRequestSendGift;
   import transactions.TWorldLoad;
   import zlabs.Zlab;
   import zlabs.entity.EntityComponent;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.renderingISO.IsoSpriteComponent;
   
   public class RetainedVisitorAvatarComponent extends EntityComponent
   {
      
      private static var AVATAR_FADEOUT_TIME:Number = 500;
      
      private var giftType:String = "mysterygift";
      
      private var dGiftType:String = "gift";
      
      private var requestType:String = "recently_played";
      
      private var subtypeCategory:String = "";
      
      private var quest:String = "Q0651";
      
      private var m_visitorPlayer:Player = null;
      
      private var m_pick:PortraitRetainedSlidePickTending = null;
      
      private var m_view:IsoView = null;
      
      private var m_flag:Boolean = true;
      
      public function RetainedVisitorAvatarComponent(param1:Player, param2:GameItem, param3:IsoView)
      {
         super();
         this.m_visitorPlayer = param1;
         this.m_view = param3;
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         this.createMovieClip();
         owner.eventDispatcher.addEventListener(IsoSpriteComponent.UPDATE_SPRITE,this.onUpdate,false,0,true);
      }
      
      protected function onUpdate(param1:Event) : void
      {
         this.updatePosition();
      }
      
      private function updatePosition() : void
      {
         var _loc1_:BuildingSpatialComponent = BuildingSpatialComponent(owner.lookupComponentByType(BuildingSpatialComponent));
         var _loc2_:Pt = Pt.toPt(_loc1_.position);
         this.m_view.isoToLocal(_loc2_);
         this.m_pick.position = _loc2_;
      }
      
      private function createMovieClip() : void
      {
         this.m_pick = new PortraitRetainedSlidePickTending(this.m_visitorPlayer,this.m_view.currentZoom);
         this.m_pick.addEventListener(PortraitRetainedSlidePick.VISIT,this.onVisit,false,0,true);
         this.m_pick.addEventListener(PortraitRetainedSlidePick.GiftAndDismiss,this.onGiftAndDismiss,false,0,true);
         this.m_pick.addEventListener(PortraitSlidePick.PICK_ENTERED,this.onPickEntered,false,0,true);
         this.m_pick.addEventListener(PortraitSlidePick.PICK_EXITED,this.onPickExited,false,0,true);
         this.updatePosition();
         this.m_view.foregroundContainer.addChild(this.m_pick.mc);
      }
      
      private function onVisit(param1:Event) : void
      {
         if(ZGlobal.player.didCompleteQuest(this.quest))
         {
            this.visitNeighbor(this.m_visitorPlayer.uid,PVPManager.VISIT_MODE_NONE,TWorldLoad.DBG_VISIT,false,null);
            this.m_flag = true;
            this.startFadeOut();
         }
         else
         {
            TutorialManager.instance.showInvalidVisitPopup();
            this.m_flag = false;
            this.startFadeOut();
         }
      }
      
      private function onGiftAndDismiss(param1:Event) : void
      {
         StatsManager.count("game_actions","retainneighbor","giftclose");
         var _loc2_:Array = [this.m_visitorPlayer.uid];
         TransactionManager.addTransaction(new TRequestSendGift(_loc2_,this.giftType,this.dGiftType,this.requestType,this.subtypeCategory));
         this.m_flag = true;
         this.startFadeOut();
      }
      
      private function onPickEntered(param1:Event) : void
      {
      }
      
      private function onPickExited(param1:Event) : void
      {
      }
      
      private function startFadeOut() : void
      {
         Zlab.processManager.schedule(AVATAR_FADEOUT_TIME,this,this.onFadeoutEnded);
         TweenLite.to(this.m_pick.mc,AVATAR_FADEOUT_TIME * 0.001,{"alpha":0});
      }
      
      private function onFadeoutEnded() : void
      {
         var _loc1_:WorldEvent = new WorldEvent(VisitorManager.RETAIN_VISITS_DONE,{
            "id":this.m_visitorPlayer.uid,
            "mflag":this.m_flag
         });
         VisitorManager.instance.dispatchEvent(_loc1_);
      }
      
      private function visitNeighbor(param1:String, param2:int, param3:int, param4:Boolean = false, param5:String = null) : void
      {
         StatsManager.count("game_actions","retainneighbor","visit");
         TransactionManager.addTransaction(new TWorldLoad(param1,param2,{
            "dbg":param3,
            "ctx":param5
         },param4),true);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         this.m_pick.dispose();
         this.m_pick = null;
      }
   }
}

