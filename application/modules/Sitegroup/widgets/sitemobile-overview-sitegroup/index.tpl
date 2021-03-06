<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitegroup
 * @copyright  Copyright 2010-2011 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: index.tpl 2011-05-05 9:40:21Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>
	
<?php if(false):?>
	<?php if ($this->can_edit && $this->can_edit_overview):?>
		<?php if(!empty($this->sitegroup->overview)):?>
			<div class="seaocore_add"  data-role="controlgroup" data-type="horizontal">
				<a data-role="button" data-icon="plus" data-iconpos="left" data-inset = 'false' data-mini="true" data-corners="true" data-shadow="true" href='<?php echo $this->url(array('group_id' => $this->sitegroup->group_id, 'action' => 'overview', 'tab' => $this->identity), 'sitegroup_dashboard', true) ?>'  class="icon_sitegroups_overview buttonlink"><?php echo $this->translate('Edit Overview'); ?></a>
			</div>
		<?php endif;?>
	<?php endif;?>
<?php endif;?>

<div>
	<?php if(!empty($this->sitegroup->overview)):?>
		<?php echo $this->sitegroup->overview ?>
	<?php else:?>
		<div class="tip">
			<span>
				<?php   echo $this->translate("No overview has been composed for this Group yet.");?>
			</span>
		</div>
	<?php endif;?>
</div>