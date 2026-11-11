package Engine.Managers
{
   import Engine.Events.FreezeEvent;
   import by.blooddy.crypto.Base64;
   import by.blooddy.crypto.image.JPEGEncoder;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.display.StageDisplayState;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.filters.BitmapFilterQuality;
   import flash.filters.BlurFilter;
   import flash.geom.Point;
   import flash.utils.ByteArray;
   
   public class FreezeManager extends EventDispatcher
   {
      
      private static var m_instance:FreezeManager;
      
      public var freezingUnlocked:Boolean = false;
      
      private var m_frozenBitmap:Bitmap;
      
      private var m_frozenSprite:Sprite;
      
      private var m_frozenDispObj:Array = null;
      
      protected var m_state:int = 0;
      
      protected const STATE_THAWED:int = 0;
      
      protected const STATE_RENDER_FROZEN:int = 1;
      
      protected const STATE_ALL_FROZEN:int = 2;
      
      protected var m_frozenTime:Number = 0;
      
      protected const CLICK_TO_THAW_TIME:int = 3000;
      
      protected var m_postThawCallbackArray:Array = [];
      
      public function FreezeManager()
      {
         super();
      }
      
      public static function getInstance() : FreezeManager
      {
         if(m_instance == null)
         {
            m_instance = new FreezeManager();
         }
         return m_instance;
      }
      
      public static function setInstance(param1:FreezeManager) : void
      {
         if(m_instance == null)
         {
            m_instance = param1;
         }
      }
      
      public function freezeAll() : void
      {
         var _loc1_:Stage = null;
         var _loc2_:BitmapData = null;
         var _loc3_:Shape = null;
         if(this.freezingUnlocked && this.isAllFrozen() == false)
         {
            this.thawRender();
            if(GlobalEngine.stage.displayState == StageDisplayState.FULL_SCREEN)
            {
               GlobalEngine.stage.displayState = StageDisplayState.NORMAL;
            }
            _loc1_ = GlobalEngine.stage;
            _loc2_ = new BitmapData(_loc1_.stageWidth,_loc1_.stageHeight,false,0);
            _loc2_.draw(_loc1_);
            _loc3_ = new Shape();
            _loc3_.graphics.beginFill(0,0.3);
            _loc3_.graphics.drawRect(0,0,_loc1_.stageWidth,_loc1_.stageHeight);
            _loc3_.graphics.endFill();
            _loc2_.draw(_loc3_);
            this.createFrozenSprite(_loc2_,this.onFrozenAllClick);
            this.freezeObjects();
            _loc1_.addChild(this.m_frozenSprite);
            this.m_frozenBitmap.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            this.m_frozenTime = GlobalEngine.currentTime;
            this.m_state = this.STATE_ALL_FROZEN;
         }
      }
      
      public function freezeRender() : void
      {
         var _loc1_:Stage = null;
         var _loc2_:Sprite = null;
         var _loc3_:DisplayObjectContainer = null;
         var _loc4_:BitmapData = null;
         var _loc5_:Shape = null;
         var _loc6_:int = 0;
         if(this.freezingUnlocked && this.isAnythingFrozen() == false)
         {
            _loc1_ = GlobalEngine.stage;
            _loc2_ = GlobalEngine.viewport;
            _loc3_ = _loc2_.parent;
            _loc4_ = new BitmapData(_loc1_.stageWidth,_loc1_.stageHeight,false,0);
            _loc4_.draw(_loc2_);
            _loc5_ = new Shape();
            _loc5_.graphics.beginFill(0,0.3);
            _loc5_.graphics.drawRect(0,0,_loc1_.stageWidth,_loc1_.stageHeight);
            _loc5_.graphics.endFill();
            _loc4_.draw(_loc5_);
            this.createFrozenSprite(_loc4_,this.onFrozenRenderClick);
            _loc6_ = _loc3_.getChildIndex(_loc2_);
            _loc3_.removeChild(_loc2_);
            _loc3_.addChildAt(this.m_frozenSprite,_loc6_);
            this.m_state = this.STATE_RENDER_FROZEN;
            getInstance().dispatchEvent(new FreezeEvent(FreezeEvent.FROZEN));
         }
      }
      
      protected function freezeObjects() : void
      {
         var _loc1_:Stage = GlobalEngine.stage;
         if(this.m_frozenDispObj == null)
         {
            this.m_frozenDispObj = new Array();
         }
         var _loc2_:* = 0;
         _loc2_ = 0;
         while(_loc2_ < _loc1_.numChildren)
         {
            this.m_frozenDispObj.push(_loc1_.getChildAt(_loc2_));
            _loc2_++;
         }
         _loc2_ = int(_loc1_.numChildren - 1);
         while(_loc2_ >= 0)
         {
            _loc1_.removeChildAt(_loc2_);
            _loc2_--;
         }
      }
      
      public function pushPostThawCallback(param1:Function) : void
      {
         this.m_postThawCallbackArray.push(param1);
      }
      
      public function thaw(param1:Boolean = false) : void
      {
         var _loc2_:Function = null;
         var _loc3_:Stage = null;
         var _loc4_:DisplayObject = null;
         var _loc5_:DisplayObject = null;
         if(this.isAnythingFrozen())
         {
            if(this.isRenderFrozen() || PopupQueueManager.getInstance().hasActiveDialog() || param1)
            {
               this.thawRender();
            }
            if(this.isAllFrozen())
            {
               _loc3_ = GlobalEngine.stage;
               _loc3_.removeChild(this.m_frozenSprite);
               this.m_frozenBitmap.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
               if(this.m_frozenBitmap.bitmapData)
               {
                  this.m_frozenBitmap.bitmapData.dispose();
               }
               this.m_frozenSprite.removeEventListener(MouseEvent.CLICK,this.onFrozenAllClick);
               this.m_frozenSprite = null;
               this.m_frozenBitmap = null;
               this.freezeObjects();
               for each(_loc4_ in this.m_frozenDispObj)
               {
                  if(_loc4_)
                  {
                     GlobalEngine.stage.addChildAt(_loc4_,GlobalEngine.stage.numChildren);
                  }
               }
               _loc5_ = GlobalEngine.stage.getChildByName("root1");
               if((Boolean(_loc5_)) && _loc5_ is BaseGame)
               {
                  _loc3_.setChildIndex(_loc5_,0);
               }
               this.m_frozenDispObj.splice(0,this.m_frozenDispObj.length);
               this.m_state = this.STATE_THAWED;
               InputManager.enableInput();
               if(PopupQueueManager.getInstance().hasActiveDialog())
               {
                  this.freezeRender();
               }
               else
               {
                  PopupQueueManager.getInstance().pumpPopupQueue();
               }
               getInstance().dispatchEvent(new FreezeEvent(FreezeEvent.THAWED));
            }
            while(this.m_postThawCallbackArray.length > 0)
            {
               _loc2_ = this.m_postThawCallbackArray.shift();
               _loc2_();
            }
         }
      }
      
      protected function thawRender() : void
      {
         var _loc1_:DisplayObjectContainer = null;
         var _loc2_:int = 0;
         if(this.isRenderFrozen())
         {
            _loc1_ = this.m_frozenSprite.parent;
            _loc2_ = _loc1_.getChildIndex(this.m_frozenSprite);
            _loc1_.removeChild(this.m_frozenSprite);
            _loc1_.addChildAt(GlobalEngine.viewport,_loc2_);
            this.m_frozenSprite.removeEventListener(MouseEvent.CLICK,this.onFrozenRenderClick);
            if(this.m_frozenBitmap.bitmapData)
            {
               this.m_frozenBitmap.bitmapData.dispose();
            }
            this.m_frozenBitmap = null;
            this.m_frozenSprite = null;
            this.m_state = this.STATE_THAWED;
         }
      }
      
      public function isRenderFrozen() : Boolean
      {
         return this.STATE_RENDER_FROZEN == this.m_state;
      }
      
      public function isAllFrozen() : Boolean
      {
         return this.STATE_ALL_FROZEN == this.m_state;
      }
      
      public function isAnythingFrozen() : Boolean
      {
         return this.STATE_THAWED != this.m_state;
      }
      
      protected function onFrozenRenderClick(param1:Event) : void
      {
         if(this.isRenderFrozen() && PopupQueueManager.getInstance().hasActiveDialog() == false)
         {
            this.thaw();
         }
      }
      
      protected function onFrozenAllClick(param1:Event) : void
      {
         if(this.isAllFrozen() && this.CLICK_TO_THAW_TIME + this.m_frozenTime < GlobalEngine.currentTime)
         {
            this.thaw();
         }
      }
      
      public function removeFrozenPopup(param1:DisplayObject) : void
      {
         var _loc2_:int = 0;
         if(this.m_frozenDispObj)
         {
            _loc2_ = 0;
            while(_loc2_ < this.m_frozenDispObj.length)
            {
               if(this.m_frozenDispObj[_loc2_] as DisplayObject == param1)
               {
                  this.m_frozenDispObj.splice(_loc2_,1);
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      protected function onEnterFrame(param1:Event) : void
      {
         if(this.isAllFrozen())
         {
            GlobalEngine.zaspManager.preUpdate();
            getInstance().dispatchEvent(new FreezeEvent(FreezeEvent.UPDATE));
            GlobalEngine.zaspManager.postUpdate();
         }
      }
      
      public function exportScreenshot() : String
      {
         var _loc6_:String = null;
         var _loc1_:String = null;
         var _loc2_:Stage = GlobalEngine.stage;
         var _loc3_:BlurFilter = new BlurFilter(6,6,BitmapFilterQuality.HIGH);
         var _loc4_:BitmapData = new BitmapData(_loc2_.stageWidth,_loc2_.stageHeight,false,0);
         _loc4_.draw(_loc2_);
         _loc4_.applyFilter(_loc4_,_loc4_.rect,new Point(0,0),_loc3_);
         var _loc5_:ByteArray = JPEGEncoder.encode(_loc4_,50);
         if(_loc5_)
         {
            _loc6_ = Base64.encode(_loc5_);
            if(_loc6_)
            {
               _loc1_ = _loc6_;
            }
         }
         return _loc1_;
      }
      
      protected function createFrozenSprite(param1:BitmapData, param2:Function = null) : void
      {
         this.m_frozenBitmap = new Bitmap(param1);
         this.m_frozenSprite = new Sprite();
         this.m_frozenSprite.addChild(this.m_frozenBitmap);
         if(param2 != null)
         {
            this.m_frozenSprite.mouseEnabled = true;
            this.m_frozenSprite.mouseChildren = true;
            this.m_frozenSprite.addEventListener(MouseEvent.CLICK,param2);
         }
      }
   }
}

