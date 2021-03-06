<?php
 /**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitelike
 * @copyright  Copyright 2009-2010 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: index.tpl 6590 2010-11-04 9:40:21Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>
<h2>
  <?php echo $this->translate('Likes Plugin & Widgets') ?>
</h2>
<?php if( count($this->navigation) ): ?>
<div class='tabs'>
  <?php
    // Render the menu
    echo $this->navigation()->menu()->setContainer($this->navigation)->render()
  ?>
</div>
<?php endif; ?>
<div class='seaocore_settings_form'>
  <div class='settings'>
    <?php
      //RENDEDR THE FORM	
			if( !empty($this->form) ) {
				echo $this->form->render($this);
			}
    ?>
  </div>
</div>