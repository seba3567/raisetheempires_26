package displays.screens
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.gameobjects.CrewTemplateWrapper;
   import core.gameobjects.GameItem;
   import core.managers.CrewManager;
   import core.managers.ExperimentsManager;
   import core.managers.MatchMakingManager;
   import core.managers.WorldResourceManager;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.ImageLoaderFactory;
   import entity.GameDataComponent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class MatchMakingScreen extends CrewGather
   {
      
      private static var instance:MatchMakingScreen;
      
      protected var m_currentTab:uint;
      
      protected var m_resource:SWFResource;
      
      protected var m_textInfo:Object = {
         "title":"CrewDialogTitle",
         "desc":"CrewDialogDesc"
      };
      
      protected var m_page:int;
      
      protected var m_buttons:Array = [];
      
      private var arrCardUIDs:Array = new Array();
      
      public function MatchMakingScreen(param1:IEntity, param2:GameItem, param3:Object)
      {
         var _loc4_:Class = CrewGatherSlotOwnerPartial;
         var _loc5_:String = param2.getCrewTemplateName(false);
         var _loc6_:CrewTemplateWrapper = _loc5_ ? ZGlobal.gameSettings.getCrewTemplateWrapper(_loc5_) : null;
         var _loc7_:Array = Boolean(param3) && Boolean(param3.crewInfo) ? param3.crewInfo : new Array();
         super(param1,_loc6_,param2,_loc7_,_loc4_);
         CrewManager.instance.addEventListener(CrewManager.PURCHASED_CREW_SLOT_FULL,this.onPurchasedSlotFull,false,0,true);
         addEventListener(CrewResizablePopUp.CLOSED,this.onWindowClosed);
      }
      
      public static function display(param1:IEntity, param2:GameItem, param3:Object) : PopUpBase
      {
         var _loc4_:PopUpBase = new MatchMakingScreen(param1,param2,param3);
         WindowManager.instance.push(_loc4_);
         return _loc4_;
      }
      
      override protected function getAsset() : String
      {
         return "assets/displays/screens/MatchMakingScreen.swf";
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         this.m_resource = param1;
         m_window = param1.clip.main_mc;
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClicked,false,0,true);
         m_fixedButtonSounds.addButton(m_window.exit_bt,ButtonSound.DEFAULT);
         this.setupIcons();
         this.setupTextFields();
         this.setupCrew();
         this.setupTabs();
         if(MatchMakingManager.instance.optIn)
         {
            this.setupCards();
         }
         else
         {
            this.setupOptIn();
         }
         addChild(m_window);
         contentWidth = m_window.width;
         contentHeight = m_window.height;
         m_origOffsetX = m_window.x;
         m_origOffsetY = m_window.y;
         centerWithinStage(Zlab.mainStage);
         StatsManager.count("MatchMaking","MatchMaking_ui",this.asnCategory());
      }
      
      private function asnCategory() : String
      {
         var _loc1_:Number = ZGlobal.player.asn;
         if(_loc1_ == 0)
         {
            return "LW";
         }
         if(_loc1_ >= 1 && _loc1_ <= 5)
         {
            return "S";
         }
         return "WL";
      }
      
      protected function setupOptIn() : void
      {
         var _loc6_:MovieClip = null;
         var _loc7_:Rectangle = null;
         var _loc8_:ZGameButton = null;
         var _loc9_:ZGameButton = null;
         m_window.tabContent1_mc.visible = false;
         var _loc1_:MovieClip = m_window.optOut_mc;
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","WorldParliamentMatchMaking_OptIn_Desc");
         var _loc3_:String = ZGameUtils.ZlocT("Dialogs","WorldParliamentMatchMaking_OptIn_Link");
         var _loc4_:String = ZGameUtils.ZlocT("Dialogs","WorldParliamentMatchMaking_OptIn_Button");
         TextFieldUtil.compactTextField(_loc1_.description_tf,_loc2_);
         if(_loc1_.link_tf)
         {
            TextFieldUtil.compactTextField(_loc1_.link_tf,_loc3_);
            _loc6_ = new MovieClip();
            _loc1_.link_tf.parent.addChild(_loc6_);
            _loc7_ = _loc1_.link_tf.getBounds(_loc1_.link_tf.parent);
            _loc6_.graphics.beginFill(16711680,0);
            _loc6_.graphics.drawRect(_loc7_.x,_loc7_.y,_loc7_.width,_loc7_.height);
            _loc6_.graphics.endFill();
            _loc6_.generic_tf = new TextField();
            _loc8_ = new ZGameButton(_loc6_,this.onClick);
            _loc8_.sounds = ButtonSound.DEFAULT;
            m_fixedButtonSounds.addButton(_loc8_.m_overlay,ButtonSound.DEFAULT);
            this.m_buttons.push(_loc8_);
         }
         if(_loc1_.info_bt)
         {
            _loc9_ = new ZGameButton(_loc1_.info_bt,this.onInfoClick);
            _loc9_.sounds = ButtonSound.DEFAULT;
            _loc9_.text = "?";
            this.m_buttons.push(_loc9_);
         }
         var _loc5_:ZGameButton = new ZGameButton(_loc1_.ok_bt,this.optIn);
         _loc5_.sounds = ButtonSound.DEFAULT;
         m_fixedButtonSounds.addButton(_loc5_.m_overlay,ButtonSound.DEFAULT);
         this.m_buttons.push(_loc5_);
         _loc5_.text = _loc4_;
         this.m_buttons.push(_loc5_);
         _loc5_.sounds = ButtonSound.DEFAULT;
         _loc1_.visible = true;
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         navigateToURL(new URLRequest("http://accounts.zynga.com/?game=81"),"_blank");
      }
      
      protected function optIn(param1:MouseEvent) : void
      {
         StatsManager.count("MatchMaking","Count_me_in");
         MatchMakingManager.instance.optIn = true;
         UIDispatcher.instance.dispatchEvent(new Event(MatchMakingManager.MATCHMAKING_OPTIN));
         this.onExitClicked(null);
      }
      
      protected function setupCrew() : void
      {
         var _loc2_:Point = null;
         var _loc4_:Point = null;
         var _loc1_:Class = this.m_resource.getAssetClass("crewCard");
         m_mc = m_window.tabContent2_mc;
         if(m_mc.build_bt)
         {
            m_mc.build_bt.visible = false;
         }
         if(m_mc.title_tf)
         {
            m_mc.title_tf.mouseEnabled = false;
         }
         m_slotCards = createSlotCards(_loc1_);
         _loc2_ = new Point(m_slotCards[0].width,m_slotCards[0].height);
         var _loc3_:int = m_wrapper.numPositions;
         _loc4_ = this.getGridLayout(_loc3_);
         var _loc5_:Point = getGridLayoutDimensions(_loc4_,_loc2_);
         var _loc6_:uint = uint(m_mc.panel_mc.width);
         onWidthSet(_loc6_);
         m_slotContainer.mouseEnabled = false;
         m_slotContainer.x = (m_mc.width - _loc5_.x) * 0.5;
         m_slotContainer.y = 0;
         m_mc.addChild(m_slotContainer);
         contentWidth = dialogWidth;
         contentHeight = dialogHeight;
         if(this.showConfirmButton())
         {
            initConfirmButtonMC();
            m_confirmButton = new ZGameButton(actionButtonMC,onConfirmClick);
            m_confirmButton.sounds = ButtonSound.DEFAULT;
            m_fixedButtonSounds.addButton(m_confirmButton.m_overlay,ButtonSound.DEFAULT);
            this.m_buttons.push(m_confirmButton);
         }
         initDialog();
         setupText();
         initSlotCards(_loc4_,_loc2_);
      }
      
      override protected function showConfirmButton() : Boolean
      {
         var _loc1_:BuildingFSMComponent = BuildingFSMComponent(owner.lookupComponentByType(BuildingFSMComponent));
         var _loc2_:BehaviorStateMachine = BehaviorStateMachine(_loc1_.stateMachine);
         return Boolean(BehaviorState(_loc2_.currentState)) && BehaviorState(_loc2_.currentState).isCrewState() || !CrewManager.isCrewBuildingFull(owner);
      }
      
      protected function setupTextFields() : void
      {
         var _loc1_:int = 0;
         var _loc2_:String = null;
         TextFieldUtil.compactTextField(m_window.title_tf,ZGameUtils.ZlocT("Dialogs","WorldParliamentMatchMaking_Title"));
         TextFieldUtil.compactTextField(m_window.description_tf,ZGameUtils.ZlocT("Dialogs","WorldParliamentMatchMaking_Description"));
         if(Boolean(ZGlobal.player.matchmakingFriends) && ZGlobal.player.matchmakingFriends.length > 0)
         {
            TextFieldUtil.compactTextField(m_window.tabContent1_mc.description_tf,ZGameUtils.ZlocT("Dialogs","WorldParliamentMatchMaking_Explain"));
         }
         else
         {
            _loc1_ = ZGlobal.gameSettings.getInt("matchMakingStaleDays",1);
            _loc2_ = ZGameUtils.ZlocT("Dialogs","WorldParliamentMatchMaking_NoSuggestions",{"days":_loc1_});
            TextFieldUtil.compactTextField(m_window.tabContent1_mc.description_tf,_loc2_);
         }
      }
      
      protected function setupIcons() : void
      {
         var _loc1_:String = ZGlobal.gameSettings.getImageByName("Parliament","screenicon");
         ImageLoaderFactory.CreateImageLoader(_loc1_,m_window.buildingImage);
      }
      
      protected function setupTabs() : void
      {
         var _loc4_:MovieClip = null;
         m_window.optOut_mc.visible = false;
         var _loc1_:Array = [m_window.tab01_mc,m_window.tab02_mc];
         var _loc2_:int = 0;
         var _loc3_:String = "";
         _loc2_ = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc4_ = _loc1_[_loc2_];
            if(_loc2_ == 0)
            {
               _loc4_.gotoAndStop(_loc4_.totalFrames);
            }
            else
            {
               _loc4_.gotoAndStop(1);
            }
            _loc3_ = ZGameUtils.ZlocT("Dialogs","MatchMakingTab" + _loc2_);
            TextFieldUtil.compactTextField(_loc1_[_loc2_].tabName_tf,_loc3_);
            _loc1_[_loc2_].addEventListener(MouseEvent.MOUSE_OVER,this.onTabMouseOver,false,0,true);
            _loc1_[_loc2_].addEventListener(MouseEvent.MOUSE_OUT,this.onTabMouseOut,false,0,true);
            _loc1_[_loc2_].addEventListener(MouseEvent.CLICK,this.onTabClick,false,0,true);
            m_fixedButtonSounds.addButton(_loc1_[_loc2_],ButtonSound.DEFAULT);
            _loc2_++;
         }
         this.currentTab = 0;
         this.m_page = 0;
      }
      
      protected function onTabMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:String = "";
         var _loc3_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc3_.currentFrame < _loc3_.totalFrames - 1)
         {
            _loc3_.gotoAndStop(2);
         }
         var _loc4_:int = _loc3_ == m_window.tab01_mc ? 0 : 1;
         _loc2_ = ZGameUtils.ZlocT("Dialogs","MatchMakingTab" + _loc4_);
         TextFieldUtil.compactTextField(_loc3_.tabName_tf,_loc2_);
      }
      
      protected function onTabMouseOut(param1:MouseEvent) : void
      {
         var _loc2_:String = "";
         var _loc3_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc3_.currentFrame < _loc3_.totalFrames - 1)
         {
            _loc3_.gotoAndStop(1);
         }
         var _loc4_:int = _loc3_ == m_window.tab01_mc ? 0 : 1;
         _loc2_ = ZGameUtils.ZlocT("Dialogs","MatchMakingTab" + _loc4_);
         TextFieldUtil.compactTextField(_loc3_.tabName_tf,_loc2_);
      }
      
      protected function onTabClick(param1:MouseEvent) : void
      {
         var _loc2_:String = "";
         var _loc3_:MovieClip = param1.currentTarget as MovieClip;
         var _loc4_:int = _loc3_ == m_window.tab01_mc ? 0 : 1;
         if(_loc4_ == this.currentTab)
         {
            return;
         }
         _loc3_.gotoAndStop(_loc3_.totalFrames);
         var _loc5_:MovieClip = _loc4_ ? m_window.tab01_mc : m_window.tab02_mc;
         _loc5_.gotoAndStop(1);
         var _loc6_:int = 0;
         while(_loc6_ < 2)
         {
            _loc3_ = m_window["tab0" + (_loc6_ + 1) + "_mc"];
            _loc2_ = ZGameUtils.ZlocT("Dialogs","MatchMakingTab" + _loc6_);
            TextFieldUtil.compactTextField(_loc3_.tabName_tf,_loc2_);
            _loc6_++;
         }
         this.currentTab = int(!this.currentTab);
      }
      
      protected function get currentTab() : uint
      {
         return this.m_currentTab;
      }
      
      protected function set currentTab(param1:uint) : void
      {
         var _loc2_:Array = null;
         if(MatchMakingManager.instance.optIn)
         {
            _loc2_ = [m_window.tabContent1_mc,m_window.tabContent2_mc];
            m_window.optOut_mc.visible = false;
         }
         else
         {
            _loc2_ = [m_window.optOut_mc,m_window.tabContent2_mc];
            m_window.tabContent1_mc.visible = false;
         }
         this.m_currentTab = param1;
         _loc2_[int(!this.currentTab)].visible = false;
         _loc2_[this.currentTab].visible = true;
      }
      
      protected function setupCards() : void
      {
         var _loc6_:String = null;
         var _loc7_:Object = null;
         var _loc8_:MovieClip = null;
         var _loc9_:String = null;
         var _loc10_:ZGameButton = null;
         var _loc11_:String = null;
         var _loc12_:String = null;
         var _loc13_:String = null;
         var _loc14_:String = null;
         var _loc15_:String = null;
         var _loc16_:ZGameButton = null;
         var _loc1_:Array = ZGlobal.player.matchmakingFriends;
         var _loc2_:MovieClip = m_window.tabContent1_mc;
         var _loc3_:Array = [_loc2_.card1_mc,_loc2_.card2_mc,_loc2_.card3_mc,_loc2_.card4_mc,_loc2_.card5_mc];
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc3_[_loc4_].visible = false;
            if((_loc4_ + this.m_page) % 5 < ZGlobal.player.matchmakingFriends.length)
            {
               _loc6_ = _loc1_[(_loc4_ + this.m_page) % ZGlobal.player.matchmakingFriends.length];
               _loc7_ = MatchMakingManager.instance.getMMFriendInfo(_loc6_);
               if(_loc7_ != null)
               {
                  _loc3_[_loc4_].visible = true;
                  _loc8_ = _loc3_[_loc4_];
                  TextFieldUtil.compactTextField(_loc8_.profilename_tf,_loc7_.name);
                  TextFieldUtil.compactTextField(_loc8_.profilelevel_tf,_loc7_.level);
                  _loc9_ = _loc7_.picture_url ? _loc7_.picture_url : "";
                  _loc8_.profileloader_mc.source = null;
                  ImageLoaderFactory.CreateImageLoader(_loc9_,_loc8_.profileloader_mc);
                  this.arrCardUIDs[_loc4_] = _loc6_;
                  _loc10_ = new ZGameButton(_loc8_.add_bt,this.onAddClick);
                  m_fixedButtonSounds.addButton(_loc10_.m_overlay,ButtonSound.DEFAULT);
                  if(MatchMakingManager.IsRequestPending(_loc6_))
                  {
                     _loc10_.sounds = ButtonSound.DEFAULT;
                     _loc10_.text = ZGameUtils.ZlocT("Dialogs","MatchMaking_InviteSent");
                     _loc10_.disable_visual(true);
                  }
                  else
                  {
                     _loc10_.text = ZGameUtils.ZlocT("Dialogs","MatchMaking_AddMe");
                     _loc10_.enable();
                  }
                  this.m_buttons.push(_loc10_);
                  if(_loc8_.manIcon_mc)
                  {
                     _loc8_.manIcon_mc.visible = false;
                  }
                  if(_loc8_.profilename_tf_white)
                  {
                     _loc8_.profilename_tf_white.visible = false;
                  }
                  if(_loc8_.new_tf)
                  {
                     _loc8_.new_tf.visible = false;
                  }
                  _loc11_ = _loc7_.country ? _loc7_.country : ZGameUtils.ZlocT("Dialogs","Unknown");
                  _loc12_ = ZGameUtils.ZlocT("Dialogs","WorldParliamentMatchMaking_country",{"country":_loc11_});
                  TextFieldUtil.compactTextField(_loc8_.description1_tf,_loc12_);
                  _loc13_ = this.engagementText(_loc7_.engagement_7day);
                  _loc14_ = ZGameUtils.ZlocT("Dialogs",_loc13_);
                  TextFieldUtil.compactTextField(_loc8_.description2_tf,_loc14_);
                  if(ExperimentsManager.instance.getExperimentVariant("empires_matchmaking_showengagement") <= 1)
                  {
                     _loc8_.description2_tf.visible = false;
                  }
                  _loc15_ = WorldResourceManager.instance.getResourceImageURL(_loc7_.resource,WorldResourceManager.XTRA_SMALL_ICON);
                  ImageLoaderFactory.CreateImageLoader(_loc15_,_loc8_.ore_mc);
               }
            }
            _loc4_++;
         }
         var _loc5_:ZGameButton = new ZGameButton(m_window.tabContent1_mc.refresh_bt,this.onRefreshClick);
         _loc5_.sounds = ButtonSound.DEFAULT;
         _loc5_.text = ZGameUtils.ZlocT("Dialogs","MatchMaking_Refresh");
         this.m_buttons.push(_loc5_);
         if(_loc2_.info_bt != null)
         {
            _loc16_ = new ZGameButton(_loc2_.info_bt,this.onInfoClick);
            _loc16_.sounds = ButtonSound.DEFAULT;
            _loc16_.text = "?";
            this.m_buttons.push(_loc16_);
         }
      }
      
      private function onInfoClick(param1:MouseEvent) : void
      {
         var _loc2_:String = "http://accounts.zynga.com/?game=81";
         navigateToURL(new URLRequest(_loc2_),null);
         this.onExitClicked(null);
      }
      
      private function engagementText(param1:int) : String
      {
         if(param1 == 7)
         {
            return "WorldParliamentMatchMaking_Eng_3";
         }
         if(param1 == 6)
         {
            return "WorldParliamentMatchMaking_Eng_2";
         }
         if(param1 >= 4)
         {
            return "WorldParliamentMatchMaking_Eng_1";
         }
         return "WorldParliamentMatchMaking_Eng_0";
      }
      
      protected function onAddClick(param1:MouseEvent) : void
      {
         var _loc2_:ZGameButton = param1.currentTarget.buttonPointer as ZGameButton;
         _loc2_.text = ZGameUtils.ZlocT("Dialogs","MatchMaking_InviteSent");
         _loc2_.disable(true);
         var _loc3_:MovieClip = m_window.tabContent1_mc;
         var _loc4_:Array = [_loc3_.card1_mc,_loc3_.card2_mc,_loc3_.card3_mc,_loc3_.card4_mc,_loc3_.card5_mc];
         var _loc5_:Array = ZGlobal.player.matchmakingFriends;
         var _loc6_:int = 0;
         while(_loc6_ < _loc4_.length)
         {
            if(_loc4_[_loc6_] == param1.currentTarget.parent)
            {
               break;
            }
            _loc6_++;
         }
         StatsManager.count("MatchMaking","main_dialog","Friend_Request");
         MatchMakingManager.instance.addNeighbor(this.arrCardUIDs[_loc6_]);
      }
      
      protected function onRefreshClick(param1:MouseEvent) : void
      {
         StatsManager.count("MatchMaking","Refresh");
         if(Boolean(ZGlobal.player.matchmakingFriends) && ZGlobal.player.matchmakingFriends.length > 5)
         {
            this.m_page = (this.m_page + 5) % ZGlobal.player.matchmakingFriends.length;
         }
         else
         {
            this.m_page = 0;
         }
         this.setupCards();
      }
      
      private function onExitClicked(param1:MouseEvent) : void
      {
         m_window.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClicked);
         this.deinitDialog();
         this.deinitTabs();
         close();
      }
      
      private function onWindowClosed(param1:Event) : void
      {
         m_window.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClicked);
         this.deinitTabs();
      }
      
      protected function deinitTabs() : void
      {
         var _loc1_:Array = [m_window.tab01_mc,m_window.tab02_mc];
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc1_[_loc2_].removeEventListener(MouseEvent.MOUSE_OVER,this.onTabMouseOver);
            _loc1_[_loc2_].removeEventListener(MouseEvent.MOUSE_OUT,this.onTabMouseOut);
            _loc1_[_loc2_].removeEventListener(MouseEvent.CLICK,this.onTabClick);
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < this.m_buttons.length)
         {
            if(this.m_buttons[_loc2_])
            {
               this.m_buttons[_loc2_].dispose();
            }
            _loc2_++;
         }
      }
      
      override protected function getTitleText() : String
      {
         return ZGameUtils.ZlocTP("Dialogs",this.m_textInfo.title,getStringTokens());
      }
      
      override protected function getDescriptionText() : String
      {
         return ZGameUtils.ZlocTP("Dialogs",this.m_textInfo.desc,getStringTokens());
      }
      
      override protected function getButtonTextKey() : String
      {
         if(this.m_textInfo.button)
         {
            return canFinishBuilding() ? this.m_textInfo.button.finish : this.m_textInfo.button.hire;
         }
         return super.getButtonTextKey();
      }
      
      override protected function onConfirmFinish() : void
      {
         if(canFinishBuilding())
         {
            CrewManager.setCrewInfo(owner,m_crewInfo);
         }
         super.onConfirmFinish();
      }
      
      private function onPurchasedSlotFull(param1:WorldEvent) : void
      {
         var _loc2_:GameDataComponent = GameDataComponent.getGameDataComponent(owner);
         if(Boolean(_loc2_) && _loc2_.id == param1.eventData.objid)
         {
            m_crewInfo = param1.eventData.crew;
            updateElements();
         }
      }
      
      override protected function get resize() : Boolean
      {
         return false;
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         CrewManager.instance.removeEventListener(CrewManager.PURCHASED_CREW_SLOT_FULL,this.onPurchasedSlotFull);
      }
      
      override protected function getGridLayout(param1:int) : Point
      {
         return new Point(param1,1);
      }
   }
}

