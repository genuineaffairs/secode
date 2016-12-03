<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Store
 * @copyright  Copyright Hire-Experts LLC
 * @license    http://www.hire-experts.com
 * @version    $Id: transactions.tpl 2011-09-21 17:53 mirlan $
 * @author     Mirlan
 */
?>

<div class="layout_left">
    <?php if (!$this->isPublic): ?>
        <div id='panel_options'>
            <?php // This is rendered by application/modules/core/views/scripts/_navIcons.tpl
            echo $this->navigation()
                ->menu()
                ->setContainer($this->navigation)
                ->setPartial(array('_navIcons.tpl', 'core'))
                ->render()
            ?>
        </div>
    <?php endif; ?>
</div>

<script type="text/javascript">
  var currentOrder = '<?php echo $this->filterValues['order'] ?>';
  var currentOrderDirection = '<?php echo $this->filterValues['direction'] ?>';
  var changeOrder = function (order, default_direction) {
    // Just change direction
    if (order == currentOrder) {
      $('direction').value = ( currentOrderDirection == 'ASC' ? 'DESC' : 'ASC' );
    } else {
      $('order').value = order;
      $('direction').value = default_direction;
    }
    $('search_form').submit();
  }
</script>


<div class="layout_middle">

  <div class="he-items">
    <h3>
      <?php echo $this->translate('My Purchases'); ?>
    </h3>

    <p class="flying-text-imp">
      <?php echo $this->translate('STORE_VIEWS_SCRIPTS_PURCHASES_DESCRIPTION') ?>
    </p>

    <?php if ($this->paginator->count() > 0): ?>

<div class="he-item-list-bg">

    <div><?php echo $this->filterForm->render($this);?></div>

    <div class="store-list-result">
      <div>
        <?php $count = $this->paginator->getTotalItemCount() ?>
        <?php echo $this->translate(array("%s purchase is found.", "%s purchases are found.", $count),
        $this->locale()->toNumber($count)) ?>
      </div>
    </div>

    <br/>

    <table class='table store-product-list'>
      <thead>
        <tr>
          <th style="width: 1%"><a href="javascript:void(0);"
                                   onclick="javascript:changeOrder('order_id', 'ASC');"><?php echo $this->translate("ID") ?></a>
          </th>
          <th><?php echo $this->translate("Order Key") ?></th>
          <th style="width: 1%"><a href="javascript:void(0);"
                                   onclick="javascript:changeOrder('status', 'ASC');"><?php echo $this->translate("Status") ?></a>
          </th>
          <th style="width: 1%"><a href="javascript:void(0);"
                                   onclick="javascript:changeOrder('total_amt', 'ASC');"><?php echo $this->translate("Total Gross Amount") ?></a>
          </th>
          <th style="width: 1%"><a href="javascript:void(0);"
                                   onclick="javascript:changeOrder('gateway_title', 'ASC');"><?php echo $this->translate("Gateway") ?></a>
          </th>
          <th><a href="javascript:void(0);"
                 onclick="javascript:changeOrder('payment_date', 'ASC');"><?php echo $this->translate("Date") ?></a></th>
          <th style="width: 1%"><?php echo $this->translate('Options'); ?></th>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($this->paginator as $item): ?>
          <tr>
            <td><?php echo $item->order_id; ?></td>
            <td class="request-key"><?php echo $item->ukey; ?></td>
            <td><?php echo $this->translate(ucfirst($item->status)); ?></td>
            <td>
              <?php if ($item->via_credits) : ?>
                <span class="store_credit_icon">
                  <span class="store-credit-price"><?php echo $this->api->getCredits($item->total_amt); ?></span>
                </span>
              <?php else : ?>
                <span class="store-price">
                  <?php echo str_replace("US$","OGV",$this->locale()->toCurrency($item->total_amt, $item->currency)); ?>
                </span>
              <?php endif; ?>
            </td>
            <td>
              <?php if (isset($this->gateways[$item->gateway_id])): ?>
                <?php echo str_replace("Credit","OGV",$this->gateways[$item->gateway_id]->getTitle()); ?>
              <?php else: ?>
              	<?php if ($item->gateway_id == '99') :?>
	        		<?php echo $this->translate('Item'); ?>
	        	<?php else:?>
	            	<?php echo $this->translate('Unknown Gateway'); ?>
	            <?php endif;?>
              <?php endif; ?>
            </td>
            <td>
              <?php echo $this->timestamp($item->payment_date); ?>
            </td>
            <td><?php echo $this->htmlLink(array('route'   => 'store_purchase',
                                                 'order_id'=> $item->ukey), $this->translate('Details'), array()); ?>
            </td>
          </tr>
        <?php endforeach; ?>
      </tbody>
    </table>

    <br/>


    <?php else: ?>
      <div class="tip"><span><?php echo $this->translate("STORE_There is no purchases"); ?></span></div>
    <?php endif; ?>
  </div>
</div>

    <div>
      <?php echo $this->paginationControl($this->paginator, null, null, array(
        'query'       => $this->filterValues,
        'pageAsQuery' => true,
      )); ?>
    </div>

</div>


