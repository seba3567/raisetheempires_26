package zlabs.core
{
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.serialization.ISerializable;
   
   public class InputMap implements ISerializable
   {
      
      private var _lastMouseX:Number = -Infinity;
      
      private var _lastMouseY:Number = -Infinity;
      
      private var _suppressDeltaNextTime:Boolean = false;
      
      private var _keymap:Dictionary = new Dictionary();
      
      private var _bindings:Dictionary = new Dictionary();
      
      private var _registeredForKeyEvents:Boolean = false;
      
      public function InputMap()
      {
         super();
      }
      
      public function serialize(param1:XML) : void
      {
         var _loc2_:String = null;
         for(_loc2_ in this._keymap)
         {
            param1.appendChild(new XML("<" + this._keymap[_loc2_] + ">" + InputKey.codeToString(parseInt(_loc2_)) + "</" + this._keymap[_loc2_] + ">"));
         }
      }
      
      public function deserialize(param1:XML) : *
      {
         var _loc2_:XML = null;
         for each(_loc2_ in param1.children())
         {
            this.mapKeyToAction(InputKey.stringToKey(_loc2_.toString()),_loc2_.name());
         }
         return this;
      }
      
      public function mapKeyToAction(param1:InputKey, param2:String) : void
      {
         if(!param1)
         {
            throw new Error("Got a null key in mapKeyToAction; you probably have a typo in a key name.");
         }
         if(this._keymap[param1.keyCode] == null)
         {
            if(param1 == InputKey.MOUSE_BUTTON)
            {
               Zlab.inputManager.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
               Zlab.inputManager.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
            }
            else if(param1 == InputKey.MOUSE_X && !this._keymap[InputKey.MOUSE_Y])
            {
               Zlab.inputManager.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
            }
            else if(param1 == InputKey.MOUSE_Y && !this._keymap[InputKey.MOUSE_X])
            {
               Zlab.inputManager.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
            }
            else if(param1 == InputKey.MOUSE_WHEEL)
            {
               Zlab.inputManager.addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel);
            }
            else if(param1 == InputKey.MOUSE_HOVER)
            {
               Zlab.inputManager.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
               Zlab.inputManager.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
            }
            else if(!this._registeredForKeyEvents)
            {
               Zlab.inputManager.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
               Zlab.inputManager.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUp);
               this._registeredForKeyEvents = true;
            }
         }
         this._keymap[param1.keyCode] = param2;
      }
      
      public function mapActionToHandler(param1:String, param2:Function) : void
      {
         this._bindings[param1] = param2;
      }
      
      public function mapKeyToHandler(param1:InputKey, param2:Function) : void
      {
         var _loc3_:String = InputKey.codeToString(param1.keyCode);
         this.mapKeyToAction(param1,_loc3_);
         this.mapActionToHandler(_loc3_,param2);
      }
      
      public function destroy() : void
      {
         Zlab.inputManager.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         Zlab.inputManager.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         Zlab.inputManager.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         Zlab.inputManager.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         Zlab.inputManager.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
         Zlab.inputManager.removeEventListener(KeyboardEvent.KEY_UP,this.onKeyUp);
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         this.onInputEvent(param1.keyCode,1);
      }
      
      private function onKeyUp(param1:KeyboardEvent) : void
      {
         this.onInputEvent(param1.keyCode,0);
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         this.onInputEvent(InputKey.MOUSE_BUTTON.keyCode,1);
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         this.onInputEvent(InputKey.MOUSE_BUTTON.keyCode,0);
      }
      
      private function onMouseMove(param1:MouseEvent) : void
      {
         if(this._lastMouseX == Number.NEGATIVE_INFINITY)
         {
            this._lastMouseX = Zlab.mainStage.mouseX;
            this._lastMouseY = Zlab.mainStage.mouseY;
            this._suppressDeltaNextTime = true;
            return;
         }
         if(param1.stageX != this._lastMouseX || this._suppressDeltaNextTime)
         {
            this.onInputEvent(InputKey.MOUSE_X.keyCode,this._suppressDeltaNextTime ? 0 : Zlab.mainStage.mouseX - this._lastMouseX);
         }
         if(param1.stageY != this._lastMouseY || this._suppressDeltaNextTime)
         {
            this.onInputEvent(InputKey.MOUSE_Y.keyCode,this._suppressDeltaNextTime ? 0 : Zlab.mainStage.mouseY - this._lastMouseY);
         }
         this._lastMouseX = param1.stageX;
         this._lastMouseY = param1.stageY;
         this._suppressDeltaNextTime = false;
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         this.onInputEvent(InputKey.MOUSE_HOVER.keyCode,1);
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         this.onInputEvent(InputKey.MOUSE_HOVER.keyCode,0);
      }
      
      private function onMouseWheel(param1:MouseEvent) : void
      {
         this.onInputEvent(InputKey.MOUSE_WHEEL.keyCode,param1.delta);
      }
      
      private function onInputEvent(param1:int, param2:Number) : void
      {
         var _loc3_:String = this._keymap[param1];
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:Function = this._bindings[_loc3_];
         if(_loc4_ == null)
         {
            Logger.print(this,"Got an action for \'" + _loc3_ + "\' but no registered callback; ignoring.");
            return;
         }
         _loc4_(param2);
      }
   }
}

