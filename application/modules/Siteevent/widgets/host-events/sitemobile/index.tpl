<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Siteevent
 * @copyright  Copyright 2013-2014 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: index.tpl 6590 2014-01-02 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>

<?php $currency = Engine_Api::_()->getApi('settings', 'core')->getSetting('payment.currency', 'USD'); ?>
<?php
$ratingValue = $this->ratingType;
$ratingShow = 'small-star';
if ($this->ratingType == 'rating_editor') {
  $ratingType = 'editor';
} elseif ($this->ratingType == 'rating_avg') {
  $ratingType = 'overall';
} else {
  $ratingType = 'user';
}
?>

<?php $isLarge = ($this->columnWidth > 170); ?>
<?php if ($this->paginator->getTotalItemCount() > 0) : ?>
  <div class="sm-content-list" id="host_events">
    <ul data-role="listview" data-inset="false" data-icon="false">
      <?php foreach ($this->paginator as $siteevent): ?>
        <li data-icon="arrow-r">
          <a href="<?php echo $siteevent->getHref(); ?>">
            <?php echo $this->itemPhoto($siteevent, 'thumb.icon'); ?>
            <h3><?php echo Engine_Api::_()->seaocore()->seaocoreTruncateText($siteevent->getTitle(), $this->title_truncation); ?></h3>
            <?php if (!empty($this->statistics)) : ?>
              <?php echo $this->eventInfoSM($siteevent, $this->statistics, array('ratingShow' => $ratingShow, 'ratingValue' => $ratingValue, 'ratingType' => $ratingType, 'truncationLocation' => $this->truncationLocation)); ?>
            <?php endif; ?>
            <?php if (Engine_Api::_()->getApi('settings', 'core')->getSetting('siteevent.reviews', 2) && !empty($this->statistics) && in_array('ratingStar', $this->statistics)): ?>
              <?php if ($ratingValue == 'rating_both'): ?>
                <p><?php echo $this->showRatingStarSiteeventSM($siteevent->rating_editor, 'editor', $ratingShow); ?></p>
                <p><?php echo $this->showRatingStarSiteeventSM($siteevent->rating_users, 'user', $ratingShow); ?> </p>
              <?php else: ?>
                <p><?php echo $this->showRatingStarSiteeventSM($siteevent->$ratingValue, $ratingType, $ratingShow); ?> </p>
              <?php endif; ?>
            <?php endif; ?>
          </a>
        </li>
      <?php endforeach; ?>

    </ul>
    <?php if ($this->paginator->count() > 1): ?>
      <?php
      echo $this->paginationAjaxControl(
              $this->paginator, $this->identity, "host_events");
      ?>
    <?php endif; ?>
  </div>
<?php else: ?>
  <div class="tip"> 
    <span>
      <?php echo $this->translate("There are not any event."); ?> 
    </span>
  </div>  
<?php endif; ?>

<style type="text/css">
  .sm_profile_item_designation{
    font-size: 14px;
    margin: 2px 0 0 8px;
    overflow: hidden;
  }
  .sr_editor_profile_stats{
    margin: 2px 0 0 8px;
    overflow: hidden;
  }
  .layout_siteevent_host_events > h3{
    display:none;
  }
</style>
