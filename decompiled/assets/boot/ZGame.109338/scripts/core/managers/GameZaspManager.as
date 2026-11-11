package core.managers
{
   import Engine.Managers.ZaspManager;
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import flash.display.DisplayObject;
   import flash.utils.getQualifiedClassName;
   import rendering.renderingIso.QuadTreeLayoutRenderer;
   import zlabs.displays.popups.IWindow;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class GameZaspManager extends ZaspManager
   {
      
      public function GameZaspManager(param1:DisplayObject)
      {
         super(param1,String(GlobalEngine.getFlashVar("zaspSessionKey")));
      }
      
      override protected function gameDetail() : String
      {
         var _loc4_:String = null;
         var _loc1_:* = PopupManager.instance.displayedWindow;
         if(_loc1_ != null)
         {
            return getQualifiedClassName(_loc1_);
         }
         var _loc2_:IWindow = WindowManager.instance.displayedWindow;
         if(_loc2_ != null)
         {
            return getQualifiedClassName(_loc2_);
         }
         var _loc3_:Array = GameModeManager.instance.getActiveGameModes();
         var _loc5_:Array = new Array();
         var _loc6_:Number = 0;
         while(_loc6_ < _loc3_.length)
         {
            _loc4_ = getQualifiedClassName(_loc3_[_loc6_]);
            _loc5_.push(_loc4_.substring(_loc4_.lastIndexOf("::") + 2));
            _loc6_++;
         }
         return _loc5_.join(",");
      }
      
      override protected function modifyReport(param1:Object) : void
      {
         if(param1["type"] == "fps")
         {
            param1["constants"] += " V:0";
            param1["game_state"] = this.gameDetail();
            if(ZGlobal.player)
            {
               param1["string5"] = ZGlobal.player.level;
            }
            else
            {
               param1["string5"] = -1;
            }
            param1["string6"] = QuadTreeLayoutRenderer.getVisibleObjectCount();
            param1["string7"] = 0;
            param1["string8"] = 0;
            param1["number7"] = 0;
            param1["number8"] = 0;
         }
         else if(param1["type"] == "GPI")
         {
            param1["level"] = ZGlobal.player ? ZGlobal.player.level : -1;
         }
      }
   }
}

