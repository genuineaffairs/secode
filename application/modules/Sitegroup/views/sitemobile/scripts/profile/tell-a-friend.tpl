<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitegroup
 * @copyright  Copyright 2010-2011 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: tellfriend.tpl 2011-05-05 9:40:21Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>
<?php
$this->headLink()
        ->prependStylesheet($this->layout()->staticBaseUrl . 'application/modules/Sitegroup/externals/styles/style_sitegroup_profile.css');
?>
<div class="sitegroup_tellafriend_popup">
  <?php  
     if (isset($this->form->captcha)):
       $this->form->removeElement('captcha');      
     endif;
  
   ?>
  <?php echo $this->form->render($this); ?>
</div>