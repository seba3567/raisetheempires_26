package core.ui.menuitem.campaignMapMenu
{
   import core.ZGlobal;
   import core.managers.tutorialManager.TutorialManager;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class CampaignMapMenuGridSlot extends GridSlot
   {
      
      public static const CAMPAIGNMAPMENUGRIDSLOT_SELECTED:String = "campaignMapMenuGridSlotSelected";
      
      private static const SLOTSTYLE_LOCKED:int = 0;
      
      private static const SLOTSTYLE_ACTIVE:int = 1;
      
      private static const SLOTSTYLE_SELECTED:int = 2;
      
      private static const SLOTSTYLE_INVADED:int = 3;
      
      private var m_data:CampaignMapMenuMapData = null;
      
      private var m_index:int = 0;
      
      private var m_style:int = 0;
      
      private var m_loaders:Array = null;
      
      private var m_button:ZGameButton = null;
      
      public function CampaignMapMenuGridSlot(param1:MovieClip, param2:int, param3:int, param4:CampaignMapMenuMapData)
      {
         this.m_data = param4;
         this.m_index = param3;
         super(null,param1,null);
         slot.x = param2 * sizerWidth;
         slot.y = param3 * sizerHeight;
         slot.highlight_mc.visible = false;
         this.configButtonStyle();
         this.m_loaders = new Array();
         this.configButtonImages();
         if(this.m_data.showAsNew)
         {
            TextFieldUtil.compactTextField(slot.new_tf,ZGameUtils.ZlocT("Dialogs","NewCaps"),{
               "maxLines":1,
               "minScale":0.7
            });
         }
         else
         {
            slot.new_tf.visible = false;
         }
         TutorialManager.instance.addEventListener(TutorialManager.CAMPAIGN_SELECTOR_HIGHLIGHT,this.onHighlight,false,0,true);
      }
      
      override public function dispose() : void
      {
         var _loc1_:ImageLoader = null;
         TutorialManager.instance.removeEventListener(TutorialManager.CAMPAIGN_SELECTOR_HIGHLIGHT,this.onHighlight);
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
            UIDispatcher.instance.dispatchEvent(new WorldEvent(CAMPAIGNMAPMENUGRIDSLOT_SELECTED,this));
         }
      }
      
      public function get campaignName() : String
      {
         return this.m_data.name;
      }
      
      private function configButtonStyle() : void
      {
         if(this.m_data.isLocked)
         {
            this.m_style = SLOTSTYLE_LOCKED;
         }
         else if(this.m_data.name == ZGlobal.player.campaign.currentCampaignName)
         {
            this.m_style = SLOTSTYLE_SELECTED;
         }
         else
         {
            this.m_style = SLOTSTYLE_ACTIVE;
         }
         this.configButtons();
      }
      
      private function configButtons() : void
      {
         slot.default_btn.visible = this.m_style == SLOTSTYLE_ACTIVE;
         slot.battle_btn.visible = this.m_style == SLOTSTYLE_INVADED;
         slot.selected_mc.visible = this.m_style == SLOTSTYLE_SELECTED;
         slot.locked_mc.visible = this.m_style == SLOTSTYLE_LOCKED;
         slot.new_tf.visible = true;
         this.setButtonText(this.m_data.menuName);
         switch(this.m_style)
         {
            case SLOTSTYLE_ACTIVE:
               this.m_button = new ZGameButton(slot.default_btn,this.doOnClick);
               break;
            case SLOTSTYLE_INVADED:
               this.m_button = new ZGameButton(slot.battle_btn,this.doOnClick);
               break;
            case SLOTSTYLE_SELECTED:
               this.m_button = new ZGameButton(slot.selected_mc,this.doOnClick);
               break;
            case SLOTSTYLE_LOCKED:
               this.m_button = new ZGameButton(slot.locked_mc,this.doOnClick);
               slot.new_tf.visible = false;
               Tooltip.subscribe(slot,ZGameUtils.ZlocT("Campaign","CampaignUnlockLevelTooltip",{"level":25}));
         }
      }
      
      private function configButtonImages() : void
      {
         switch(this.m_style)
         {
            case SLOTSTYLE_LOCKED:
               this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/Campaign02_Menu_Lock_36.png"),slot.map_icon));
               break;
            default:
               this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.m_data.iconName),slot.map_icon));
         }
      }
      
      private function setButtonText(param1:String) : void
      {
         var _loc2_:MovieClip = null;
         switch(this.m_style)
         {
            case SLOTSTYLE_ACTIVE:
               _loc2_ = slot.default_btn;
               break;
            case SLOTSTYLE_INVADED:
               _loc2_ = slot.battle_btn;
               break;
            case SLOTSTYLE_SELECTED:
               _loc2_ = slot.selected_mc;
               break;
            case SLOTSTYLE_LOCKED:
               _loc2_ = slot.locked_mc;
         }
         if(_loc2_)
         {
            TextFieldUtil.processTextField(_loc2_.generic_tf,param1);
            if(_loc2_.generic_tf.numLines <= 1)
            {
               _loc2_.generic_tf.y = _loc2_.anchor_mc.y;
            }
         }
      }
      
      private function onHighlight(param1:WorldEvent) : void
      {
         var _loc2_:Point = null;
         var _loc3_:Number = NaN;
         var _loc4_:Point = null;
         if(param1.eventData as int == this.m_index)
         {
            _loc2_ = new Point(slot.width * 0.5,slot.height * 0.5);
            _loc3_ = 0.6;
            _loc4_ = new Point(-110,150);
            TutorialManager.instance.addStencilToUIElement(slot,_loc2_,_loc3_);
            TutorialManager.instance.addArrowToUIElement(slot,true,true,_loc4_,-90);
         }
         else
         {
            this.m_button.disable();
            disable();
         }
      }
   }
}

