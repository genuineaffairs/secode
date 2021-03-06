<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Store
 * @copyright  Copyright Hire-Experts LLC
 * @license    http://www.hire-experts.com
 * @version    $Id: manifest.php 2011-08-19 17:07:11 mirlan $
 * @author     Mirlan
 */

/**
 * @category   Application_Extensions
 * @package    Store
 * @copyright  Copyright Hire-Experts LLC
 * @license    http://www.hire-experts.com
 */

return array(
  'package' => array(
    'type' => 'module',
    'name' => 'store',
    'version' => '4.3.2p2',
    'path' => 'application/modules/Store',
    'title' => 'Store',
    'description' => 'Store Plugin from Hire-Express LLC',
    'author' => '<a href="http://www.hire-experts.com" title="Hire-Experts LLC" target="_blank">Hire-Experts LLC</a>',
    'meta' => array(
      'title' => 'Store',
      'description' => 'Store Plugin from Hire-Express LLC',
      'author' => '<a href="http://www.hire-experts.com" title="Hire-Experts LLC" target="_blank">Hire-Experts LLC</a>',
    ),
    'dependencies' => array(
      array(
        'type' => 'module',
        'name' => 'core',
        'minVersion' => '4.1.8',
      ),
      array(
        'type' => 'module',
        'name' => 'hecore',
        'minVersion' => '4.2.4p1',
      ),
    ),
    'callback' => array(
      'path' => 'application/modules/Store/settings/install.php',
      'class' => 'Store_Installer',
    ),
    'actions' => array(
      'install',
      'upgrade',
      'refresh',
      'enable',
      'disable',
    ),
    'directories' => array(
      'application/modules/Store',
      'application/libraries/Experts',
    ),
    'files' => array(
      'application/languages/en/store.csv',
    ),
  ),
  // Items ---------------------------------------------------------------------
  'items' => array(
    'store_product',
    'store_photo',
    'store_order',
    'store_orderitem',
    'store_cart',
    'store_cartitem',
    'store_location',
    'store_gateway',
    'store_request',
    'store_balance',
    'store_video',
    'store_brequest'
  ),
  // Hooks ---------------------------------------------------------------------
  'hooks' => array(
    array(
      'event' => 'onRenderLayoutDefault',
      'resource' => 'Store_Plugin_Core',
    ),
  ),
  // Routes --------------------------------------------------------------------
  'routes' => array(
    'store_extended' => array(
      'route' => 'store/:controller/:action/*',
      'defaults' => array(
        'module' => 'store',
        'controller' => 'index',
        'action' => 'index',
      ),
      'reqs' => array(
        'controller' => '\D+',
        'action' => '\D+',
      ),
    ),

    'store_general' => array(
      'route' => 'store/:action/:page/*',
      'defaults' => array(
        'module' => 'store',
        'controller' => 'index',
        'action' => 'index',
        'page' => 1,
      ),
      'reqs' => array(
        'page' => '\d+',
        'cat' => '\d+',
        'sub_cat' => '\d+',
        'action' => '(index|products|stores|faq)'
      ),
    ),

    'store_download' => array(
      'route' => 'store/download/:id',
      'defaults' => array(
        'module' => 'store',
        'controller' => 'index',
        'action' => 'download',
      ),
      'reqs' => array(
        'id' => '\d+',
      )
    ),

    'store_download_free' => array(
      'route' => 'store/download-free/:id',
      'defaults' => array(
        'module' => 'store',
        'controller' => 'index',
        'action' => 'download',
        'free' => true
      ),
      'reqs' => array(
        'id' => '\d+',
      )
    ),

    'store_profile' => array(
      'route' => 'store/product/:product_id/:title/*',
      'defaults' => array(
        'module' => 'store',
        'controller' => 'product',
        'action' => 'index',
      ),
      'reqs' => array(
        'product_id' => '\d+'
      )
    ),

    'store_specific' => array(
      'route' => 'store/product/:action/:product_id/*',
      'defaults' => array(
        'module' => 'store',
        'controller' => 'product',
        'action' => 'index',
      ),
      'reqs' => array(
        'action' => '(index|edit|delete|join|leave|cancel|accept|invite|style)',
        'product_id' => '\d+',
      )
    ),

    'store_panel' => array(
      'route' => 'store/panel/:action/*',
      'defaults' => array(
        'module' => 'store',
        'controller' => 'panel',
        'action' => 'index',
      ),
    ),


    'store_purchase' => array(
      'route' => 'store/panel/purchase/:order_id',
      'defaults' => array(
        'module' => 'store',
        'controller' => 'panel',
        'action' => 'purchase',
      ),
    ),

    'store_transaction_profile' => array(
      'route' => 'store/transaction/:order_id',
      'defaults' => array(
        'module' => 'store',
        'controller' => 'transaction',
        'action' => 'index',
      ),
    ),

    'store_transaction' => array(
      'route' => 'store/transaction/:action/*',
      'defaults' => array(
        'module' => 'store',
        'controller' => 'transaction',
        'action' => 'index',
      ),
      'reqs' => array(
        'action' => '(index|info|gateway|process|return|finish)',
      )
    ),


    'store_page' => array(
      'route' => 'page-store/:action/*',
      'defaults' => array(
        'module' => 'store',
        'controller' => 'page',
        'action' => 'index'
      )
    ),

    'store_statistics' => array(
      'route' => 'store/statistics/:action/:page_id/*',
      'defaults' => array(
        'module' => 'store',
        'controller' => 'statistics',
        'action' => 'chart',
      ),
      'reqs' => array(
        'action' => '(chart|list|chart-data)',
        'page_id' => '\d+',
      )
    ),

    'store_products' => array(
      'route' => 'store/products/:action/*',
      'defaults' => array(
        'module' => 'store',
        'controller' => 'products',
      ),
      'reqs' => array(
        'action' => '(create|edit|delete|copy)',
      )
    ),

    'store_settings' => array(
      'route' => 'store/:controller/:action/:page_id/*',
      'defaults' => array(
        'module' => 'store',
        'controller' => 'settings',
        'action' => 'index',
      ),
      'reqs' => array(
        'controller' => '(settings|locations)',
        'action' => '(index|add|edit|remove|gateway|gateway-edit)',
      )
    ),
    
    'store_cart' => array(
      'route' => 'store/cart/:action/:product_id/*',
      'defaults' => array(
        'module' => 'store',
        'controller' => 'cart',
        'action' => 'checkout',
      ),
    ),
    
    'store_checkout_product' => array(
      'route' => 'store/cart/checkout/:product_id/*',
      'defaults' => array(
        'module' => 'store',
        'controller' => 'cart',
        'action' => 'checkout',
      ),
    ),
    
	'store_request' => array(
      'route' => 'store/request/:action/:id/*',
      'defaults' => array(
        'module' => 'store',
        'controller' => 'request',
        'action' => 'index',
      ),
    ),
    
	
	
    /*'store_product_locations' => array(
      'route' => 'store/product-locations/:action/:product_id/*',
      'defaults' => array(
        'module' => 'store',
        'controller' => 'product-locations',
        'action' => 'index',
      ),
      'reqs' => array(
        'action' => '(index|add|edit|remove)',
      )
    )*/
  )
); ?>