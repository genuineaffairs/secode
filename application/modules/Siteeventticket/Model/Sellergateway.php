<?php

/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Siteeventticket
 * @copyright  Copyright 2015-2016 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: Sellergateway.php 2015-05-11 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
class Siteeventticket_Model_Sellergateway extends Core_Model_Item_Abstract {

    protected $_searchTriggers = false;
    protected $_modifiedTriggers = false;

    /**
     * @var Engine_Payment_Plugin_Abstract
     */
    protected $_plugin;

    /**
     * Get the payment plugin
     *
     * @return Engine_Payment_Plugin_Abstract
     */
    public function getPlugin() {
        if (null === $this->_plugin) {
  
            if(Engine_Api::_()->hasModuleBootstrap('sitegateway') && strstr($this->plugin, 'Sitegateway_Plugin_Gateway_')) {
                $class = $this->plugin;
            }
            else {
                $class = "Siteeventticket_Plugin_Gateway_PayPal";
            }            
            
            Engine_Loader::loadClass($class);
            $plugin = new $class($this);

            if (!($plugin instanceof Engine_Payment_Plugin_Abstract)) {
                throw new Engine_Exception(sprintf('Payment plugin "%1$s" must ' .
                        'implement Engine_Payment_Plugin_Abstract', $class));
            }
            $this->_plugin = $plugin;
        }
        return $this->_plugin;
    }

    /**
     * Get the payment gateway
     * 
     * @return Engine_Payment_Gateway
     */
    public function getGateway() {
        return $this->getPlugin()->getGateway();
    }

    /**
     * Get the payment service api
     * 
     * @return Zend_Service_Abstract
     */
    public function getService() {
        return $this->getPlugin()->getService();
    }

}
