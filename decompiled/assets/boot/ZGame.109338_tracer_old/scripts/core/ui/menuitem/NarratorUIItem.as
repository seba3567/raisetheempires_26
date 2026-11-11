package core.ui.menuitem
{
   import com.greensock.TweenLite;
   import core.ui.UIManager;
   import flash.events.FullScreenEvent;
   import flash.geom.Rectangle;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zgame.assets.ui.TutorialPopup;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   
   public class NarratorUIItem extends MenuItem
   {
      
      public static const ITEM_ID:String = "narratorUIItem";
      
      public static const IMMEDIATE:String = "immediate";
      
      public static const ADD_NARRATOR_EVENT:String = "addnarratorevent";
      
      public static const REMOVE_NARRATOR_EVENT:String = "removenarratorevent";
      
      private static const NARRATOR_BAR_OFFSETY:Number = 35;
      
      private static const NARRATOR_BAR_OFFSETX:Number = 15;
      
      public static var NARRATOR_UPPER_RIGHT:String = "UPPER_RIGHT";
      
      public static var NARRATOR_LOWER_RIGHT:String = "LOWER_RIGHT";
      
      public static var NARRATOR_LOWER_LEFT:String = "LOWER_LEFT";
      
      public static var NARRATOR_UPPER_LEFT:String = "UPPER_LEFT";
      
      private var m_bar:TutorialPopup = null;
      
      private var m_location:String = NARRATOR_UPPER_RIGHT;
      
      private var m_bubbleScale:Number = 0;
      
      public function NarratorUIItem()
      {
         super(ITEM_ID);
         this.m_bar = new TutorialPopup();
         this.m_bar.mouseEnabled = false;
         addChild(this.m_bar);
         this.visible = false;
         this.m_bubbleScale = this.m_bar.speechBubble_mc.scaleX;
         addEventListener(ADD_NARRATOR_EVENT,this.onAddNarratorEvent);
         addEventListener(REMOVE_NARRATOR_EVENT,this.onRemoveNarratorEvent);
         Zlab.inputManager.addEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreen,false,0,true);
      }
      
      public static function getNarratorBar() : MenuItem
      {
         return UIManager.instance.getMenuItemByName(NarratorUIItem.ITEM_ID);
      }
      
      public function get location() : String
      {
         return this.m_location;
      }
      
      public function set location(param1:String) : void
      {
         this.m_location = param1;
      }
      
      override public function removeItem() : void
      {
         this.m_bar = null;
         removeEventListener(ADD_NARRATOR_EVENT,this.onAddNarratorEvent);
         removeEventListener(REMOVE_NARRATOR_EVENT,this.onRemoveNarratorEvent);
      }
      
      private function onAddNarratorEvent(param1:WorldEvent) : void
      {
         var _loc2_:Number = 1;
         if(null != param1.eventData.scale)
         {
            _loc2_ = Number(param1.eventData.scale);
         }
         this.m_bar.text_mc.generic_tf.scaleX = _loc2_;
         this.m_bar.text_mc.generic_tf.scaleY = _loc2_;
         TextFieldUtil.processTextField(this.m_bar.text_mc.generic_tf,param1.eventData.text);
         ZGameUtils.alignTextVertically(this.m_bar.text_mc.generic_tf);
      }
      
      private function onRemoveNarratorEvent(param1:WorldEvent) : void
      {
      }
      
      override public function show(param1:Boolean = false) : void
      {
         this.visible = true;
         this.FlipHorizontal();
         this.updateLocation(param1);
      }
      
      override public function hide(param1:Boolean = false) : void
      {
         var _loc2_:Rectangle = this.getBounds(this);
         var _loc3_:Number = _loc2_.top < 0 ? Math.abs(_loc2_.top) : 0;
         var _loc4_:Number = 0;
         switch(this.m_location)
         {
            case NARRATOR_LOWER_LEFT:
            case NARRATOR_LOWER_RIGHT:
               _loc4_ = Zlab.mainStage.stageHeight + _loc3_;
               break;
            case NARRATOR_UPPER_RIGHT:
            case NARRATOR_UPPER_LEFT:
               _loc4_ = 0 - this.height;
         }
         if(param1)
         {
            TweenLite.to(this,0.5,{
               "y":_loc4_,
               "onComplete":this.onHideComplete
            });
         }
         else
         {
            this.y = Zlab.mainStage.stageHeight + _loc3_;
            this.visible = false;
         }
      }
      
      private function onHideComplete() : void
      {
         this.visible = false;
      }
      
      public function FlipHorizontal() : void
      {
         switch(this.m_location)
         {
            case NARRATOR_LOWER_LEFT:
            case NARRATOR_UPPER_LEFT:
               this.m_bar.scarlettContainer_mc.x = 0;
               this.m_bar.ring_mc.x = 33;
               this.m_bar.speechBubble_mc.scaleX = this.m_bubbleScale * -1;
               this.m_bar.speechBubble_mc.x = this.m_bar.speechBubble_mc.width + 142;
               this.m_bar.text_mc.x = 179;
               break;
            case NARRATOR_LOWER_RIGHT:
            case NARRATOR_UPPER_RIGHT:
               this.m_bar.speechBubble_mc.scaleX = this.m_bubbleScale;
               this.m_bar.speechBubble_mc.x = 0;
               this.m_bar.text_mc.x = 12;
               this.m_bar.scarlettContainer_mc.x = 192;
               this.m_bar.ring_mc.x = 225;
         }
      }
      
      private function updateLocation(param1:Boolean) : void
      {
         var _loc2_:Number = 0;
         TweenLite.killTweensOf(this);
         switch(this.m_location)
         {
            case NARRATOR_LOWER_LEFT:
               this.x = 0;
               _loc2_ = Zlab.mainStage.stageHeight - this.height + NARRATOR_BAR_OFFSETY;
               break;
            case NARRATOR_LOWER_RIGHT:
               this.x = Zlab.mainStage.stageWidth - this.width - NARRATOR_BAR_OFFSETX;
               _loc2_ = Zlab.mainStage.stageHeight - this.height + NARRATOR_BAR_OFFSETY;
               break;
            case NARRATOR_UPPER_RIGHT:
               this.y = 0 - this.height;
               this.x = Zlab.mainStage.stageWidth - this.width - NARRATOR_BAR_OFFSETX;
               _loc2_ += NARRATOR_BAR_OFFSETY;
               break;
            case NARRATOR_UPPER_LEFT:
               this.x = 0;
               this.y = 0 - this.height;
               _loc2_ += NARRATOR_BAR_OFFSETY;
         }
         if(param1)
         {
            TweenLite.to(this,0.5,{"y":_loc2_});
         }
         else
         {
            this.y = _loc2_;
         }
      }
      
      private function onFullScreen(param1:FullScreenEvent) : void
      {
         if(this.visible)
         {
            this.updateLocation(false);
         }
      }
   }
}

