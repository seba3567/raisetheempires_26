package displays.screens
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   
   public class RequestDialogListItem
   {
      
      private var m_card:MovieClip;
      
      private var m_selectedCard:MovieClip;
      
      private var m_friendInfo:Object;
      
      private var m_selected:Boolean;
      
      private var m_checkCallback:Function;
      
      private var m_removeItemCallback:Function;
      
      private var m_preselectVariant:Number;
      
      private var m_visible:Boolean = true;
      
      public function RequestDialogListItem(param1:Object, param2:Function, param3:Function)
      {
         super();
         this.m_friendInfo = param1;
         this.m_checkCallback = param2;
         this.m_removeItemCallback = param3;
         this.m_preselectVariant = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_PRESELECT);
         if(Boolean(this.m_friendInfo) && Boolean(this.m_friendInfo.hasOwnProperty("is_app_user")) && Boolean(this.m_friendInfo.is_app_user) && this.m_preselectVariant < 3)
         {
            this.m_selected = true;
         }
         else
         {
            this.m_selected = false;
         }
         if(this.m_preselectVariant == 2 && ZGlobal.player.isZyngaFriend(this.m_friendInfo))
         {
            this.m_selected = true;
         }
      }
      
      public function getFriendInfo() : Object
      {
         return this.m_friendInfo;
      }
      
      public function setCard(param1:MovieClip) : void
      {
         if(this.m_card)
         {
            this.dispose();
         }
         this.m_card = param1;
         if(this.m_card)
         {
            if(this.m_friendInfo)
            {
               this.m_card.empires_mc.visible = false;
               this.m_card.zynga_mc.visible = false;
               if(this.m_friendInfo.hasOwnProperty("is_app_user") && Boolean(this.m_friendInfo.is_app_user))
               {
                  this.m_card.empires_mc.visible = true;
               }
               else if(this.m_preselectVariant == 2 && ZGlobal.player.isZyngaFriend(this.m_friendInfo))
               {
                  this.m_card.zynga_mc.visible = true;
               }
               this.m_selected = false;
               this.m_card.visible = true;
               this.m_card.highlight_mc.visible = false;
               this.m_card.addEventListener(MouseEvent.MOUSE_OUT,this.onOut,false,0,true);
               this.m_card.addEventListener(MouseEvent.MOUSE_OVER,this.onOver,false,0,true);
               this.m_card.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
               this.updateSelected();
            }
            else
            {
               this.m_card.visible = false;
            }
         }
      }
      
      public function setSelectedCard(param1:MovieClip) : void
      {
         if(this.m_card)
         {
            this.dispose();
         }
         this.m_card = param1;
         if(this.m_card)
         {
            if(this.m_friendInfo)
            {
               this.m_selected = true;
               this.m_card.visible = true;
               this.m_card.highlight_mc.visible = false;
               this.m_card.remove_bt.visible = false;
               this.m_card.remove_bt.visible = true;
               this.m_card.empires_mc.visible = false;
               this.m_card.zynga_mc.visible = false;
               if(this.m_friendInfo.hasOwnProperty("is_app_user") && Boolean(this.m_friendInfo.is_app_user))
               {
                  this.m_card.empires_mc.visible = true;
               }
               else if(this.m_preselectVariant == 2 && ZGlobal.player.isZyngaFriend(this.m_friendInfo))
               {
                  this.m_card.zynga_mc.visible = true;
               }
               this.m_card.addEventListener(MouseEvent.MOUSE_OUT,this.onOut,false,0,true);
               this.m_card.addEventListener(MouseEvent.MOUSE_OVER,this.onOver,false,0,true);
               this.m_card.remove_bt.addEventListener(MouseEvent.CLICK,this.removeSelected,false,0,true);
               this.updateSelected();
            }
            else
            {
               this.m_card.visible = false;
            }
         }
      }
      
      private function updateSelected() : void
      {
         TextFieldUtil.processTextField(this.m_card.generic_tf,this.m_friendInfo.name);
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         this.m_card.highlight_mc.visible = false;
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         this.m_card.highlight_mc.visible = true;
      }
      
      private function onClick(param1:MouseEvent = null) : void
      {
         this.m_checkCallback(this.m_friendInfo);
      }
      
      private function onSelectedCardClick(param1:MouseEvent) : void
      {
      }
      
      private function removeSelected(param1:MouseEvent) : void
      {
         this.m_removeItemCallback(this.m_friendInfo);
      }
      
      public function get visible() : Boolean
      {
         return this.m_card.visible;
      }
      
      public function get isSelected() : Boolean
      {
         return this.m_selected;
      }
      
      public function get isVisible() : Boolean
      {
         return this.m_visible;
      }
      
      public function set isVisible(param1:Boolean) : void
      {
         this.m_visible = param1;
      }
      
      public function show() : void
      {
         this.m_card.visible = true;
      }
      
      public function hide() : void
      {
         this.m_card.visible = false;
      }
      
      public function release() : void
      {
         this.dispose();
      }
      
      public function dispose() : void
      {
         if(this.m_card)
         {
            this.m_card.removeEventListener(MouseEvent.MOUSE_OUT,this.onOut);
            this.m_card.removeEventListener(MouseEvent.MOUSE_OVER,this.onOver);
            this.m_card.removeEventListener(MouseEvent.CLICK,this.onClick);
            if(this.m_card.remove_bt)
            {
               this.m_card.remove_bt.removeEventListener(MouseEvent.CLICK,this.removeSelected);
            }
            this.m_card = null;
         }
      }
   }
}

