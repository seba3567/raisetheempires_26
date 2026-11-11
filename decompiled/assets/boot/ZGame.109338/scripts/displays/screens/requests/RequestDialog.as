package displays.screens.requests
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.AlliancesManager;
   import core.managers.ExperimentsManager;
   import core.managers.MatchMakingManager;
   import core.managers.ZRTManager;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import dispatchers.MessageDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import displays.screens.RequestDialogCardInterface;
   import displays.screens.RequestDialogListItem;
   import displays.screens.RequestPlayerCard;
   import fl.motion.AdjustColor;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TMFSRewardCollect;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class RequestDialog extends GallantPopup
   {
      
      public static const GIFT_REQUEST:String = "409001";
      
      public static const NEIGHBOR_REQUEST:String = "409002";
      
      public static const HELP_REQUEST:String = "409003";
      
      public static const OTHER_REQUEST:String = "409004";
      
      private static const NUM_SLOTS:int = 25;
      
      private static var NUM_LIST:int = 9;
      
      private static const NUM_SELECTED:int = 4;
      
      public static const TYPE_RECENTLY_PLAYED:String = "recently_played";
      
      public static const TYPE_GIFT:String = "gift";
      
      public static const TYPE_CREW:String = "crew";
      
      public static const TYPE_GIFT_REQUEST:String = "gift_request";
      
      public static const TYPE_NEIGHBOR:String = "neighbor";
      
      public static const TYPE_INVASION_HELP:String = "invasion_help";
      
      public static const TYPE_ALLIANCE:String = "alliance";
      
      public static const SUBTYPE_TAB:String = "tab";
      
      public static const SUBTYPE_INTERSTITIAL:String = "interstitial";
      
      public static const SUBTYPE_IDLE:String = "idle";
      
      public static const SUBTYPE_NONE:String = "";
      
      public static const REQUEST_SPEEDUP:String = "request_speedup";
      
      public static const REQUEST_CREW:String = "request_crew";
      
      public static const REQUEST_GIFT_REQUEST:String = "request_gift_request";
      
      public static const REQUEST_GIFT_SEND:String = "request_gift_send";
      
      public static const REQUEST_BUILDINGPART_SEND:String = "request_buildingpart_send";
      
      public static const REQUEST_REPEL_INVASION:String = "request_repel_invasion";
      
      public static const REQUEST_NEIGHBOR_REQUEST:String = "request_neighbor";
      
      public static const REQUEST_ALLIANCE_REQUEST:String = "request_alliance_invite";
      
      public static const MFS_TAB_ALL:int = 0;
      
      public static const MFS_TAB_ZYNGA:int = 1;
      
      public static const MFS_TAB_ENA:int = 2;
      
      private var m_friends:Array;
      
      private var m_zyngaFriends:Array;
      
      private var m_enaFriends:Array;
      
      private var m_cards:Array;
      
      private var m_zyngaCards:Array;
      
      private var m_enaCards:Array;
      
      private var m_selectedCards:Array;
      
      private var m_sendButton:ZGameButton = null;
      
      private var m_selectAllButton:ZGameButton = null;
      
      private var m_currentPage:int = 1;
      
      private var m_currentListPage:int = 1;
      
      private var m_currentSelectedPage:int = 1;
      
      private var m_sentCount:int = 0;
      
      private var m_title:String;
      
      private var m_body:String;
      
      private var m_placeholder:String;
      
      private var m_zyngaPlaceholder:String;
      
      private var m_toaster:String;
      
      private var m_iconURL:String;
      
      private var m_icon:ImageLoader;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var variant:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MFS_UILI);
      
      private var mfsp2_variant:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MFSP2_MASTER);
      
      private var mfsp2_gameClick_variant:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MFSP2_GAMECLICK);
      
      private var mfsp2_tab_variant:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MFSP2_TAB);
      
      private var mfsp2_search_variant:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MFSP2_SEARCH);
      
      private var mfsp2_rewardBar_variant:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MFSP2_REWARDBAR);
      
      private var m_isListDragging:Boolean = false;
      
      private var m_isSelectedDragging:Boolean = false;
      
      private var m_allSelected:Boolean;
      
      private var m_totalSelected:uint = 0;
      
      protected var m_requestType:String;
      
      protected var m_requestSubcategory:String;
      
      protected var m_requestSubtype:String;
      
      protected var m_resource:SWFResource = null;
      
      private var m_maxNumFriends:uint = 0;
      
      private var m_sendButtonClicks:int = 0;
      
      private var m_gameFrame:int = 1;
      
      private var m_animationPlaying:Boolean = false;
      
      private var m_rewardBarMax:int = 0;
      
      private var m_selectedTab:int = 0;
      
      private var mfsData:Object;
      
      private var rewardButtons:Array = new Array();
      
      private var friendPick:Class;
      
      private var m_friendPick:MovieClip;
      
      private var m_randomFriendPic:String = "";
      
      private var m_friendPickStrings:Array = new Array();
      
      private var m_activeSearchBar:Array = null;
      
      private var m_defaultSearchBar:Array = null;
      
      private var m_skipSearch:Boolean = true;
      
      public function RequestDialog(param1:Array, param2:String, param3:String, param4:String, param5:String, param6:String, param7:String = "")
      {
         var _loc8_:int = 1;
         while(_loc8_ <= 15)
         {
            this.m_friendPickStrings.push(ZGameUtils.ZlocT("Dialogs","MFS_Pick" + _loc8_.toString(),{"user":ZGlobal.player.firstName}));
            _loc8_++;
         }
         var _loc9_:String = null;
         if(this._mfsp2)
         {
            _loc9_ = "assets/displays/dialogs/PU_requestsNewV2.swf";
            if(this._search && this._tab)
            {
               NUM_LIST = 9;
            }
            else if(this._search)
            {
               NUM_LIST = 11;
            }
            else if(this._tab)
            {
               NUM_LIST = 10;
            }
            else
            {
               NUM_LIST = 12;
            }
         }
         else if(this.isNewMFSDialog())
         {
            _loc9_ = "assets/displays/dialogs/PU_requestsNew.swf";
         }
         else
         {
            _loc9_ = "assets/displays/dialogs/PU_Requests.swf";
         }
         super(ZGlobal.getAssetURL(_loc9_));
         this.m_title = param2;
         this.m_body = param3;
         this.m_toaster = param4;
         this.m_iconURL = param5;
         this.m_requestType = param6;
         this.m_requestSubcategory = param7;
         this.m_requestSubtype = param7;
         this.m_placeholder = ZGameUtils.ZlocT("Dialogs","RequestPlaceholderEmpire");
         this.m_zyngaPlaceholder = ZGameUtils.ZlocT("Dialogs","RequestPlaceholderZynga");
         this.m_allSelected = false;
         this.initFriends(param1);
         this.sortFriends();
         if(this.m_maxNumFriends < this.m_friends.length)
         {
            this.m_friends.splice(this.m_maxNumFriends,this.m_friends.length - this.m_maxNumFriends);
         }
         this.removeActiveRequests();
      }
      
      public function isNewMFSDialog() : Boolean
      {
         return this.variant == ExperimentsManager.VARIANT_MFS_UILI_NEW_CYCLIC || this.variant == ExperimentsManager.VARIANT_MFS_UILI_NEW_EXHAUSTIVE;
      }
      
      public function isCyclic() : Boolean
      {
         return this.variant == ExperimentsManager.VARIANT_MFS_UILI_NEW_CYCLIC || this.variant == ExperimentsManager.VARIANT_MFS_UILI_OLD_CYCLIC;
      }
      
      public function get _mfsp2() : Boolean
      {
         return this.mfsp2_variant == ExperimentsManager.VARIANT_MFSP2_MASTER_ON;
      }
      
      public function get _gameClick() : Boolean
      {
         return this._mfsp2 && (this.mfsp2_gameClick_variant == ExperimentsManager.VARIANT_MFSP2_GAMECLICK_3 || this.mfsp2_gameClick_variant == ExperimentsManager.VARIANT_MFSP2_GAMECLICK_4);
      }
      
      public function get _tab() : Boolean
      {
         return this._mfsp2 && this.mfsp2_tab_variant == ExperimentsManager.VARIANT_MFSP2_TAB_ON;
      }
      
      public function get _search() : Boolean
      {
         return this._mfsp2 && this.mfsp2_search_variant == ExperimentsManager.VARIANT_MFSP2_SEARCH_ON;
      }
      
      public function get _rewardBar() : Boolean
      {
         return this._mfsp2 && this.mfsp2_rewardBar_variant == ExperimentsManager.VARIANT_MFSP2_REWARDBAR_ON;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         this.m_resource = param1;
         this.friendPick = this.m_resource.getAssetClass("friendPick_mc");
         super.onLoadComplete(param1);
      }
      
      protected function get sendButton() : ZGameButton
      {
         return this.m_sendButton;
      }
      
      protected function get friends() : Array
      {
         return this.m_friends;
      }
      
      private function removeActiveRequests() : void
      {
         switch(this.m_requestType)
         {
            case TYPE_RECENTLY_PLAYED:
               ZGlobal.player.pruneActiveGiftRecipients(this.m_friends);
               if(this._tab)
               {
                  ZGlobal.player.pruneActiveGiftRecipients(this.m_zyngaFriends);
                  ZGlobal.player.pruneActiveGiftRecipients(this.m_enaFriends);
               }
               break;
            case TYPE_GIFT:
               ZGlobal.player.pruneActiveGiftRecipients(this.m_friends);
               if(this._tab)
               {
                  ZGlobal.player.pruneActiveGiftRecipients(this.m_zyngaFriends);
                  ZGlobal.player.pruneActiveGiftRecipients(this.m_enaFriends);
               }
               break;
            case TYPE_CREW:
               ZGlobal.player.pruneActiveRequestRecipient(this.m_friends,REQUEST_CREW);
               if(this._tab)
               {
                  ZGlobal.player.pruneActiveRequestRecipient(this.m_zyngaFriends,REQUEST_CREW);
                  ZGlobal.player.pruneActiveRequestRecipient(this.m_enaFriends,REQUEST_CREW);
               }
               break;
            case TYPE_GIFT_REQUEST:
               ZGlobal.player.pruneActiveHelpRecipients(this.m_friends);
               if(this._tab)
               {
                  ZGlobal.player.pruneActiveHelpRecipients(this.m_zyngaFriends);
                  ZGlobal.player.pruneActiveHelpRecipients(this.m_enaFriends);
               }
               break;
            case TYPE_NEIGHBOR:
               ZGlobal.player.pruneActiveRequestRecipient(this.m_friends,REQUEST_NEIGHBOR_REQUEST);
               if(this._tab)
               {
                  ZGlobal.player.pruneActiveRequestRecipient(this.m_zyngaFriends,REQUEST_NEIGHBOR_REQUEST);
                  ZGlobal.player.pruneActiveRequestRecipient(this.m_enaFriends,REQUEST_NEIGHBOR_REQUEST);
               }
               break;
            case TYPE_INVASION_HELP:
               ZGlobal.player.pruneActiveRequestRecipient(this.m_friends,REQUEST_REPEL_INVASION);
               if(this._tab)
               {
                  ZGlobal.player.pruneActiveRequestRecipient(this.m_zyngaFriends,REQUEST_REPEL_INVASION);
                  ZGlobal.player.pruneActiveRequestRecipient(this.m_enaFriends,REQUEST_REPEL_INVASION);
               }
               break;
            case TYPE_ALLIANCE:
               ZGlobal.player.pruneActiveRequestRecipient(this.m_friends,REQUEST_ALLIANCE_REQUEST);
               if(this._tab)
               {
                  ZGlobal.player.pruneActiveRequestRecipient(this.m_zyngaFriends,REQUEST_ALLIANCE_REQUEST);
                  ZGlobal.player.pruneActiveRequestRecipient(this.m_enaFriends,REQUEST_ALLIANCE_REQUEST);
               }
         }
         this.m_maxNumFriends = this.m_friends.length;
      }
      
      private function insertArray(param1:Array, param2:Array, param3:uint) : void
      {
         var _loc5_:uint = 0;
         var _loc4_:Array = param1.splice(param3,param1.length - param3);
         _loc5_ = 0;
         while(_loc5_ < param2.length)
         {
            param1.push(param2[_loc5_]);
            _loc5_++;
         }
         _loc5_ = 0;
         while(_loc5_ < _loc4_.length)
         {
            param1.push(_loc4_[_loc5_]);
            _loc5_++;
         }
      }
      
      private function containsZid(param1:Array, param2:String) : Boolean
      {
         var _loc3_:int = 0;
         if(param1 != null)
         {
            _loc3_ = 0;
            while(_loc3_ < param1.length)
            {
               if(param1[_loc3_] != null && param2 == param1[_loc3_].zid)
               {
                  return true;
               }
               _loc3_++;
            }
         }
         return false;
      }
      
      private function initFriends(param1:Array) : void
      {
         var _loc2_:Dictionary = null;
         var _loc3_:Array = null;
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         this.m_friends = new Array();
         if(this._mfsp2)
         {
            this.m_friends = this.m_friends.concat(ZGlobal.player.allFriendsByEngagement);
            this.m_zyngaFriends = new Array();
            this.m_zyngaFriends = this.m_zyngaFriends.concat(ZGlobal.player.zyngaFriendsByEngagement);
            this.m_enaFriends = new Array();
            this.m_enaFriends = this.m_enaFriends.concat(ZGlobal.player.empireFriendsByEngagement);
            if(MatchMakingManager.instance.isActive() && this.m_requestType != TYPE_NEIGHBOR)
            {
               _loc2_ = ZGlobal.player.neighbors;
               _loc3_ = new Array();
               for each(_loc4_ in _loc2_)
               {
                  if(MatchMakingManager.instance.isMatchMadeNeighbor(_loc4_.uid))
                  {
                     _loc5_ = new Object();
                     _loc5_.zid = _loc5_.uid = _loc4_.uid.toString();
                     _loc5_.name = _loc5_.first_name = _loc4_.name;
                     _loc5_.last_name = "";
                     _loc5_.pic = _loc4_.matchMakingData.image;
                     _loc5_.pic_big = _loc5_.pic + "?type=large";
                     _loc5_.pic_normal = _loc5_.pic + "?type=normal";
                     _loc5_.pic_small = _loc5_.pic + "?type=small";
                     _loc5_.pic_square = _loc5_.pic + "?type=square";
                     _loc5_.is_app_user = true;
                     _loc3_.push(_loc5_);
                  }
               }
               this.m_friends = this.m_friends.concat(_loc3_);
               this.m_zyngaFriends = this.m_zyngaFriends.concat(_loc3_);
               this.m_enaFriends = this.m_enaFriends.concat(_loc3_);
            }
            this.m_maxNumFriends = Math.min(this.calculateMaxFriends(),this.m_friends.length);
            return;
         }
         this.m_friends = param1;
         this.m_maxNumFriends = Math.min(this.calculateMaxFriends(),this.m_friends.length);
      }
      
      protected function get mc() : MovieClip
      {
         return m_window.requests_mc;
      }
      
      protected function get meterMC() : MovieClip
      {
         return this.mc.progressBar_mc.meter_mc;
      }
      
      protected function initProgressBar() : void
      {
         if(this._mfsp2)
         {
            this.sendClicks = 0;
            return;
         }
         this.mc.progressBar_mc.meter_mc.visible = false;
         this.mc.progressBar_mc.meter_ep_mc.visible = false;
         this.meterMC.visible = true;
         TweenLite.to(this.meterMC,0,{"width":0});
      }
      
      protected function onListMouseDown(param1:MouseEvent) : void
      {
         this.listScrollBar.startDrag(true,new Rectangle(this.listScrollLine.x,this.listScrollLine.y + this.listScrollBar.height / 2,0,this.listScrollLine.height - this.listScrollBar.height));
         this.m_isListDragging = true;
         StatsManager.count("dialog","MFS_UILI","drag","list");
         addEventListener(MouseEvent.MOUSE_UP,this.onListMouseUp);
         addEventListener(MouseEvent.MOUSE_MOVE,this.onListMouseMove);
      }
      
      protected function onListMouseUp(param1:MouseEvent) : void
      {
         removeEventListener(MouseEvent.MOUSE_MOVE,this.onListMouseMove);
         removeEventListener(MouseEvent.MOUSE_UP,this.onListMouseUp);
         this.m_isListDragging = false;
         this.listMC.scrollPane_mc.stopDrag();
      }
      
      protected function onListMouseMove(param1:MouseEvent) : void
      {
         if(this.m_isListDragging)
         {
            this.m_currentListPage = int(Math.round((this.listScrollBar.y - (this.listScrollLine.y + this.listScrollBar.height / 2)) / this.getListScrollValue())) + 1;
            this.updatePlayerList();
            this.updateListArrows();
         }
      }
      
      protected function onSelectedMouseDown(param1:MouseEvent) : void
      {
         this.selectedScrollBar.startDrag(true,new Rectangle(this.selectedScrollLine.x,this.selectedScrollLine.y + this.selectedScrollBar.height / 2,0,this.selectedScrollLine.height - this.selectedScrollBar.height));
         this.m_isSelectedDragging = true;
         StatsManager.count("dialog","MFS_UILI","drag","selected");
         addEventListener(MouseEvent.MOUSE_UP,this.onSelectedMouseUp);
         addEventListener(MouseEvent.MOUSE_MOVE,this.onSelectedMouseMove);
      }
      
      protected function onSelectedMouseUp(param1:MouseEvent) : void
      {
         removeEventListener(MouseEvent.MOUSE_MOVE,this.onSelectedMouseMove);
         removeEventListener(MouseEvent.MOUSE_UP,this.onSelectedMouseUp);
         this.m_isSelectedDragging = false;
         this.selectedScrollBar.stopDrag();
      }
      
      protected function onSelectedMouseMove(param1:MouseEvent) : void
      {
         if(this.m_isSelectedDragging)
         {
            this.m_currentSelectedPage = int(Math.round((this.selectedScrollBar.y - (this.selectedScrollLine.y + this.selectedScrollBar.height / 2)) / this.getSelectedScrollValue())) + 1;
            this.updateSelectedPlayerList();
            this.updateListArrows();
         }
      }
      
      protected function initializeScrollBars() : void
      {
         this.listScrollBar.addEventListener(MouseEvent.MOUSE_DOWN,this.onListMouseDown);
         this.listScrollBar.addEventListener(MouseEvent.MOUSE_UP,this.onListMouseUp);
         this.listScrollBar.addEventListener(MouseEvent.MOUSE_MOVE,this.onListMouseMove);
         this.selectedScrollBar.addEventListener(MouseEvent.MOUSE_DOWN,this.onSelectedMouseDown);
         this.selectedScrollBar.addEventListener(MouseEvent.MOUSE_UP,this.onSelectedMouseUp);
         this.selectedScrollBar.addEventListener(MouseEvent.MOUSE_MOVE,this.onSelectedMouseMove);
      }
      
      protected function deinitializeScrollBars() : void
      {
         this.listScrollBar.removeEventListener(MouseEvent.MOUSE_DOWN,this.onListMouseDown);
         this.listScrollBar.removeEventListener(MouseEvent.MOUSE_UP,this.onListMouseUp);
         this.listScrollBar.removeEventListener(MouseEvent.MOUSE_MOVE,this.onListMouseMove);
         this.selectedScrollBar.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSelectedMouseDown);
         this.selectedScrollBar.removeEventListener(MouseEvent.MOUSE_UP,this.onSelectedMouseUp);
         this.selectedScrollBar.removeEventListener(MouseEvent.MOUSE_MOVE,this.onSelectedMouseMove);
      }
      
      private function get listMC() : MovieClip
      {
         if(this._mfsp2)
         {
            if(this._search && this._tab)
            {
               return m_window.requests_mc.exp1_mc.list_mc;
            }
            if(this._search)
            {
               return m_window.requests_mc.exp2_mc.list_mc;
            }
            if(this._tab)
            {
               return m_window.requests_mc.exp3_mc.list_mc;
            }
            return m_window.requests_mc.exp4_mc.list_mc;
         }
         return m_window.requests_mc.list_mc;
      }
      
      private function get selectionMC() : MovieClip
      {
         if(this._mfsp2)
         {
            if(this._search && this._tab)
            {
               return m_window.requests_mc.exp1_mc.selectionArea_mc;
            }
            if(this._search)
            {
               return m_window.requests_mc.exp2_mc.selectionArea_mc;
            }
            if(this._tab)
            {
               return m_window.requests_mc.exp3_mc.selectionArea_mc;
            }
            return m_window.requests_mc.exp4_mc.selectionArea_mc;
         }
         return m_window.requests_mc.selectionArea_mc;
      }
      
      private function get sendButtonMC() : MovieClip
      {
         if(this._mfsp2)
         {
            if(this._search && this._tab)
            {
               return m_window.requests_mc.exp1_mc.button_mc;
            }
            if(this._search)
            {
               return m_window.requests_mc.exp2_mc.button_mc;
            }
            if(this._tab)
            {
               return m_window.requests_mc.exp3_mc.button_mc;
            }
            return m_window.requests_mc.exp4_mc.button_mc;
         }
         return m_window.requests_mc.button_mc;
      }
      
      private function get selectAllBtn() : MovieClip
      {
         if(this._mfsp2)
         {
            if(this._search && this._tab)
            {
               return m_window.requests_mc.exp1_mc.selectAll_btn;
            }
            if(this._search)
            {
               return m_window.requests_mc.exp2_mc.selectAll_btn;
            }
            if(this._tab)
            {
               return m_window.requests_mc.exp3_mc.selectAll_btn;
            }
            return m_window.requests_mc.exp4_mc.selectAll_btn;
         }
         return m_window.requests_mc.selectAll_btn;
      }
      
      private function get tabs() : Array
      {
         var _loc1_:String = null;
         var _loc2_:Array = null;
         if(this._mfsp2)
         {
            _loc1_ = "";
            if(this._search && this._tab)
            {
               _loc1_ = "exp1_mc";
            }
            else if(this._search)
            {
               _loc1_ = "exp2_mc";
            }
            else if(this._tab)
            {
               _loc1_ = "exp3_mc";
            }
            else
            {
               _loc1_ = "exp4_mc";
            }
            _loc2_ = new Array();
            _loc2_.push(m_window.requests_mc[_loc1_].tab1_bt);
            _loc2_.push(m_window.requests_mc[_loc1_].tab2_bt);
            _loc2_.push(m_window.requests_mc[_loc1_].tab3_bt);
            return _loc2_;
         }
         return null;
      }
      
      private function get searchBar() : TextField
      {
         if(this._mfsp2)
         {
            if(this._search && this._tab)
            {
               return m_window.requests_mc.exp1_mc.input_tf;
            }
            if(this._search)
            {
               return m_window.requests_mc.exp2_mc.input_tf;
            }
            if(this._tab)
            {
               return m_window.requests_mc.exp3_mc.input_tf;
            }
            return m_window.requests_mc.exp4_mc.input_tf;
         }
         return null;
      }
      
      private function get listScrollBar() : MovieClip
      {
         return this.listMC.scrollPane_mc;
      }
      
      private function get listScrollLine() : MovieClip
      {
         return this.listMC.area_mc;
      }
      
      private function get selectedScrollBar() : MovieClip
      {
         return this.selectionMC.scrollPane_mc;
      }
      
      private function get selectedScrollLine() : MovieClip
      {
         return this.selectionMC.area_mc;
      }
      
      private function getListScrollValue() : Number
      {
         var _loc1_:int = this.maxListPages >= 2 ? this.maxListPages : 2;
         return (this.listScrollLine.height - this.listScrollBar.height) / (_loc1_ - 1);
      }
      
      private function getSelectedScrollValue() : Number
      {
         var _loc1_:int = this.maxSelectedPages >= 2 ? this.maxSelectedPages : 2;
         return (this.selectedScrollLine.height - this.selectedScrollBar.height) / (_loc1_ - 1);
      }
      
      override protected function initializeScreen() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:ImageLoader = null;
         if(this._mfsp2)
         {
            m_window.requests_mc.exp1_mc.visible = false;
            m_window.requests_mc.exp2_mc.visible = false;
            m_window.requests_mc.exp3_mc.visible = false;
            m_window.requests_mc.exp4_mc.visible = false;
            if(this._search && this._tab)
            {
               m_window.requests_mc.exp1_mc.visible = true;
            }
            else if(this._search)
            {
               m_window.requests_mc.exp2_mc.visible = true;
            }
            else if(this._tab)
            {
               m_window.requests_mc.exp3_mc.visible = true;
            }
            else
            {
               m_window.requests_mc.exp4_mc.visible = true;
            }
            if(this._tab)
            {
               this.tabs[0].visible = true;
               TextFieldUtil.processTextField(this.tabs[0].generic_tf,ZGameUtils.ZlocT("Dialogs","MFS_Tab_Empires"));
               this.enaFriendsBtn.addEventListener(MouseEvent.CLICK,this.onEmpireFriendsClicked);
               this.enaFriendsBtn.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
               this.enaFriendsBtn.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
               this.tabs[1].visible = true;
               TextFieldUtil.processTextField(this.tabs[1].generic_tf,ZGameUtils.ZlocT("Dialogs","MFS_Tab_Zynga"));
               this.zyngaFriendsBtn.addEventListener(MouseEvent.CLICK,this.onZyngaFriendsClicked);
               this.zyngaFriendsBtn.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
               this.zyngaFriendsBtn.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
               this.tabs[2].visible = true;
               TextFieldUtil.processTextField(this.tabs[2].generic_tf,ZGameUtils.ZlocT("Dialogs","MFS_Tab_All"));
               this.allFriendsBtn.addEventListener(MouseEvent.CLICK,this.onAllFriendsClicked);
               this.allFriendsBtn.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
               this.allFriendsBtn.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
               this.allFriendsBtn.enabled = true;
               this.allFriendsBtn.gotoAndStop(1);
               this.enaFriendsBtn.enabled = false;
               this.enaFriendsBtn.gotoAndStop(3);
               this.zyngaFriendsBtn.enabled = true;
               this.zyngaFriendsBtn.gotoAndStop(1);
               this.m_selectedTab = MFS_TAB_ENA;
               this.m_currentListPage = 1;
            }
            if(this._search)
            {
               this.m_activeSearchBar = this.searchBar.filters;
               this.m_defaultSearchBar = [this.DefaultColorMatrix()];
               TextFieldUtil.processTextField(this.searchBar,ZGameUtils.ZlocT("Dialogs","MFS_SearchBar"));
               this.searchBar.mouseEnabled = true;
               this.searchBar.filters = this.m_defaultSearchBar;
               this.searchBar.selectable = true;
               this.searchBar.addEventListener(Event.CHANGE,this.onSearchChanged);
               this.searchBar.addEventListener(MouseEvent.CLICK,this.onSearchClick);
               this.searchBar.addEventListener(MouseEvent.MOUSE_OUT,this.onSearchOut);
               this.searchBar.visible = true;
            }
            if(this._rewardBar)
            {
               m_window.progressBar_mc.visible = true;
               m_window.progressBar_mc.meter_ep_mc.visible = false;
               m_window.progressBar_mc.meter_mc.visible = true;
               _loc1_ = 0;
               this.mfsData = ZGlobal.gameSettings.getMFSData();
               for each(_loc2_ in this.mfsData.rewards)
               {
                  if(parseInt(_loc2_.points) > _loc1_)
                  {
                     _loc1_ = parseInt(_loc2_.points);
                  }
               }
               _loc3_ = 1;
               for each(_loc2_ in this.mfsData.rewards)
               {
                  m_window.progressBar_mc["icon_0" + _loc3_.toString()].x = parseInt(_loc2_.points) / _loc1_ * m_window.progressBar_mc.base_mc.width;
                  TextFieldUtil.compactTextField(m_window.progressBar_mc["icon_0" + _loc3_.toString()].generic_tf,ZGameUtils.ZlocT("Dialogs","MFS_Tooltip_EnabledReward"));
                  _loc4_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc2_.icon),m_window.progressBar_mc["icon_0" + _loc3_.toString()].icon1);
                  _loc4_.smooth = true;
                  m_window.progressBar_mc["icon_0" + _loc3_.toString()].addEventListener(MouseEvent.CLICK,this.collectReward);
                  m_window.progressBar_mc["icon_0" + _loc3_.toString()].addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
                  m_window.progressBar_mc["icon_0" + _loc3_.toString()].addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
                  this.rewardButtons.push(m_window.progressBar_mc["icon_0" + _loc3_.toString()]);
                  _loc3_++;
               }
               this.m_rewardBarMax = _loc1_;
               Tooltip.subscribe(m_window.progressBar_mc.base_mc,ZGameUtils.ZlocT("Dialogs","MFS_Tooltip_Bar"));
               MessageDispatcher.instance.addEventListener(MessageDispatcher.MFSP2_REWARDBAR_UPDATED,this.onMFSPointsUpdated);
               this.onMFSPointsUpdated();
            }
            else
            {
               m_window.progressBar_mc.visible = false;
            }
            if(this._gameClick)
            {
               m_window.requests_mc.progressBar_mc.tank_mc.stop();
               m_window.requests_mc.progressBar_mc.counter_mc.stop();
               m_window.requests_mc.progressBar_mc.tank_mc.gotoAndStop(1);
               m_window.requests_mc.progressBar_mc.counter_mc.gotoAndStop(1);
            }
         }
         if(this.isNewMFSDialog())
         {
            super.initializeScreen();
            this.initProgressBar();
            this.m_icon = ImageLoaderFactory.CreateImageLoader(this.m_iconURL,this.mc.icon);
            if(this.m_icon)
            {
               this.m_icon.smooth = true;
            }
            centerWithinStage(Zlab.mainStage);
            this.initializeScrollBars();
            this.listScrollBar.y = this.listScrollLine.y + this.listScrollBar.height / 2;
            this.selectedScrollBar.y = this.selectedScrollLine.y + this.selectedScrollBar.height / 2;
            TextFieldUtil.compactTextField(this.mc.title_tf,this.m_title,{
               "minScale":0.6,
               "maxLines":1
            });
            TextFieldUtil.processTextField(this.mc.body_tf,this.m_body);
            this.m_sendButton = new ZGameButton(this.sendButtonMC,this.onSendClicked,1.1,true);
            this.m_sendButton.compactText(this.sendButtonString,{
               "maxLines":1,
               "minScale":0.5,
               "onFail":"return"
            });
            this.m_sendButton.sounds = ButtonSound.DEFAULT;
            this.m_sendButton.show();
            this.m_sendButton.enable();
            this.selectAllBtn.check_mc.visible = false;
            this.initSelectAllButton();
            this.m_buttonSounds = new ButtonMouseEventSoundContainer();
            this.m_buttonSounds.addButton(this.mc.exit_mc,ButtonSound.DEFAULT);
            this.mc.exit_mc.addEventListener(MouseEvent.CLICK,this.exitButtonClicked,false,0,true);
            StatsManager.count("dialog","r2_" + this.m_requestSubtype + "_" + this.m_requestType,"view","batch_num_" + this.m_currentListPage);
            this.createList();
            this.pushPreSelected();
            this.m_currentListPage = 1;
            this.m_currentSelectedPage = 1;
            this.updatePlayerList();
            this.updateSelectedPlayerList();
            this.checkSelectAll();
            this.updateListArrows();
            this.updateProgressBar(false);
            this.updateSendButton();
         }
         else
         {
            super.initializeScreen();
            this.initProgressBar();
            this.m_icon = ImageLoaderFactory.CreateImageLoader(this.m_iconURL,this.mc.icon);
            if(this.m_icon)
            {
               this.m_icon.smooth = true;
            }
            this.contentWidth = this.mc.background_mc.width;
            this.contentHeight = this.mc.background_mc.height;
            ZGameUtils.hideIfExists(this.mc.background_mc);
            centerWithinStage(Zlab.mainStage);
            TextFieldUtil.compactTextField(this.mc.title_tf,this.m_title,{
               "minScale":0.6,
               "maxLines":1
            });
            TextFieldUtil.processTextField(this.mc.body_tf,this.m_body);
            this.initPlaceholders();
            this.m_sendButton = new ZGameButton(this.sendButtonMC,this.onSendClicked,1.1,true);
            this.m_sendButton.compactText(this.sendButtonString,{
               "maxLines":1,
               "minScale":0.5,
               "onFail":"return"
            });
            this.m_sendButton.sounds = ButtonSound.DEFAULT;
            this.m_sendButton.show();
            this.m_sendButton.enable();
            this.selectAllBtn.check_mc.visible = false;
            this.initSelectAllButton();
            this.m_buttonSounds = new ButtonMouseEventSoundContainer();
            this.m_buttonSounds.addButton(this.mc.exit_mc,ButtonSound.DEFAULT);
            this.m_buttonSounds.addButton(this.mc.forward_bt,ButtonSound.DEFAULT);
            this.m_buttonSounds.addButton(this.mc.back_bt,ButtonSound.DEFAULT);
            this.mc.exit_mc.addEventListener(MouseEvent.CLICK,this.exitButtonClicked,false,0,true);
            this.m_currentPage = 1;
            StatsManager.count("dialog","r2_" + this.m_requestSubtype + "_" + this.m_requestType,"view","batch_num_" + this.m_currentPage);
            this.createCards();
            this.updatePlayerCards();
            this.updateArrows();
            this.updateProgressBar(false);
            this.updateSendButton();
         }
      }
      
      private function removeSelectedCallback(param1:Object) : void
      {
         var _loc3_:Object = null;
         var _loc4_:RequestDialogListItem = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.m_selectedCards.length)
         {
            _loc3_ = this.m_selectedCards[_loc2_].getFriendInfo();
            if(param1.uid == _loc3_.uid)
            {
               _loc4_ = new RequestDialogListItem(param1,this.selectedItemCallback,null);
               this.m_cards.push(_loc4_);
               if(ZGlobal.player.isZyngaFriend(param1))
               {
                  this.m_zyngaCards.push(_loc4_);
               }
               if(param1.hasOwnProperty("is_app_user") && Boolean(param1.is_app_user))
               {
                  this.m_enaCards.push(_loc4_);
               }
               --this.m_totalSelected;
               this.updatePlayerList();
               this.m_selectedCards[_loc2_].release();
               this.m_selectedCards.splice(_loc2_,1);
               this.updateSelectedPlayerList();
               this.updateSendButton();
               this.updateListArrows();
               break;
            }
            _loc2_++;
         }
      }
      
      protected function selectedItemCallback(param1:Object) : void
      {
         var _loc6_:Object = null;
         var _loc7_:RequestDialogListItem = null;
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         while(_loc3_ < this.m_cards.length)
         {
            _loc6_ = this.m_cards[_loc3_].getFriendInfo();
            if(param1.uid == _loc6_.uid)
            {
               this.m_cards[_loc3_].release();
               this.m_cards.splice(_loc3_,1);
               _loc2_ = true;
               break;
            }
            _loc3_++;
         }
         var _loc4_:int = 0;
         while(_loc4_ < this.m_zyngaCards.length)
         {
            if(this.m_zyngaCards[_loc4_].getFriendInfo().uid == param1.uid)
            {
               this.m_zyngaCards[_loc4_].release();
               this.m_zyngaCards.splice(_loc4_,1);
               _loc2_ = true;
               break;
            }
            _loc4_++;
         }
         var _loc5_:int = 0;
         while(_loc5_ < this.m_enaCards.length)
         {
            if(this.m_enaCards[_loc5_].getFriendInfo().uid == param1.uid)
            {
               this.m_enaCards[_loc5_].release();
               this.m_enaCards.splice(_loc5_,1);
               _loc2_ = true;
               break;
            }
            _loc5_++;
         }
         if(_loc2_ == true)
         {
            _loc7_ = new RequestDialogListItem(param1,null,this.removeSelectedCallback);
            this.m_selectedCards.push(_loc7_);
            ++this.m_totalSelected;
            this.updatePlayerList();
            this.updateSendButton();
            this.updateSelectedPlayerList();
         }
         this.updateListArrows();
      }
      
      protected function initPlaceholders() : void
      {
         TextFieldUtil.processTextField(this.mc.placeholder_tf,this.m_placeholder);
         TextFieldUtil.processTextField(this.mc.placeholder_tf2,this.m_zyngaPlaceholder);
      }
      
      protected function get sendButtonString() : String
      {
         return ZGameUtils.ZlocT("Dialogs","Send");
      }
      
      protected function initSelectAllButton() : void
      {
         this.m_selectAllButton = new ZGameButton(this.selectAllBtn.selectAll_mc,this.onSelectAllClicked,1,true);
         this.m_selectAllButton.compactText(ZGameUtils.ZlocT("Dialogs","SelectAllButton"),{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
         this.m_selectAllButton.sounds = ButtonSound.DEFAULT;
         this.m_selectAllButton.show();
         this.m_selectAllButton.enable();
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:int = 0;
         if(this._tab)
         {
            this.enaFriendsBtn.removeEventListener(MouseEvent.CLICK,this.onEmpireFriendsClicked);
            this.enaFriendsBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            this.enaFriendsBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
            this.zyngaFriendsBtn.removeEventListener(MouseEvent.CLICK,this.onZyngaFriendsClicked);
            this.zyngaFriendsBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            this.zyngaFriendsBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
            this.allFriendsBtn.removeEventListener(MouseEvent.CLICK,this.onAllFriendsClicked);
            this.allFriendsBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            this.allFriendsBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         }
         if(this._search)
         {
            this.searchBar.removeEventListener(Event.CHANGE,this.onSearchChanged);
            this.searchBar.removeEventListener(MouseEvent.CLICK,this.onSearchClick);
            this.searchBar.removeEventListener(MouseEvent.MOUSE_OUT,this.onSearchOut);
         }
         if(this._rewardBar)
         {
            MessageDispatcher.instance.removeEventListener(MessageDispatcher.MFSP2_REWARDBAR_UPDATED,this.onMFSPointsUpdated);
            _loc1_ = 0;
            while(_loc1_ < this.rewardButtons.length)
            {
               this.rewardButtons[_loc1_].removeEventListener(MouseEvent.CLICK,this.collectReward);
               this.rewardButtons[_loc1_].removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
               this.rewardButtons[_loc1_].removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
               _loc1_++;
            }
         }
         if(this.m_friendPick)
         {
            m_window.removeChild(this.m_friendPick);
            this.m_friendPick = null;
         }
         if(this.isNewMFSDialog())
         {
            this.deinitializeScrollBars();
         }
         this.mc.exit_mc.removeEventListener(MouseEvent.CLICK,this.exitButtonClicked);
         if(this.mc.forward_bt)
         {
            this.mc.forward_bt.removeEventListener(MouseEvent.CLICK,this.onFwdClicked);
         }
         if(this.mc.back_bt)
         {
            this.mc.back_bt.removeEventListener(MouseEvent.CLICK,this.onBackClicked);
         }
         if(this.selectionMC)
         {
            this.selectionMC.forward_bt.removeEventListener(MouseEvent.CLICK,this.onSelectedListFwdClicked);
         }
         if(this.selectionMC)
         {
            this.selectionMC.back_bt.removeEventListener(MouseEvent.CLICK,this.onSelectedListBackClicked);
         }
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         if(this.m_sendButton)
         {
            this.m_sendButton.dispose();
            this.m_sendButton = null;
         }
         if(this.m_icon)
         {
            this.m_icon.destroy();
            this.m_icon = null;
         }
         if(this.m_selectAllButton)
         {
            this.m_selectAllButton.dispose();
            this.m_selectAllButton = null;
         }
         if(!this.isNewMFSDialog())
         {
            this.disposeCards();
         }
         else
         {
            this.disposeList();
         }
         m_initialized = false;
         super.deinitDialog();
      }
      
      protected function createCard(param1:Object) : RequestDialogCardInterface
      {
         return new RequestPlayerCard(param1,this.checkCallback);
      }
      
      private function createCards() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Object = null;
         var _loc3_:RequestDialogCardInterface = null;
         this.m_cards = new Array();
         for(_loc1_ in this.m_friends)
         {
            if(_loc1_ != null)
            {
               _loc2_ = this.m_friends[_loc1_];
               _loc3_ = this.createCard(_loc2_);
               this.m_cards.push(_loc3_);
            }
         }
         this.createDummyCards();
      }
      
      private function createList() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:RequestDialogListItem = null;
         var _loc6_:Object = null;
         var _loc7_:RequestDialogListItem = null;
         var _loc8_:Object = null;
         var _loc9_:RequestDialogListItem = null;
         this.m_cards = new Array();
         this.m_zyngaCards = new Array();
         this.m_enaCards = new Array();
         this.m_selectedCards = new Array();
         if(this._tab)
         {
            for(_loc2_ in this.m_zyngaFriends)
            {
               if(_loc2_ != null)
               {
                  _loc4_ = this.m_zyngaFriends[_loc2_];
                  _loc5_ = new RequestDialogListItem(_loc4_,this.selectedItemCallback,null);
                  this.m_zyngaCards.push(_loc5_);
               }
            }
            for(_loc3_ in this.m_enaFriends)
            {
               if(_loc3_ != null)
               {
                  _loc6_ = this.m_enaFriends[_loc3_];
                  _loc7_ = new RequestDialogListItem(_loc6_,this.selectedItemCallback,null);
                  this.m_enaCards.push(_loc7_);
               }
            }
         }
         for(_loc1_ in this.m_friends)
         {
            if(_loc1_ != null)
            {
               _loc8_ = this.m_friends[_loc1_];
               _loc9_ = new RequestDialogListItem(_loc8_,this.selectedItemCallback,null);
               this.m_cards.push(_loc9_);
            }
         }
      }
      
      private function pushPreSelected() : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:RequestDialogListItem = null;
         var _loc1_:* = 0;
         while(_loc1_ < this.m_cards.length)
         {
            if(this.m_cards[_loc1_].isSelected)
            {
               _loc2_ = this.m_cards[_loc1_].getFriendInfo();
               this.m_cards[_loc1_].release();
               this.m_cards.splice(_loc1_,1);
               _loc1_--;
               _loc3_ = 0;
               while(_loc3_ < this.m_zyngaCards.length)
               {
                  if(this.m_zyngaCards[_loc3_].getFriendInfo().uid == _loc2_.uid)
                  {
                     this.m_zyngaCards[_loc3_].release();
                     this.m_zyngaCards.splice(_loc3_,1);
                     break;
                  }
                  _loc3_++;
               }
               _loc4_ = 0;
               while(_loc4_ < this.m_enaCards.length)
               {
                  if(this.m_enaCards[_loc4_].getFriendInfo().uid == _loc2_.uid)
                  {
                     this.m_enaCards[_loc4_].release();
                     this.m_enaCards.splice(_loc4_,1);
                     break;
                  }
                  _loc4_++;
               }
               _loc5_ = new RequestDialogListItem(_loc2_,null,this.removeSelectedCallback);
               this.m_selectedCards.push(_loc5_);
               ++this.m_totalSelected;
            }
            _loc1_++;
         }
         this.m_currentSelectedPage = 1;
         this.m_currentListPage = 1;
         this.updateSelectedPlayerList();
         this.updatePlayerList();
         this.updateSendButton();
         this.checkSelectAll();
         this.updateListArrows();
      }
      
      private function createDummyCards() : void
      {
         var _loc1_:RequestDialogCardInterface = null;
         while(this.m_cards.length < this.maxPages * this.maxSlots)
         {
            _loc1_ = this.createCard(null);
            this.m_cards.push(_loc1_);
         }
      }
      
      private function createDummyList() : void
      {
         var _loc1_:RequestDialogListItem = null;
         while(this.m_cards.length < this.maxInitListPages * this.maxListItems)
         {
            _loc1_ = new RequestDialogListItem(null,this.selectedItemCallback,null);
            this.m_cards.push(_loc1_);
         }
      }
      
      private function disposeCards() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.m_cards.length)
         {
            this.m_cards[_loc1_].release();
            _loc1_++;
         }
      }
      
      private function disposeList() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.m_cards.length)
         {
            this.m_cards[_loc1_].release();
            _loc1_++;
         }
      }
      
      private function disposeSelectedList() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.m_selectedCards.length)
         {
            this.m_selectedCards[_loc1_].release();
            _loc1_++;
         }
      }
      
      private function updatePlayerList() : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc1_:int = 0;
         switch(this.m_selectedTab)
         {
            case MFS_TAB_ALL:
               _loc2_ = this.m_cards;
               break;
            case MFS_TAB_ZYNGA:
               _loc2_ = this.m_zyngaCards;
               break;
            case MFS_TAB_ENA:
               _loc2_ = this.m_enaCards;
         }
         if(_loc2_.length > 0)
         {
            _loc3_ = 0;
            _loc4_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               if(_loc4_ >= (this.m_currentListPage - 1) * this.maxListItems && _loc4_ < this.m_currentListPage * this.maxListItems && Boolean(_loc2_[_loc3_].isVisible))
               {
                  _loc5_ = _loc4_ - (this.m_currentListPage - 1) * this.maxListItems;
                  _loc2_[_loc3_].setCard(this.listMC["text" + _loc5_]);
               }
               else
               {
                  _loc2_[_loc3_].setCard(null);
               }
               if(_loc2_[_loc3_].isVisible)
               {
                  _loc4_++;
               }
               _loc3_++;
            }
            if(_loc4_ < this.m_currentListPage * this.maxListItems)
            {
               _loc1_ = _loc4_ - (this.m_currentListPage - 1) * this.maxListItems;
               while(_loc1_ < this.maxListItems)
               {
                  this.listMC["text" + _loc1_].visible = false;
                  _loc1_++;
               }
            }
         }
         else
         {
            _loc1_ = 0;
            while(_loc1_ < this.maxListItems)
            {
               this.listMC["text" + _loc1_].visible = false;
               _loc1_++;
            }
         }
      }
      
      private function updateSelectedPlayerList() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         if(this.m_totalSelected > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < this.m_totalSelected)
            {
               if(_loc1_ >= (this.m_currentSelectedPage - 1) * this.maxSelectedItems && _loc1_ < this.m_currentSelectedPage * this.maxSelectedItems)
               {
                  _loc2_ = _loc1_ - (this.m_currentSelectedPage - 1) * this.maxSelectedItems;
                  this.m_selectedCards[_loc1_].setSelectedCard(this.selectionMC["text" + _loc2_]);
               }
               else
               {
                  this.m_selectedCards[_loc1_].setSelectedCard(null);
               }
               _loc1_++;
            }
            if(_loc1_ < this.m_currentSelectedPage * this.maxSelectedItems)
            {
               _loc3_ = _loc1_ - (this.m_currentSelectedPage - 1) * this.maxSelectedItems;
               while(_loc3_ < this.maxSelectedItems)
               {
                  this.selectionMC["text" + _loc3_].visible = false;
                  _loc3_++;
               }
            }
         }
         else
         {
            _loc1_ = 0;
            while(_loc1_ < 4)
            {
               this.selectionMC["text" + _loc1_].visible = false;
               _loc1_++;
            }
         }
      }
      
      private function updatePlayerCards() : void
      {
         var _loc2_:int = 0;
         this.m_totalSelected = 0;
         var _loc1_:int = 0;
         while(_loc1_ < this.m_cards.length)
         {
            if(_loc1_ >= (this.m_currentPage - 1) * this.maxSlots && _loc1_ < this.m_currentPage * this.maxSlots)
            {
               _loc2_ = _loc1_ - (this.m_currentPage - 1) * this.maxSlots;
               if(_loc1_ < this.m_friends.length && MatchMakingManager.instance.isMatchMadeNeighbor(this.m_friends[_loc1_].uid))
               {
                  this.mc["card_mc_" + _loc2_].visible = false;
                  this.m_cards[_loc1_].setCard(this.mc["matchcard_mc_" + _loc2_]);
               }
               else
               {
                  this.mc["matchcard_mc_" + _loc2_].visible = false;
                  this.m_cards[_loc1_].setCard(this.mc["card_mc_" + _loc2_]);
               }
               ++this.m_totalSelected;
            }
            else
            {
               this.m_cards[_loc1_].setCard(null);
            }
            _loc1_++;
         }
      }
      
      private function excludeFriends(param1:Array, param2:Array) : Array
      {
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc6_:Boolean = false;
         var _loc7_:Object = null;
         var _loc3_:Array = null;
         if(param2.length > 0)
         {
            _loc3_ = new Array();
            for(_loc4_ in param1)
            {
               _loc5_ = param1[_loc4_].zid;
               _loc6_ = true;
               for(_loc7_ in param2)
               {
                  if(_loc5_ == param2[_loc7_])
                  {
                     _loc6_ = false;
                     break;
                  }
               }
               if(_loc6_)
               {
                  _loc3_.push(param1[_loc4_]);
               }
            }
            return _loc3_;
         }
         return param1.slice();
      }
      
      protected function getFriends(param1:String) : Array
      {
         if(param1 == null)
         {
            param1 = ExperimentsManager.EXPERIMENT_REQUEST2_MFS;
         }
         switch(ExperimentsManager.instance.getExperimentVariant(param1))
         {
            case 1:
               return ZGlobal.player.recommendedFriends;
            case 2:
               return ZGlobal.player.zyngaFriends;
            case 3:
               return ZGlobal.player.empireFriends;
            case 4:
               return ZGlobal.player.allFriendsSNAPI;
            case 5:
               return ZGlobal.player.sevenDayLapsers;
            default:
               return ZGlobal.player.recommendedFriends;
         }
      }
      
      protected function getAllFriends(param1:String) : Array
      {
         var _loc2_:Dictionary = null;
         var _loc3_:Array = null;
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         if(MatchMakingManager.instance.isActive())
         {
            _loc2_ = ZGlobal.player.neighbors;
            _loc3_ = new Array();
            for each(_loc4_ in _loc2_)
            {
               if(MatchMakingManager.instance.isMatchMadeNeighbor(_loc4_.uid))
               {
                  _loc5_ = new Object();
                  _loc5_.zid = _loc5_.uid = _loc4_.uid.toString();
                  _loc5_.name = _loc5_.first_name = _loc4_.name;
                  _loc5_.last_name = "";
                  _loc5_.pic = _loc4_.matchMakingData.image;
                  _loc5_.pic_big = _loc5_.pic + "?type=large";
                  _loc5_.pic_normal = _loc5_.pic + "?type=normal";
                  _loc5_.pic_small = _loc5_.pic + "?type=small";
                  _loc5_.pic_square = _loc5_.pic + "?type=square";
                  _loc5_.is_app_user = true;
                  _loc3_.push(_loc5_);
               }
            }
            return this.getUpdatedFriends(_loc3_.concat(this.getFriends(param1)));
         }
         return this.getUpdatedFriends(this.getFriends(param1));
      }
      
      protected function getUpdatedFriends(param1:Array) : Array
      {
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Object = null;
         var _loc12_:Object = null;
         var _loc2_:Array = param1;
         if(AlliancesManager.isExperimentEnabled() && Boolean(AlliancesManager.instance.clanId))
         {
            _loc3_ = AlliancesManager.instance.members;
            _loc4_ = new Array();
            _loc5_ = new Array();
            _loc6_ = 0;
            while(_loc6_ < param1.length)
            {
               _loc8_ = _loc3_.indexOf(param1[_loc6_].zid);
               if(_loc8_ >= 0)
               {
                  _loc5_.push(param1[_loc6_].zid);
               }
               _loc6_++;
            }
            _loc7_ = 0;
            while(_loc7_ < _loc3_.length)
            {
               _loc9_ = _loc5_.indexOf(_loc3_[_loc7_]);
               if(_loc9_ == -1 && _loc3_[_loc7_] != ZGlobal.player.uid)
               {
                  _loc4_.push(_loc3_[_loc7_]);
               }
               _loc7_++;
            }
            if(Boolean(_loc4_) && _loc4_.length > 0)
            {
               _loc10_ = 0;
               while(_loc10_ < _loc4_.length)
               {
                  _loc11_ = AlliancesManager.instance.memberInfo(_loc4_[_loc10_]);
                  _loc12_ = new Object();
                  _loc12_.zid = _loc12_.uid = _loc11_.uid;
                  _loc12_.name = _loc12_.first_name = _loc11_.name;
                  _loc12_.last_name = "";
                  _loc12_.pic = _loc11_.image;
                  _loc12_.pic_big = _loc12_.pic + "?type=large";
                  _loc12_.pic_normal = _loc12_.pic + "?type=normal";
                  _loc12_.pic_small = _loc12_.pic + "?type=small";
                  _loc12_.pic_square = _loc12_.pic + "?type=square";
                  _loc12_.is_app_user = true;
                  _loc2_.push(_loc12_);
                  _loc10_++;
               }
            }
         }
         return _loc2_;
      }
      
      protected function updateProgressBar(param1:Boolean = true) : void
      {
         if(this.m_sentCount >= this.maxFriends)
         {
            this.m_sentCount = this.maxFriends;
         }
         if(this._gameClick)
         {
            TextFieldUtil.processTextField(this.mc.progressBar_mc.counter_mc.counter_tf,ZGameUtils.ZlocT("Dialogs","RequestProgressBar",{
               "count":this.m_sentCount,
               "total":this.maxFriends
            }));
            return;
         }
         var _loc2_:int = Math.min(this.maxFriends,this.m_sentCount);
         var _loc3_:int = this.mc.progressBar_mc.base_mc.width * Number(_loc2_ / this.maxFriends);
         if(param1)
         {
            TweenLite.to(this.meterMC,0.5,{"width":_loc3_});
         }
         else
         {
            this.meterMC.width = _loc3_;
         }
         TextFieldUtil.processTextField(this.mc.progressBar_mc.counter_tf,ZGameUtils.ZlocT("Dialogs","RequestProgressBar",{
            "count":this.m_sentCount,
            "total":this.maxFriends
         }));
      }
      
      protected function exitButtonClicked(param1:MouseEvent) : void
      {
         if(this.isNewMFSDialog())
         {
            StatsManager.count("dialog","MFS_UILI","view_close");
         }
         StatsManager.count("dialog","r2_" + this.m_requestSubtype + "_" + this.m_requestType,"no","batch_num_" + this.m_currentPage);
         close();
      }
      
      private function get maxSlots() : int
      {
         return NUM_SLOTS;
      }
      
      private function get maxListItems() : int
      {
         return NUM_LIST;
      }
      
      private function get maxSelectedItems() : int
      {
         return NUM_SELECTED;
      }
      
      private function get maxPages() : int
      {
         return Math.max(1,(this.numFriends - 1) / NUM_SLOTS + 1);
      }
      
      private function get maxListPages() : int
      {
         if(this._tab)
         {
            if(this.m_selectedTab == MFS_TAB_ZYNGA)
            {
               return Math.max(1,(this.m_zyngaCards.length - 1) / NUM_LIST + 1);
            }
            if(this.m_selectedTab == MFS_TAB_ENA)
            {
               return Math.max(1,(this.m_enaCards.length - 1) / NUM_LIST + 1);
            }
         }
         return Math.max(1,(this.m_cards.length - 1) / NUM_LIST + 1);
      }
      
      private function get maxSelectedPages() : int
      {
         return Math.max(1,(this.m_totalSelected - 1) / NUM_SELECTED + 1);
      }
      
      private function get maxInitListPages() : int
      {
         return Math.max(1,(this.numFriends - 1) / NUM_LIST + 1);
      }
      
      private function get maxFriends() : uint
      {
         return this.m_maxNumFriends;
      }
      
      public function get numFriends() : uint
      {
         return this.m_friends.length;
      }
      
      protected function calculateMaxFriends() : uint
      {
         var _loc1_:uint = uint.MAX_VALUE;
         var _loc2_:uint = uint(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_LIMIT));
         switch(_loc2_)
         {
            case 1:
               _loc1_ = 50;
               break;
            case 2:
               _loc1_ = 75;
               break;
            case 3:
               _loc1_ = 100;
               break;
            case 4:
               _loc1_ = 125;
               break;
            case 5:
               _loc1_ = 150;
               break;
            case 6:
               _loc1_ = 200;
               break;
            case 7:
               _loc1_ = 300;
         }
         return _loc1_;
      }
      
      private function onFwdClicked(param1:MouseEvent) : void
      {
         if(this.isNewMFSDialog())
         {
            this.incrementListPage();
         }
         else
         {
            this.incrementPage();
         }
      }
      
      private function onBackClicked(param1:MouseEvent) : void
      {
         if(this.isNewMFSDialog())
         {
            this.decrementListPage();
         }
         else
         {
            this.decrementPage();
         }
      }
      
      private function onSelectedListFwdClicked(param1:MouseEvent) : void
      {
         if(this.isNewMFSDialog())
         {
            this.incrementSelectedListPage();
         }
      }
      
      private function onSelectedListBackClicked(param1:MouseEvent) : void
      {
         if(this.isNewMFSDialog())
         {
            this.decrementSelectedListPage();
         }
      }
      
      private function selectAllInList() : void
      {
         var _loc1_:* = 0;
         var _loc2_:Array = null;
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         var _loc7_:RequestDialogListItem = null;
         if(!this.m_allSelected)
         {
            this.m_allSelected = true;
         }
         else
         {
            this.m_allSelected = false;
         }
         if(this.m_allSelected)
         {
            if(this._tab)
            {
               switch(this.m_selectedTab)
               {
                  case MFS_TAB_ALL:
                     _loc2_ = this.m_cards;
                     break;
                  case MFS_TAB_ZYNGA:
                     _loc2_ = this.m_zyngaCards;
                     break;
                  case MFS_TAB_ENA:
                     _loc2_ = this.m_enaCards;
               }
               _loc3_ = new Array();
               _loc4_ = 0;
               while(_loc4_ < _loc2_.length)
               {
                  _loc3_.push(_loc2_[_loc4_].getFriendInfo());
                  _loc4_++;
               }
               for each(_loc5_ in _loc3_)
               {
                  this.selectedItemCallback(_loc5_);
               }
               this.checkSelectAll();
               return;
            }
            _loc1_ = 0;
            while(_loc1_ < this.m_cards.length)
            {
               _loc6_ = this.m_cards[_loc1_].getFriendInfo();
               _loc7_ = new RequestDialogListItem(_loc6_,null,this.removeSelectedCallback);
               this.m_selectedCards.push(_loc7_);
               ++this.m_totalSelected;
               this.m_cards[_loc1_].release();
               this.m_cards.splice(_loc1_,1);
               _loc1_--;
               _loc1_++;
            }
            this.m_currentListPage = 1;
            this.updateSelectedPlayerList();
            this.updatePlayerList();
            this.updateSendButton();
            this.checkSelectAll();
            this.updateListArrows();
         }
         else
         {
            this.clearSelectedList();
            this.createList();
            this.m_currentListPage = 1;
            this.updatePlayerList();
            this.updateListArrows();
            this.checkSelectAll();
            this.updateProgressBar(false);
            this.updateSendButton();
         }
      }
      
      private function onSelectAllClicked(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(this.isNewMFSDialog())
         {
            this.selectAllInList();
         }
         else
         {
            if(!this.m_allSelected)
            {
               this.m_allSelected = true;
            }
            else
            {
               this.m_allSelected = false;
               StatsManager.count("dialog","MFS_UILI","unselect_all");
            }
            _loc2_ = 0;
            while(_loc2_ < this.m_cards.length)
            {
               if(this.m_allSelected)
               {
                  this.m_cards[_loc2_].setSelectedState();
               }
               else
               {
                  this.m_cards[_loc2_].setDeselectedState();
               }
               _loc2_++;
            }
            this.checkSelectAll();
            this.updatePlayerCards();
         }
      }
      
      private function checkSelectAll() : void
      {
         this.selectAllBtn.check_mc.visible = this.m_allSelected ? true : false;
         if(this.m_allSelected)
         {
            this.m_sendButton.enable();
         }
         else
         {
            this.m_sendButton.disable();
         }
      }
      
      protected function checkCallback(param1:Boolean) : void
      {
         this.selectAllBtn.check_mc.visible = false;
         if(param1)
         {
            ++this.m_totalSelected;
            this.m_sendButton.enable();
         }
         else
         {
            this.m_allSelected = false;
            if(this.m_totalSelected > 0)
            {
               --this.m_totalSelected;
            }
            if(!this.m_totalSelected)
            {
               this.m_sendButton.disable();
            }
         }
      }
      
      private function clearSelectedList() : void
      {
         var _loc1_:* = 0;
         while(_loc1_ < this.m_selectedCards.length)
         {
            this.m_selectedCards[_loc1_].release();
            this.m_selectedCards.splice(_loc1_,1);
            --this.m_totalSelected;
            _loc1_--;
            _loc1_++;
         }
         this.m_currentSelectedPage = 1;
         this.updateSelectedPlayerList();
      }
      
      protected function onSendClicked(param1:MouseEvent) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:Object = null;
         var _loc13_:RequestDialogListItem = null;
         var _loc14_:uint = 0;
         var _loc15_:uint = 0;
         var _loc16_:Array = null;
         var _loc17_:Array = null;
         var _loc18_:int = 0;
         var _loc2_:Array = new Array();
         var _loc3_:Array = new Array();
         var _loc4_:Array = new Array();
         var _loc5_:int = 0;
         if(this.isNewMFSDialog())
         {
            _loc6_ = 0;
            _loc7_ = 0;
            _loc8_ = 0;
            _loc9_ = 50;
            if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MFS_BUNDLE) == 2)
            {
               if(ZRTManager.instance.getMFSBundleData() >= 25)
               {
                  _loc9_ = ZRTManager.instance.getMFSBundleData();
               }
            }
            _loc10_ = Math.min(this.m_selectedCards.length,_loc9_);
            _loc11_ = 0;
            _loc5_ = 0;
            while(_loc5_ < _loc10_)
            {
               _loc12_ = this.m_selectedCards[_loc11_].getFriendInfo();
               if(_loc12_ != null)
               {
                  this.m_selectedCards[_loc11_].release();
                  this.m_selectedCards.splice(_loc11_,1);
                  --this.m_totalSelected;
                  _loc2_.push(_loc12_.uid);
                  ++this.m_sentCount;
                  if(this.isCyclic())
                  {
                     _loc13_ = new RequestDialogListItem(_loc12_,this.selectedItemCallback,null);
                     this.m_cards.push(_loc13_);
                     if(ZGlobal.player.isZyngaFriend(_loc12_))
                     {
                        this.m_zyngaCards.push(_loc13_);
                     }
                     if(_loc12_.hasOwnProperty("is_app_user") && Boolean(_loc12_.is_app_user))
                     {
                        this.m_enaCards.push(_loc13_);
                     }
                  }
                  if(_loc12_.hasOwnProperty("is_app_user") && Boolean(_loc12_.is_app_user))
                  {
                     _loc6_++;
                  }
                  else if(ZGlobal.player.isZyngaFriend(_loc12_))
                  {
                     _loc7_++;
                  }
                  else
                  {
                     _loc8_++;
                  }
               }
               else
               {
                  _loc11_++;
               }
               _loc5_++;
            }
            StatsManager.count("dialog","MFS_UILI","recipients","ena","","",_loc6_);
            StatsManager.count("dialog","MFS_UILI","recipients","zynga","","",_loc7_);
            StatsManager.count("dialog","MFS_UILI","recipients","fb","","",_loc8_);
            this.updatePlayerList();
            this.updateProgressBar();
            if(_loc2_.length > 0)
            {
               StatsManager.count("dialog","r2_" + this.m_requestSubtype + "_" + this.m_requestType,"num_friends_selected","batch_num_" + this.m_currentPage,_loc2_.length.toString());
               this.sendRequest(_loc2_);
               this.m_randomFriendPic = this.chooseRandom(_loc2_);
            }
            if(this.m_sentCount >= this.maxFriends)
            {
               this.m_sendButton.disable_visual();
               this.updateProgressBar();
               Zlab.processManager.schedule(500,this,close);
            }
            else if(this.m_totalSelected > 0)
            {
               this.m_sendButton.enable();
            }
            else
            {
               this.m_sendButton.disable_visual();
            }
            this.m_currentSelectedPage = 1;
            this.updateSelectedPlayerList();
            this.updateListArrows();
            StatsManager.count("dialog","MFS_UILI","send_click");
         }
         else
         {
            StatsManager.count("dialog","r2_" + this.m_requestSubtype + "_" + this.m_requestType,"yes","batch_num_" + this.m_currentPage);
            if(this.m_cards.length > this.m_friends.length)
            {
               this.m_cards.splice(this.m_friends.length,this.m_cards.length - this.m_friends.length);
            }
            _loc14_ = (this.m_currentPage - 1) * this.maxSlots;
            _loc15_ = Math.min(this.maxSlots,this.m_friends.length - _loc14_);
            _loc16_ = this.m_friends.splice(_loc14_,_loc15_);
            _loc17_ = this.m_cards.splice(_loc14_,_loc15_);
            _loc5_ = 0;
            while(_loc5_ < _loc15_)
            {
               if(_loc17_[_loc5_].selected)
               {
                  _loc2_.push(_loc16_[_loc5_].uid);
                  _loc3_.push(_loc17_[_loc5_]);
                  _loc4_.push(_loc16_[_loc5_]);
                  ++this.m_sentCount;
               }
               else
               {
                  this.m_friends.push(_loc16_[_loc5_]);
                  this.m_cards.push(_loc17_[_loc5_]);
               }
               _loc5_++;
            }
            if(this.isCyclic())
            {
               _loc18_ = 0;
               while(_loc18_ < _loc2_.length)
               {
                  this.m_friends.push(_loc4_[_loc18_]);
                  _loc3_[_loc18_].setDeselectedState();
                  this.m_cards.push(_loc3_[_loc18_]);
                  _loc18_++;
               }
            }
            this.updateProgressBar();
            if(_loc2_.length > 0)
            {
               StatsManager.count("dialog","r2_" + this.m_requestSubtype + "_" + this.m_requestType,"num_friends_selected","batch_num_" + this.m_currentPage,_loc2_.length.toString());
               this.sendRequest(_loc2_);
               this.m_randomFriendPic = this.chooseRandom(_loc2_);
            }
            if(this.m_sentCount >= this.maxFriends)
            {
               this.m_sendButton.disable_visual();
               this.updateProgressBar();
               Zlab.processManager.schedule(500,this,close);
            }
            else
            {
               if(this.m_currentPage > this.maxPages)
               {
                  this.m_currentPage = 1;
                  this.updateArrows();
               }
               this.createDummyCards();
               this.updatePlayerCards();
               if(this.m_totalSelected > 0)
               {
                  this.m_sendButton.enable();
               }
               else
               {
                  this.m_sendButton.disable_visual();
               }
            }
         }
         ++this.sendClicks;
      }
      
      protected function sendRequest(param1:Array) : void
      {
      }
      
      private function incrementPage() : void
      {
         ++this.m_currentPage;
         if(this.m_currentPage > this.maxPages)
         {
            this.m_currentPage = 1;
         }
         this.updatePlayerCards();
         this.updateArrows();
         this.updateSendButton();
      }
      
      private function incrementListPage() : void
      {
         ++this.m_currentListPage;
         if(this.m_currentListPage > this.maxListPages)
         {
            this.m_currentListPage = 1;
         }
         this.updatePlayerList();
         this.updateListArrows();
      }
      
      private function incrementSelectedListPage() : void
      {
         ++this.m_currentSelectedPage;
         if(this.m_currentSelectedPage > this.maxSelectedPages)
         {
            this.m_currentSelectedPage = 1;
         }
         this.updateSelectedPlayerList();
         this.updateListArrows();
      }
      
      protected function get shouldEnableSendButton() : Boolean
      {
         return this.m_totalSelected > 0;
      }
      
      protected function updateSendButton() : void
      {
         if(!this.m_sendButton)
         {
            return;
         }
         if(this.shouldEnableSendButton)
         {
            this.m_sendButton.enable();
         }
         else
         {
            this.m_sendButton.disable();
         }
      }
      
      private function decrementPage() : void
      {
         --this.m_currentPage;
         if(this.m_currentPage < 0)
         {
            this.m_currentPage = this.maxPages;
         }
         this.updatePlayerCards();
         this.updateArrows();
         this.updateSendButton();
      }
      
      private function decrementListPage() : void
      {
         --this.m_currentListPage;
         if(this.m_currentListPage < 0)
         {
            this.m_currentListPage = this.maxListPages;
         }
         this.updatePlayerList();
         this.updateListArrows();
      }
      
      private function decrementSelectedListPage() : void
      {
         --this.m_currentSelectedPage;
         if(this.m_currentSelectedPage < 0)
         {
            this.m_currentSelectedPage = this.maxSelectedPages;
         }
         this.updateSelectedPlayerList();
         this.updateListArrows();
      }
      
      private function updateListScroll() : void
      {
         this.listScrollBar.y = this.listScrollLine.y + this.listScrollBar.height / 2 + (this.m_currentListPage - 1) * this.getListScrollValue();
      }
      
      private function updateSelectedScroll() : void
      {
         this.selectedScrollBar.y = this.selectedScrollLine.y + this.selectedScrollBar.height / 2 + (this.m_currentSelectedPage - 1) * this.getSelectedScrollValue();
      }
      
      private function updateArrows() : void
      {
         if(this.m_currentPage > 1)
         {
            ZGameUtils.enableButton(this.mc.back_bt,this.onBackClicked);
         }
         else
         {
            ZGameUtils.disableButton(this.mc.back_bt,this.onBackClicked);
         }
         if(this.m_currentPage < this.maxPages)
         {
            ZGameUtils.enableButton(this.mc.forward_bt,this.onFwdClicked);
         }
         else
         {
            ZGameUtils.disableButton(this.mc.forward_bt,this.onFwdClicked);
         }
      }
      
      private function updateListArrows() : void
      {
         if(this.m_currentListPage > 1)
         {
            ZGameUtils.enableButton(this.listMC.back_bt,this.onBackClicked);
         }
         else
         {
            ZGameUtils.disableButton(this.listMC.back_bt,this.onBackClicked);
         }
         if(this.m_currentListPage < this.maxListPages)
         {
            ZGameUtils.enableButton(this.listMC.forward_bt,this.onFwdClicked);
         }
         else
         {
            ZGameUtils.disableButton(this.listMC.forward_bt,this.onFwdClicked);
         }
         this.updateListScroll();
         if(this.m_currentSelectedPage > 1)
         {
            ZGameUtils.enableButton(this.selectionMC.back_bt,this.onSelectedListBackClicked);
         }
         else
         {
            ZGameUtils.disableButton(this.selectionMC.back_bt,this.onSelectedListBackClicked);
         }
         if(this.m_currentSelectedPage < this.maxSelectedPages && this.m_totalSelected > NUM_SELECTED)
         {
            ZGameUtils.enableButton(this.selectionMC.forward_bt,this.onSelectedListFwdClicked);
         }
         else
         {
            ZGameUtils.disableButton(this.selectionMC.forward_bt,this.onSelectedListFwdClicked);
         }
         this.updateSelectedScroll();
      }
      
      private function set sendClicks(param1:int) : void
      {
         this.m_sendButtonClicks = param1;
         var _loc2_:int = 0;
         var _loc3_:int = -1;
         if(this._gameClick)
         {
            switch(this.mfsp2_gameClick_variant)
            {
               case ExperimentsManager.VARIANT_MFSP2_GAMECLICK_3:
                  _loc2_ = int(this.m_sendButtonClicks * 100 / 3);
                  _loc3_ = 3;
                  break;
               case ExperimentsManager.VARIANT_MFSP2_GAMECLICK_4:
                  _loc2_ = int(this.m_sendButtonClicks * 100 / 4);
                  _loc3_ = 4;
            }
            if(_loc2_ > 100)
            {
               _loc2_ = 100;
            }
            if(_loc2_ > 1 && this.m_gameFrame != _loc2_)
            {
               this.m_gameFrame = _loc2_;
               m_window.requests_mc.progressBar_mc.tank_mc.addEventListener(Event.ENTER_FRAME,this.stopAtPercentageTank);
               m_window.requests_mc.progressBar_mc.counter_mc.addEventListener(Event.ENTER_FRAME,this.stopAtPercentageMessage);
               m_window.requests_mc.progressBar_mc.tank_mc.play();
               m_window.requests_mc.progressBar_mc.counter_mc.play();
            }
         }
      }
      
      private function get sendClicks() : int
      {
         return this.m_sendButtonClicks;
      }
      
      private function onMFSPointsUpdated(param1:WorldEvent = null) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:MovieClip = null;
         if(this._rewardBar)
         {
            _loc2_ = ZGlobal.player.MFSRewardPoints;
            _loc3_ = _loc2_ / this.m_rewardBarMax;
            TweenLite.to(m_window.progressBar_mc.meter_mc,0.1,{"width":m_window.progressBar_mc.base_mc.width * _loc3_});
            _loc4_ = 1;
            for each(_loc5_ in this.mfsData.rewards)
            {
               if(_loc2_ > _loc5_.points || _loc2_ == _loc5_.points && ZGlobal.player.MFSRewardClaimed == true)
               {
                  _loc6_ = new MovieClip();
                  this.rewardButtons[_loc4_ - 1].visible = false;
                  Tooltip.unsubscribe(this.rewardButtons[_loc4_ - 1]);
               }
               else if(_loc2_ == _loc5_.points && ZGlobal.player.MFSRewardClaimed != true)
               {
                  this.rewardButtons[_loc4_ - 1].visible = true;
                  this.rewardButtons[_loc4_ - 1].gotoAndStop(1);
                  this.rewardButtons[_loc4_ - 1].enabled = true;
                  Tooltip.subscribe(this.rewardButtons[_loc4_ - 1],ZGameUtils.ZlocT("Dialogs","MFS_Tooltip_EnabledReward"));
               }
               else
               {
                  this.rewardButtons[_loc4_ - 1].visible = true;
                  this.rewardButtons[_loc4_ - 1].enabled = false;
                  this.rewardButtons[_loc4_ - 1].gotoAndStop(5);
                  Tooltip.subscribe(this.rewardButtons[_loc4_ - 1],ZGameUtils.ZlocT("Dialogs","MFS_Tooltip_DisabledReward",{
                     "required":_loc5_.points - ZGlobal.player.MFSRewardPoints,
                     "count":_loc5_.laps[ZGlobal.player.MFSRewardLap].count,
                     "reward":(ZGlobal.gameSettings.getItemByCode(_loc5_.laps[ZGlobal.player.MFSRewardLap].data,GameItem) as GameItem).getFriendlyName(GameItem.MENU_FRIENDLYNAME)
                  }));
               }
               _loc4_++;
            }
         }
      }
      
      private function collectReward(param1:Event = null) : void
      {
         TransactionManager.addTransaction(new TMFSRewardCollect(),true);
         ZGlobal.player.MFSRewardClaimed = true;
         this.onMFSPointsUpdated();
      }
      
      private function onAllFriendsClicked(param1:MouseEvent = null) : void
      {
         this.allFriendsBtn.enabled = false;
         this.allFriendsBtn.gotoAndStop(3);
         this.enaFriendsBtn.enabled = true;
         this.enaFriendsBtn.gotoAndStop(1);
         this.zyngaFriendsBtn.enabled = true;
         this.zyngaFriendsBtn.gotoAndStop(1);
         this.m_selectedTab = MFS_TAB_ALL;
         this.m_currentListPage = 1;
         this.updatePlayerList();
         this.updateListArrows();
      }
      
      private function onZyngaFriendsClicked(param1:MouseEvent = null) : void
      {
         this.allFriendsBtn.enabled = true;
         this.allFriendsBtn.gotoAndStop(1);
         this.enaFriendsBtn.enabled = true;
         this.enaFriendsBtn.gotoAndStop(1);
         this.zyngaFriendsBtn.enabled = false;
         this.zyngaFriendsBtn.gotoAndStop(3);
         this.m_selectedTab = MFS_TAB_ZYNGA;
         this.m_currentListPage = 1;
         this.updatePlayerList();
         this.updateListArrows();
      }
      
      private function onEmpireFriendsClicked(param1:MouseEvent = null) : void
      {
         this.allFriendsBtn.enabled = true;
         this.allFriendsBtn.gotoAndStop(1);
         this.enaFriendsBtn.enabled = false;
         this.enaFriendsBtn.gotoAndStop(3);
         this.zyngaFriendsBtn.enabled = true;
         this.zyngaFriendsBtn.gotoAndStop(1);
         this.m_selectedTab = MFS_TAB_ENA;
         this.m_currentListPage = 1;
         this.updatePlayerList();
         this.updateListArrows();
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(param1.currentTarget.enabled)
         {
            param1.currentTarget.gotoAndStop(2);
         }
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(param1.currentTarget.enabled)
         {
            param1.currentTarget.gotoAndStop(1);
         }
      }
      
      private function get allFriendsBtn() : MovieClip
      {
         return this.tabs[2];
      }
      
      private function get zyngaFriendsBtn() : MovieClip
      {
         return this.tabs[1];
      }
      
      private function get enaFriendsBtn() : MovieClip
      {
         return this.tabs[0];
      }
      
      private function onSearchChanged(param1:Event) : void
      {
         var _loc2_:int = 0;
         if(!this.m_skipSearch)
         {
            _loc2_ = 0;
            while(_loc2_ < this.m_cards.length)
            {
               if(this.m_cards[_loc2_].getFriendInfo().name.toLowerCase().indexOf(this.searchBar.text.toLowerCase()) < 0)
               {
                  this.m_cards[_loc2_].isVisible = false;
               }
               else
               {
                  this.m_cards[_loc2_].isVisible = true;
               }
               _loc2_++;
            }
            _loc2_ = 0;
            while(_loc2_ < this.m_zyngaCards.length)
            {
               if(this.m_zyngaCards[_loc2_].getFriendInfo().name.toLowerCase().indexOf(this.searchBar.text.toLowerCase()) < 0)
               {
                  this.m_zyngaCards[_loc2_].isVisible = false;
               }
               else
               {
                  this.m_zyngaCards[_loc2_].isVisible = true;
               }
               _loc2_++;
            }
            _loc2_ = 0;
            while(_loc2_ < this.m_enaCards.length)
            {
               if(this.m_enaCards[_loc2_].getFriendInfo().name.toLowerCase().indexOf(this.searchBar.text.toLowerCase()) < 0)
               {
                  this.m_enaCards[_loc2_].isVisible = false;
               }
               else
               {
                  this.m_enaCards[_loc2_].isVisible = true;
               }
               _loc2_++;
            }
            this.m_currentListPage = 1;
            this.updatePlayerList();
         }
      }
      
      private function onSearchClick(param1:MouseEvent) : void
      {
         if(this.m_skipSearch)
         {
            this.searchBar.text = "";
            this.searchBar.filters = this.m_activeSearchBar;
            this.m_skipSearch = false;
         }
      }
      
      private function onSearchFocusIn(param1:FocusEvent) : void
      {
         if(param1.target == this.searchBar && this.m_skipSearch)
         {
            (param1.target as TextField).text = "";
            (param1.target as TextField).filters = this.m_activeSearchBar;
            this.m_skipSearch = false;
         }
      }
      
      private function onSearchFocusOut(param1:FocusEvent) : void
      {
         if(param1.target == this.searchBar && !this.m_skipSearch && this.searchBar.text.length == 0)
         {
            TextFieldUtil.processTextField(param1.target as TextField,ZGameUtils.ZlocT("Dialogs","MFS_SearchBar"));
            param1.target.filters = this.m_defaultSearchBar;
            param1.target.mouseEnabled = true;
            this.m_skipSearch = true;
         }
      }
      
      private function onSearchOut(param1:MouseEvent) : void
      {
         if(!this.m_skipSearch && this.searchBar.text.length == 0)
         {
            TextFieldUtil.processTextField(param1.currentTarget as TextField,ZGameUtils.ZlocT("Dialogs","MFS_SearchBar"));
            param1.currentTarget.filters = this.m_defaultSearchBar;
            param1.currentTarget.mouseEnabled = true;
            param1.currentTarget.selectable = true;
            this.m_skipSearch = true;
            stage.focus = stage;
         }
      }
      
      private function chooseRandom(param1:Array) : String
      {
         var _loc2_:String = "";
         var _loc3_:Array = new Array();
         _loc3_ = _loc3_.concat(ZGlobal.player.allFriendsSNAPI);
         _loc3_ = _loc3_.concat(ZGlobal.player.matchmakingFriends);
         var _loc4_:int = int(Math.random() * param1.length);
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_.length)
         {
            if(_loc3_[_loc5_].uid == param1[_loc4_])
            {
               _loc2_ = _loc3_[_loc5_].pic;
               break;
            }
            _loc5_++;
         }
         return _loc2_;
      }
      
      private function DefaultColorMatrix() : ColorMatrixFilter
      {
         var _loc1_:AdjustColor = new AdjustColor();
         _loc1_.hue = 0;
         _loc1_.saturation = -50;
         _loc1_.brightness = 80;
         _loc1_.contrast = 0;
         var _loc2_:Array = _loc1_.CalculateFinalFlatArray();
         return new ColorMatrixFilter(_loc2_);
      }
      
      private function stopAtPercentageMessage(param1:Event) : void
      {
         if(param1.currentTarget.currentFrame == this.m_gameFrame)
         {
            param1.currentTarget.removeEventListener(Event.ENTER_FRAME,this.stopAtPercentageMessage);
            param1.currentTarget.stop();
         }
      }
      
      private function stopAtPercentageTank(param1:Event) : void
      {
         var _loc2_:ImageLoader = null;
         var _loc3_:int = 0;
         if(param1.currentTarget.currentFrame == this.m_gameFrame)
         {
            param1.currentTarget.removeEventListener(Event.ENTER_FRAME,this.stopAtPercentageTank);
            param1.currentTarget.stop();
            if(!this.m_friendPick)
            {
               this.m_friendPick = new this.friendPick();
               m_window.addChild(this.m_friendPick);
            }
            m_window.removeChild(this.m_friendPick);
            _loc2_ = ImageLoaderFactory.CreateImageLoader(this.m_randomFriendPic,this.m_friendPick.icon);
            _loc2_.smooth = true;
            _loc3_ = int(this.m_friendPickStrings.length * Math.random());
            TextFieldUtil.compactTextField(this.m_friendPick.text_tf,this.m_friendPickStrings[_loc3_]);
            this.m_friendPickStrings.splice(_loc3_,1);
            m_window.addChild(this.m_friendPick);
            this.m_friendPick.x = m_window.requests_mc.x + m_window.requests_mc.progressBar_mc.x + m_window.requests_mc.progressBar_mc.tank_mc.x + m_window.requests_mc.progressBar_mc.tank_mc.tankAsset_mc.x;
            this.m_friendPick.y = m_window.requests_mc.y + m_window.requests_mc.progressBar_mc.y + m_window.requests_mc.progressBar_mc.tank_mc.y + m_window.requests_mc.progressBar_mc.tank_mc.tankAsset_mc.y;
         }
      }
      
      protected function sortFriends() : void
      {
         if(this._mfsp2)
         {
            return;
         }
         var _loc1_:uint = uint(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_LOGIC));
         if(_loc1_ > 0)
         {
            switch(_loc1_)
            {
               case 1:
                  this.sortArrayAlphabetically(this.m_friends,0,this.m_friends.length - 1);
                  break;
               case 2:
                  this.sortArrayRandomlyPaged(this.m_friends,0,this.m_friends.length - 1);
                  break;
               case 3:
                  this.sortFriendsAppUsersFirst(0,this.m_friends.length - 1);
                  break;
               case 4:
                  this.sortFriendsAppUsersZyngaFirst(0,this.m_friends.length - 1);
            }
         }
         else
         {
            _loc1_ = uint(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_SORT));
            switch(_loc1_)
            {
               case 2:
                  this.sortArrayAlphabetically(this.m_friends,0,this.m_friends.length - 1);
                  break;
               case 3:
                  this.sortArrayAlphabeticallyReverse(this.m_friends,0,this.m_friends.length - 1);
                  break;
               case 4:
                  this.sortArrayRandomly(this.m_friends,0,this.m_friends.length - 1);
                  break;
               case 5:
                  this.sortArrayRandomlyPaged(this.m_friends,0,this.m_friends.length - 1);
            }
         }
      }
      
      protected function sortArrayAlphabetically(param1:Array, param2:uint, param3:uint) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Array = null;
         if(param2 == 0 && param3 == param1.length - 1)
         {
            param1.sortOn("name",Array.CASEINSENSITIVE);
         }
         else
         {
            _loc4_ = param3 - param2 + 1;
            _loc5_ = param1.splice(param2,_loc4_);
            _loc5_.sortOn("name",Array.CASEINSENSITIVE);
            this.insertArray(param1,_loc5_,param2);
         }
      }
      
      private function sortArrayAlphabeticallyReverse(param1:Array, param2:uint, param3:uint) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Array = null;
         if(param2 == 0 && param3 == param1.length - 1)
         {
            param1.sortOn("name",Array.CASEINSENSITIVE | Array.DESCENDING);
         }
         else
         {
            _loc4_ = param3 - param2 + 1;
            _loc5_ = param1.splice(param2,_loc4_);
            _loc5_.sortOn("name",Array.CASEINSENSITIVE | Array.DESCENDING);
            this.insertArray(param1,_loc5_,param2);
         }
      }
      
      private function sortArrayRandomly(param1:Array, param2:uint, param3:uint) : void
      {
         ZGameUtils.shuffleArray(param1,param2,param3);
      }
      
      private function sortArrayRandomlyPaged(param1:Array, param2:uint, param3:uint, param4:uint = 0) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         ZGameUtils.shuffleArray(param1,Math.max(param2,param4),param3);
         var _loc7_:int = 0;
         while(_loc7_ < this.maxPages)
         {
            _loc5_ = Math.max(_loc7_ * this.maxSlots,param4);
            _loc6_ = Math.min((_loc7_ + 1) * this.maxSlots - 1,param1.length - 1);
            if(_loc5_ < _loc6_)
            {
               this.sortArrayAlphabetically(param1,_loc5_,_loc6_);
            }
            _loc7_++;
         }
      }
      
      private function sortFriendsAppUsersZyngaFirst(param1:uint, param2:uint) : void
      {
         var _loc11_:String = null;
         var _loc14_:Object = null;
         var _loc15_:Boolean = false;
         var _loc16_:Object = null;
         var _loc3_:Array = this.m_friends;
         var _loc4_:Array = new Array();
         var _loc5_:Array = new Array();
         var _loc6_:Array = ZGlobal.player.zyngaFriends;
         var _loc7_:Array = new Array();
         var _loc8_:Boolean = false;
         var _loc9_:uint = 0;
         var _loc10_:uint = 0;
         for(_loc11_ in this.m_friends)
         {
            if(this.m_friends[_loc11_].is_app_user)
            {
               _loc4_.push(this.m_friends[_loc11_]);
            }
            else
            {
               _loc5_.push(this.m_friends[_loc11_]);
            }
         }
         _loc4_ = this.orderAppFriends(_loc4_);
         this.m_friends = _loc4_;
         _loc9_ = 0;
         while(_loc9_ < _loc6_.length)
         {
            _loc14_ = _loc6_[_loc9_];
            _loc15_ = false;
            if(_loc14_ != null)
            {
               _loc10_ = 0;
               while(!_loc15_ && _loc10_ < _loc4_.length)
               {
                  if(_loc14_.zid == _loc4_[_loc10_].zid)
                  {
                     _loc15_ = true;
                  }
                  _loc10_++;
               }
               if(_loc15_ == false)
               {
                  _loc7_.push(_loc14_);
               }
            }
            _loc9_++;
         }
         this.sortArrayAlphabetically(_loc7_,0,_loc7_.length - 1);
         this.m_friends = this.m_friends.concat(_loc7_);
         var _loc12_:Array = new Array();
         _loc9_ = 0;
         while(_loc9_ < _loc3_.length)
         {
            _loc16_ = _loc3_[_loc9_];
            if(_loc16_ != null)
            {
               _loc8_ = false;
               _loc10_ = 0;
               while(_loc10_ < _loc4_.length)
               {
                  if(_loc4_[_loc10_] != null && _loc16_.zid == _loc4_[_loc10_].zid)
                  {
                     _loc8_ = true;
                     break;
                  }
                  _loc10_++;
               }
               if(!_loc8_)
               {
                  _loc10_ = 0;
                  while(_loc10_ < _loc7_.length)
                  {
                     if(_loc7_[_loc10_] != null && _loc16_.zid == _loc7_[_loc10_].zid)
                     {
                        _loc8_ = true;
                        break;
                     }
                     _loc10_++;
                  }
               }
               if(!_loc8_)
               {
                  _loc12_.push(_loc16_);
               }
            }
            _loc9_++;
         }
         this.m_friends = this.m_friends.concat(_loc12_);
         var _loc13_:uint = _loc4_.length + _loc7_.length;
         this.sortArrayRandomlyPaged(this.m_friends,0,this.m_friends.length - 1,_loc13_);
      }
      
      private function sortFriendsAppUsersFirst(param1:uint, param2:uint) : void
      {
         var _loc5_:String = null;
         var _loc6_:uint = 0;
         var _loc3_:Array = new Array();
         var _loc4_:Array = new Array();
         for(_loc5_ in this.m_friends)
         {
            if(this.m_friends[_loc5_].is_app_user)
            {
               _loc3_.push(this.m_friends[_loc5_]);
            }
            else
            {
               _loc4_.push(this.m_friends[_loc5_]);
            }
         }
         _loc3_ = this.orderAppFriends(_loc3_);
         _loc6_ = _loc3_.length;
         this.m_friends = _loc3_;
         this.m_friends = this.m_friends.concat(_loc4_);
         this.sortArrayRandomlyPaged(this.m_friends,0,this.m_friends.length - 1,_loc6_);
      }
      
      private function orderAppFriends(param1:Array) : Array
      {
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:Object = null;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc8_:int = 0;
         var _loc9_:Array = null;
         var _loc10_:Array = null;
         var _loc11_:Array = null;
         var _loc12_:Array = null;
         var _loc13_:Boolean = false;
         var _loc14_:Object = null;
         var _loc15_:Object = null;
         var _loc16_:Object = null;
         var _loc2_:uint = uint(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_OPTIMIZE));
         if(_loc2_ > 0)
         {
            _loc8_ = 0;
            switch(_loc2_)
            {
               case 1:
                  this.sortArrayAlphabetically(param1,0,param1.length - 1);
                  break;
               case 2:
                  this.sortArrayAlphabetically(param1,0,param1.length - 1);
                  break;
               case 3:
                  _loc3_ = param1;
                  _loc4_ = new Array();
                  _loc8_ = 0;
                  while(_loc8_ < _loc3_.length)
                  {
                     _loc5_ = _loc3_[_loc8_];
                     if(_loc5_ != null)
                     {
                        _loc6_ = this.containsZid(ZGlobal.player.sevenDayLapsers,_loc5_.zid) || this.containsZid(ZGlobal.player.fourteenDayLapsers,_loc5_.zid) || this.containsZid(ZGlobal.player.thirtyDayLapsers,_loc5_.zid);
                        if(!_loc6_)
                        {
                           _loc4_.push(_loc5_);
                        }
                     }
                     _loc8_++;
                  }
                  param1 = this.sortAndPutValidFriendEntries(ZGlobal.player.sevenDayLapsers,_loc3_);
                  param1.concat(this.sortAndPutValidFriendEntries(_loc4_,_loc3_));
                  param1.concat(this.sortAndPutValidFriendEntries(ZGlobal.player.fourteenDayLapsers,_loc3_));
                  param1.concat(this.sortAndPutValidFriendEntries(ZGlobal.player.thirtyDayLapsers,_loc3_));
                  break;
               case 4:
                  _loc3_ = param1;
                  _loc4_ = new Array();
                  _loc8_ = 0;
                  while(_loc8_ < _loc3_.length)
                  {
                     _loc5_ = _loc3_[_loc8_];
                     if(_loc5_ != null)
                     {
                        _loc6_ = this.containsZid(ZGlobal.player.sevenDayLapsers,_loc5_.zid) || this.containsZid(ZGlobal.player.fourteenDayLapsers,_loc5_.zid) || this.containsZid(ZGlobal.player.thirtyDayLapsers,_loc5_.zid);
                        if(!_loc6_)
                        {
                           _loc4_.push(_loc5_);
                        }
                     }
                     _loc8_++;
                  }
                  param1 = this.sortAndPutValidFriendEntries(_loc4_,_loc3_);
                  param1.concat(this.sortAndPutValidFriendEntries(ZGlobal.player.sevenDayLapsers,_loc3_));
                  param1.concat(this.sortAndPutValidFriendEntries(ZGlobal.player.fourteenDayLapsers,_loc3_));
                  param1.concat(this.sortAndPutValidFriendEntries(ZGlobal.player.thirtyDayLapsers,_loc3_));
                  break;
               case 5:
                  _loc3_ = param1;
                  _loc9_ = new Array();
                  _loc10_ = new Array();
                  _loc11_ = new Array();
                  _loc12_ = new Array();
                  _loc8_ = 0;
                  while(_loc8_ < _loc3_.length)
                  {
                     _loc5_ = _loc3_[_loc8_];
                     if(_loc5_ != null)
                     {
                        _loc13_ = this.containsZid(ZGlobal.player.sevenDayLapsers,_loc5_.zid) || this.containsZid(ZGlobal.player.fourteenDayLapsers,_loc5_.zid) || this.containsZid(ZGlobal.player.thirtyDayLapsers,_loc5_.zid) || this.containsZid(ZGlobal.player.payerFriends,_loc5_.zid);
                        if(!_loc13_)
                        {
                           _loc9_.push(_loc5_);
                        }
                     }
                     _loc8_++;
                  }
                  _loc8_ = 0;
                  while(_loc8_ < ZGlobal.player.sevenDayLapsers.length)
                  {
                     _loc14_ = ZGlobal.player.sevenDayLapsers[_loc8_];
                     if(_loc14_ != null)
                     {
                        _loc7_ = this.containsZid(ZGlobal.player.payerFriends,_loc14_.zid);
                        if(!_loc7_)
                        {
                           _loc10_.push(_loc14_);
                        }
                     }
                     _loc8_++;
                  }
                  _loc8_ = 0;
                  while(_loc8_ < ZGlobal.player.fourteenDayLapsers.length)
                  {
                     _loc15_ = ZGlobal.player.fourteenDayLapsers[_loc8_];
                     if(_loc15_ != null)
                     {
                        _loc7_ = this.containsZid(ZGlobal.player.payerFriends,_loc15_.zid);
                        if(!_loc7_)
                        {
                           _loc11_.push(_loc15_);
                        }
                     }
                     _loc8_++;
                  }
                  _loc8_ = 0;
                  while(_loc8_ < ZGlobal.player.thirtyDayLapsers.length)
                  {
                     _loc16_ = ZGlobal.player.thirtyDayLapsers[_loc8_];
                     if(_loc16_ != null)
                     {
                        _loc7_ = this.containsZid(ZGlobal.player.payerFriends,_loc16_.zid);
                        if(!_loc7_)
                        {
                           _loc12_.push(_loc16_);
                        }
                     }
                     _loc8_++;
                  }
                  param1 = this.sortAndPutValidFriendEntries(ZGlobal.player.payerFriends,_loc3_);
                  param1.concat(this.sortAndPutValidFriendEntries(_loc9_,_loc3_));
                  param1.concat(this.sortAndPutValidFriendEntries(_loc10_,_loc3_));
                  param1.concat(this.sortAndPutValidFriendEntries(_loc11_,_loc3_));
                  param1.concat(this.sortAndPutValidFriendEntries(_loc12_,_loc3_));
                  break;
               default:
                  this.sortArrayAlphabetically(param1,0,param1.length - 1);
            }
         }
         else
         {
            this.sortArrayAlphabetically(param1,0,param1.length - 1);
         }
         return param1;
      }
      
      private function sortAndPutValidFriendEntries(param1:Array, param2:Array) : Array
      {
         var _loc5_:int = 0;
         if(param1 == null || param2 == null)
         {
            return new Array();
         }
         var _loc3_:Array = new Array();
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc5_ = 0;
            while(_loc5_ < param2.length)
            {
               if(param1[_loc4_].zid == param2[_loc5_].zid)
               {
                  _loc3_.push(param1[_loc4_]);
                  break;
               }
               _loc5_++;
            }
            _loc4_++;
         }
         this.sortArrayAlphabetically(_loc3_,0,_loc3_.length - 1);
         return _loc3_;
      }
   }
}

