package utils
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import com.zynga.zap.w2e.IWatchToEarnActivity;
   import com.zynga.zap.w2e.IWatchToEarnGameFacade;
   import com.zynga.zap.w2e.WatchToEarnService;
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import transactions.TWatchToEarn;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.sound.SoundManager;
   
   public class WatchToEarnGameFacade implements IWatchToEarnGameFacade
   {
      
      private var muted:Boolean = false;
      
      public function WatchToEarnGameFacade()
      {
         super();
      }
      
      public function log(param1:String) : void
      {
         Logger.print(WatchToEarnService,param1);
      }
      
      public function error(param1:String) : void
      {
         Logger.error(WatchToEarnService,"",param1);
      }
      
      public function count(param1:String, param2:String = "", param3:String = "", param4:String = "", param5:String = "", param6:String = "", param7:int = 1) : void
      {
         StatsManager.count(param1,param2,param3,param4,param5,param6,param7);
      }
      
      public function pauseGame() : void
      {
         if(!Zlab.soundManager.getCategoryMuted(SoundManager.MUSIC_MIXER_CATEGORY))
         {
            Zlab.soundManager.toggleMusic();
            this.muted = true;
         }
      }
      
      public function resumeGame() : void
      {
         if(this.muted)
         {
            Zlab.soundManager.toggleMusic();
            this.muted = false;
         }
      }
      
      public function verifyActivity(param1:IWatchToEarnActivity) : void
      {
         var _loc2_:TWatchToEarn = new TWatchToEarn(param1);
         TransactionManager.addTransaction(_loc2_,true);
      }
      
      public function getBountyExperimentVariant() : int
      {
         var _loc1_:String = ExperimentsManager.EXPERIMENT_WTE_BOUNTY;
         return ExperimentsManager.instance.getExperimentVariant(_loc1_);
      }
      
      public function get isPayingUser() : Boolean
      {
         return ZGlobal.player.isPayingUserFromTargeting;
      }
   }
}

