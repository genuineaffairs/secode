<?php
/**
 * SocialEngine
 *
 * @category   Application_Core
 * @package    Payment
 * @copyright  Copyright 2006-2010 Webligo Developments
 * @license    http://www.socialengine.net/license/
 * @version    $Id: index.tpl 9673 2012-04-11 22:49:36Z richard $
 * @author     John Boehr <j@webligo.com>
 */
?>

  <h2>
    <?php echo $this->translate("Transactions") ?>
  </h2>
<?php if( count($this->navigation) ): ?>
  <div class='tabs'>

    <?php
    // Render the menu
    //->setUlClass()
    echo $this->navigation()->menu()->setContainer($this->navigation)->render()
    ?>
  </div>
<?php endif; ?>



  <p>
    <?php echo $this->translate("PAYMENT_VIEWS_ADMIN_INDEX_INDEX_DESCRIPTION") ?>
  </p>

  <br />


<?php if( !empty($this->error) ): ?>
  <ul class="form-errors">
    <li>
      <?php echo $this->error ?>
    </li>
  </ul>

  <br />
  <?php return; endif; ?>


<?php if( $this->paginator->getTotalItemCount() > 0 ): ?>
  <div class='admin_search'>
    <?php echo $this->formFilter->render($this) ?>
    <?php echo $this->formRefund->render() ?>
  </div>

  <br />
<?php endif; ?>


  <script type="text/javascript">
    var currentOrder = '<?php echo $this->filterValues['order'] ?>';
    var currentOrderDirection = '<?php echo $this->filterValues['direction'] ?>';
    var changeOrder = function(order, default_direction){
      // Just change direction
      if( order == currentOrder ) {
        $('direction').value = ( currentOrderDirection == 'ASC' ? 'DESC' : 'ASC' );
      } else {
        $('order').value = order;
        $('direction').value = default_direction;
      }
      $('filter_form').submit();
    }
    var refund = function(id){
      if (confirm("Are sure refund this transaction?")) {
        $('refund_id').value = id;
        setTimeout(function(){
          $('refund_form').submit();
        },1000)


      }
    }
  </script>


  <div class='admin_results'>
    <div>
      <?php $count = $this->paginator->getTotalItemCount() ?>
      <?php echo $this->translate(array("%s transaction found", "%s transactions found", $count), $count) ?>
    </div>
    <div>
      <?php echo $this->paginationControl($this->paginator, null, null, array(
        'query' => $this->filterValues,
        'pageAsQuery' => true,
      )); ?>
    </div>
  </div>

  <br />


<?php if( $this->paginator->getTotalItemCount() > 0 ): ?>
  <table class='admin_table'>
    <thead>
    <tr>
      <?php $class = ( $this->order == 'transaction_id' ? 'admin_table_ordering admin_table_direction_' . strtolower($this->direction) : '' ) ?>
      <th style='width: 1%;' class="<?php echo $class ?>">
        <a href="javascript:void(0);" onclick="javascript:changeOrder('transaction_id', 'DESC');">
          <?php echo $this->translate("ID") ?>
        </a>
      </th>
      <?php $class = ( $this->order == 'user_id' ? 'admin_table_ordering admin_table_direction_' . strtolower($this->direction) : '' ) ?>
      <th style='width: 1%;' class="<?php echo $class ?>">
        <a href="javascript:void(0);" onclick="javascript:changeOrder('user_id', 'ASC');">
          <?php echo $this->translate("Member") ?>
        </a>
      </th>
      <?php $class = ( $this->order == 'gateway_id' ? 'admin_table_ordering admin_table_direction_' . strtolower($this->direction) : '' ) ?>
      <th style='width: 1%;' class='admin_table_centered <?php echo $class ?>'>
        <a href="javascript:void(0);" onclick="javascript:changeOrder('gateway_id', 'ASC');">
          <?php echo $this->translate("Gateway") ?>
        </a>
      </th>
      <?php $class = ( $this->order == 'event_id' ? 'admin_table_ordering admin_table_direction_' . strtolower($this->direction) : '' ) ?>
      <th style='width: 1%;' class='admin_table_centered <?php echo $class ?>'>
        <a href="javascript:void(0);" onclick="javascript:changeOrder('event_id', 'ASC');">
          <?php echo $this->translate("Event") ?>
        </a>
      </th>
      <?php $class = ( $this->order == 'page_id' ? 'admin_table_ordering admin_table_direction_' . strtolower($this->direction) : '' ) ?>
      <th style='width: 1%;' class='admin_table_centered <?php echo $class ?>'>
        <a href="javascript:void(0);" onclick="javascript:changeOrder('page_id', 'ASC');">
          <?php echo $this->translate("Owner") ?>
        </a>
      </th>
      <?php $class = ( $this->order == 'state' ? 'admin_table_ordering admin_table_direction_' . strtolower($this->direction) : '' ) ?>
      <th style='width: 1%;' class='admin_table_centered <?php echo $class ?>'>
        <a href="javascript:void(0);" onclick="javascript:changeOrder('state', 'DESC');">
          <?php echo $this->translate("State") ?>
        </a>
      </th>
      <?php $class = ( $this->order == 'amount' ? 'admin_table_ordering admin_table_direction_' . strtolower($this->direction) : '' ) ?>
      <th style='width: 1%;' class='admin_table_centered <?php echo $class ?>'>
        <a href="javascript:void(0);" onclick="javascript:changeOrder('amount', 'DESC');">
          <?php echo $this->translate("Amount") ?>
        </a>
      </th>
      <?php $class = ( $this->order == 'timestamp' ? 'admin_table_ordering admin_table_direction_' . strtolower($this->direction) : '' ) ?>
      <th style='width: 1%;' class='admin_table_centered <?php echo $class ?>'>
        <a href="javascript:void(0);" onclick="javascript:changeOrder('timestamp', 'DESC');">
          <?php echo $this->translate("Date") ?>
        </a>
      </th>
      <th style='width: 1%;' class='admin_table_options'>
        <?php echo $this->translate("Options") ?>
      </th>
      <th style='width: 1%;' class='admin_table_options'>
        <?php echo $this->translate("Refund") ?>
      </th>
    </tr>
    </thead>
    <tbody>
    <?php foreach( $this->paginator as $item ):
      $user = @$this->users[$item->user_id];
      $order = @$this->orders[$item->order_id];
      $event = @ Engine_Api::_()->getItem('event', $item->event_id);
      $gateway = @$this->gateways[$item->gateway_id];
      ?>
      <tr>
        <td><?php echo $item->transaction_id ?></td>
        <td class='admin_table_bold'>
          <?php echo ( $user ? $user->__toString() : '<i>' . $this->translate('Deleted or Unknown Member') . '</i>' ) ?>
        </td>
        <td class='center'>
          <?php echo ($gateway ? $gateway->title : $this->translate('Credits')) ?>
        </td>
        <td class='center'>
          <?php echo ($event) ? $this->htmlLink($event->getHref(), $event->getTitle(), array()) : 'Deleted item'; ?>
        </td>
        <td class='center'>
          <?php
         if ($event) {
            echo $this->htmlLink($event->getOwner()->getHref(), $event->getOwner()->getTitle(), array());
          } else {
            echo '-';
          }
          ?>
        </td>
        <td class='center'>
          <?php echo $this->translate(ucfirst($item->state)) ?>
        </td>
        <td class='center'>
          <?php if ($item->gateway_id) : ?>
            <?php echo $this->locale()->toCurrency($item->amount, $item->currency) ?>
            <?php echo $this->translate('(%s)', $item->currency) ?>
          <?php else : ?>
            <?php echo Engine_Api::_()->event()->getCredits($item->amount); ?>
            <?php echo $this->translate('(%s)', $this->translate('Credits')) ?>
          <?php endif; ?>
        </td>
        <td>
          <?php echo $this->locale()->toDateTime($item->timestamp) ?>
        </td>
        <td class='admin_table_options'>
          <a class="smoothbox" href='<?php echo $this->url(array('action' => 'detail', 'transaction_id' => $item->transaction_id));?>'>
            <?php echo $this->translate("details") ?>
          </a>
        <td class='admin_table_options'>
          <div class="buttons">
            <?php if($item->state == 'refunded'){
              ?>
              <button id="refund" type="button" name="refund" style="background-color:lightgray; color: darkgray;border: 1px solid gray;"><?php echo $this->translate("Refunded") ?></button>
            <?php
            }else{
              ?>
              <button id="refund" type="button" name="refund" onclick="javascript:refund('<?php echo $item->transaction_id ?>');"> <?php echo $this->translate("Refund") ?></button>
            <?php
            }?>

          </div>
        </td>
      </tr>
    <?php endforeach; ?>
    </tbody>
  </table>
<?php endif; ?>