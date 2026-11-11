package Engine.Managers
{
   import Engine.Init.InitializationManager;
   import Engine.Interfaces.IDialog;
   import flash.events.Event;
   import flash.utils.getQualifiedClassName;
   
   public class PopupQueueManager
   {
      
      private static var m_instance:PopupQueueManager = null;
      
      private static var m_canInstantiate:Boolean = false;
      
      private var m_popupQueue:Vector.<IDialog> = new Vector.<IDialog>();
      
      private var m_popupStack:Vector.<IDialog> = new Vector.<IDialog>();
      
      public function PopupQueueManager()
      {
         super();
         if(!m_canInstantiate)
         {
            throw new Error("Cannot call PopupQueueManager constructor directly - use getInstance() instead.");
         }
      }
      
      public static function getInstance() : PopupQueueManager
      {
         if(null == m_instance)
         {
            m_canInstantiate = true;
            m_instance = new PopupQueueManager();
            m_canInstantiate = false;
         }
         return m_instance;
      }
      
      public function showDialog(param1:IDialog, param2:Boolean = true) : void
      {
         var _loc4_:IDialog = null;
         var _loc5_:IDialog = null;
         var _loc6_:Boolean = false;
         var _loc3_:Boolean = true;
         if(param1.unique == true)
         {
            for each(_loc4_ in this.m_popupStack)
            {
               if(param1.dialogName == _loc4_.dialogName)
               {
                  _loc3_ = false;
                  break;
               }
            }
            for each(_loc5_ in this.m_popupQueue)
            {
               if(param1.dialogName == _loc5_.dialogName)
               {
                  _loc3_ = false;
                  break;
               }
            }
         }
         if(_loc3_)
         {
            if(param2)
            {
               this.m_popupQueue.push(param1);
               this.pumpPopupQueue();
            }
            else
            {
               _loc6_ = FreezeManager.getInstance().isAnythingFrozen();
               if(_loc6_ == false || _loc6_ == true && this.m_popupStack.length > 0)
               {
                  this.displayImmediately(param1);
               }
               else
               {
                  this.m_popupQueue.unshift(param1);
               }
            }
         }
      }
      
      public function closeShownDialogs() : void
      {
         var _loc1_:IDialog = null;
         for each(_loc1_ in this.m_popupStack)
         {
            _loc1_.close();
         }
         this.m_popupStack = new Vector.<IDialog>();
      }
      
      private function displayImmediately(param1:IDialog) : void
      {
         var _loc2_:IDialog = null;
         if(this.m_popupStack.length > 0)
         {
            _loc2_ = this.m_popupStack[this.m_popupStack.length - 1];
            _loc2_.disable();
         }
         GlobalEngine.stage.addChild(param1.getDisplayObject());
         param1.getDisplayObject().addEventListener(Event.CLOSE,this.onPopupClosed,false,0,true);
         this.m_popupStack.push(param1);
         param1.show();
         FreezeManager.getInstance().freezeRender();
      }
      
      private function onPopupClosed(param1:Event) : void
      {
         var _loc2_:IDialog = null;
         param1.currentTarget.removeEventListener(Event.CLOSE,this.onPopupClosed);
         this.m_popupStack.pop();
         if(this.m_popupStack.length > 0)
         {
            _loc2_ = this.m_popupStack[this.m_popupStack.length - 1];
            _loc2_.enable();
         }
         else
         {
            this.pumpPopupQueue();
            FreezeManager.getInstance().thaw(true);
         }
      }
      
      public function pumpPopupQueue() : void
      {
         var _loc1_:IDialog = null;
         if(this.m_popupQueue.length > 0 && this.m_popupStack.length == 0 && InitializationManager.getInstance().haveAllCompleted())
         {
            _loc1_ = this.m_popupQueue.shift();
            this.displayImmediately(_loc1_);
         }
      }
      
      public function hasActiveDialog() : Boolean
      {
         return this.m_popupStack.length > 0;
      }
      
      public function getActiveDialog() : IDialog
      {
         var _loc1_:IDialog = null;
         if(this.hasActiveDialog())
         {
            _loc1_ = this.m_popupStack[this.m_popupStack.length - 1];
         }
         return _loc1_;
      }
      
      public function getActiveDialogName() : String
      {
         var _loc1_:String = "";
         var _loc2_:IDialog = this.getActiveDialog();
         if(_loc2_ != null)
         {
            _loc1_ = getQualifiedClassName(_loc2_);
            if(_loc1_.length >= 39)
            {
               _loc1_ = _loc1_.substr(_loc1_.lastIndexOf(".") + 1);
               if(_loc1_.length >= 39)
               {
                  _loc1_ = _loc1_.substr(_loc1_.indexOf("::") + 2);
               }
            }
            _loc1_ = "popup:" + _loc1_;
         }
         else
         {
            _loc1_ = "unkownUI";
         }
         return _loc1_;
      }
   }
}

