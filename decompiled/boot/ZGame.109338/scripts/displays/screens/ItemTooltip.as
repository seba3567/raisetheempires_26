package displays.screens
{
   import core.ZGlobal;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.DecorationItem;
   import core.gameobjects.GameItem;
   import core.gameobjects.IslandItem;
   import core.gameobjects.UnitItem;
   import core.gameobjects.UpgradeItem;
   import core.managers.PopulationManager;
   import core.managers.WorldResourceManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.decorationsManager.DecorationsManager;
   import core.managers.tutorialManager.TutorialClassHighlighter;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.unitClassManager.UnitClass;
   import core.managers.unitClassManager.UnitClassManager;
   import core.resource.ResourceInfo;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.researchScreens.UpgradesDisplay;
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Point;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   
   public class ItemTooltip extends Sprite
   {
      
      public static const SOURCE_NONE:int = 0;
      
      public static const SOURCE_INVENTORY:int = 1;
      
      public static const SOURCE_STORE:int = 2;
      
      public static const SOURCE_MARKET:int = 3;
      
      private static const TOOLTIP_PKG:String = "Tooltips";
      
      private static const CAMPAIGN_PKG:String = "Campaign";
      
      private var m_tooltip:MovieClip = null;
      
      private var m_iconLoaders:Array = new Array();
      
      private var m_tooltipIsChild:Boolean = false;
      
      private var m_source:int = 0;
      
      private var m_tutorialClassHighlighter:TutorialClassHighlighter = null;
      
      private var m_upgradesDisplay:UpgradesDisplay = null;
      
      public function ItemTooltip(param1:String, param2:Object, param3:int = 0)
      {
         super();
         if(!ZGlobal.stencilActive)
         {
            this.m_source = param3;
            this.loadTooltip(param1,param2);
            this.mouseEnabled = false;
            this.mouseChildren = false;
         }
      }
      
      private function loadTooltip(param1:String, param2:Object) : void
      {
         var _loc3_:String = null;
         this.m_tooltip = this.createTooltipClip(param1,param2);
         addChild(this.m_tooltip);
         this.m_tooltipIsChild = true;
         ZGameUtils.hideIfExists(this.m_tooltip.description_tf);
         switch(param1)
         {
            case GameItem.CIVIC_TOOLTIP:
               this.m_tooltip.gotoAndStop("3");
               this.populateHouseTooltip(GameItem(param2),{
                  "value":param2.workersCap,
                  "label":"HousePopulationCap_Line"
               });
               break;
            case GameItem.SPARSE_TOOLTIP:
               this.m_tooltip.gotoAndStop("1");
               this.populateSparseTooltip(GameItem(param2));
               break;
            case GameItem.BASIC_TOOLTIP:
               this.m_tooltip.gotoAndStop("2");
               _loc3_ = param2 ? param2.purchaseXp.toString() : null;
               this.populateXpOnlyTooltipButWithOptionalString(_loc3_,GameItem(param2));
               break;
            case GameItem.DECORATION_TOOLTIP:
               this.m_tooltip.gotoAndStop("2");
               _loc3_ = this.getItemBuyXp(GameItem(param2));
               this.populateXpOnlyTooltipButWithOptionalString(_loc3_,GameItem(param2));
               break;
            case GameItem.DECORATION_MEANINGFUL_TOOLTIP:
               this.populateMeaningfulDecorationTooltip(GameItem(param2));
               break;
            case GameItem.DEFAULT_TOOLTIP:
               this.m_tooltip.gotoAndStop("2");
               _loc3_ = param2 ? param2.placeXp.toString() : null;
               this.populateXpOnlyTooltipButWithOptionalString(_loc3_,null);
               break;
            case GameItem.CONSUMABLE_TOOLTIP:
               this.m_tooltip.gotoAndStop("1");
               this.populateConsumableTooltip(GameItem(param2));
               break;
            case GameItem.HOUSE_TOOLTIP:
               this.m_tooltip.gotoAndStop("3");
               this.populateHouseTooltip(GameItem(param2),{
                  "value":param2.workers,
                  "label":"HousePopulation_Line"
               });
               break;
            case GameItem.STORE_RESOURCE_TOOLTIP:
               this.m_tooltip.gotoAndStop("2");
               this.populateStoreResourceTooltip(GameItem(param2));
               break;
            case GameItem.RESOURCE_TOOLTIP:
               this.m_tooltip.gotoAndStop("1");
               this.populateResourceTooltip(param2);
               break;
            case GameItem.ENERGY_TOOLTIP:
               this.m_tooltip.gotoAndStop("2");
               this.populateEnergyTooltip(GameItem(param2));
               break;
            case GameItem.AMMO_TOOLTIP:
               this.m_tooltip.gotoAndStop("2");
               this.populateAmmoTooltip(GameItem(param2));
               break;
            case GameItem.MANA_TOOLTIP:
               this.populateManaTooltip(GameItem(param2));
               break;
            case GameItem.EXPANSION_TOOLTIP:
               this.populateExpansionTooltip(GameItem(param2));
               break;
            case GameItem.ISLAND_TOOLTIP:
               this.populateIslandTooltip(IslandItem(GameItem(param2)));
               break;
            case GameItem.UPGRADE_TOOLTIP:
               this.m_tooltip.gotoAndStop("1");
               this.populateUpgradeDescriptionTooltip(UpgradeItem(GameItem(param2)));
               break;
            case GameItem.BONUS_AGAINST_TOOLTIP:
               this.populateBonusAgainst(param2 as UnitItem);
               break;
            case GameItem.UNIT_TOOLTIP:
            case GameItem.BONUS_AGAINST_WITH_UPGRADES_TOOLTIP:
               this.populateBonusAgainstWithUpgrades(param2 as UnitItem);
               break;
            case GameItem.SUPPORT_UNIT_TOOLTIP:
               this.populateSupportUnit(param2 as UnitItem);
               break;
            case GameItem.TITAN_TOOLTIP:
               this.populateTitanUnit(param2 as UnitItem);
               break;
            case GameItem.WORLDGAMES_TOOLTIP:
               this.populateWorldGames(param2 as UnitItem);
            default:
               this.m_tooltip.visible = false;
         }
      }
      
      private function failedResearchCheck(param1:UnitItem) : Boolean
      {
         if(!param1.researchTemplate.toString().length)
         {
            return true;
         }
         if(!WorldUpgradeManager.instance.isAutoUpgradeItem(param1.code))
         {
            if(!ZGlobal.player.getSeenFlag(WorldUpgradeManager.FIRST_RESEARCH_DIALOG))
            {
               return true;
            }
         }
         return false;
      }
      
      private function failedContractCheck(param1:GameItem) : Boolean
      {
         if(!GameItem(param1).contractLocked)
         {
            return false;
         }
         var _loc2_:int = ZGameTimeUtil.instance.getDateStatus(null,param1.xml);
         if(_loc2_ == ZGameTimeUtil.DATE_STATUS_NONE)
         {
            return false;
         }
         if(ZGlobal.player.hasPurchasedContract(param1.code))
         {
            return false;
         }
         return true;
      }
      
      private function createTooltipClip(param1:String, param2:Object) : MovieClip
      {
         if(param1 == GameItem.BONUS_AGAINST_WITH_UPGRADES_TOOLTIP || param1 == GameItem.UNIT_TOOLTIP)
         {
            if(GameItem(param2).zpoints || this.failedResearchCheck(param2 as UnitItem) || this.failedContractCheck(param2 as GameItem))
            {
               if(param2 is UnitItem && (param2 as UnitItem).hasType(UnitItem.MEGA_UNIT))
               {
                  param1 = GameItem.TITAN_TOOLTIP;
               }
               else
               {
                  param1 = GameItem.BONUS_AGAINST_TOOLTIP;
               }
            }
         }
         switch(param1)
         {
            case GameItem.BONUS_AGAINST_TOOLTIP:
               return new BonusAgainstTooltip();
            case GameItem.UNIT_TOOLTIP:
            case GameItem.BONUS_AGAINST_WITH_UPGRADES_TOOLTIP:
               return new BonusAgainstTooltipWithUpgrades();
            case GameItem.SUPPORT_UNIT_TOOLTIP:
               return new secondaryAbilityTooltip();
            case GameItem.DECORATION_MEANINGFUL_TOOLTIP:
               return new DeccoCardTooltip_mc();
            case GameItem.TITAN_TOOLTIP:
               return new titanTooltip();
            default:
               return new AssetGroupTooltip();
         }
      }
      
      private function getItemBuyXp(param1:GameItem) : String
      {
         var _loc3_:Number = NaN;
         var _loc2_:String = null;
         if(param1)
         {
            if(this.m_source != SOURCE_STORE)
            {
               return param1.placeXp.toString();
            }
            _loc3_ = ZGlobal.gameSettings.getBuyXp(param1.cost);
            if(_loc3_ > 0)
            {
               _loc2_ = _loc3_.toString();
            }
         }
         return _loc2_;
      }
      
      private function populateStoreResourceTooltip(param1:GameItem) : void
      {
         this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(WorldResourceManager.instance.getResourceImageURLByType(param1.resourceType,WorldResourceManager.XTRA_SMALL_ICON),this.m_tooltip.icon_0));
         this.m_tooltip.bottom_tf.visible = false;
         TextFieldUtil.processTextField(this.m_tooltip.top_tf,param1.resourceYield.toString());
         this.populateItemDescription(param1);
      }
      
      private function populateResourceTooltip(param1:Object) : void
      {
         var _loc2_:ResourceInfo = null;
         var _loc3_:String = null;
         if(param1.type == Market.TYPE_RESOURCE)
         {
            _loc3_ = WorldResourceManager.instance.getResourceTypeFromIndex(param1.item);
            _loc2_ = WorldResourceManager.instance.getResourceInfoByType(_loc3_);
         }
         if(_loc2_)
         {
            this.m_tooltip.description_tf.visible = true;
            TextFieldUtil.processTextField(this.m_tooltip.description_tf,ZGameUtils.ZlocT(TOOLTIP_PKG,_loc2_.tooltipKey));
         }
      }
      
      private function populateEnergyTooltip(param1:GameItem) : void
      {
         this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/unitEnergy.png"),this.m_tooltip.icon_0));
         this.m_tooltip.bottom_tf.visible = false;
         TextFieldUtil.processTextField(this.m_tooltip.top_tf,param1.energyYield.toString());
         this.populateItemDescription(param1);
      }
      
      private function populateAmmoTooltip(param1:GameItem) : void
      {
         this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/Ammo01_24.png"),this.m_tooltip.icon_0));
         this.m_tooltip.bottom_tf.visible = false;
         TextFieldUtil.processTextField(this.m_tooltip.top_tf,param1.ammoYield.toString());
         this.populateItemDescription(param1);
      }
      
      private function populateManaTooltip(param1:GameItem) : void
      {
         this.m_tooltip.gotoAndStop("2");
         this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/contracts/Contracts_Icons_0.swf/ElementZ01_96.png"),this.m_tooltip.icon_0));
         this.m_tooltip.bottom_tf.visible = false;
         TextFieldUtil.processTextField(this.m_tooltip.top_tf,param1.manaYield.toString());
         this.populateItemDescription(param1);
      }
      
      private function initDecorationTooltipCard(param1:DecorationItem, param2:XML, param3:MovieClip) : void
      {
         var _loc11_:String = null;
         var _loc12_:int = 0;
         var _loc13_:Object = null;
         var _loc14_:String = null;
         param3.visible = true;
         var _loc4_:String = param2.@effect.toString();
         var _loc5_:String = "DecoTooltip_Category_" + _loc4_;
         var _loc6_:String = ZGameUtils.ZlocT("Decorations",_loc5_);
         var _loc7_:String = "DecoTooltip_Effect_" + _loc4_;
         var _loc8_:int = DecorationsManager.instance.getEffectVariantAmount(param2.@amountNormal.toString(),_loc4_);
         var _loc9_:Object = {"amount":_loc8_};
         var _loc10_:String = ZGameUtils.ZlocT("Decorations",_loc7_,_loc9_);
         TextFieldUtil.compactTextField(param3.category_tf,_loc6_);
         TextFieldUtil.compactTextField(param3.effect_tf,_loc10_,{"minScale":0.5});
         if(param1.getCrewTemplateName())
         {
            _loc11_ = "DecoTooltip_CrewedBonus_" + _loc4_;
            _loc12_ = DecorationsManager.instance.getEffectVariantAmount(param2.@amountCrewed.toString(),_loc4_);
            _loc13_ = {"amount":_loc12_};
            _loc14_ = ZGameUtils.ZlocT("Decorations",_loc11_,_loc13_);
            TextFieldUtil.compactTextField(param3.crewed_tf,_loc14_,{"maxLines":1});
         }
         else
         {
            param3.crewed_tf.visible = false;
         }
      }
      
      private function populateMeaningfulDecorationTooltip(param1:GameItem) : void
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:XMLList = null;
         var _loc7_:int = 0;
         var _loc2_:String = ZGameUtils.ZlocT("Decorations","TooltipHeader");
         TextFieldUtil.processTextField(this.m_tooltip.title_tf,_loc2_);
         var _loc3_:DecorationItem = ZGlobal.gameSettings.getItemByCode(param1.code,DecorationItem) as DecorationItem;
         if(_loc3_)
         {
            _loc4_ = DecorationsManager.instance.getStoreTooltipAOELabel(_loc3_);
            _loc5_ = ZGameUtils.ZlocT("Dialogs",_loc4_);
            TextFieldUtil.compactTextField(this.m_tooltip.aoe_tf,_loc5_,{"maxLines":1});
            _loc6_ = _loc3_.effectsXML;
            if(_loc6_.length() == 1)
            {
               this.initDecorationTooltipCard(_loc3_,_loc6_[0],this.m_tooltip.info_mc1);
               this.m_tooltip.info_mc2.visible = false;
               _loc7_ = int(this.m_tooltip.info_mc2.height);
               this.m_tooltip.title_tf.y += _loc7_;
               this.m_tooltip.aoe_tf.y += _loc7_;
               this.m_tooltip.info_mc1.y += _loc7_;
               this.m_tooltip.bubble_mc.height -= _loc7_;
            }
            else if(_loc6_.length() == 2)
            {
               this.initDecorationTooltipCard(_loc3_,_loc6_[0],this.m_tooltip.info_mc1);
               this.initDecorationTooltipCard(_loc3_,_loc6_[1],this.m_tooltip.info_mc2);
            }
            else
            {
               this.m_tooltip.info_mc1.visible = false;
               this.m_tooltip.info_mc2.visible = false;
            }
         }
      }
      
      private function populateXpOnlyTooltipButWithOptionalString(param1:String, param2:GameItem) : void
      {
         if(param1)
         {
            this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/icon_level.png"),this.m_tooltip.icon_0));
            TextFieldUtil.processTextField(this.m_tooltip.top_tf,ZGameUtils.ZlocT(TOOLTIP_PKG,"Xp_Line",{"xp":param1}));
         }
         else
         {
            this.m_tooltip.top_tf.visible = false;
         }
         if(param2 != null)
         {
            this.populateItemDescription(param2);
         }
         this.m_tooltip.bottom_tf.visible = false;
      }
      
      private function populateHouseTooltip(param1:GameItem, param2:Object) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         if(param1)
         {
            TextFieldUtil.processTextField(this.m_tooltip.topLeft_tf," ");
            _loc3_ = param1.getMatureDuration(null);
            _loc4_ = ZGameTimeUtil.instance.getTimeString(_loc3_);
            this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(WorldResourceManager.instance.getResourceImageURLByType("coins",WorldResourceManager.XTRA_SMALL_ICON),this.m_tooltip.icon_1));
            TextFieldUtil.processTextField(this.m_tooltip.middleLeft_tf,ZGameUtils.ZlocT(TOOLTIP_PKG,"HouseHarvest_Line",{
               "coins":param1.coinsYield,
               "duration":_loc4_
            }));
            _loc5_ = int(param2.value);
            _loc6_ = param2.label;
            this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(PopulationManager.instance.MEDIUM_ICON),this.m_tooltip.icon_2));
            TextFieldUtil.processTextField(this.m_tooltip.bottomLeft_tf,ZGameUtils.ZlocT(TOOLTIP_PKG,_loc6_,{"pop":_loc5_}));
            this.m_tooltip.topRight_tf.text = "";
            this.populateItemDescription(param1);
         }
      }
      
      private function getUnitIndexes(param1:int) : Array
      {
         var _loc2_:Array = new Array();
         switch(param1)
         {
            case 1:
               _loc2_.push(2);
               break;
            case 2:
               _loc2_.push(1);
               _loc2_.push(3);
               break;
            case 3:
               _loc2_.push(1);
               _loc2_.push(2);
               _loc2_.push(3);
               break;
            case 4:
               _loc2_.push(0);
               _loc2_.push(1);
               _loc2_.push(3);
               _loc2_.push(4);
               break;
            case 5:
               _loc2_.push(0);
               _loc2_.push(1);
               _loc2_.push(2);
               _loc2_.push(3);
               _loc2_.push(4);
         }
         return _loc2_;
      }
      
      private function populateExpansionTooltip(param1:GameItem) : void
      {
         if(param1)
         {
            this.populateItemDescription(param1);
         }
      }
      
      private function populateIslandTooltip(param1:IslandItem) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Array = null;
         var _loc4_:MovieClip = null;
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc7_:Array = null;
         var _loc8_:* = 0;
         var _loc9_:String = null;
         var _loc10_:GameItem = null;
         if(param1)
         {
            this.m_tooltip.gotoAndStop("5");
            _loc2_ = [this.m_tooltip.unit_0,this.m_tooltip.unit_1,this.m_tooltip.unit_2,this.m_tooltip.unit_3,this.m_tooltip.unit_4];
            _loc3_ = [this.m_tooltip.question_0,this.m_tooltip.question_1,this.m_tooltip.question_2,this.m_tooltip.question_3,this.m_tooltip.question_4];
            for each(_loc4_ in _loc3_)
            {
               _loc4_.visible = false;
            }
            _loc5_ = ZGameUtils.ZlocT(CAMPAIGN_PKG,"map_" + ZGlobal.player.campaign.currentMapName + "_" + param1.name + "_name");
            TextFieldUtil.processTextField(this.m_tooltip.title_tf,_loc5_);
            this.m_tooltip.description_tf.visible = false;
            TextFieldUtil.processTextField(this.m_tooltip.costs_tf,ZGameUtils.ZlocT("Dialogs","BattleUnitsCaption"));
            this.m_tooltip.costs_tf.visible = true;
            _loc6_ = param1.getUnits();
            _loc7_ = this.getUnitIndexes(_loc6_.length);
            _loc8_ = 0;
            for each(_loc9_ in _loc6_)
            {
               _loc10_ = ZGlobal.gameSettings.getItemByCode(_loc9_,GameItem) as GameItem;
               if(null == _loc10_)
               {
                  Logger.error(this,"populateIslandTooltip","no such unit with code " + _loc9_);
               }
               else
               {
                  ImageLoaderFactory.CreateImageLoader(_loc10_.getCachedImage("icon").url,_loc2_[_loc7_[_loc8_++]]);
               }
            }
         }
      }
      
      private function populateSparseTooltip(param1:GameItem) : void
      {
         var _loc2_:String = null;
         if(param1)
         {
            this.m_tooltip.description_tf.visible = true;
            _loc2_ = "";
            if(param1.isSuperOre())
            {
               _loc2_ = ZGameUtils.ZlocT("Items",ZGlobal.player.rareResourceName + "_menuName");
            }
            TextFieldUtil.compactTextField(this.m_tooltip.description_tf,ZGameUtils.ZlocT("Items",param1.name + "_description",{"rare":_loc2_}));
         }
      }
      
      private function populateConsumableTooltip(param1:GameItem) : void
      {
         if(param1)
         {
            this.populateItemDescription(param1);
         }
      }
      
      private function populateUpgradeDescriptionTooltip(param1:UpgradeItem) : void
      {
         this.m_tooltip.description_tf.visible = true;
         if(!param1.hasSentenceNameOverride())
         {
            TextFieldUtil.processTextField(this.m_tooltip.description_tf,ZGameUtils.ZlocT(TOOLTIP_PKG,param1.shieldModifier > 0 ? "UpgradeTooltip_Shield" : "UpgradeTooltip",{
               "action":param1.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME),
               "amount":param1.modifierString
            }));
         }
         else
         {
            TextFieldUtil.processTextField(this.m_tooltip.description_tf,ZGameUtils.ZlocT(TOOLTIP_PKG,param1.shieldModifier > 0 ? "UpgradeTooltip_Shield" : "UpgradeTooltip",{
               "action":ZGameUtils.ZlocT("Items",param1.uiNameOverride + "_sentenceName_override"),
               "amount":param1.modifierString
            }));
         }
      }
      
      private function populateUnitTooltip(param1:UnitItem) : void
      {
         if(param1)
         {
            this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/unitStrength.png"),this.m_tooltip.icon_0));
            TextFieldUtil.processTextField(this.m_tooltip.top_tf,ZGameUtils.ZlocT(TOOLTIP_PKG,"UnitStrength_Line",{"strength":param1.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(param1.code))}));
            this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/unitEnergy.png"),this.m_tooltip.icon_1));
            TextFieldUtil.processTextField(this.m_tooltip.bottom_tf,ZGameUtils.ZlocT(TOOLTIP_PKG,"UnitEnergy_Line",{"energy":param1.attackCost}));
            this.populateItemDescription(param1,false);
         }
      }
      
      private function populateItemDescription(param1:GameItem, param2:Boolean = true) : void
      {
         this.m_tooltip.description_tf.visible = true;
         TextFieldUtil.processTextField(this.m_tooltip.description_tf,ZGameUtils.ZlocT("Items",param1.name + "_description"));
         if(this.m_tooltip.costs_tf != null)
         {
            if(param2)
            {
               this.m_tooltip.costs_tf.visible = true;
               TextFieldUtil.processTextField(this.m_tooltip.costs_tf,ZGameUtils.ZlocT(TOOLTIP_PKG,"Rewards_Line"));
            }
            else
            {
               this.m_tooltip.costs_tf.visible = false;
            }
         }
      }
      
      private function populateTitanUnit(param1:UnitItem) : void
      {
         if(param1)
         {
            this.populateBonusAgainst(param1);
            TextFieldUtil.processTextField(this.m_tooltip.description_tf,"description_tf");
            TextFieldUtil.compactTextField(this.m_tooltip.secondAbility_tf,ZGameUtils.ZlocT(TOOLTIP_PKG,"TitanAttack_desc",{"amount":1}),{
               "minScale":0.7,
               "fontSize":12
            });
            this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/ElementZ_24.png"),this.m_tooltip.classIcon));
         }
      }
      
      private function populateWorldGames(param1:UnitItem) : void
      {
         if(param1)
         {
            this.populateItemDescription(param1,false);
         }
      }
      
      private function populateBonusAgainstWithUpgrades(param1:UnitItem) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Boolean = false;
         if(param1)
         {
            if(this.m_tooltip is titanTooltip)
            {
               this.populateTitanUnit(param1);
               return;
            }
            if(this.m_tooltip is BonusAgainstTooltipWithUpgrades)
            {
               TextFieldUtil.processTextField(this.m_tooltip.upgrades_mc.upgrades_tf,ZGameUtils.ZlocT(TOOLTIP_PKG,"Upgrades"));
               _loc2_ = [this.m_tooltip.upgrades_mc.icon0,this.m_tooltip.upgrades_mc.icon1,this.m_tooltip.upgrades_mc.icon2,this.m_tooltip.upgrades_mc.icon3,this.m_tooltip.upgrades_mc.icon4];
               _loc3_ = WorldUpgradeManager.instance.isAutoUpgradeItem(param1.code);
               this.m_upgradesDisplay = new UpgradesDisplay(_loc2_,this.m_tooltip.upgrades_mc,null,null,param1,WorldUpgradeManager.instance.getUpgradesByCode(param1.code),_loc3_);
            }
            this.populateBonusAgainst(param1);
         }
      }
      
      private function populateSupportUnit(param1:UnitItem) : void
      {
         var _loc2_:ConsumableItem = ZGlobal.gameSettings.getItemByCode(param1.secondaryAbility,ConsumableItem) as ConsumableItem;
         TextFieldUtil.compactTextField(this.m_tooltip.secondAbility_tf,ZGameUtils.ZlocT("Main","ManaAction",{"num":_loc2_.mana}),{
            "minScale":0.7,
            "fontSize":12
         });
         if(ZGameUtils.showIfExists(this.m_tooltip.description_tf))
         {
            TextFieldUtil.processTextField(this.m_tooltip.description_tf,ZGameUtils.ZlocT("Items",_loc2_.name + "_description"));
         }
         TextFieldUtil.processTextField(this.m_tooltip.abilityName_tf,_loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(_loc2_.getCachedImage("icon").url,this.m_tooltip.abilityIcon));
         this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/ElementZ_24.png"),this.m_tooltip.classIcon));
      }
      
      private function populateBonusAgainst(param1:UnitItem) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:Point = null;
         var _loc5_:int = 0;
         if(param1)
         {
            TextFieldUtil.processTextField(this.m_tooltip.bonusInfo_tf,ZGameUtils.ZlocT(TOOLTIP_PKG,"BonusAgainst"));
            _loc2_ = param1.goodAgainst;
            _loc3_ = int(_loc2_.length);
            switch(_loc3_)
            {
               case 1:
                  this.m_tooltip.icon_mc.x = this.m_tooltip.anchor1_mc.x;
                  break;
               case 2:
                  this.m_tooltip.icon_mc.x = this.m_tooltip.anchor2_mc.x;
                  break;
               default:
                  this.m_tooltip.icon_mc.x = this.m_tooltip.anchor3_mc.x;
            }
            switch(_loc3_)
            {
               case 3:
               case 4:
                  this.loadUnitClassAltIconImage(_loc2_[2],this.m_tooltip.icon_mc.icon2);
               case 2:
                  this.loadUnitClassAltIconImage(_loc2_[1],this.m_tooltip.icon_mc.icon1);
               case 1:
                  this.loadUnitClassAltIconImage(_loc2_[0],this.m_tooltip.icon_mc.icon0);
            }
            if(TutorialManager.instance.active)
            {
               if(TutorialManager.instance.highlightCombatTooltipClassIcon)
               {
                  _loc4_ = new Point(21,21);
                  this.m_tutorialClassHighlighter = new TutorialClassHighlighter();
                  _loc5_ = 0;
                  while(_loc5_ < _loc2_.length)
                  {
                     if(_loc2_[_loc5_] == TutorialManager.instance.highlightCombatTooltipClassIcon)
                     {
                        switch(_loc5_)
                        {
                           case 0:
                              this.m_tutorialClassHighlighter.setDisplayObject(this.m_tooltip.icon_mc.icon0,_loc4_,1,true);
                              break;
                           case 1:
                              this.m_tutorialClassHighlighter.setDisplayObject(this.m_tooltip.icon_mc.icon1,_loc4_,1,true);
                              break;
                           case 2:
                              this.m_tutorialClassHighlighter.setDisplayObject(this.m_tooltip.icon_mc.icon2,_loc4_,1,true);
                        }
                        break;
                     }
                     _loc5_++;
                  }
               }
            }
         }
      }
      
      private function loadUnitClassAltIconImage(param1:String, param2:UILoader) : void
      {
         var _loc3_:UnitClass = UnitClassManager.instance.unitClassNamed(param1);
         if(_loc3_)
         {
            this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc3_.getAltIconURL()),param2));
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_iconLoaders)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         this.m_iconLoaders = null;
         if(this.m_tooltipIsChild)
         {
            removeChild(this.m_tooltip);
         }
         if(this.m_tutorialClassHighlighter)
         {
            this.m_tutorialClassHighlighter.dispose();
            this.m_tutorialClassHighlighter = null;
         }
         if(this.m_upgradesDisplay)
         {
            this.m_upgradesDisplay.dispose();
         }
         this.m_tooltip = null;
      }
      
      public function moveBy(param1:Number, param2:Number) : void
      {
         if(this.m_tooltip)
         {
            this.m_tooltip.x += param1;
            this.m_tooltip.y += param2;
         }
      }
   }
}

