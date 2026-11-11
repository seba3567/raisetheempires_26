package transactions
{
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import com.zynga.zap.w2e.IWatchToEarnActivity;
   import com.zynga.zap.w2e.WatchToEarnService;
   import core.ZGlobal;
   import core.gamemode.GameMode;
   import core.gamemode.GameModeManager;
   import core.gamemode.battle.GMBattle;
   import core.managers.rewardPickupManager.RewardPickupManager;
   import core.managers.viralsManager.ViralsManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import flash.geom.Point;
   import flash.utils.setTimeout;
   import utils.ZGameRandom;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   
   public class TWatchToEarn extends TZGameTransaction
   {
      
      private var m_activity:IWatchToEarnActivity;
      
      public function TWatchToEarn(param1:IWatchToEarnActivity)
      {
         super();
         this.m_activity = param1;
         Logger.print(WatchToEarnService,"TWatchToEarn: queueing doobers");
         setTimeout(this.spawnDoobers,1000);
      }
      
      private function spawnDoobers() : void
      {
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:Pt = null;
         var _loc1_:int = ZGlobal.watchToEarn.getBounty();
         var _loc2_:GameMode = GameModeManager.instance.getTopGameMode();
         var _loc3_:Boolean = _loc2_ as GMBattle != null;
         var _loc4_:Point = new Point(Math.floor(Zlab.mainStage.stageWidth / 2),Math.floor(Zlab.mainStage.stageHeight / 2));
         var _loc5_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         var _loc6_:IsoScene = IsoScene(_loc5_.getSceneByID("gameScene"));
         var _loc7_:Point = _loc6_.getContainer().globalToLocal(_loc4_);
         var _loc8_:Pt = new Pt(_loc7_.x,_loc7_.y);
         var _loc9_:Pt = IsoMath.screenToIso(_loc8_);
         Logger.print(WatchToEarnService,"TWatchToEarn: inCombat: " + _loc3_);
         Logger.print(WatchToEarnService,"TWatchToEarn: centerPoint:" + _loc4_.x + "," + _loc4_.y);
         Logger.print(WatchToEarnService,"TWatchToEarn: mouseLoc:" + _loc7_.x + "," + _loc7_.y);
         Logger.print(WatchToEarnService,"TWatchToEarn: isoPt:" + _loc8_.x + "," + _loc8_.y);
         Logger.print(WatchToEarnService,"TWatchToEarn: gridPosition:" + _loc9_.x + "," + _loc9_.y);
         var _loc10_:Pt = new Pt(_loc4_.x,_loc4_.y);
         var _loc11_:int = 0;
         while(_loc11_ < _loc1_)
         {
            if(_loc3_)
            {
               RewardPickupManager.instance.add2DEnergyReward(_loc10_,1);
            }
            else
            {
               _loc12_ = -15 + ZGameRandom.instance.randBetween(0,30);
               _loc13_ = -15 + ZGameRandom.instance.randBetween(0,30);
               _loc14_ = new Pt(_loc9_.x + _loc12_,_loc9_.y + _loc13_);
               RewardPickupManager.instance.addEnergyRewardAtGridPos(_loc14_,1);
            }
            _loc11_++;
         }
         ViralsManager.instance.enable();
      }
      
      override public function perform() : void
      {
         Logger.print(WatchToEarnService,"TWatchToEarn.perform: " + this.m_activity);
         var _loc1_:Object = {"activity":this.m_activity.toJSON()};
         signedCall("UserService.grantWatchToEarnReward",modifiedData(_loc1_));
      }
   }
}

