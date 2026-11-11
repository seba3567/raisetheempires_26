package core.managers.MOTDManager
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.managers.promoManager.PromoManager;
   import core.player.Player;
   import utils.CriteriaUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   
   public class MOTDData
   {
      
      public static const BEHAVIOR_LIGHTNINGDEAL:String = "LIGHTNING_DEAL";
      
      public static const DEFAULT_TITLE:String = "Title";
      
      public static const DEFAULT_DESCRIPTION:String = "Description";
      
      public static const DEFAULT_ACCEPT_BUTTON_TEXT:String = "Accept";
      
      public static const DEFAULT_IMAGEURL:String = "none";
      
      public static const DEFAULT_PRIORITY:int = 3;
      
      public static const DEFAULT_REQUIRE_USER_INTERACT:Boolean = false;
      
      public static const ACCEPT_DEFAULT:String = "NONE";
      
      public static const ACCEPT_ARROW_ON_PVP_BUTTON:String = "ARROW ON PVP";
      
      public static const ACCEPT_OPEN_BUILD_MENU:String = "OPEN_BUILD_MENU";
      
      public static const ACCEPT_PLACE_OBJECT:String = "PLACE_OBJECT";
      
      public static const ACCEPT_BUY_OBJECT:String = "BUY_OBJECT";
      
      public static const ACCEPT_REDIRECT:String = "REDIRECT";
      
      public static const ACCEPT_OPEN_OPTION_MENU:String = "OPEN_OPTION_MENU";
      
      public static const ACCEPT_REDIRECT_NEW_TAB:String = "REDIRECT_NEW_TAB";
      
      public static const ACCEPT_OPEN_LEADERBOARDS:String = "OPEN_LEADERBOARDS";
      
      public static const ACCEPT_BUY_OBJECT_PAYMENTS_REDIRECT:String = "BUY_OBJECT_PAYMENTS_REDIRECT";
      
      public static const ACCEPT_OPEN_BUILD_MENU_TAB:String = "OPEN_BUILD_MENU_TAB";
      
      public static const ACCEPT_SHOW_TUTORIAL_UI_ITEM:String = "SHOW_TUTORIAL_UI_ITEM";
      
      public static const GLOBALPVP_LEGAL_SCREEN:String = "GLOBALPVP_LEGAL_SCREEN";
      
      public static const DOMINATION_FTUE:String = "DOMINATION_FTUE";
      
      public static const ACCEPT_PAN_TO_ITEM:String = "PAN_TO_ITEM";
      
      public static const ACCEPT_PAN_OR_PLACE_ITEM:String = "PAN_OR_PLACE_OBJECT";
      
      public static const SHOW_POWERUPFACTORY_DIALOG:String = "SHOW_POWERUPFACTORY_DIALOG";
      
      public static const SHOW_MASTERYFACTORY_DIALOG:String = "SHOW_MASTERYFACTORY_DIALOG";
      
      public static const SHOW_MECHLAB_ACTIVATION_DIALOG:String = "SHOW_MECHLAB_ACTIVATION_DIALOG";
      
      public static const SHOW_MECHLAB_PARTS_GATHER:String = "SHOW_MECHLAB_PARTS_GATHER";
      
      public static const ACCEPT_OPEN_FB_PERMISSIONS_DIALOG:String = "OPEN_FB_PERMISSIONS";
      
      public static const SHOW_SPEECH:String = "SHOW_SPEECH";
      
      public static const SHOW_SPEECH_PAN_TO_ITEM:String = "SHOW_SPEECH_PAN_TO_ITEM";
      
      public static const ACCEPT_CUSTOM_ACTION:String = "CUSTOM_ACTION";
      
      public static const SHOW_WONDERS_DIALOG:String = "SHOW_WONDERS_DIALOG";
      
      public static const SHOW_FLASHFEED_DIALOG:String = "SHOW_FLASHFEED_DIALOG";
      
      public static const SHOW_SURVIVALMODE_WELCOME:String = "SHOW_SURVIVALMODE_WELCOME";
      
      public static const SHOW_ALLIANCE_CREATE_DIALOG:String = "SHOW_ALLIANCE_CREATE_DIALOG";
      
      public static const SHOW_QUEST_TASK_ARROW:String = "SHOW_QUEST_TASK_ARROW";
      
      public static const SHOW_CAMPAIGN_ARROW:String = "SHOW_CAMPAIGNMAP";
      
      public static const MOTD_TYPE_MESSAGE:String = "message";
      
      public static const MOTD_TYPE_PLACEMENT:String = "placement";
      
      public static const MOTD_TYPE_MERCHANDISING:String = "merchandising";
      
      public static const MOTD_TYPE_SURVIVALREWARDS:String = "survivalmoderewardrefresh";
      
      public static const MOTD_TYPE_DEATHMATCH:String = "deathMatch";
      
      private static var ENTITY_PLACED:uint = 0;
      
      private static var ENTITY_BUILT:uint = 1;
      
      private const LOCALIZATION_FILE:String = "MessageOfTheDay";
      
      public var name:String;
      
      public var titleText:String;
      
      public var descriptionText:String;
      
      public var acceptButtonText:String;
      
      public var acceptButtonAlternateText:String;
      
      public var priority:int;
      
      public var imageURL:String;
      
      public var bgURL:String = "assets/game/motds/MOTD_BkgdBlueCity.png";
      
      public var showCardBg:Boolean = true;
      
      public var collapseCardButton:Boolean = false;
      
      public var requireUserInteract:Boolean;
      
      public var acceptButtonBehavior:String;
      
      public var acceptButtonBehaviorData:String;
      
      public var oncePerDay:Boolean;
      
      public var flagName:String = null;
      
      public var numTimes:Number = 0;
      
      public var isXPromo:Boolean = false;
      
      public var xPromoGameID:String;
      
      public var xPromoID:int;
      
      public var linkText:String;
      
      public var linkUrl:String;
      
      public var hideScrollBarsOnLoad:Boolean = true;
      
      public var checkPermission:String;
      
      public var hasPermission:Boolean = false;
      
      public var type:String;
      
      public var version:int;
      
      public var advisorId:String = null;
      
      public var merchData:Object;
      
      public var m_discountCode:String = null;
      
      public var m_discountEndDate:String = null;
      
      private var m_motd:XML;
      
      public function MOTDData(param1:XML)
      {
         var _loc5_:String = null;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:XML = null;
         var _loc12_:XMLList = null;
         var _loc13_:Object = null;
         var _loc14_:XMLList = null;
         var _loc15_:XML = null;
         var _loc16_:Object = null;
         var _loc17_:XMLList = null;
         var _loc18_:XML = null;
         super();
         this.m_motd = param1;
         var _loc2_:String = param1.attribute("title");
         var _loc3_:String = param1.attribute("desc");
         var _loc4_:String = param1.attribute("acceptButtonText");
         if(param1.@acceptButtonAlternateText != undefined)
         {
            _loc5_ = param1.attribute("acceptButtonAlternateText");
         }
         this.titleText = this.textFromKey(_loc2_);
         this.descriptionText = this.textFromKey(_loc3_);
         this.acceptButtonText = this.textFromKey(_loc4_);
         if(Boolean(_loc5_) && _loc5_.length > 0)
         {
            this.acceptButtonAlternateText = this.textFromKey(_loc5_);
         }
         this.name = param1.attribute("name");
         this.priority = int(param1.attribute("priority"));
         this.imageURL = param1.attribute("imageURL");
         var _loc6_:int = ZGlobal.player.level;
         var _loc7_:Object = new Object();
         if(ExperimentsManager.instance.experimentGateEnabled("empire_variable_rewards","2") && param1.hasOwnProperty("motdModifier"))
         {
            _loc8_ = 0;
            while(_loc8_ < param1.motdModifier.length())
            {
               if(Boolean(param1.motdModifier[_loc8_].hasOwnProperty("@minLevel")) && Boolean(param1.motdModifier[_loc8_].hasOwnProperty("@maxLevel")) && Boolean(param1.motdModifier[_loc8_].hasOwnProperty("@imageURL")))
               {
                  _loc7_.minLevel = int(param1.motdModifier[_loc8_].@minLevel);
                  _loc7_.maxLevel = int(param1.motdModifier[_loc8_].@maxLevel);
                  _loc7_.imageURL = String(param1.motdModifier[_loc8_].@imageURL);
                  if(_loc7_.minLevel != 0 && _loc7_.maxLevel != 0 && _loc7_.imageURL != 0)
                  {
                     if(_loc6_ >= _loc7_.minLevel && _loc6_ <= _loc7_.maxLevel)
                     {
                        if(param1.hasOwnProperty("difficultyMode"))
                        {
                           if(param1.difficultyMode.hasOwnProperty("@experiment") && ExperimentsManager.instance.experimentGateEnabled(param1.difficultyMode.@experiment,param1.difficultyMode.@variant))
                           {
                              _loc9_ = param1.difficultyMode.attribute("desc");
                              this.descriptionText = this.textFromKey(_loc9_);
                           }
                        }
                        this.imageURL = _loc7_.imageURL;
                        break;
                     }
                  }
               }
               _loc8_++;
            }
         }
         if(param1.@bgURL != undefined)
         {
            this.bgURL = param1.@bgURL.toString();
         }
         if(param1.@showCardBg != undefined)
         {
            this.showCardBg = param1.@showCardBg == "false" ? false : true;
         }
         if(param1.@collapseCardButton != undefined)
         {
            this.collapseCardButton = param1.@collapseCardButton == "true" ? true : false;
         }
         this.requireUserInteract = false;
         if(param1.@requireUserInteract != undefined)
         {
            _loc10_ = param1.@requireUserInteract.toString();
            this.requireUserInteract = _loc10_ == "true" || _loc10_ == "0";
         }
         this.acceptButtonBehavior = param1.attribute("acceptButtonBehavior");
         this.acceptButtonBehaviorData = param1.attribute("acceptButtonBehaviorData");
         this.oncePerDay = this.m_motd.hasOwnProperty("oncePerDay");
         if(param1.@isXPromo != undefined)
         {
            this.isXPromo = param1.attribute("isXPromo");
            this.xPromoGameID = param1.attribute("xPromoGameID");
            this.xPromoID = parseInt(param1.attribute("xPromoID"));
         }
         if(this.m_motd.hasOwnProperty("forceShow"))
         {
            this.flagName = this.m_motd.forceShow[0].attribute("seenFlagName");
            this.numTimes = this.m_motd.forceShow[0].attribute("numTimes");
         }
         if(this.m_motd.@link != undefined && this.m_motd.@linkUrl != undefined)
         {
            this.linkText = this.textFromKey(this.m_motd.@link.toString());
            this.descriptionText = this.descriptionText + " " + this.linkText;
            this.linkUrl = this.textFromKey(this.m_motd.@linkUrl.toString());
         }
         if(this.m_motd.@checkPermission != undefined)
         {
            this.checkPermission = this.m_motd.attribute("checkPermission");
         }
         this.type = param1.@type == undefined ? MOTD_TYPE_MESSAGE : param1.@type;
         this.version = param1.@version == undefined ? 1 : int(param1.@version);
         if(this.m_motd.@advisorId != undefined)
         {
            this.advisorId = this.m_motd.attribute("advisorId");
         }
         if(this.m_motd.hasOwnProperty("merchData"))
         {
            this.merchData = new Object();
            this.merchData.merchItems = new Array();
            this.merchData.bonusItems = new Array();
            _loc12_ = this.m_motd.merchData.merchItems.item;
            for each(_loc11_ in _loc12_)
            {
               _loc17_ = _loc11_.attributes();
               _loc13_ = new Object();
               for each(_loc18_ in _loc17_)
               {
                  _loc13_[_loc18_.name().toString()] = _loc18_.valueOf().toString();
               }
               this.merchData.merchItems.push(_loc13_);
            }
            _loc14_ = this.m_motd.merchData.bonusItems.item;
            for each(_loc15_ in _loc14_)
            {
               _loc17_ = _loc15_.attributes();
               _loc16_ = new Object();
               for each(_loc18_ in _loc17_)
               {
                  _loc16_[_loc18_.name().toString()] = _loc18_.valueOf().toString();
               }
               this.merchData.bonusItems.push(_loc16_);
            }
         }
      }
      
      public function get xml() : XML
      {
         return this.m_motd;
      }
      
      public function isRelevant(param1:Player, param2:Boolean = true) : Boolean
      {
         if(this.hasPermission)
         {
            return false;
         }
         var _loc3_:int = ZGameTimeUtil.instance.getDateStatus(null,this.xml);
         if(_loc3_ != ZGameTimeUtil.DATE_STATUS_NONE && _loc3_ != ZGameTimeUtil.DATE_STATUS_ACTIVE)
         {
            return false;
         }
         if(param2)
         {
            if(this.flagName)
            {
               if(param1.getSeenFlag(this.flagName) == this.numTimes)
               {
                  return false;
               }
            }
            else
            {
               if(this.requireUserInteract && ZGlobal.player.hasMotdBeenAccepted(this.name))
               {
                  return false;
               }
               if(!this.requireUserInteract && ZGlobal.player.hasMotdBeenViewed(this.name))
               {
                  return false;
               }
            }
            if(this.oncePerDay && ZGlobal.newDayThisSession == false)
            {
               return false;
            }
         }
         if(CriteriaUtil.meetsCriteria(this.m_motd.criteria))
         {
            if(this.m_motd.criteria.BuildableDiscountZRTControlled[0] != null)
            {
               this.m_discountCode = CriteriaUtil.discountCode;
               this.m_discountEndDate = CriteriaUtil.discountEndDate;
            }
            else
            {
               this.m_discountCode = null;
               this.m_discountEndDate = null;
            }
            return true;
         }
         return false;
      }
      
      public function get clockValuesXML() : XML
      {
         var _loc1_:int = 0;
         var _loc2_:Date = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:XML = null;
         var _loc8_:XML = null;
         if(this.xml.@behavior.toString() == MOTDData.BEHAVIOR_LIGHTNINGDEAL)
         {
            _loc1_ = ZGlobal.player.getLightningDealInfo(PromoManager.LD_MC_KEY_DATEEND) as int;
            _loc2_ = new Date();
            _loc2_.setTime(_loc1_ * 1000);
            _loc3_ = _loc2_.month + 1;
            _loc4_ = _loc2_.date;
            _loc5_ = _loc2_.fullYear;
            _loc6_ = _loc3_ + "/" + _loc4_ + "/" + _loc5_;
            _loc7_ = <requiredDate start="01/01/2011" end={_loc6_}/>;
            _loc8_ = <messageOfTheday/>;
            _loc8_.appendChild(_loc7_);
            return _loc8_;
         }
         return this.xml;
      }
      
      public function shouldShowCountdownClock() : Boolean
      {
         var _loc1_:int = ZGameTimeUtil.instance.getDateStatus(null,this.xml);
         if(Boolean(_loc1_ == ZGameTimeUtil.DATE_STATUS_ACTIVE) && Boolean(this.xml.requiredDate) && this.xml.requiredDate.@countdown == "true")
         {
            return true;
         }
         if(this.xml.@behavior != undefined)
         {
            return true;
         }
         return false;
      }
      
      private function textFromKey(param1:String) : String
      {
         if(param1 == null || param1.length == 0)
         {
            return "";
         }
         var _loc2_:Array = param1.split(":");
         if(_loc2_.length > 1)
         {
            return ZGameUtils.ZlocT(_loc2_[0],_loc2_[1]);
         }
         return ZGameUtils.ZlocT(this.LOCALIZATION_FILE,param1);
      }
      
      public function get swfOverride() : String
      {
         if(this.xml.@swfOverride == undefined)
         {
            return null;
         }
         return this.xml.@swfOverride;
      }
      
      public function isTypeMerchandise() : Boolean
      {
         return this.type == MOTD_TYPE_MERCHANDISING;
      }
      
      public function isTypeMessage() : Boolean
      {
         return this.type == MOTD_TYPE_MESSAGE;
      }
      
      public function isTypePlacement() : Boolean
      {
         return this.type == MOTD_TYPE_PLACEMENT;
      }
      
      public function get behavior() : String
      {
         if(this.xml.@behavior != undefined)
         {
            return this.xml.@behavior.toString();
         }
         return null;
      }
   }
}

