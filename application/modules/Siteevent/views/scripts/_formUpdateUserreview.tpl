<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Siteevent
 * @copyright  Copyright 2013-2014 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: _formUpdateUserreview.tpl 6590 2014-01-02 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>
<?php
$rating_value_2 = 0;
$rating_value_2 = $this->myReviews;
switch ($rating_value_2) {
  case 0:
    $rating_value = '';
    break;
  case 1:
    $rating_value = 'onestar';
    break;
  case 2:
    $rating_value = 'twostar';
    break;
  case 3:
    $rating_value = 'threestar';
    break;
  case 4:
    $rating_value = 'fourstar';
    break;
  case 5:
    $rating_value = 'fivestar';
    break;
}
?>

<div class="form-wrapper" id="overall_my_rating" style="display:none;">
  <div class="form-label">
    <label>
      <?php echo $this->translate("Overall Rating"); ?>
    </label>
  </div>	
  <div class="form-element">
    <ul id= 'rate_0' class='siteevent_ug_rating <?php echo $rating_value; ?>'>
      <li id="1" class="rate one"><a href="javascript:void(0);" onclick="doEditMyDefaultRating('update_star_1', '0', 'onestar');" title="<?php echo $this->translate('1 Star'); ?>"   id="update_star_1_0">1</a></li>
      <li id="2" class="rate two"><a href="javascript:void(0);"  onclick="doEditMyDefaultRating('update_star_2', '0', 'twostar');" title="<?php echo $this->translate('2 Stars'); ?>"   id="update_star_2_0">2</a></li>
      <li id="3" class="rate three"><a href="javascript:void(0);"  onclick="doEditMyDefaultRating('update_star_3', '0', 'threestar');" title="<?php echo $this->translate('3 Stars'); ?>" id="update_star_3_0">3</a></li>
      <li id="4" class="rate four"><a href="javascript:void(0);"  onclick="doEditMyDefaultRating('update_star_4', '0', 'fourstar');" title="<?php echo $this->translate('4 Stars'); ?>"  id="update_star_4_0">4</a></li>
      <li id="5" class="rate five"><a href="javascript:void(0);"  onclick="doEditMyDefaultRating('update_star_5', '0', 'fivestar');" title="<?php echo $this->translate('5 Stars'); ?>" id="update_star_5_0">5</a></li>
    </ul>
    <input type="hidden" name='update_review_rate_0' id='update_review_rate_0' value='<?php echo $rating_value_2; ?>' />
  </div>
</div>
<?php //endif;  ?>

<script type="text/javascript">

  function doEditMyRating(element_id, ratingparam_id, classstar) {
    $(element_id + '_' + ratingparam_id).getParent().getParent().className = 'sr-us-box rating-box ' + classstar;
    $('update_review_rate_' + ratingparam_id).value = $(element_id + '_' + ratingparam_id).getParent().id;
  }

  function doEditMyDefaultRating(element_id, ratingparam_id, classstar) {
    $(element_id + '_' + ratingparam_id).getParent().getParent().className = 'siteevent_ug_rating ' + classstar;
    $('update_review_rate_' + ratingparam_id).value = $(element_id + '_' + ratingparam_id).getParent().id;
  }

</script>