package core.ui.menuitem
{
   import com.greensock.TweenLite;
   import com.greensock.easing.Back;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.utils.Dictionary;
   
   public class MenuItem extends Sprite
   {
      
      protected var _uiDisplayObject:Sprite;
      
      protected var m_menuItems:Dictionary;
      
      protected var tweenTimeSeconds:Number = 1;
      
      private var _uiParent:MenuItem;
      
      public var id:String;
      
      public function MenuItem(param1:String)
      {
         super();
         this.m_menuItems = new Dictionary(true);
         this.id = param1;
      }
      
      public function set uiParent(param1:MenuItem) : void
      {
         this._uiParent = param1;
      }
      
      public function get uiParent() : MenuItem
      {
         return this._uiParent;
      }
      
      public function addItem(param1:MenuItem, param2:int = 0) : MenuItem
      {
         this.m_menuItems[param1.id] = param1;
         param1.uiParent = this;
         addChild(param1);
         return param1;
      }
      
      public function getChildById(param1:String) : MenuItem
      {
         if(this.m_menuItems[param1])
         {
            return this.m_menuItems[param1];
         }
         return null;
      }
      
      public function removeItem() : void
      {
      }
      
      public function show(param1:Boolean = false) : void
      {
         this.visible = true;
         if(param1)
         {
            this.alpha = 0;
            TweenLite.to(this,this.tweenTimeSeconds,{
               "alpha":1,
               "ease":Back.easeOut,
               "onComplete":this.showTweenComplete
            });
         }
      }
      
      public function moveToNewLayer(param1:DisplayObjectContainer, param2:int = 0) : void
      {
         param1.addChildAt(this,param2);
      }
      
      public function hide(param1:Boolean = false) : void
      {
         if(param1)
         {
            TweenLite.to(this,this.tweenTimeSeconds,{
               "alpha":0,
               "ease":Back.easeOut,
               "onComplete":this.hideTweenComplete
            });
         }
         else
         {
            this.visible = false;
         }
      }
      
      protected function hideTweenComplete() : void
      {
         this.visible = false;
      }
      
      protected function showTweenComplete() : void
      {
      }
      
      public function destroy() : void
      {
         this.m_menuItems = null;
         this._uiParent = null;
      }
   }
}

