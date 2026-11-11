package core.ui.menuitem.battleListMenu
{
   import core.ZGlobal;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class BattleListMenuGridSlot extends GridSlot
   {
      
      public static const SELECTED:String = "selected";
      
      public static const SLOTTYPE_DOMINANCE:uint = 0;
      
      public static const SLOTTYPE_BBLITZ:uint = 1;
      
      private static const SLOTSTYLE_LOCKED:int = 0;
      
      private static const SLOTSTYLE_ACTIVE:int = 1;
      
      private static const LOCKED_ICON_PATH:String = "assets/game/GeneralAssetGroup_UI.swf/DominanceStarLock_36.png";
      
      private var m_data:Object;
      
      private var m_index:int = 0;
      
      private var m_style:int = 0;
      
      private var m_loaders:Array = null;
      
      private var m_button:ZGameButton = null;
      
      public function BattleListMenuGridSlot(param1:MovieClip, param2:int, param3:int, param4:Object)
      {
         this.m_data = param4;
         this.m_index = param3;
         super(null,param1,null);
         slot.x = param2 * sizerWidth;
         slot.y = param3 * sizerHeight;
         this.configButtonStyle();
         this.m_loaders = new Array();
         this.configButtonImages();
      }
      
      public function get battleType() : uint
      {
         return this.m_data.battleType;
      }
      
      override public function dispose() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         if(this.m_button)
         {
            this.m_button.dispose();
         }
         super.dispose();
      }
      
      override protected function createSlot(param1:SWFResource) : MovieClip
      {
         return new MapChooserButton();
      }
      
      override protected function onRollOver(param1:MouseEvent) : void
      {
      }
      
      override protected function onRollOut(param1:MouseEvent) : void
      {
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         if(this.m_style != SLOTSTYLE_LOCKED)
         {
            UIDispatcher.instance.dispatchEvent(new WorldEvent(SELECTED,this));
         }
      }
      
      private function configButtonStyle() : void
      {
         if(this.m_data.enabled)
         {
            this.m_style = SLOTSTYLE_ACTIVE;
         }
         else
         {
            this.m_style = SLOTSTYLE_LOCKED;
         }
         this.configButtons();
      }
      
      private function configButtons() : void
      {
         slot.status_icon.visible = false;
         slot.selected_mc.visible = false;
         slot.highlight_mc.visible = false;
         slot.battle_btn.visible = false;
         slot.default_btn.visible = this.m_style == SLOTSTYLE_ACTIVE;
         slot.locked_mc.visible = this.m_style == SLOTSTYLE_LOCKED;
         if(this.m_data.highlightNew)
         {
            TextFieldUtil.compactTextField(slot.new_tf,ZGameUtils.ZlocT("Dialogs","NewCaps"),{
               "maxLines":1,
               "minScale":0.7
            });
            slot.new_tf.visible = true;
         }
         else
         {
            slot.new_tf.visible = false;
         }
         this.setButtonText(this.m_data.buttonTextKey);
         switch(this.m_style)
         {
            case SLOTSTYLE_ACTIVE:
               this.m_button = new ZGameButton(slot.default_btn,this.doOnClick);
               break;
            case SLOTSTYLE_LOCKED:
               this.m_button = new ZGameButton(slot.locked_mc,this.doOnClick);
               Tooltip.subscribe(slot,ZGameUtils.ZlocT("Dialogs","ComingSoon"));
         }
      }
      
      private function configButtonImages() : void
      {
         var _loc1_:ImageLoader = null;
         switch(this.m_style)
         {
            case SLOTSTYLE_LOCKED:
               _loc1_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(LOCKED_ICON_PATH),slot.map_icon);
               break;
            default:
               _loc1_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.m_data.iconName),slot.map_icon);
         }
         if(_loc1_)
         {
            _loc1_.smooth = true;
            this.m_loaders.push(_loc1_);
         }
      }
      
      private function setButtonText(param1:String) : void
      {
         var _loc3_:String = null;
         var _loc2_:MovieClip = null;
         switch(this.m_style)
         {
            case SLOTSTYLE_ACTIVE:
               _loc2_ = slot.default_btn;
               break;
            case SLOTSTYLE_LOCKED:
               _loc2_ = slot.locked_mc;
         }
         if(_loc2_)
         {
            _loc3_ = ZGameUtils.ZlocT("Main",param1);
            TextFieldUtil.processTextField(_loc2_.generic_tf,_loc3_);
            if(_loc2_.generic_tf.numLines <= 1)
            {
               _loc2_.generic_tf.y = _loc2_.anchor_mc.y;
            }
         }
      }
   }
}

