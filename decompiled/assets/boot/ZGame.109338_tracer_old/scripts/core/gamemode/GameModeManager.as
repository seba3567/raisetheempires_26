package core.gamemode
{
   import core.ZGlobal;
   import core.gamemode.avatar.GMAvatar;
   import core.managers.PVPManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.player.Player;
   import events.GameModeEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.FullScreenEvent;
   import flash.utils.getQualifiedClassName;
   import zlabs.Zlab;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class GameModeManager extends EventDispatcher
   {
      
      private static var m_instance:GameModeManager;
      
      public static const DRAGSTART:String = "dragstart";
      
      public static const DRAGSTOP:String = "dragstop";
      
      protected var m_activeModes:Array = [];
      
      protected var m_modeLock:int = 1;
      
      public function GameModeManager()
      {
         super();
         Zlab.mainStage.addEventListener(FullScreenEvent.FULL_SCREEN,this.passEvent,false,0,true);
         WindowManager.instance.addEventListener(WindowManager.SHOW_SCREEN,this.onShowScreen,false,0,true);
         PopupManager.instance.addEventListener(WindowManager.SHOW_SCREEN,this.onShowScreen,false,0,true);
      }
      
      public static function get instance() : GameModeManager
      {
         if(m_instance == null)
         {
            m_instance = new GameModeManager();
         }
         return m_instance;
      }
      
      public function addGameMode(param1:GameMode, param2:Boolean = true) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:GameMode = null;
         var _loc6_:GameMode = null;
         _loc3_ = getQualifiedClassName(param1);
         _loc4_ = 0;
         while(_loc4_ < this.m_activeModes.length)
         {
            _loc5_ = this.m_activeModes[_loc4_] as GameMode;
            _loc5_.disableMode();
            _loc4_++;
         }
         if(param2)
         {
            for each(_loc6_ in this.m_activeModes)
            {
               _loc6_.dispose();
            }
            this.m_activeModes = new Array(param1);
         }
         else
         {
            this.m_activeModes.push(param1);
         }
         param1.enableMode();
         dispatchEvent(new GameModeEvent(GameModeEvent.ADD_MODE));
      }
      
      public function cleanUp() : void
      {
         while(this.m_activeModes.length)
         {
            this.popGameMode();
         }
      }
      
      public function set hideISOGameUI(param1:Boolean) : void
      {
         GridPointer.instance.hide = param1;
      }
      
      public function getActiveGameModes() : Array
      {
         return this.m_activeModes;
      }
      
      public function getTopGameMode() : GameMode
      {
         var _loc1_:GameMode = null;
         if(this.m_activeModes.length)
         {
            _loc1_ = this.m_activeModes[this.m_activeModes.length - 1];
         }
         return _loc1_;
      }
      
      public function isModeLocked() : Boolean
      {
         return this.m_modeLock > 0;
      }
      
      public function lockGameMode() : void
      {
         ++this.m_modeLock;
      }
      
      public function popGameMode() : void
      {
         var _loc1_:GameMode = null;
         if(this.m_activeModes.length)
         {
            _loc1_ = this.m_activeModes.pop() as GameMode;
            _loc1_.disableMode();
            _loc1_.dispose();
            if(this.m_activeModes.length)
            {
               this.m_activeModes[this.m_activeModes.length - 1].enableMode();
            }
         }
      }
      
      public function removeGameMode(param1:GameMode) : void
      {
         var _loc2_:int = 0;
         var _loc3_:GameMode = null;
         if(this.m_activeModes.length)
         {
            _loc2_ = 0;
            while(_loc2_ < this.m_activeModes.length)
            {
               _loc3_ = this.m_activeModes[_loc2_] as GameMode;
               if(_loc3_ == param1)
               {
                  param1.disableMode();
                  param1.dispose();
                  this.m_activeModes.splice(_loc2_,1);
                  if(_loc2_ == this.m_activeModes.length && this.m_activeModes.length > 0)
                  {
                     this.m_activeModes[this.m_activeModes.length - 1].enableMode();
                  }
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      public function setDefaultGameMode() : GMDefault
      {
         var _loc1_:GMDefault = null;
         if(ZGlobal.isVisiting())
         {
            if(ZGlobal.hostPlayer.uid == Player.FAKE_PLAYER_ID)
            {
               _loc1_ = new GMVisit();
            }
            else
            {
               _loc1_ = PVPManager.instance.getNewGameMode();
            }
         }
         else if(TutorialManager.instance.active)
         {
            _loc1_ = new GMTutorial();
         }
         else
         {
            _loc1_ = new GMAvatar();
         }
         this.addGameMode(_loc1_);
         return _loc1_;
      }
      
      public function unlockGameMode() : void
      {
         if(this.m_modeLock > 0)
         {
            --this.m_modeLock;
         }
      }
      
      public function passEvent(param1:Event) : void
      {
         dispatchEvent(param1);
      }
      
      public function onShowScreen(param1:Event) : void
      {
         m_instance.getTopGameMode().focusLost();
      }
   }
}

