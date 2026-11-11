package displays.screens
{
   import core.ZGlobal;
   import core.entities.components.behaviors.states.BuildingPartsDialogState;
   import core.gamemode.GMObjectPlace;
   import core.gamemode.GameModeManager;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import core.managers.WorldObjectManager;
   import core.ui.GenericButton;
   import dispatchers.UIDispatcher;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import events.MarketEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class WonderHeraquaters extends ZGamePopUp
   {
      
      public function WonderHeraquaters()
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/WonderHeadquarters.swf"));
      }
      
      private function placeObject(param1:String) : void
      {
         var _loc2_:GameItem = null;
         var _loc3_:int = 0;
         if(ZGlobal.isHome())
         {
            _loc2_ = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
            if(_loc2_)
            {
               _loc3_ = ZGlobal.player.getNumberOfInventoryItems(param1);
               if(_loc3_ > 0)
               {
                  GameModeManager.instance.addGameMode(new GMObjectPlace(_loc2_.name,MarketEvent.SOURCE_INVENTORY,true));
               }
            }
         }
      }
      
      private function populateCard(param1:Object, param2:String, param3:String) : void
      {
         var gItem:GameItem = null;
         var button:GenericButton = null;
         var inventoryQty:int = 0;
         var card:Object = param1;
         var code:String = param2;
         var exp:String = param3;
         gItem = null;
         if(ZGlobal.gameSettings.getItemByCode(code,GameItem))
         {
            gItem = ZGlobal.gameSettings.getItemByCode(code,GameItem) as GameItem;
         }
         if(gItem)
         {
            card.check_mc.visible = false;
            card.soon_tf.visible = false;
            TextFieldUtil.processTextField(card.title_tf,gItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(gItem.name,"sw"),card.icon);
            if(ExperimentsManager.instance.getExperimentVariant(exp) <= 0)
            {
               button = new GenericButton(card.buy_bt);
               button.text = ZGameUtils.ZlocT("Dialogs","Place_text");
               button.turnOff();
               button.disabled = true;
               button.turnOff();
               TextFieldUtil.processTextField(card.soon_tf,ZGameUtils.ZlocT("Dialogs","Soon_text"));
               card.soon_tf.visible = true;
            }
            else
            {
               inventoryQty = ZGlobal.player.inventory[gItem.code] ? int(ZGlobal.player.inventory[gItem.code]) : 0;
               if(inventoryQty > 0)
               {
                  button = new GenericButton(card.buy_bt,function(param1:MouseEvent):void
                  {
                     placeObject(gItem.code);
                     close();
                  });
                  button.turnOff();
                  button.text = ZGameUtils.ZlocT("Dialogs","Place_text");
                  button.turnOn();
               }
               else if(WorldObjectManager.instance.getNumberBuiltObjectsWithCode(gItem.code) <= 0)
               {
                  button = new GenericButton(card.buy_bt,function(param1:MouseEvent):void
                  {
                     UIDispatcher.instance.dispatchEvent(new WorldEvent(BuildingPartsDialogState.SHOW_BUILDING_PART_DIALOG + gItem.code));
                     close();
                  });
                  button.turnOff();
                  button.text = ZGameUtils.ZlocT("Dialogs","Finish_text");
                  button.turnOn();
               }
               else
               {
                  button = new GenericButton(card.buy_bt);
                  button.text = ZGameUtils.ZlocT("Dialogs","Place_text");
                  button.turnOff();
                  button.disabled = true;
                  card.check_mc.visible = true;
               }
            }
         }
      }
      
      override protected function initDialog() : void
      {
         var _loc1_:GenericButton = null;
         var _loc2_:int = 0;
         super.initDialog();
         m_window.visible = true;
         m_window.card_mc1.visible = true;
         m_window.card_mc2.visible = true;
         m_window.card_mc3.visible = true;
         m_window.card_wonder_mc.check_mc.visible = false;
         if(Boolean(WorldObjectManager.instance.getNumberBuiltObjectsWithCode("BB20")) && Boolean(WorldObjectManager.instance.getNumberBuiltObjectsWithCode("BB19")) && Boolean(WorldObjectManager.instance.getNumberBuiltObjectsWithCode("BB21")))
         {
            _loc2_ = ZGlobal.player.inventory["BB22"] ? int(ZGlobal.player.inventory["BB22"]) : 0;
            if(_loc2_ > 0)
            {
               m_window.card_wonder_mc.locked_mc.visible = false;
               _loc1_ = new GenericButton(m_window.card_wonder_mc.place_bt,this.onFluxatronActivation);
               _loc1_.text = ZGameUtils.ZlocT("Dialogs","Active_text");
            }
            else if(WorldObjectManager.instance.getNumberBuiltObjectsWithCode("BB22"))
            {
               m_window.card_wonder_mc.check_mc.visible = true;
               m_window.card_wonder_mc.locked_mc.visible = false;
               _loc1_ = new GenericButton(m_window.card_wonder_mc.place_bt,this.onFluxatronActivation);
               _loc1_.text = ZGameUtils.ZlocT("Dialogs","Active_text");
               _loc1_.turnOff();
            }
         }
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClicked);
         m_window.exit_bt.visible = true;
         TextFieldUtil.processTextField(m_window.title_tf,ZGameUtils.ZlocT("Dialogs","Fluxatron_Title"));
         TextFieldUtil.processTextField(m_window.description_tf,ZGameUtils.ZlocT("Dialogs","Fluxatron_Desc"));
         m_window.title_tf.visible = true;
         m_window.description_tf.visible = true;
         this.populateCard(m_window.card_mc3,"BB21","empire_wonder_3");
         this.populateCard(m_window.card_mc2,"BB19","empire_wonder_2");
         this.populateCard(m_window.card_mc1,"BB20","empire_wonder_1");
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         m_window = param1.clip.screen_mc;
         addChild(m_window);
         m_origOffsetX = m_window.x;
         m_origOffsetY = m_window.y;
         this.contentWidth = m_window.panel_mc.width;
         this.contentHeight = m_window.panel_mc.height;
         this.initDialog();
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function onExitClicked(param1:MouseEvent) : void
      {
         close();
      }
      
      private function onFluxatronActivation(param1:MouseEvent) : void
      {
         this.placeObject("BB22");
         close();
      }
   }
}

