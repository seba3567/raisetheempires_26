package transactions
{
   import Engine.Transactions.Transaction;
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import com.adobe.serialization.json.JSON;
   import com.zynga.ads.w2e.IReward;
   import com.zynga.ads.w2e.ISlot;
   import core.gamemode.GameMode;
   import core.gamemode.GameModeManager;
   import core.gamemode.battle.GMBattle;
   import core.managers.rewardPickupManager.RewardPickupManager;
   import core.managers.viralsManager.ViralsManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import flash.geom.Point;
   import utils.ZGameRandom;
   import zlabs.Zlab;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   
   public class TGrantWatchToEarnReward extends Transaction
   {
      
      private var m_payload:String;
      
      public function TGrantWatchToEarnReward(param1:String, param2:ISlot, param3:IReward)
      {
         var _loc4_:int = 0;
         super();
         this.m_payload = param1;
         if(param3.type === "energy")
         {
            _loc4_ = param3 ? int(param3.value) : 0;
            this.spawnDoobers(_loc4_);
         }
      }
      
      override public function perform() : void
      {
         signedCall("UserService.grantWatchToEarnRewardNew",this.m_payload);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         GlobalEngine.log("ZAP W2E","TGrantWatchToEarnReward::onComplete: " + com.adobe.serialization.json.JSON.encode(param1));
         super.onComplete(param1);
      }
      
      private function spawnDoobers(param1:int) : void
      {
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:Pt = null;
         var _loc2_:GameMode = GameModeManager.instance.getTopGameMode();
         var _loc3_:Boolean = _loc2_ as GMBattle != null;
         var _loc4_:Point = new Point(Math.floor(Zlab.mainStage.stageWidth / 2),Math.floor(Zlab.mainStage.stageHeight / 2));
         var _loc5_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         var _loc6_:IsoScene = IsoScene(_loc5_.getSceneByID("gameScene"));
         var _loc7_:Point = _loc6_.getContainer().globalToLocal(_loc4_);
         var _loc8_:Pt = new Pt(_loc7_.x,_loc7_.y);
         var _loc9_:Pt = IsoMath.screenToIso(_loc8_);
         var _loc10_:Pt = new Pt(_loc4_.x,_loc4_.y);
         var _loc11_:int = 0;
         while(_loc11_ < param1)
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
   }
}

