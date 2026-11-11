package core.ui.components.PortraitSlidePick
{
   import core.player.IPVPPlayer;
   import flash.filters.ColorMatrixFilter;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   
   public class PortraitSlidePickPVPAlreadyDefended extends PortraitSlidePickPVPFriendDefend
   {
      
      public function PortraitSlidePickPVPAlreadyDefended(param1:IEntity, param2:IPVPPlayer, param3:Number, param4:Class, param5:Object)
      {
         super(param1,param2,param3,param4,param5);
      }
      
      override protected function onCreatePickAsset(param1:IPVPPlayer) : void
      {
         super.onCreatePickAsset(param1);
         slideCard.menuFrame.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
         portraitBubble.pickFrame.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
         portraitBubble.pickArrow.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
      }
      
      override protected function setButtons() : void
      {
         if(slideCard.green_btn_0)
         {
            slideCard.green_btn_0.visible = false;
         }
         if(slideCard.orange_btn)
         {
            slideCard.orange_btn.visible = false;
         }
         if(slideCard.green_btn_1)
         {
            slideCard.green_btn_1.visible = false;
         }
         if(slideCard.green_btn_2)
         {
            slideCard.green_btn_2.visible = false;
         }
         if(slideCard.clock_mc)
         {
            slideCard.clock_mc.visible = false;
         }
      }
      
      override protected function setPickText() : void
      {
         TextFieldUtil.processTextField(slideCard.title01_tf,ZGameUtils.ZlocT("Dialogs","InvadedText"));
      }
      
      override protected function updateComment() : void
      {
         super.updateComment();
         TextFieldUtil.processTextField(slideCard.title02_tf,ZGameUtils.ZlocT("Dialogs","CannotRepelInvasion"));
         slideCard.title02_tf.textColor = 4521987;
      }
   }
}

