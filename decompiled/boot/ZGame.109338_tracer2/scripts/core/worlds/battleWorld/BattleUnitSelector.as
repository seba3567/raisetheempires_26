package core.worlds.battleWorld
{
   import dispatchers.StrategicDispatcher;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import zlabs.Zlab;
   import zlabs.core.ITickedObject;
   import zlabs.events.WorldEvent;
   
   public class BattleUnitSelector implements ITickedObject
   {
      
      private var m_layer:Sprite = null;
      
      private var m_selected:Object = null;
      
      private var m_disposed:Boolean = false;
      
      public function BattleUnitSelector(param1:Sprite)
      {
         super();
         this.m_layer = param1;
         this.m_layer.addEventListener(MouseEvent.CLICK,this.onLayerClick);
         StrategicDispatcher.instance.addEventListener(StrategicDispatcher.BATTLE_COMPLETE,this.onBattleComplete);
         Zlab.processManager.addTickedObject(this);
      }
      
      public function dispose() : void
      {
         if(!this.m_disposed)
         {
            Zlab.processManager.removeTickedObject(this);
            StrategicDispatcher.instance.removeEventListener(StrategicDispatcher.BATTLE_COMPLETE,this.onBattleComplete);
            this.m_layer.removeEventListener(MouseEvent.CLICK,this.onLayerClick);
            this.m_layer = null;
            this.m_selected = null;
            this.m_disposed = true;
         }
      }
      
      protected function isValid(param1:Object, param2:Point) : Boolean
      {
         return false;
      }
      
      protected function dispatcher(param1:Object) : EventDispatcher
      {
         return param1 as EventDispatcher;
      }
      
      protected function select(param1:Object) : void
      {
         var _loc2_:EventDispatcher = null;
         if(this.m_selected != param1)
         {
            _loc2_ = this.dispatcher(param1);
            if(_loc2_)
            {
               _loc2_.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER));
            }
         }
         this.m_selected = param1;
      }
      
      private function deselect() : void
      {
         var _loc1_:EventDispatcher = null;
         if(this.m_selected)
         {
            _loc1_ = this.dispatcher(this.m_selected);
            if(_loc1_)
            {
               _loc1_.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
            }
            this.m_selected = null;
         }
      }
      
      private function onBattleComplete(param1:WorldEvent) : void
      {
         this.deselect();
         this.dispose();
      }
      
      public function onTick(param1:Number) : void
      {
         var _loc7_:Object = null;
         var _loc2_:Boolean = true;
         var _loc3_:Stage = Zlab.mainStage;
         var _loc4_:Point = new Point(_loc3_.mouseX,_loc3_.mouseY);
         var _loc5_:Array = _loc3_.getObjectsUnderPoint(_loc4_);
         var _loc6_:* = int(_loc5_.length - 1);
         while(_loc6_ >= 0)
         {
            _loc7_ = _loc5_[_loc6_];
            if(this.isValid(_loc7_,_loc4_))
            {
               _loc2_ = false;
               if(_loc7_ != this.m_selected)
               {
                  this.deselect();
                  this.select(_loc7_);
               }
               break;
            }
            _loc6_--;
         }
         if(_loc2_)
         {
            this.deselect();
         }
      }
      
      private function onLayerClick(param1:MouseEvent) : void
      {
         var _loc2_:EventDispatcher = null;
         if(this.m_selected)
         {
            _loc2_ = this.dispatcher(this.m_selected);
            if(_loc2_)
            {
               _loc2_.dispatchEvent(new MouseEvent(MouseEvent.CLICK,false));
            }
         }
      }
   }
}

