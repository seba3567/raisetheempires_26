package utils
{
   import Engine.Managers.TransactionManager;
   import com.zynga.ads.w2e.IService;
   import com.zynga.ads.w2e.ISlot;
   import com.zynga.ads.w2e.ServiceEvent;
   import com.zynga.ads.w2e.SlotEvent;
   import com.zynga.ads.w2e.WatchToEarn;
   import core.ZGlobal;
   import transactions.TGrantWatchToEarnReward;
   import zlabs.Zlab;
   import zlabs.sound.SoundManager;
   
   public class Watch2EarnHandler
   {
      
      public static const W2E_SLOT_NAME:String = "FB_EMPIRES_W2E";
      
      public static const EXPERIMENT_ZAP_ZAC_W2E:String = "empires_zap_zac_w2e";
      
      public static const VARIANT_ZAP_ZAC_W2E_ENABLED:int = 1;
      
      public static const W2E_ENERGY_REWARD:int = 7;
      
      private static var muted:Boolean = false;
      
      public function Watch2EarnHandler()
      {
         super();
      }
      
      public static function initW2e() : void
      {
         var _loc1_:IService = WatchToEarn.create([W2E_SLOT_NAME],"zap-w2e-container");
         ZGlobal.newWatchToEarn = _loc1_;
         _loc1_.addEventListener(ServiceEvent.PAUSE_GAME,pauseGameHandler);
         _loc1_.addEventListener(ServiceEvent.RESUME_GAME,resumeGameHandler);
         _loc1_.getSlot(W2E_SLOT_NAME).addEventListener(SlotEvent.ACTIVITY_COMPLETE,activityCompleteHandler);
      }
      
      public static function launchActivity(param1:String) : Boolean
      {
         var _loc2_:ISlot = ZGlobal.newWatchToEarn.getSlot(param1);
         if(_loc2_.available)
         {
            _loc2_.startActivity();
            return true;
         }
         return false;
      }
      
      public static function checkSlotAvailability(param1:String) : Boolean
      {
         var _loc2_:ISlot = ZGlobal.newWatchToEarn.getSlot(param1);
         _loc2_.reportStatus();
         return _loc2_.available;
      }
      
      private static function resumeGameHandler(param1:ServiceEvent) : void
      {
         if(muted)
         {
            Zlab.soundManager.toggleMusic();
            muted = false;
         }
         ZGame.instance.enableAllInput();
      }
      
      private static function pauseGameHandler(param1:ServiceEvent) : void
      {
         if(!Zlab.soundManager.getCategoryMuted(SoundManager.MUSIC_MIXER_CATEGORY))
         {
            Zlab.soundManager.toggleMusic();
            muted = true;
         }
         ZGame.instance.disableAllInput();
      }
      
      private static function activityCompleteHandler(param1:SlotEvent) : void
      {
         TransactionManager.addTransaction(new TGrantWatchToEarnReward(param1.payload,null,param1.reward));
      }
   }
}

