package core.worlds.battleWorld
{
   import core.ZGlobal;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.GameItem;
   import core.ui.Tooltip;
   import displays.ImageLoaderFactory;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import utils.ZGameUtils;
   
   public class BattleUnitIcon
   {
      
      private static const ICON_SIZE:int = 24;
      
      private var m_parent:DisplayObjectContainer = null;
      
      private var m_sprite:Sprite = null;
      
      private var m_bitmap:Bitmap = null;
      
      private var m_currentString:String = null;
      
      private var m_focus:Boolean = false;
      
      public function BattleUnitIcon(param1:DisplayObjectContainer)
      {
         super();
         this.m_parent = param1;
         this.m_sprite = new Sprite();
         this.m_parent.addChild(this.m_sprite);
         this.m_bitmap = new Bitmap();
         this.m_sprite.addChild(this.m_bitmap);
         this.m_sprite.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
         this.m_sprite.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
      }
      
      public function onImageLoaded(param1:String, param2:BitmapData) : void
      {
         if(null != this.m_bitmap)
         {
            if(this.m_currentString)
            {
               this.m_bitmap.bitmapData = param2;
               this.m_bitmap.smoothing = true;
            }
         }
      }
      
      public function update(param1:ConsumableItem, param2:Object, param3:uint, param4:uint) : void
      {
         ImageLoaderFactory.CreateImageLoader(this.getBarIconUrl(param1),null,this.onImageLoaded);
         this.m_currentString = this.getTooltipString(param1,param2);
         var _loc5_:Number = 1;
         if(param4 > 3)
         {
            _loc5_ = 3 / Number(param4);
         }
         this.m_sprite.scaleX = this.m_sprite.scaleY = _loc5_;
         this.m_bitmap.x = param3 * ICON_SIZE;
         this.m_bitmap.y = -ICON_SIZE;
         if(this.m_focus)
         {
            Tooltip.getInstance().setCurrentProps(this.m_currentString);
            Tooltip.getInstance().updateText();
         }
      }
      
      public function dispose() : void
      {
         this.clear();
         this.m_sprite.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.m_sprite.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.m_sprite.removeChild(this.m_bitmap);
         this.m_bitmap = null;
         this.m_parent.removeChild(this.m_sprite);
         this.m_sprite = null;
      }
      
      public function clear() : void
      {
         this.m_currentString = null;
         this.m_bitmap.bitmapData = null;
         if(this.m_focus)
         {
            Tooltip.hide();
         }
      }
      
      private function getBarIconUrl(param1:ConsumableItem) : String
      {
         return ZGlobal.gameSettings.getImageByName(param1.name,"bar");
      }
      
      private function getTooltipString(param1:ConsumableItem, param2:Object) : String
      {
         var _loc3_:Object = new Object();
         _loc3_.nameColor = "#ff6666";
         _loc3_.itemName = param1.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
         _loc3_.current = param2.duration ? param2.duration.toString() : 0;
         if(param1.code == ConsumableItem.DOUBLE_SHOT_ITEM_CODE)
         {
            ++_loc3_.current;
         }
         return ZGameUtils.ZlocT("Tooltips","Icon_Tooltip",_loc3_);
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         if(null != this.m_currentString)
         {
            this.m_focus = true;
            Tooltip.show(this.m_currentString);
         }
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         this.m_focus = false;
         Tooltip.hide();
      }
   }
}

