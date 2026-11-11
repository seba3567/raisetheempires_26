package transactions
{
   import Engine.Classes.SNAPISocialNetwork;
   import Engine.Managers.ErrorManager;
   import Engine.Transactions.TStreamPublish;
   import flash.display.StageDisplayState;
   import flash.external.ExternalInterface;
   import flash.utils.Dictionary;
   import zlabs.debug.Logger;
   
   public class TStreamPublishWithCallback extends TStreamPublish
   {
      
      private static var m_callbackMappings:Dictionary = new Dictionary();
      
      protected var m_callbackKey:String;
      
      public function TStreamPublishWithCallback(param1:String, param2:Object, param3:String, param4:String, param5:String = null, param6:Boolean = false)
      {
         super(param1,param2,param3,param5,param6);
         this.m_callbackKey = param4;
      }
      
      public static function init() : void
      {
         ExternalInterface.addCallback("streamPublishCallback",jsCallback);
      }
      
      public static function setCallback(param1:String, param2:Function) : void
      {
         m_callbackMappings[param1] = param2;
      }
      
      private static function jsCallback(param1:Object, param2:String, param3:String, param4:Object, param5:String) : void
      {
         var _loc7_:Function = null;
         var _loc6_:String = null;
         if(param1 is String)
         {
            Logger.print("TStreamPublishWithCallback","publishResponse is a STRING " + param1);
            _loc6_ = param1 as String;
         }
         else if(Boolean(param1) && Boolean(param1.post_id))
         {
            Logger.print("TStreamPublishWithCallback","publishResponse is an OBJECT " + param1.post_id);
            _loc6_ = param1.post_id;
         }
         if(_loc6_)
         {
            _loc7_ = m_callbackMappings[param5];
            if(_loc7_ != null)
            {
               _loc7_.apply(null,[{
                  "feedType":param2,
                  "feedData":param4,
                  "target":param3
               }]);
            }
         }
      }
      
      public function get type() : String
      {
         return m_type;
      }
      
      override protected function onComplete(param1:Object) : void
      {
         if(GlobalEngine.socialNetwork is SNAPISocialNetwork)
         {
            this.callExternalInterface(param1);
         }
      }
      
      private function callExternalInterface(param1:Object) : void
      {
         var data:Object = param1;
         try
         {
            if(m_autoPublish)
            {
               data.auto_publish = true;
            }
            if(ExternalInterface.available)
            {
               if(GlobalEngine.stage.displayState == StageDisplayState.FULL_SCREEN)
               {
                  GlobalEngine.stage.displayState = StageDisplayState.NORMAL;
               }
               ExternalInterface.call("snapiStreamPublishWithCallback",data,m_type,m_targetId,m_data,this.m_callbackKey);
            }
         }
         catch(err:Error)
         {
            ErrorManager.addError("ExternalInterface exception: " + err.message);
         }
      }
   }
}

