<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitegrouppoll
 * @copyright  Copyright 2010-2011 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: readme.tpl 2011-05-05 9:40:21Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>
<h2><?php echo $this->translate('Groups / Communities Plugin') ?></h2>
<div class="tabs">
  <ul class="navigation">
    <li class="active">
      <a href="<?php echo $this->baseUrl() . '/admin/sitegroupmember/settings/readme' ?>" ><?php echo $this->translate('Please go through these important points and proceed by clicking the button at the bottom of this group.') ?></a>

    </li>
  </ul>
</div>		
<?php include_once APPLICATION_PATH . '/application/modules/Sitegroupmember/views/scripts/admin-settings/faq_help.tpl'; ?>
<br />
<button onclick="form_submit();"><?php echo $this->translate('Proceed to enter License Key') ?> </button>

<script type="text/javascript" >

  function form_submit() {
	
    var url='<?php echo $this->url(array('module' => 'sitegroupmember', 'controller' => 'settings'), 'admin_default', true) ?>';
    window.location.href=url;
  }

</script>