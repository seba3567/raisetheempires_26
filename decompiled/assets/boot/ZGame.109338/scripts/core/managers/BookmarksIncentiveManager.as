package core.managers
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import displays.popups.BookmarkFavoriteIncentivePopup;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import transactions.TBookmarksIncentive;
   import zlabs.managers.PopupManager;
   
   public class BookmarksIncentiveManager extends EventDispatcher
   {
      
      private static var m_instance:BookmarksIncentiveManager;
      
      public static const TOKENS_PER_SPIN:uint = 5;
      
      public static const SPIN_PURCHASE_COST:uint = 5;
      
      public static const BOOKMARK_TOKEN_CODE:String = "BKTK";
      
      public static const FIRST_INSTALL_TOKEN_COUNT:uint = 20;
      
      public static const USE_TOKEN_MODE:uint = 1;
      
      public static const BUY_SPIN_MODE:uint = 2;
      
      public static const SPIN_START:String = "dailySpinStart";
      
      public static const SPIN_RESULTS:String = "dailySpinResults";
      
      private static const VARIANT_BOOKMARKSINCENTIVE_ON:int = 3;
      
      public function BookmarksIncentiveManager(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public static function get instance() : BookmarksIncentiveManager
      {
         if(!m_instance)
         {
            m_instance = new BookmarksIncentiveManager();
         }
         return m_instance;
      }
      
      public static function isEnabled() : Boolean
      {
         var _loc1_:int = ZGlobal.gameSettings.getInt("bookmarkIncentiveMinLevel",8);
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_BOOKMARKSINCENTIVE_MASTER) == VARIANT_BOOKMARKSINCENTIVE_ON && ZGlobal.player.level >= _loc1_)
         {
            return true;
         }
         return false;
      }
      
      public static function getTokenCount(param1:Boolean = false) : int
      {
         var _loc2_:int = 0;
         if(param1)
         {
            _loc2_ = int(FIRST_INSTALL_TOKEN_COUNT);
         }
         else
         {
            _loc2_ = 5;
         }
         return _loc2_;
      }
      
      public static function showIncentivePopup(param1:int, param2:Boolean) : void
      {
         PopupManager.instance.push(new BookmarkFavoriteIncentivePopup(param1,param2));
      }
      
      public function dailySpin(param1:uint) : Boolean
      {
         var _loc2_:int = 0;
         switch(param1)
         {
            case BUY_SPIN_MODE:
               _loc2_ = int(SPIN_PURCHASE_COST);
               if(ZGlobal.player.canBuyCash(_loc2_,true,"",false))
               {
                  ZGlobal.player.cash -= _loc2_;
                  break;
               }
               return false;
               break;
            case USE_TOKEN_MODE:
               _loc2_ = int(TOKENS_PER_SPIN);
               if(_loc2_ <= ZGlobal.player.inventory[BOOKMARK_TOKEN_CODE])
               {
                  ZGlobal.player.removeInventoryItem(BOOKMARK_TOKEN_CODE,_loc2_);
                  break;
               }
               return false;
               break;
            default:
               return false;
         }
         var _loc3_:TBookmarksIncentive = new TBookmarksIncentive(param1);
         TransactionManager.addTransaction(_loc3_);
         return true;
      }
   }
}

