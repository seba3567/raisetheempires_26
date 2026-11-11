package displays.popups
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import core.entities.components.behaviors.states.NeighborhoodDialogState;
   import core.gamemode.GMNeighborhoodAdd;
   import core.gamemode.GMNeighborhoodRemove;
   import core.gamemode.GameModeManager;
   import core.gameobjects.CrewTemplateWrapper;
   import core.gameobjects.GameItem;
   import core.managers.CrewManager;
   import core.managers.rewardPickupManager.RewardPickupManager;
   import core.ui.ZGameButton;
   import displays.ImageLoaderFactory;
   import displays.popups.buyEnergy.BuyEnergyPopup;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.requests.RequestCrewDialog;
   import entity.GameDataComponent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import transactions.TGetNeighborhoodInfo;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class NeighborhoodDialog extends ZGamePopUp
   {
      
      public static const NUM_SLOTS:int = 5;
      
      public static const NUM_BLOCKS:int = 3;
      
      protected var m_blocks:int = 1;
      
      protected var m_entity:IEntity;
      
      protected var m_block:int = 1;
      
      protected var m_gdc:GameDataComponent;
      
      protected var m_result:Object;
      
      protected var m_resource:SWFResource;
      
      protected var m_block1:ZGameButton;
      
      protected var m_block2:ZGameButton;
      
      protected var m_block3:ZGameButton;
      
      protected var m_harvest:ZGameButton;
      
      protected var m_buttons:Array;
      
      protected var m_state:NeighborhoodDialogState;
      
      protected const NUM_CREW:int = 3;
      
      protected const CREW_COST:int = 3;
      
      protected var bonusInfo:Array = new Array();
      
      public function NeighborhoodDialog(param1:IEntity, param2:NeighborhoodDialogState)
      {
         this.m_entity = param1;
         this.m_state = param2;
         this.m_blocks = param2.data.@blocks;
         var _loc3_:GameDataComponent = GameDataComponent(this.m_entity.lookupComponentByType(GameDataComponent));
         this.m_gdc = _loc3_;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_Neighborhood.swf"));
         this.bonusInfo.push(5);
         this.bonusInfo.push(7);
         this.bonusInfo.push(10);
      }
      
      public static function display(param1:IEntity, param2:NeighborhoodDialogState) : PopUpBase
      {
         var _loc3_:PopUpBase = new NeighborhoodDialog(param1,param2);
         WindowManager.instance.push(_loc3_);
         return _loc3_;
      }
      
      protected function populateCard(param1:MovieClip, param2:Object) : void
      {
         var _loc3_:ZGameButton = null;
         var _loc4_:GameItem = null;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         if(param1)
         {
            if(param2)
            {
               _loc4_ = ZGlobal.gameSettings.getItemByName(param2.itemName,GameItem) as GameItem;
               if(param1.itemName_tf)
               {
                  TextFieldUtil.compactTextField(param1.itemName_tf,_loc4_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
               }
               if(param1.buildingIcon_mc)
               {
                  param1.buildingIcon_mc.visible = true;
                  ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(param2.itemName,"icon"),param1.buildingIcon_mc);
               }
               if(param1.description_tf)
               {
                  for each(_loc6_ in this.m_result.harvest_info)
                  {
                     if(Boolean(_loc6_.id) && param2.id == _loc6_.id)
                     {
                        TextFieldUtil.compactTextField(param1.description2_tf,ZGameUtils.ZlocT("Dialogs","Neighborhood_coins_ready",{"value":_loc6_.coins}));
                        break;
                     }
                  }
                  TextFieldUtil.compactTextField(param1.description_tf,ZGameUtils.ZlocT("Dialogs","Neighborhood_population",{"value":_loc4_.workers}));
               }
               if(param1.fill_bt)
               {
                  _loc3_ = new ZGameButton(param1.fill_bt,this.onRemove);
                  _loc3_.text = ZGameUtils.ZlocT("Dialogs","Neighborhood_Remove");
                  if(this.m_buttons == null)
                  {
                     this.m_buttons = new Array();
                  }
                  this.m_buttons.push({
                     "button":_loc3_,
                     "item":param2
                  });
               }
               if(param1.harvest_mc)
               {
                  param1.harvest_mc.visible = false;
                  if(this.m_result.harvest_info[param2.id])
                  {
                     if(this.m_result.harvest_info[param2.id].duration == -1)
                     {
                        param1.harvest_mc.visible = true;
                     }
                  }
               }
            }
            else
            {
               if(param1.itemName_tf)
               {
                  TextFieldUtil.compactTextField(param1.itemName_tf,ZGameUtils.ZlocT("Dialogs","Neighborhood_Empty"));
               }
               if(param1.description_tf)
               {
                  TextFieldUtil.compactTextField(param1.description_tf,ZGameUtils.ZlocT("Dialogs","Neighborhood_Empty"));
               }
               if(param1.description2_tf)
               {
                  TextFieldUtil.compactTextField(param1.description2_tf,"");
               }
               if(param1.fill_bt)
               {
                  _loc3_ = new ZGameButton(param1.fill_bt,this.onFill);
                  _loc3_.text = ZGameUtils.ZlocT("Dialogs","Neighborhood_Fill");
               }
               if(param1.buildingIcon_mc)
               {
                  param1.buildingIcon_mc.visible = false;
               }
               if(param1.harvest_mc)
               {
                  param1.harvest_mc.visible = false;
               }
            }
         }
      }
      
      protected function onHire(param1:MouseEvent) : void
      {
         StatsManager.count("dialog","Deco_interface","hire",this.m_gdc.gameData.name);
         if(WindowManager.isFullScreen())
         {
            WindowManager.toggleFullScreen();
         }
         var _loc2_:int = this.m_gdc.id;
         var _loc3_:int = 0;
         var _loc4_:Array = this.m_result.crewInfo as Array;
         if(_loc4_)
         {
            _loc3_ = int(_loc4_.length);
         }
         var _loc5_:CrewTemplateWrapper = ZGlobal.gameSettings.getCrewTemplateWrapper(this.m_gdc.gameData.name);
         PopupManager.instance.push(new RequestCrewDialog(_loc2_,this.m_gdc.gameData.name,this.NUM_CREW - _loc3_));
         close();
      }
      
      protected function onBuyCrew(param1:MouseEvent) : void
      {
         var _loc2_:Array = null;
         if(ZGlobal.player.canBuyCash(this.CREW_COST,true))
         {
            close();
            _loc2_ = this.m_result.crewInfo as Array;
            if(!this.m_result.crewInfo)
            {
               CrewManager.instance.buyCrewSlot(this.m_entity,this.CREW_COST,0);
            }
            else if(Boolean(_loc2_) && _loc2_.length < this.NUM_CREW)
            {
               CrewManager.instance.buyCrewSlot(this.m_entity,this.CREW_COST,_loc2_.length);
            }
         }
      }
      
      protected function populateLockedCard(param1:MovieClip) : void
      {
         var _loc2_:ZGameButton = null;
         var _loc3_:ZGameButton = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         if(param1.crew_bt)
         {
            _loc2_ = new ZGameButton(param1.crew_bt,this.onHire);
            _loc2_.text = ZGameUtils.ZlocT("Dialogs","Neighborhood_Crew");
         }
         if(param1.buy_bt)
         {
            _loc3_ = new ZGameButton(param1.buy_bt,this.onBuyCrew);
            _loc3_.text = ZGameUtils.ZlocT("Dialogs","Neighborhood_CrewBuy",{"value":this.CREW_COST});
         }
         if(param1.itemName_tf)
         {
            TextFieldUtil.compactTextField(param1.itemName_tf,ZGameUtils.ZlocT("Dialogs","Neighborhood_AskCrew"));
         }
         if(param1.description_tf)
         {
            _loc4_ = this.m_result.crewInfo as Array;
            _loc5_ = 0;
            if(_loc4_)
            {
               _loc5_ = int(_loc4_.length);
            }
            TextFieldUtil.compactTextField(param1.description_tf,ZGameUtils.ZlocT("Dialogs","Neighborhood_CrewInfo",{
               "have":_loc5_,
               "need":this.NUM_CREW
            }));
         }
      }
      
      protected function onTab(param1:MouseEvent) : void
      {
         if(param1.target == this.m_block1.hit)
         {
            removeChild(m_window);
            this.m_block = 1;
            this.setupUI(this.m_result);
         }
         else if(param1.target == this.m_block2.hit)
         {
            removeChild(m_window);
            this.m_block = 2;
            this.setupUI(this.m_result);
         }
         else if(param1.target == this.m_block3.hit)
         {
            removeChild(m_window);
            this.m_block = 3;
            this.setupUI(this.m_result);
         }
      }
      
      public function setupUI(param1:Object) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Class = null;
         var _loc6_:Array = null;
         this.m_result = param1;
         this.m_gdc.userData = param1;
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClicked);
         TextFieldUtil.compactTextField(m_window.title_tf,ZGameUtils.ZlocT("Dialogs","Neighborhood_Title"));
         TextFieldUtil.compactTextField(m_window.description_tf,ZGameUtils.ZlocT("Dialogs","Neighborhood_Desc"));
         TextFieldUtil.compactTextField(m_window.description2_tf,ZGameUtils.ZlocT("Dialogs","Neighborhood_Desc3"));
         TextFieldUtil.compactTextField(m_window.body_tf,ZGameUtils.ZlocT("Dialogs","Neighborhood_Desc2"));
         ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(this.m_gdc.objectName,"icon_150"),m_window.icon);
         this.m_block1 = new ZGameButton(m_window.tab01_mc,this.onTab,1.1,false,this.setTabs);
         this.m_block1.text = ZGameUtils.ZlocT("Dialogs","Neighborhood_Block1");
         m_window.tab01_mc.lock_mc.visible = false;
         if(this.m_blocks == 3)
         {
            this.m_block3 = new ZGameButton(m_window.tab03_mc,this.onTab,1.1,false,this.setTabs);
            this.m_block3.text = ZGameUtils.ZlocT("Dialogs","Neighborhood_Block3");
            m_window.tab03_mc.lock_mc.visible = false;
            this.m_block2 = new ZGameButton(m_window.tab02_mc,this.onTab,1.1,false,this.setTabs);
            this.m_block2.text = ZGameUtils.ZlocT("Dialogs","Neighborhood_Block2");
            m_window.tab02_mc.lock_mc.visible = false;
         }
         else if(this.m_blocks == 2)
         {
            this.m_block2 = new ZGameButton(m_window.tab02_mc,this.onTab,1.1,false,this.setTabs);
            this.m_block2.text = ZGameUtils.ZlocT("Dialogs","Neighborhood_Block2");
            m_window.tab02_mc.lock_mc.visible = false;
            this.m_block3 = new ZGameButton(m_window.tab03_mc,this.onUnlock,1.1,false,this.setTabs);
            this.m_block3.text = ZGameUtils.ZlocT("Dialogs","Neighborhood_Block3");
            m_window.tab03_mc.lock_mc.visible = true;
            this.m_block3.addTooltip(ZGameUtils.ZlocT("Dialogs","Neighborhood_block_tooltip"));
         }
         else if(this.m_blocks == 1)
         {
            this.m_block2 = new ZGameButton(m_window.tab02_mc,this.onUnlock,1.1,false,this.setTabs);
            this.m_block2.text = ZGameUtils.ZlocT("Dialogs","Neighborhood_Block2");
            m_window.tab02_mc.lock_mc.visible = true;
            this.m_block2.addTooltip(ZGameUtils.ZlocT("Dialogs","Neighborhood_block_tooltip"));
            this.m_block3 = new ZGameButton(m_window.tab03_mc,this.onUnlock,1.1,false,this.setTabs);
            this.m_block3.text = ZGameUtils.ZlocT("Dialogs","Neighborhood_Block3");
            m_window.tab03_mc.lock_mc.visible = true;
            this.m_block3.disable();
         }
         this.m_harvest = new ZGameButton(m_window.harvest_bt,this.onHarvest);
         var _loc2_:int = -this.getEnergyCost();
         TextFieldUtil.compactTextField(m_window.harvest_bt.generic2_tf,"x" + _loc2_);
         if(_loc2_ == 0)
         {
            this.m_harvest.disable_visual(true);
         }
         else
         {
            this.m_harvest.enable();
         }
         this.m_harvest.text = ZGameUtils.ZlocT("Dialogs","Neighborhood_Harvest");
         TextFieldUtil.compactTextField(m_window.body1_tf,ZGameUtils.ZlocT("Dialogs","Neighborhood_Bonus1"));
         TextFieldUtil.compactTextField(m_window.body2_tf,ZGameUtils.ZlocT("Dialogs","Neighborhood_Bonus2"));
         TextFieldUtil.compactTextField(m_window.body3_tf,ZGameUtils.ZlocT("Dialogs","Neighborhood_Bonus3"));
         var _loc5_:Object = param1.blocks;
         if(_loc5_)
         {
            _loc6_ = _loc5_["block" + this.m_block];
            m_window.contracts_mc.card5_mc.visible = false;
            if(_loc6_)
            {
               _loc3_ = 0;
               while(_loc3_ < 4)
               {
                  if(_loc3_ < _loc6_.length)
                  {
                     this.populateCard(m_window.contracts_mc["card" + (_loc3_ + 1) + "_mc"],_loc6_[_loc3_]);
                  }
                  else
                  {
                     this.populateCard(m_window.contracts_mc["card" + (_loc3_ + 1) + "_mc"],null);
                  }
                  _loc3_++;
               }
               if(this.m_block == 1 && !param1.slot_unlocked)
               {
                  m_window.contracts_mc["locked_mc"].visible = true;
                  m_window.contracts_mc.card5_mc.visible = false;
                  this.populateLockedCard(m_window.contracts_mc.locked_mc);
               }
               else
               {
                  m_window.contracts_mc["locked_mc"].visible = false;
                  m_window.contracts_mc.card5_mc.visible = true;
                  if(_loc6_.length != 5)
                  {
                     this.populateCard(m_window.contracts_mc.card5_mc,null);
                  }
                  else
                  {
                     this.populateCard(m_window.contracts_mc.card5_mc,_loc6_[_loc3_]);
                  }
               }
            }
            else
            {
               _loc3_ = 0;
               while(_loc3_ < 4)
               {
                  this.populateCard(m_window.contracts_mc["card" + (_loc3_ + 1) + "_mc"],null);
                  _loc3_++;
               }
               if(this.m_block == 1 && !param1.slot_unlocked)
               {
                  m_window.contracts_mc["locked_mc"].visible = true;
                  m_window.contracts_mc.card5_mc.visible = false;
                  this.populateLockedCard(m_window.contracts_mc.locked_mc);
               }
               else
               {
                  m_window.contracts_mc.card5_mc.visible = true;
                  m_window.contracts_mc.locked_mc.visible = false;
                  this.populateCard(m_window.contracts_mc.card5_mc,null);
               }
            }
         }
         this.setTabs(null);
         addChild(m_window);
         m_origOffsetX = m_window.panel_mc.x;
         m_origOffsetY = m_window.panel_mc.y;
         this.contentWidth = m_window.width;
         this.contentHeight = m_window.height;
         centerWithinStage(Zlab.mainStage);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      protected function setTabs(param1:MouseEvent) : void
      {
         Zlab.mainStage.invalidate();
         switch(this.m_block)
         {
            case 3:
               m_window.tab03_mc.gotoAndStop(3);
               break;
            case 2:
               m_window.tab02_mc.gotoAndStop(3);
               break;
            default:
               m_window.tab01_mc.gotoAndStop(3);
         }
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         this.m_resource = param1;
         m_window = param1.clip.screen_mc;
         var _loc2_:TGetNeighborhoodInfo = new TGetNeighborhoodInfo(this.m_entity,this,this.m_gdc.id);
         TransactionManager.addTransaction(_loc2_,true);
      }
      
      private function onExitClicked(param1:MouseEvent) : void
      {
         close();
      }
      
      private function onFill(param1:MouseEvent) : void
      {
         close();
         GameModeManager.instance.addGameMode(new GMNeighborhoodAdd(this.m_entity,this.m_block));
      }
      
      private function onRemove(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         for each(_loc2_ in this.m_buttons)
         {
            if(param1.target == _loc2_.button.hit)
            {
               close();
               _loc2_.item.neighborhood = true;
               GameModeManager.instance.addGameMode(new GMNeighborhoodRemove(_loc2_.item.itemName,this.m_entity,_loc2_.item,this.m_block));
            }
         }
      }
      
      private function getEnergyCost() : int
      {
         var _loc2_:Object = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.m_result.harvest_info)
         {
            if(Boolean(_loc2_.id) && _loc2_.duration == -1)
            {
               _loc1_ += int(_loc2_.energy);
            }
         }
         return _loc1_;
      }
      
      private function onHarvest(param1:MouseEvent) : void
      {
         var _loc2_:int = this.getEnergyCost();
         PopupManager.instance.push(GenericPopup2B.NewYesNo(ZGameUtils.ZlocT("Dialogs","Neighborhood_confirmation",{"total":-_loc2_}),ZGameUtils.ZlocT("Dialogs","Neighborhood_confirmation_title"),this.onHarvestFinal));
      }
      
      private function onHarvestFinal(param1:GenericPopupEvent) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         var _loc7_:Transaction = null;
         var _loc8_:Array = null;
         var _loc9_:int = 0;
         var _loc10_:Object = null;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         if(param1.button == GenericPopup.NO)
         {
            return;
         }
         close();
         var _loc2_:Array = new Array();
         var _loc3_:int = this.getEnergyCost();
         if(ZGlobal.player.resources.checkResourceAmount("energy",_loc3_))
         {
            _loc5_ = this.m_result.blocks;
            _loc6_ = 1;
            while(_loc6_ <= NUM_BLOCKS)
            {
               _loc8_ = _loc5_["block" + _loc6_];
               if(_loc8_)
               {
                  _loc9_ = ZGlobal.player.coins;
                  for each(_loc10_ in _loc8_)
                  {
                     for each(_loc4_ in this.m_result.harvest_info)
                     {
                        if(Boolean(_loc4_.id) && Boolean(_loc4_.duration == -1) && _loc4_.id == _loc10_.id)
                        {
                           _loc2_.push(_loc4_.id);
                           RewardPickupManager.instance.addResourceReward(this.m_entity,"coins",int(_loc4_.coins));
                           RewardPickupManager.instance.addXpReward(this.m_entity,int(_loc4_.xp));
                           ZGlobal.player.resources.updateResourceAmount("energy",int(_loc4_.energy));
                           break;
                        }
                     }
                  }
                  if(_loc8_.length == NUM_SLOTS)
                  {
                     _loc11_ = ZGlobal.player.coins - _loc9_;
                     _loc12_ = _loc11_ * this.bonusInfo[_loc6_ - 1] / 100;
                     if(_loc12_ > 0)
                     {
                        RewardPickupManager.instance.addResourceReward(this.m_entity,"coins",_loc12_);
                     }
                  }
               }
               _loc6_++;
            }
            _loc7_ = new THarvestNeighborhood(this.m_entity,_loc2_);
            TransactionManager.addTransaction(_loc7_,true);
         }
         else
         {
            BuyEnergyPopup.show();
         }
      }
      
      private function onUnlock(param1:MouseEvent) : void
      {
         close();
         this.m_state.showPartDialog();
      }
   }
}

