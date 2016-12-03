<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Siteeventpaid
 * @copyright  Copyright 2015-2016 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: raw-transaction-detail.tpl 2015-05-11 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>

<h2 class="payment_transaction_detail_headline">
  <?php echo "Raw Transaction Details"; ?>
</h2>

<?php if (!is_array($this->data)): ?>
  <div class="error">
    <span>
      <?php echo 'Order could not be found.'; ?>
    </span>
  </div>
<?php else: ?>
  <dl class="payment_transaction_details">
    <?php foreach ($this->data as $key => $value): ?>
      <dd>
        <?php echo $key ?>
      </dd>
      <dt>
      <?php echo $value ?>
      </dt>
    <?php endforeach; ?>
  </dl>
<?php endif; ?>