package core.managers.FXManager
{
   import flash.utils.Dictionary;
   import zlabs.debug.Logger;
   
   public class FXManager
   {
      
      public static var instance:FXManager = new FXManager();
      
      private var m_FXs:Dictionary = null;
      
      public function FXManager()
      {
         super();
      }
      
      public function initFromSettings(param1:XMLList) : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         this.m_FXs = new Dictionary();
         for each(_loc2_ in param1)
         {
            _loc3_ = _loc2_.@id.toString();
            this.m_FXs[_loc3_] = _loc2_;
         }
      }
      
      public function getFXAnim(param1:String) : String
      {
         var _loc2_:String = null;
         if(this.validName(param1))
         {
            return this.m_FXs[param1].@anim.toString();
         }
         return null;
      }
      
      public function getFXSound(param1:String) : String
      {
         if(this.validName(param1))
         {
            return this.m_FXs[param1].@sound.toString();
         }
         return null;
      }
      
      public function getFXBackground(param1:String) : Boolean
      {
         var _loc2_:String = null;
         if(this.validName(param1))
         {
            _loc2_ = this.m_FXs[param1].@background.toString();
            return _loc2_.length > 0;
         }
         return false;
      }
      
      public function getFXForeground(param1:String) : Boolean
      {
         var _loc2_:String = null;
         if(this.validName(param1))
         {
            _loc2_ = this.m_FXs[param1].@foreground.toString();
            return _loc2_.length > 0;
         }
         return false;
      }
      
      public function getFXLoopCount(param1:String) : int
      {
         if(this.validName(param1))
         {
            if(this.m_FXs[param1].@loop.toString().length > 0)
            {
               return parseInt(this.m_FXs[param1].@loop);
            }
         }
         return 0;
      }
      
      public function validName(param1:String) : Boolean
      {
         if(null != param1 && param1.length > 0 && null != this.m_FXs[param1])
         {
            return true;
         }
         Logger.error(this,"validName","unable to find FX named " + param1);
         return false;
      }
   }
}

