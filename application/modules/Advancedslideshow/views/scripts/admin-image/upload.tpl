<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Advancedslideshow
 * @copyright  Copyright 2010-2011 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: upload.tpl 2011-10-22 9:40:21Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>

<h2><?php echo $this->translate('Advanced Slideshow Plugin');?></h2>
<?php if( count($this->navigation) ): ?>
	<div class='tabs'> <?php echo $this->navigation()->menu()->setContainer($this->navigation)->render() ?> </div>
<?php endif; ?>

<img src="<?php echo $this->layout()->staticBaseUrl ?>application/modules/Advancedslideshow/externals/images/back.png" class="icon" />
<?php echo $this->htmlLink(array('route' => 'admin_default', 'module' => 'advancedslideshow', 'controller' => 'slides', 'action' => 'manage', 'advancedslideshow_id' => $this->advancedslideshow_id), $this->translate('View slides listing'), array('class'=> 'buttonlink', 'style'=> 'padding-left:0px;')) ?>
<br /><br />

<div class='settings' id="admin-slidshow-addimg-popup">
	<?php echo $this->form->render($this) ?>
</div>

<script type="text/javascript">
	var catdiv = $('file-label'); 
	var catarea = catdiv.parentNode;
	catarea.removeChild(catdiv);
</script>