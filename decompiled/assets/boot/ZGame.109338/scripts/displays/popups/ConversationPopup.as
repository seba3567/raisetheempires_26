package displays.popups
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.resource.SWFResource;
   
   public class ConversationPopup extends GallantPopup
   {
      
      private static const MAX_BUBBLES:int = 4;
      
      private static const BUTTON_X_SPACING:int = -2;
      
      private static const TRACK_EVENT_SEEN:String = "seen";
      
      private static const TRACK_EVENT_CANCEL:String = "cancel";
      
      private static const TRACK_EVENT_CLOSE:String = "close";
      
      private static const TRACK_EVENT_LINKTO:String = "linkto";
      
      private var m_conversationId:String = null;
      
      private var m_closeCallback:Function = null;
      
      private var m_resource:SWFResource = null;
      
      private var m_buttons:Array = null;
      
      private var m_loaders:Array = null;
      
      public function ConversationPopup(param1:String, param2:Function = null, param3:String = null)
      {
         var _loc4_:String = null;
         this.m_conversationId = param1;
         this.m_closeCallback = param2;
         switch(param3)
         {
            case "v2":
               _loc4_ = "assets/displays/dialogs/PU_ConversationV2.swf";
               break;
            default:
               _loc4_ = "assets/displays/dialogs/PU_Conversation.swf";
         }
         super(ZGlobal.getAssetURL(_loc4_));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         this.m_resource = param1;
         super.onLoadComplete(param1);
      }
      
      override protected function initializeScreen() : void
      {
         var _loc1_:MovieClip = null;
         _loc1_ = m_window.conversation_mc;
         contentWidth = _loc1_.sizer_mc.width;
         contentHeight = _loc1_.sizer_mc.height;
         _loc1_.sizer_mc.visible = false;
         super.initializeScreen();
         _loc1_.exit_bt.addEventListener(MouseEvent.CLICK,this.onCancel,false,0,true);
         this.displayConversation(this.m_conversationId);
         ZGlobal.player.setSeenConversation(this.m_conversationId);
      }
      
      override protected function deinitDialog() : void
      {
         this.disposeLoaders();
         this.disposeButtons();
         var _loc1_:MovieClip = m_window.conversation_mc;
         _loc1_.exit_bt.removeEventListener(MouseEvent.CLICK,this.onCancel);
         super.deinitDialog();
      }
      
      private function displayConversation(param1:String) : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:XMLList = null;
         var _loc5_:int = 0;
         var _loc6_:MovieClip = null;
         var _loc7_:Boolean = false;
         var _loc8_:Array = null;
         var _loc9_:int = 0;
         var _loc10_:XMLList = null;
         var _loc11_:int = 0;
         this.m_conversationId = param1;
         this.track(TRACK_EVENT_SEEN);
         var _loc2_:XML = ZGlobal.gameSettings.getConversation(param1);
         if(_loc2_)
         {
            _loc3_ = m_window.conversation_mc;
            _loc4_ = _loc2_.dialog;
            _loc5_ = Math.min(_loc4_.length(),MAX_BUBBLES);
            TextFieldUtil.compactTextField(_loc3_.title_tf,ZGameUtils.localizedStringForToken(_loc2_.@title,"Conversations"),{
               "maxLines":1,
               "minScale":0.6
            });
            _loc3_.layout1_mc.visible = false;
            _loc3_.layout2_mc.visible = false;
            _loc3_.layout3_mc.visible = false;
            _loc3_.layout4_mc.visible = false;
            _loc3_.layout5_mc.visible = false;
            _loc3_.layout5_mc.visible = false;
            _loc3_.layout6_mc.visible = false;
            _loc6_ = null;
            _loc7_ = Boolean(_loc2_.@altLayout.toString().length) && _loc2_.@altLayout.toString() == "true";
            switch(_loc5_)
            {
               case 1:
                  _loc6_ = _loc7_ ? _loc3_.layout5_mc : _loc3_.layout1_mc;
                  break;
               case 2:
                  _loc6_ = _loc3_.layout2_mc;
                  break;
               case 3:
                  _loc6_ = _loc3_.layout3_mc;
                  break;
               case 4:
                  _loc6_ = _loc7_ ? _loc3_.layout6_mc : _loc3_.layout4_mc;
            }
            if(_loc6_)
            {
               _loc6_.visible = true;
               this.disposeLoaders();
               this.m_loaders = new Array();
               this.addActorImage(_loc2_.@leftActor.toString(),_loc6_.icon1,_loc3_.names_mc.name_tf0);
               this.addActorImage(_loc2_.@rightActor.toString(),_loc6_.icon2,_loc3_.names_mc.name_tf1);
               _loc8_ = [_loc6_.line_mc1,_loc6_.line_mc2,_loc6_.line_mc3,_loc6_.line_mc4];
               _loc9_ = 0;
               while(_loc9_ < _loc5_)
               {
                  TextFieldUtil.processTextField(_loc8_[_loc9_],ZGameUtils.localizedStringForToken(_loc4_[_loc9_].@line.toString(),"Conversations"));
                  _loc9_++;
               }
               this.disposeButtons();
               this.m_buttons = new Array();
               _loc10_ = _loc2_.button;
               _loc11_ = 0;
               while(_loc11_ < _loc10_.length())
               {
                  this.addButton(_loc10_[_loc11_]);
                  _loc11_++;
               }
               return;
            }
         }
         this.close();
      }
      
      private function addActorImage(param1:String, param2:UILoader, param3:TextField) : void
      {
         var _loc4_:GameItem = null;
         if(Boolean(param1) && Boolean(param1.length > 0) && Boolean(param2))
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
            this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(_loc4_.getCachedImage("speech225").url,param2));
            TextFieldUtil.processTextField(param3,_loc4_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            param3.visible = true;
         }
         else
         {
            param3.visible = false;
         }
      }
      
      private function addButton(param1:XML) : void
      {
         var _loc2_:String = null;
         var _loc3_:Function = null;
         var _loc4_:String = "ButtonOrange";
         switch(param1.@type.toString())
         {
            case "ok":
               _loc2_ = ZGameUtils.localizedStringForToken("Dialogs:Close");
               _loc3_ = this.onOkButton;
               _loc4_ = "ButtonRed";
               break;
            case "linkto":
               _loc2_ = ZGameUtils.localizedStringForToken("Conversations:MoreCaption");
               _loc3_ = this.onLinktoButton;
               _loc4_ = "ButtonGreen";
         }
         if(_loc3_ == null || !_loc2_)
         {
            return;
         }
         if(param1.@caption.toString().length > 0)
         {
            _loc2_ = ZGameUtils.localizedStringForToken(param1.@caption.toString());
         }
         var _loc5_:MovieClip = m_window.conversation_mc;
         var _loc6_:Class = this.m_resource.getAssetClass(_loc4_);
         var _loc7_:MovieClip = new _loc6_();
         _loc7_.x = _loc5_.buttonAnchor_mc.width + (this.m_buttons.length == 0 ? 0 : BUTTON_X_SPACING);
         _loc5_.buttonAnchor_mc.addChild(_loc7_);
         _loc5_.buttonAnchor_mc.x = _loc5_.buttonCenter_mc.x - _loc5_.buttonAnchor_mc.width * 0.5;
         var _loc8_:ZGameButton = new ZGameButton(_loc7_.button_mc,_loc3_);
         _loc8_.text = _loc2_;
         _loc8_.buttonObject = param1;
         this.m_buttons.push(_loc8_);
      }
      
      private function disposeLoaders() : void
      {
         var _loc1_:ImageLoader = null;
         for each(_loc1_ in this.m_loaders)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         this.m_loaders = null;
      }
      
      private function disposeButtons() : void
      {
         var _loc1_:ZGameButton = null;
         for each(_loc1_ in this.m_buttons)
         {
            _loc1_.dispose();
         }
         this.m_buttons = null;
         while(m_window.conversation_mc.buttonAnchor_mc.numChildren > 0)
         {
            m_window.conversation_mc.buttonAnchor_mc.removeChildAt(0);
         }
      }
      
      override protected function close(param1:Event = null) : void
      {
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
         super.close(param1);
      }
      
      private function onCancel(param1:MouseEvent) : void
      {
         this.track(TRACK_EVENT_CANCEL);
         this.close();
      }
      
      private function onOkButton(param1:MouseEvent) : void
      {
         this.track(TRACK_EVENT_CLOSE);
         this.close();
      }
      
      private function onLinktoButton(param1:MouseEvent) : void
      {
         var _loc2_:ZGameButton = param1.target.buttonPointer;
         var _loc3_:XML = _loc2_.buttonObject as XML;
         this.displayConversation(_loc3_.@linkto.toString());
         this.track(TRACK_EVENT_LINKTO);
      }
      
      private function track(param1:String) : void
      {
      }
   }
}

