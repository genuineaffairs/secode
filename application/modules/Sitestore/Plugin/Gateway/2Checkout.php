<?php

/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitestore
 * @copyright  Copyright 2012-2013 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: 2Checkout.php 2013-09-02 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
class Sitestore_Plugin_Gateway_2Checkout extends Engine_Payment_Plugin_Abstract {

  protected $_gatewayInfo;
  protected $_gateway;

  /**
   * Constructor
   */
  public function __construct(Zend_Db_Table_Row_Abstract $gatewayInfo) {
    $this->_gatewayInfo = $gatewayInfo;
  }

  /**
   * Get the service API
   *
   * @return Engine_Service_2Checkout
   */
  public function getService() {
    return $this->getGateway()->getService();
  }

  /**
   * Get the gateway object
   *
   * @return Engine_Payment_Gateway_2Checkout
   */
  public function getGateway() {
    if (null == $this->_gateway) {
      $class = 'Engine_Payment_Gateway_2Checkout';
      Engine_Loader::loadClass($class);
      $gateway = new $class(array(
                  'config' => (array) $this->_gatewayInfo->config,
                  'testMode' => $this->_gatewayInfo->test_mode,
                  'currency' => Engine_Api::_()->getApi('settings', 'core')->getSetting('payment.currency', 'USD'),
          ));
      if (!($gateway instanceof Engine_Payment_Gateway)) {
        $error_msg = Zend_Registry::get('Zend_Translate')->_('Plugin class not instance of Engine_Payment_Gateway');
        throw new Engine_Exception($error_msg);
      }
      $this->_gateway = $gateway;
    }

    return $this->_gateway;
  }

  // Actions

  /**
   * Create a transaction object from specified parameters
   *
   * @return Engine_Payment_Transaction
   */
  public function createTransaction(array $params) {
    $transaction = new Engine_Payment_Transaction($params);
    $transaction->process($this->getGateway());
    return $transaction;
  }

  /**
   * Create an ipn object from specified parameters
   *
   * @return Engine_Payment_Ipn
   */
  public function createIpn(array $params) {
    $ipn = new Engine_Payment_Ipn($params);
    $ipn->process($this->getGateway());
    return $ipn;
  }

  public function detectIpn(array $params) {
    $expectedCommonParams = array(
            'message_type', 'message_description', 'timestamp', 'md5_hash',
            'message_id', 'key_count', 'vendor_id',
    );

    foreach ($expectedCommonParams as $key) {
      if (!isset($params[$key])) {
        return false;
      }
    }

    return true;
  }

  // SE Specific

  /**
   * Create a transaction for a subscription
   *
   * @param User_Model_User $user
   * @param Zend_Db_Table_Row_Abstract $subscription
   * @param Zend_Db_Table_Row_Abstract $package
   * @param array $params
   * @return Engine_Payment_Gateway_Transaction
   */
  public function createSubscriptionTransaction(User_Model_User $user, Zend_Db_Table_Row_Abstract $subscription, Payment_Model_Package $package, array $params = array()) {

  }

  public function createStoreTransaction(User_Model_User $user, Zend_Db_Table_Row_Abstract $store, Sitestore_Model_Package $package, array $params = array()) {
    // Do stuff to params
    $params['fixed'] = true;
    $params['skip_landing'] = true;

    // Lookup product id for this subscription
    $productInfo = $this->getService()->detailVendorProduct($package->getGatewayIdentity());
    $params['product_id'] = $productInfo['product_id'];
    $params['quantity'] = 1;

    // Create transaction
    $transaction = $this->createTransaction($params);

    return $transaction;
  }

  /**
   * Process return of subscription transaction
   *
   * @param Payment_Model_Order $order
   * @param array $params
   */
  public function onSubscriptionTransactionReturn(
  Payment_Model_Order $order, array $params = array()) {

  }

  public function onStoreTransactionReturn(
  Payment_Model_Order $order, array $params = array()) {
    // Check that gateways match
    if ($order->gateway_id != $this->_gatewayInfo->gateway_id) {
      $error_msg1 = Zend_Registry::get('Zend_Translate')->_('Gateways do not match');
      throw new Engine_Payment_Plugin_Exception($error_msg1);
    }

    // Get related info
    $user = $order->getUser();
    $store = $order->getSource();
    $package = $store->getPackage();

    // Check subscription state
    if (/* $store->status == 'active' || */
        $store->status == 'trial') {
      return 'active';
    } else
    if ($store->status == 'pending') {
      return 'pending';
    }

    // Let's log it
    $this->getGateway()->getLog()->log('Return: '
        . print_r($params, true), Zend_Log::INFO);

    // Check for processed
    if (empty($params['credit_card_processed'])) {
      // This is a sanity error and cannot produce information a user could use
      // to correct the problem.
      $error_msg2 = Zend_Registry::get('Zend_Translate')->_('There was an error processing your transaction. Please try again later.');
      throw new Payment_Model_Exception($error_msg2);
    }
    // Ensure product ids match
    if ($params['merchant_product_id'] != $package->getGatewayIdentity()) {
      // This is a sanity error and cannot produce information a user could use
      // to correct the problem.
      $error_msg3 = Zend_Registry::get('Zend_Translate')->_('There was an error processing your transaction. Please try again later.');
      throw new Payment_Model_Exception($error_msg3);
    }
    // Ensure order ids match
    if ($params['order_id'] != $order->order_id &&
        $params['merchant_order_id'] != $order->order_id) {
      // This is a sanity error and cannot produce information a user could use
      // to correct the problem.
      $error_msg4 = Zend_Registry::get('Zend_Translate')->_('There was an error processing your transaction. Please try again later.');
      throw new Payment_Model_Exception($error_msg4);
    }
    // Ensure vendor ids match
    if ($params['sid'] != $this->getGateway()->getVendorIdentity()) {
      // This is a sanity error and cannot produce information a user could use
      // to correct the problem.
      $error_msg5 = Zend_Registry::get('Zend_Translate')->_('There was an error processing your transaction. Please try again later.');
      throw new Payment_Model_Exception($error_msg5);
    }

    // Validate return
    try {
      $this->getGateway()->validateReturn($params);
    } catch (Exception $e) {
      if (!$this->getGateway()->getTestMode()) {
        // This is a sanity error and cannot produce information a user could use
        // to correct the problem.
        $error_msg6 = Zend_Registry::get('Zend_Translate')->_('There was an error processing your transaction. Please try again later.');
        throw new Payment_Model_Exception($error_msg6);
      } else {
        echo $e; // For test mode
      }
    }

    // @todo process total?
    // Update order with profile info and complete status?
    $order->state = 'complete';
    $order->gateway_order_id = $params['order_number'];
    $order->save();

    // Transaction is inserted on IPN since it doesn't send the amount back
    // Get benefit setting
    $giveBenefit = Engine_Api::_()->getDbtable('transactions', 'sitestore')
            ->getBenefitStatus($user);

    // Enable now
    if ($giveBenefit) {

      // Update subscription
      $store->gateway_id = $this->_gatewayInfo->gateway_id;
      $store->gateway_profile_id = $params['order_number']; // This is the same as sale_id
      $store->onPaymentSuccess();

      // send notification
      if ($store->didStatusChange()) {
        Engine_Api::_()->sitestore()->sendMail("ACTIVE", $store->store_id);
      }

      return 'active';
    }

    // Enable later
    else {

      // Update subscription
      $store->gateway_id = $this->_gatewayInfo->gateway_id;
      $store->gateway_profile_id = $params['order_number']; // This is the same as sale_id
      $store->onPaymentPending();

      // send notification
      if ($store->didStatusChange()) {
        Engine_Api::_()->sitestore()->sendMail("PENDING", $store->store_id);
      }

      return 'pending';
    }
  }

  /**
   * Process ipn of subscription transaction
   *
   * @param Payment_Model_Order $order
   * @param Engine_Payment_Ipn $ipn
   */
  public function onSubscriptionTransactionIpn(
  Payment_Model_Order $order, Engine_Payment_Ipn $ipn) {

  }

  /**
   * Process ipn of store transaction
   *
   * @param Payment_Model_Order $order
   * @param Engine_Payment_Ipn $ipn
   */
  public function onStoreTransactionIpn(
  Payment_Model_Order $order, Engine_Payment_Ipn $ipn) {
    // Check that gateways match
    if ($order->gateway_id != $this->_gatewayInfo->gateway_id) {
      $error_msg7 = Zend_Registry::get('Zend_Translate')->_('Gateways do not match');
      throw new Engine_Payment_Plugin_Exception($error_msg7);
    }

    // Get related info
    $user = $order->getUser();
    $store = $order->getSource();
    $package = $store->getPackage();

    // Get IPN data
    $rawData = $ipn->getRawData();

    // Get tx table
    $transactionsTable = Engine_Api::_()->getDbtable('transactions', 'sitestore');

    // Update subscription
    $storeUpdated = false;
    if (!empty($rawData['sale_id']) && empty($store->gateway_profile_id)) {
      $storeUpdated = true;
      $store->gateway_profile_id = $rawData['sale_id'];
    }
    if (!empty($rawData['invoice_id']) && empty($store->gateway_transaction_id)) {
      $storeUpdated = true;
      $store->gateway_profile_id = $rawData['invoice_id'];
    }
    if ($storeUpdated) {
      $store->save();
    }

    // switch message_type
    switch ($rawData['message_type']) {
      case 'ORDER_CREATED':
      case 'FRAUD_STATUS_CHANGED':
      case 'INVOICE_STATUS_CHANGED':
        // Check invoice and fraud status
        if (strtolower($rawData['invoice_status']) == 'declined' ||
            strtolower($rawData['fraud_status']) == 'fail') {
          // Payment failure
          $store->onPaymentFailure();
          // send notification
          if ($store->didStatusChange()) {
            Engine_Api::_()->sitestore()->sendMail("OVERDUE", $store->store_id);
          }
        } else if (strtolower($rawData['fraud_status']) == 'wait') {
          // This is redundant, the same thing is done upon return
          /*
            // Get benefit setting
            $giveBenefit = Engine_Api::_()->getDbtable('transactions', 'sitestore')->getBenefitStatus($user);
            if( $giveBenefit ) {
            $subscription->onPaymentSuccess();
            } else {
            $subscription->onPaymentPending();
            }
           *
           */
        } else {
          // Payment Success
          $store->onPaymentSuccess();
          // send notification
          if ($store->didStatusChange()) {
            Engine_Api::_()->sitestore()->sendMail("ACTIVE", $store->store_id);
          }
        }
        break;

      case 'REFUND_ISSUED':
        // Payment Refunded
        $store->onRefund();
        // send notification
        if ($store->didStatusChange()) {
          Engine_Api::_()->sitestore()->sendMail("REFUNDED", $store->store_id);
        }
        break;

      case 'RECURRING_INSTALLMENT_SUCCESS':
        $store->onPaymentSuccess();
        // send notification
        if ($store->didStatusChange()) {
          //  @todo sitestore_store_recurrence
          Engine_Api::_()->sitestore()->sendMail("RECURRENCE", $store->store_id);
        }
        break;

      case 'RECURRING_INSTALLMENT_FAILED':
        $store->onPaymentFailure();
        // send notification
        if ($store->didStatusChange()) {
          Engine_Api::_()->sitestore()->sendMail("OVERDUE", $store->store_id);
        }
        break;

      case 'RECURRING_STOPPED':
        $store->onCancel();
        // send notification
        if ($store->didStatusChange()) {
          Engine_Api::_()->sitestore()->sendMail("CANCELLED", $store->store_id);
        }
        break;

      case 'RECURRING_COMPLETE':
        $store->onExpiration();
        // send notification
        if ($store->didStatusChange()) {
          Engine_Api::_()->sitestore()->sendMail("EXPIRED", $store->store_id);
        }
        break;

      /*
        case 'RECURRING_RESTARTED':
        break;
       *
       */

      default:
        throw new Engine_Payment_Plugin_Exception(sprintf('Unknown IPN ' .
                'type %1$s', $rawData['message_type']));
        break;
    }

    return $this;
  }

  /**
   * Cancel a subscription (i.e. disable the recurring payment profile)
   *
   * @params $transactionId
   * @return Engine_Payment_Plugin_Abstract
   */
  public function cancelSubscription($transactionId) {
    return $this;
  }

  public function cancelStore($transactionId) {
    return $this;
  }

  /**
   * Generate href to a store detailing the order
   *
   * @param string $transactionId
   * @return string
   */
  public function getOrderDetailLink($orderId) {
    return 'https://www.2checkout.com/va/sales/detail?sale_id=' . $orderId;
  }

  /**
   * Generate href to a store detailing the transaction
   *
   * @param string $transactionId
   * @return string
   */
  public function getTransactionDetailLink($transactionId) {
    return 'https://www.2checkout.com/va/sales/get_list_sale_stored?invoice_id=' . $transactionId;
  }

  /**
   * Get raw data about an order or recurring payment profile
   *
   * @param string $orderId
   * @return array
   */
  public function getOrderDetails($orderId) {
    return $this->getService()->detailSale($orderId);
  }

  /**
   * Get raw data about a transaction
   *
   * @param $transactionId
   * @return array
   */
  public function getTransactionDetails($transactionId) {
    return $this->getService()->detailInvoice($transactionId);
  }

  // IPN

  /**
   * Process an IPN
   *
   * @param Engine_Payment_Ipn $ipn
   * @return Engine_Payment_Plugin_Abstract
   */
  public function onIpn(Engine_Payment_Ipn $ipn) {
    $rawData = $ipn->getRawData();

    $ordersTable = Engine_Api::_()->getDbtable('orders', 'payment');
    $transactionsTable = Engine_Api::_()->getDbtable('transactions', 'sitestore');


    // Find transactions -------------------------------------------------------
    $transactionId = null;
    $transaction = null;

    // Fetch by invoice_id
    if (!empty($rawData['invoice_id'])) {
      $transaction = $transactionsTable->fetchRow(array(
                  'gateway_id = ?' => $this->_gatewayInfo->gateway_id,
                  'gateway_transaction_id = ?' => $rawData['invoice_id'],
          ));
    }

    if ($transaction && !empty($transaction->gateway_transaction_id)) {
      $transactionId = $transaction->gateway_transaction_id;
    } else {
      $transactionId = @$rawData['invoice_id'];
    }



    // Fetch order -------------------------------------------------------------
    $order = null;

    // Get order by vendor_order_id
    if (!$order && !empty($rawData['vendor_order_id'])) {
      $order = $ordersTable->find($rawData['vendor_order_id'])->current();
    }

    // Get order by invoice_id
    if (!$order && $transactionId) {
      $order = $ordersTable->fetchRow(array(
                  'gateway_id = ?' => $this->_gatewayInfo->gateway_id,
                  'gateway_transaction_id = ?' => $transactionId,
          ));
    }

    // Get order by sale_id
    if (!$order && !empty($rawData['sale_id'])) {
      $order = $ordersTable->fetchRow(array(
                  'gateway_id = ?' => $this->_gatewayInfo->gateway_id,
                  'gateway_order_id = ?' => $rawData['sale_id'],
          ));
    }

    // Get order by order_id through transaction
    if (!$order && $transaction && !empty($transaction->order_id)) {
      $order = $ordersTable->find($transaction->order_id)->current();
    }

    // Update order with order/transaction id if necessary
    $orderUpdated = false;
    if (!empty($rawData['invoice_id']) && empty($order->gateway_transaction_id)) {
      $orderUpdated = true;
      $order->gateway_transaction_id = $rawData['invoice_id'];
    }
    if (!empty($rawData['sale_id']) && empty($order->gateway_order_id)) {
      $orderUpdated = true;
      $order->gateway_order_id = $rawData['sale_id'];
    }
    if ($orderUpdated) {
      $order->save();
    }

    // Process generic IPN data ------------------------------------------------
    // Build transaction info
    if (!empty($rawData['invoice_id'])) {
      $transactionData = array(
              'gateway_id' => $this->_gatewayInfo->gateway_id,
      );
      // Get timestamp
      if (!empty($rawData['payment_date'])) {
        $transactionData['timestamp'] = date('Y-m-d H:i:s', strtotime($rawData['timestamp']));
      } else {
        $transactionData['timestamp'] = new Zend_Db_Expr('NOW()');
      }
      // Get amount
      if (!empty($rawData['invoice_list_amount'])) {
        $transactionData['amount'] = $rawData['invoice_list_amount'];
      } else if ($transaction) {
        $transactionData['amount'] = $transaction->amount;
      } else if (!empty($rawData['item_list_amount_1'])) {
        // For recurring success
        $transactionData['amount'] = $rawData['item_list_amount_1'];
      }
      // Get currency
      if (!empty($rawData['list_currency'])) {
        $transactionData['currency'] = $rawData['list_currency'];
      } else if ($transaction) {
        $transactionData['currency'] = $transaction->currency;
      }
      // Get order/user
      if ($order) {
        $transactionData['user_id'] = $order->user_id;
        $transactionData['order_id'] = $order->order_id;
      }
      // Get transactions
      if ($transactionId) {
        $transactionData['gateway_transaction_id'] = $transactionId;
      }
      if (!empty($rawData['sale_id'])) {
        $transactionData['gateway_order_id'] = $rawData['sale_id'];
      }
      // Get payment_status
      if (!empty($rawData['invoice_status'])) {
        if ($rawData['invoice_status'] == 'declined') {
          $transactionData['type'] = 'payment';
          $transactionData['state'] = 'failed';
        } else if ($rawData['fraud_status'] == 'fail') {
          $transactionData['type'] = 'payment';
          $transactionData['state'] = 'failed-fraud';
        } else if ($rawData['fraud_status'] == 'wait') {
          $transactionData['type'] = 'payment';
          $transactionData['state'] = 'pending-fraud';
        } else {
          $transactionData['type'] = 'payment';
          $transactionData['state'] = 'okay';
        }
      }
      if ($transaction &&
          ($transaction->type == 'refund' || $transaction->state == 'refunded')) {
        $transactionData['type'] = $transaction->type;
        $transactionData['state'] = $transaction->state;
      }

      // Special case for refund_issued
      $childTransactionData = array();
      if ($rawData['message_type'] == 'REFUND_ISSUED') {
        $childTransactionData = $transactionData;
        $childTransactionData['gateway_parent_transaction_id'] = $childTransactionData['gateway_transaction_id'];
        //unset($childTransactionData['gateway_transaction_id']); // Should we unset this?
        $childTransactionData['amount'] = - $childTransactionData['amount'];
        $childTransactionData['type'] = 'refund';
        $childTransactionData['state'] = 'refunded';

        // Update parent transaction
        $transactionData['state'] = 'refunded';
      }

      // Insert or update transactions
      if (!$transaction) {
        $transactionsTable->insert($transactionData);          
      }
      // Update transaction
      else {
        unset($transactionData['timestamp']);
        $transaction->setFromArray($transactionData);
        $transaction->save();
      }

        if(Engine_Api::_()->hasModuleBootstrap('sitegateway')) {
            $transactionParams = array_merge($transactionData, array('resource_type' => $order->source_type));
            Engine_Api::_()->sitegateway()->insertTransactions($transactionParams);
        }       
      
      // Insert new child transaction
      if ($childTransactionData) {
        $childTransactionExists = $transactionsTable->select()
                ->from($transactionsTable, new Zend_Db_Expr('TRUE'))
                ->where('gateway_transaction_id = ?', $childTransactionData['gateway_transaction_id'])
                ->where('type = ?', $childTransactionData['type'])
                ->where('state = ?', $childTransactionData['state'])
                ->limit(1)
                ->query()
                ->fetchColumn();
        if (!$childTransactionExists) {
          $transactionsTable->insert($childTransactionData);
          
            if(Engine_Api::_()->hasModuleBootstrap('sitegateway')) {
                $transactionParams = array_merge($childTransactionData, array('resource_type' => $order->source_type));
                Engine_Api::_()->sitegateway()->insertTransactions($transactionParams);
            }             
        }
      }
    }

    // Process specific IPN data -----------------------------------------------
    if ($order) {
      // Subscription IPN
      if ($order->source_type == 'sitestore_store') {
        $this->onStoreTransactionIpn($order, $ipn);
        return $this;
      }
      // Unknown IPN
      else {
        $error_msg8 = Zend_Registry::get('Zend_Translate')->_('Unknown order type for IPN');
        throw new Engine_Payment_Plugin_Exception($error_msg8);
      }
    }
    // Missing order
    else {
      $error_msg9 = Zend_Registry::get('Zend_Translate')->_('Unknown or unsupported IPN type, or missing transaction or order ID');
      throw new Engine_Payment_Plugin_Exception($error_msg9);
    }
  }

  // Forms

  /**
   * Get the admin form for editing the gateway info
   *
   * @return Engine_Form
   */
  public function getAdminGatewayForm() {
    return new Payment_Form_Admin_Gateway_2Checkout();
  }

  public function processAdminGatewayForm(array $values) {
    // Should we get the vendor_id and secret word?
    $info = $this->getService()->detailCompanyInfo();
    $values['vendor_id'] = $info['vendor_id'];
    $values['secret'] = $info['secret_word'];
    return $values;
  }

}
?>