<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Heevent
 * @copyright  Copyright Hire-Experts LLC
 * @license    http://www.hire-experts.com
 * @version    $Id: IpnController.php 2012-09-01 17:22:12 taalay $
 * @author     Taalay
 */

/**
 * @category   Application_Extensions
 * @package    Heevent
 * @copyright  Copyright Hire-Experts LLC
 * @license    http://www.hire-experts.com
 */
    
class Heevent_IpnController extends Core_Controller_Action_Standard
{
  public function __call($method, array $arguments)
  {
    $params = $this->_getAllParams();
    $gatewayType = $params['action'];
    $gatewayId = ( !empty($params['gateway_id']) ? $params['gateway_id'] : null );
		unset($params['module']);
    unset($params['controller']);
    unset($params['action']);
    unset($params['rewrite']);
    unset($params['gateway_id']);
    if( !empty($gatewayType) && 'index' !== $gatewayType ) {
      $params['gatewayType'] = $gatewayType;
    } else {
      $gatewayType = null;
    }

    // Log ipn
    $ipnLogFile = APPLICATION_PATH . '/temporary/log/hevent-payment-ipn.log';
    file_put_contents($ipnLogFile,
        date('c') . ': ' .
        print_r($params, true),
        FILE_APPEND);

    // Get gateways
    $gatewayTable = Engine_Api::_()->getDbtable('gateways', 'payment');
    $gateways = $gatewayTable->fetchAll(array('enabled = ?' => 1));

    // Try to detect gateway
    $activeGateway = null;
    foreach( $gateways as $gateway ) {
      $gatewayPlugin = $gateway->getPlugin();

      // Action matches end of plugin
      if( $gatewayType &&
          substr(strtolower($gateway->plugin), - strlen($gatewayType)) == strtolower($gatewayType) ) {
        $activeGateway = $gateway;
      } else if( $gatewayId && $gatewayId == $gateway->gateway_id ) {
        $activeGateway = $gateway;
      } else if( method_exists($gatewayPlugin, 'detectIpn') &&
          $gatewayPlugin->detectIpn($params) ) {
        $activeGateway = $gateway;
      }
    }

    // Gateway could not be detected
    if( !$activeGateway ) {
      echo 'ERR';
      exit();
    }

    // Validate ipn
    $gateway = $activeGateway;
    $gatewayPlugin = $gateway->getPlugin();

		// Get Credit gateway plugin
		$str = str_replace('Payment', 'Heevent', get_class($gatewayPlugin));

		/**
		 * @var $gatewayPlugin Credit_Plugin_Gateway_PayPal
		 */
		$gatewayPlugin = new $str( $gateway );


    try {
      $ipn = $gatewayPlugin->createIpn($params);
    } catch( Exception $e ) {
      // IPN validation failed
      if( 'development' == APPLICATION_ENV ) {
        echo $e;
      }
      echo 'ERR';
      exit();
    }

    
    // Process IPN
    try {
      $gatewayPlugin->onIpn($ipn);
    } catch( Exception $e ) {
      $gatewayPlugin->getGateway()->getLog()->log($e, Zend_Log::ERR);
      // IPN validation failed
      if( 'development' == APPLICATION_ENV ) {
        echo $e;
      }
      echo 'ERR';
      exit();
    }

    // Exit
    echo 'OK';
    exit();
  }
}