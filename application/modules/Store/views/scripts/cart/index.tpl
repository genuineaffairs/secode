<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Store
 * @copyright  Copyright Hire-Experts LLC
 * @license    http://www.hire-experts.com
 * @version    Id: index.tpl  4/25/12 6:23 PM mt.uulu $
 * @author     Mirlan
 */
?>

<?php if ($this->justHtml): ?>
  <?php
  echo $this->render('cart/_browse_list.tpl');
  return;
  ?>
<?php endif; ?>



<script type="text/javascript">
  var cart = <?php echo $this->cart->getIdentity(); ?>;
  var checkout = function (gateway_id) {
    var self = this;
    new Request.JSON({
      'method': 'post',
      'data': {
        'format': 'json',
        'cart': self.cart,
        'gateway_id': gateway_id,
        'offer_id': store_cart.offer_id
      },
      'url': "<?php echo $this->url(array('module'     => 'store',
                                         'controller' => 'cart',
                                         'action'     => 'order'), 'default', true); ?>",
      'onSuccess': function ($response) {
        if ($response.status) {
          location.href = $response.link;
        } else {
          if ($response.errorMessage) {
            he_show_message($response.errorMessage, 'error');
          }
          if ($response.code == 1) {
            for (var i = 0; i < $response.errorItems.length; i++) {
              var id = 'store-cart-product-' + $response.errorItems[i];
              var $item = $(id);
              $item.setStyle('opacity', '0.5');
            }
          }
        }
      }
    }).send();
  };
</script>

<script type="text/javascript">
  product_manager.widget_url = "<?php echo $this->url(array('controller'=>'cart'), 'store_extended', true);?>";
  product_manager.widget_element = '.he-items';
  store_cart.prices_url = "<?php echo $this->url(array('controller' => 'cart', 'action' => 'price'), 'store_extended', true);?>";
</script>

<?php if ($this->details): ?>
  <div class="shipping-details">
    <span class="float_left"><?php echo $this->translate('Shipping Details'); ?>&nbsp;</span>
    <?php if (isset($this->details['zip'])): ?>
      <span class="float_left">
        <?php
        echo $this->details['first_name'] . ' ' . $this->details['last_name'] . "<br />" .
          $this->details['address_line_1'] . (($this->details['address_line_2']) ? $this->translate(' or ') . $this->details['address_line_2'] : '') . "<br />" .
          $this->details['city'] . ', ' . $this->region . ' ' . $this->details['zip'] . ', ' . $this->country . "<br />" .
          $this->details['phone'] . (($this->details['phone_extension']) ? $this->translate(' or ') . $this->details['phone_extension'] : '');
        ?>
      </span>
    <?php endif; ?>
    <?php
    echo $this->htmlLink(array(
        'route' => 'store_extended',
        'controller' => 'cart',
        'action' => 'details'),
      '<i class="hei hei-pencil-square-o"></i>',
      array(
        'class' => 'smoothbox float_right',
        'title' => $this->translate("Edit")
      ));
    ?>
  </div>
<?php endif; ?>

<div class="generic_layout_container layout_middle">
  <?php echo $this->render('cart/_browse_list.tpl'); ?>
</div>