<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitestore
 * @copyright  Copyright 2012-2013 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: facebook.tpl 2013-09-02 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>
<?php
	$this->headLink()
  ->appendStylesheet($this->layout()->staticBaseUrl
    . 'application/modules/Sitestore/externals/styles/style_sitestore_dashboard.css');
?>
<?php echo $this->form->setAttrib('class', 'global_form_popup global_form sitestore_fbconnect_form')->render($this) ?>

<?php if (@$this->closeSmoothbox): ?>
  <script type="text/javascript">
    TB_close();
  </script>
<?php endif; ?>
<style type="text/css">
  .global_form{width:550px;}
  .global_form > div{
  	float:none;
  }
</style>