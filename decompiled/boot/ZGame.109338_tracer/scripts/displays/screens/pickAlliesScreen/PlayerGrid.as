package displays.screens.pickAlliesScreen
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.MercenaryItem;
   import core.managers.AlliancesManager;
   import core.player.Friend;
   import core.player.IAlly;
   import core.player.Player;
   import core.ui.menuitem.FriendsBarUIItem;
   import displays.screens.gridScreen.GridScreen;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import utils.ZGameUtils;
   import zlabs.resource.SWFResource;
   
   public class PlayerGrid extends GridScreen
   {
      
      protected var m_eventDispatcher:EventDispatcher = null;
      
      protected var m_players:Array = new Array();
      
      protected var m_selections:Array = new Array();
      
      protected var m_maxSelections:int = 0;
      
      public function PlayerGrid(param1:MovieClip, param2:SWFResource, param3:EventDispatcher, param4:Array, param5:int)
      {
         this.m_eventDispatcher = param3;
         this.m_maxSelections = param5;
         if(Boolean(param4) && param4.length > 0)
         {
            this.m_selections = param4;
         }
         super();
         this.init(param1,param2);
      }
      
      protected function init(param1:MovieClip, param2:SWFResource) : void
      {
         setDimensions(5,2);
         this.load(param1,param2);
      }
      
      override public function get numCards() : int
      {
         return this.m_players.length;
      }
      
      override protected function getMultFactor() : Number
      {
         return 1.1;
      }
      
      public function get selections() : Array
      {
         return this.m_selections;
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         var _loc6_:IAlly = this.m_players.shift();
         return new PlayerSlot(param1,param2,screen,param3,param4,_loc6_,this.isAllySelected(_loc6_),this.getMultFactor());
      }
      
      override protected function createSpecialCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int) : GridSlot
      {
         return new AddFriendSlot(param1,param2,screen,param3,param4,this.getMultFactor());
      }
      
      override public function updateCards() : void
      {
         this.createItemList();
         super.updateCards();
         this.fillOutHeader();
      }
      
      protected function isAllySelected(param1:IAlly) : Boolean
      {
         var _loc2_:IAlly = null;
         for each(_loc2_ in this.m_selections)
         {
            if(_loc2_.id == param1.id)
            {
               return true;
            }
         }
         return false;
      }
      
      protected function resetAnchorPosition() : void
      {
         setAnchor(73,15);
      }
      
      override protected function load(param1:MovieClip, param2:SWFResource) : void
      {
         this.createItemList();
         super.load(param1,param2);
         this.resetAnchorPosition();
         this.fillOutHeader();
      }
      
      public function updateSelections(param1:Array) : void
      {
         this.m_selections = param1;
         this.fillOutHeader();
      }
      
      protected function fillOutHeader() : void
      {
         var _loc1_:int = this.m_selections ? int(this.m_selections.length) : 0;
         screen.header_tf.text = ZGameUtils.ZlocT("Dialogs","PickPlayerHeader",{"num":this.m_maxSelections - _loc1_});
      }
      
      protected function allowDefaultAllyAsNeighbor() : Boolean
      {
         return false;
      }
      
      protected function allowMercsAsNeighbors() : Boolean
      {
         return true;
      }
      
      protected function createItemList() : void
      {
         var _loc1_:String = null;
         var _loc2_:Array = null;
         var _loc3_:XMLList = null;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:Number = NaN;
         var _loc7_:Array = null;
         var _loc8_:XMLList = null;
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:Player = null;
         var _loc12_:Array = null;
         var _loc13_:XML = null;
         var _loc14_:String = null;
         if(AlliancesManager.isValid() && AlliancesManager.instance.allianceBattle)
         {
            _loc1_ = AlliancesManager.instance.battleAllianceName;
            _loc2_ = AlliancesManager.instance.members;
            _loc3_ = ZGlobal.gameSettings.getXML().defaultAlly;
            _loc4_ = 0;
            while(_loc4_ < _loc2_.length)
            {
               _loc5_ = AlliancesManager.instance.memberInfo(_loc2_[_loc4_]);
               if(_loc5_)
               {
                  _loc5_.uid = _loc2_[_loc4_];
                  _loc6_ = Number(_loc5_.uid);
                  if(_loc5_.uid != ZGlobal.player.uid && (_loc6_ >= 0 || _loc5_.uid == _loc3_.uid) && _loc5_.uid != _loc3_.uid)
                  {
                     if(_loc5_.image == null || _loc5_.image == "")
                     {
                        _loc5_.image = ZGlobal.getAssetURL(ZGameUtils.NoProfileImageUrl);
                     }
                     this.m_players.push(new Friend(_loc5_.uid,_loc5_.coins,_loc5_.xp,_loc5_.level,_loc5_.socialXpGood,_loc5_.socialLevelGood,_loc5_.socialXpBad,_loc5_.socialLevelBad,_loc5_.resource,_loc5_.image,_loc5_.name,0));
                  }
               }
               _loc4_++;
            }
         }
         else
         {
            _loc7_ = FriendsBarUIItem(FriendsBarUIItem.getFriendsBar()).neighbors;
            _loc8_ = ZGlobal.gameSettings.getXML().defaultAlly;
            _loc9_ = 0;
            while(_loc9_ < _loc7_.length)
            {
               _loc10_ = Number(_loc7_[_loc9_].uid);
               if(_loc7_[_loc9_].uid != ZGlobal.player.uid && (_loc10_ >= 0 || _loc7_[_loc9_].uid == _loc8_.uid) && (_loc7_[_loc9_].uid != _loc8_.uid || this.allowDefaultAllyAsNeighbor()))
               {
                  _loc11_ = ZGlobal.player.findFriendById(_loc7_[_loc9_].uid);
                  if(_loc11_)
                  {
                     this.m_players.push(_loc7_[_loc9_]);
                  }
               }
               _loc9_++;
            }
         }
         if(this.allowMercsAsNeighbors())
         {
            _loc12_ = ZGlobal.gameSettings.getArrayOfItemXMLByType(GameItem.TYPE_MERCENARY);
            for each(_loc13_ in _loc12_)
            {
               _loc14_ = _loc13_.@code;
               if(ZGlobal.player.getNumberOfInventoryItems(_loc14_) > 0)
               {
                  this.m_players.push(GameItem.createItemFromCode(_loc14_,XMLList(_loc13_)) as MercenaryItem);
               }
            }
         }
      }
      
      override protected function onRollOver(param1:MouseEvent) : void
      {
      }
      
      override protected function onRollOut(param1:MouseEvent) : void
      {
      }
   }
}

