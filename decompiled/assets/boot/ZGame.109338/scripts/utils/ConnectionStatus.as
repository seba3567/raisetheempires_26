package utils
{
   import Engine.Managers.StatsManager;
   import core.managers.ExperimentsManager;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.genericPopup.GenericPopup1B;
   import displays.popups.genericPopup.ModalPopup;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.utils.Timer;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   
   public class ConnectionStatus
   {
      
      protected static var m_autoRefreshOnSessionExpirationTimer:Timer;
      
      protected static var m_sessionTimer:Timer;
      
      protected static var m_currentTimeoutType:String;
      
      protected static var m_timeoutTimer:Timer;
      
      protected static var m_timeoutDialog:ModalPopup;
      
      public static const TIMEOUT_SAVE_GAME:String = "timeout_save_game";
      
      public static const TIMEOUT_CONNECTION_LOST:String = "timeout_connection_lost";
      
      public static const SESSION_DURATION_DEFAULT:uint = 7200000;
      
      public static const AUTO_REFRESH_AFTER_SESSION_EXPIRATION_DURATION:uint = 20000;
      
      private static var m_shownFaultPopup:Boolean = false;
      
      public function ConnectionStatus()
      {
         super();
      }
      
      public static function resetSessionTimer(param1:uint) : void
      {
         if(m_sessionTimer == null)
         {
            m_sessionTimer = new Timer(param1,1);
            m_sessionTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onSessionTimerComplete,false,0,true);
         }
         m_sessionTimer.stop();
         m_sessionTimer.delay = param1;
         m_sessionTimer.repeatCount = 1;
         m_sessionTimer.reset();
         m_sessionTimer.start();
      }
      
      public static function stopSessionTimer() : void
      {
         m_sessionTimer.stop();
      }
      
      public static function startTimeout(param1:String, param2:int, param3:Boolean = true) : void
      {
         var _loc4_:String = null;
         if(m_currentTimeoutType != null)
         {
            return;
         }
         m_currentTimeoutType = param1;
         m_timeoutTimer = new Timer(param2);
         m_timeoutTimer.addEventListener(TimerEvent.TIMER,onTimeout);
         m_timeoutTimer.start();
         if(param3)
         {
            switch(m_currentTimeoutType)
            {
               case TIMEOUT_SAVE_GAME:
                  _loc4_ = ZGameUtils.ZlocT("Main","SavingWorld");
                  break;
               case TIMEOUT_CONNECTION_LOST:
                  _loc4_ = ZGameUtils.ZlocT("Main","RetryingConnection");
                  break;
               default:
                  _loc4_ = ZGameUtils.ZlocT("Main","SavingWorld");
            }
            m_timeoutDialog = new ModalPopup(_loc4_);
            PopupManager.instance.push(m_timeoutDialog,0,false);
         }
      }
      
      public static function stopTimeout() : void
      {
         m_currentTimeoutType = null;
         if(m_timeoutDialog != null)
         {
            m_timeoutDialog.pop();
            m_timeoutDialog = null;
         }
         if(m_timeoutTimer != null)
         {
            m_timeoutTimer.stop();
            m_timeoutTimer.removeEventListener(TimerEvent.TIMER,onTimeout);
            m_timeoutTimer = null;
         }
      }
      
      public static function showTransactionFaultDialog(param1:String, param2:String) : void
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REPORT_BUG_POPUP) == ExperimentsManager.VARIANT_VALUE_REPORT_BUG_PROMPT_ON)
         {
            showTransactionFaultDialogReportRefresh(param1,param2);
         }
         else
         {
            showTransactionFaultDialogDefault(param1,param2);
         }
      }
      
      private static function showTransactionFaultDialogDefault(param1:String, param2:String) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:GenericPopup = null;
         if(!m_shownFaultPopup)
         {
            StatsManager.count("dialog","Connection_Error_Popup1","view");
            _loc3_ = ZGameUtils.ZlocT("Main","RefreshButtonAction");
            _loc4_ = param1 + " " + _loc3_;
            _loc5_ = GenericPopup1B.NewRefresh(_loc4_,null,param2,onTransactionFaultClose1);
            PopupManager.instance.push(_loc5_);
         }
         m_shownFaultPopup = true;
      }
      
      private static function showTransactionFaultDialogReportRefresh(param1:String, param2:String) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:GenericPopup2B = null;
         if(!m_shownFaultPopup)
         {
            StatsManager.count("dialog","Connection_Error_Popup2","view");
            _loc3_ = ZGameUtils.ZlocT("Main","RefreshButtonAction");
            _loc4_ = param1 + " " + _loc3_;
            _loc5_ = GenericPopup2B.NewReportRefresh(_loc4_,"",param2,onTransactionFaultCloseReportRefresh,null);
            PopupManager.instance.push(_loc5_);
         }
         m_shownFaultPopup = true;
      }
      
      protected static function onSessionTimerComplete(param1:TimerEvent) : void
      {
         m_sessionTimer.stop();
         m_sessionTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,onSessionTimerComplete);
         var _loc2_:String = ZGameUtils.ZlocT("Main","RefreshGame");
         showTransactionFaultDialog(_loc2_,GenericPopup.MOOD_SURPRISED);
         resetAutoRefreshOnSessionExpirationTimer();
      }
      
      protected static function resetAutoRefreshOnSessionExpirationTimer() : void
      {
         if(m_autoRefreshOnSessionExpirationTimer == null)
         {
            m_autoRefreshOnSessionExpirationTimer = new Timer(AUTO_REFRESH_AFTER_SESSION_EXPIRATION_DURATION,1);
         }
         m_autoRefreshOnSessionExpirationTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onAutoRefreshOnSessionExpirationTimerComplete,false,0,true);
         m_autoRefreshOnSessionExpirationTimer.stop();
         m_autoRefreshOnSessionExpirationTimer.delay = AUTO_REFRESH_AFTER_SESSION_EXPIRATION_DURATION;
         m_autoRefreshOnSessionExpirationTimer.repeatCount = 1;
         m_autoRefreshOnSessionExpirationTimer.reset();
         m_autoRefreshOnSessionExpirationTimer.start();
      }
      
      protected static function onAutoRefreshOnSessionExpirationTimerComplete(param1:TimerEvent) : void
      {
         m_autoRefreshOnSessionExpirationTimer.stop();
         m_autoRefreshOnSessionExpirationTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,onAutoRefreshOnSessionExpirationTimerComplete);
         onTransactionFaultClose1(null);
      }
      
      protected static function onTimeout(param1:Event = null) : void
      {
         var _loc2_:String = null;
         switch(m_currentTimeoutType)
         {
            case TIMEOUT_SAVE_GAME:
               _loc2_ = ZGameUtils.ZlocT("Main","SaveGameTimeout");
               break;
            case TIMEOUT_CONNECTION_LOST:
               _loc2_ = ZGameUtils.ZlocT("Main","ConnectionLostTimeout");
               break;
            default:
               _loc2_ = ZGameUtils.ZlocT("Main","RefreshGame");
         }
         if(m_timeoutDialog != null)
         {
            m_timeoutDialog.pop();
            m_timeoutDialog = null;
         }
         showTransactionFaultDialog(_loc2_,GenericPopup.MOOD_SURPRISED);
      }
      
      protected static function onTransactionFaultClose1(param1:Event) : void
      {
         StatsManager.count("dialog","Connection_Error_Popup1","refresh");
         ExternalInterface.call("ZYFrameManager.reloadApp");
      }
      
      protected static function onTransactionFaultClose2(param1:Event) : void
      {
         StatsManager.count("dialog","Connection_Error_Popup2","refresh_2");
         ExternalInterface.call("ZYFrameManager.reloadApp");
      }
      
      protected static function onTransactionFaultCloseReportRefresh(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:GenericPopup = null;
         if(param1.button == GenericPopup.YES)
         {
            StatsManager.count("dialog","Connection_Error_Popup2","report");
            _loc2_ = ZGameUtils.ZlocT("Main","ReportBug");
            _loc3_ = GenericPopup1B.NewRefresh(_loc2_,null,GenericPopup.MOOD_HAPPY,onTransactionFaultClose2);
            PopupManager.instance.push(_loc3_);
         }
         else
         {
            StatsManager.count("dialog","Connection_Error_Popup2","refresh_1");
            ExternalInterface.call("ZYFrameManager.reloadApp");
         }
      }
   }
}

