<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitegroup
 * @copyright  Copyright 2010-2011 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: publish.tpl 2011-05-05 9:40:21Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>
<div class='global_form_popup'>
  <?php if ($this->success): ?>
    <script type="text/javascript">
      parent.$('sitegroup-item-<?php echo $this->group_id ?>').destroy();
      setTimeout(function() {
        parent.Smoothbox.close();
      }, 1000 );
    </script>
    <div class="global_form_popup_message">
    <?php echo $this->translate('Your group has been published.'); ?>
  </div>
  <?php else: ?>
      <form method="POST" action="<?php echo $this->url() ?>">
        <div>
          <h3><?php echo $this->translate('Publish Group?'); ?></h3>
          <p>
        <?php echo $this->translate('Are you sure that you want to publish this Group?'); ?>
      </p>
      <p>&nbsp;
      </p>
      <p>
        <input type="hidden" name="group_id" value="<?php echo $this->group_id ?>"/>
        <input type="hidden" value="" name="search"><input type="checkbox" checked="checked" value="1" id="search" name="search">
        <?php echo $this->translate("Show this group in search results."); ?>
        <br />
        <br />
      <button type='submit'><?php echo $this->translate('Publish'); ?></button>
      <?php echo $this->translate(' or ') ?> <a href="javascript:void(0);" onclick="parent.Smoothbox.close();"><?php echo $this->translate('cancel') ?></a>
        </p>
      </div>
    </form>
  <?php endif; ?>
      </div>

<?php if (@$this->closeSmoothbox): ?>
          <script type="text/javascript">
            TB_close();
          </script>
<?php endif; ?>