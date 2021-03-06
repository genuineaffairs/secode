<?php
	$calling_from = 0;
	$core_final_url = '';
	$db = $this->getDb();
	$select = new Zend_Db_Select($db);
	$select
		->from('engine4_core_modules')
		->where('name = ?', 'seaocore');
	$is_enabled = $select->query()->fetchObject();
	if( !empty($is_enabled) ) {
		$is_module_enabled = $is_enabled->enabled;
		if( !empty($is_module_enabled) ) {
			$curr_module_version = strcasecmp($is_enabled->version, $SocialEngineAddOns_version);
			if ( $curr_module_version >= 0 ) 
			{
				if( !empty($_PRODUCT_FINAL_FILE) ) {
					include_once APPLICATION_PATH . '/application/modules/' . $PLUGIN_TITLE . '/controllers/license/' . $_PRODUCT_FINAL_FILE;
				}
				$select = new Zend_Db_Select($db);						
				$select
					->from('engine4_seaocores')
					->where('module_name = ?', $PRODUCT_TYPE);
				$mod_info = $select->query()->fetchObject();

				$select = new Zend_Db_Select($db);
				$select
					->from('engine4_core_modules')
					->where('name = ?', $PRODUCT_TYPE);
				$currentmod_info = $select->query()->fetchObject();

				if( empty($currentmod_info) && !empty($mod_info->is_activate)) {
					$db->query('DELETE FROM `engine4_seaocores` WHERE `engine4_seaocores`.`module_name` = "' . $PRODUCT_TYPE . '" LIMIT 1');
					$mod_info = 0;
				}

				if( !empty($currentmod_info) && !empty($mod_info) && empty($mod_info->is_activate) ) {
					$db->query('UPDATE  `engine4_seaocores` SET  `is_activate` =  "1" WHERE  `engine4_seaocores`.`module_name` = "' . $PRODUCT_TYPE . '" LIMIT 1 ;');
				}

				if( !empty($currentmod_info) && !empty($mod_info) && empty($mod_info->is_installed) ) {
					$db->query('UPDATE  `engine4_seaocores` SET  `is_installed` =  "1" WHERE  `engine4_seaocores`.`module_name` = "' . $PRODUCT_TYPE . '" LIMIT 1 ;');
					$mod_info->is_installed = 1;
				}

				if( empty($mod_info) ) {
					$db->insert('engine4_seaocores', array(
						'module_name' => $PRODUCT_TYPE,
						'title' => $PLUGIN_TITLE,
						'description' => $PRODUCT_DESCRIPTION,
						'version' => $PLUGIN_VERSION,
						'is_installed' => 0,
						'category' => $PLUGIN_CATEGORY,
						'ptype' => $PRODUCT_TYPE,
					));
					$module_auth = 0;
				}

				if( !empty($mod_info) ) {
					$module_auth = $mod_info->is_installed;
				}

				if( empty($module_auth) ) {
					if( empty($currentmod_info) ) {
						$baseUrl = $_SERVER['HTTP_HOST'] . Zend_Controller_Front::getInstance()->getBaseUrl();
						$url_string = Zend_Controller_Front::getInstance()->getRequest()->getRequestUri();
						if(strstr($url_string, 'manage/install')) {
							$calling_from = 'install';
						} else if(strstr($url_string, 'manage/query')) {
							$calling_from = 'queary';
						}
						$explode_base_url = explode('/', $baseUrl);
						foreach($explode_base_url as $url_key) {
							if($url_key != 'install') {
								$core_final_url .= $url_key . '/';
							}
						}
						if( empty($_BASE_FILE_NAME) ) {
							$final_url_2 = 'http://' . $core_final_url . 'index.php/seaocore/index/index/type/' . $PRODUCT_TYPE . '/call_from/' . $calling_from . '/plugin_title/' . @base64_encode($PRODUCT_TITLE);

							$final_url_1 = 'http://' . $core_final_url . 'seaocore/index/index/type/' . $PRODUCT_TYPE . '/call_from/' . $calling_from . '/plugin_title/' . @base64_encode($PRODUCT_TITLE);
						}else {
							$final_url_2 = 'http://' . $core_final_url . 'index.php/seaocore/index/index/type/' . $PRODUCT_TYPE . '/call_from/' . $calling_from . '/plugin_title/' . @base64_encode($PRODUCT_TITLE) . '/base_file/' . $_BASE_FILE_NAME;

							$final_url_1 = 'http://' . $core_final_url . 'seaocore/index/index/type/' . $PRODUCT_TYPE . '/call_from/' . $calling_from . '/plugin_title/' . @base64_encode($PRODUCT_TITLE) . '/base_file/' . $_BASE_FILE_NAME;
						}
						return $this->_error('<div class="global_form"><div><div><a href="'. $final_url_1 . '" class="smoothbox">Click here</a> to proceed with the installation of: "<strong>' . $PRODUCT_TITLE . '</strong>" package.. (If you get a "Page Not Found" in the next step, then <a href="'. $final_url_2 . '" class="smoothbox">Click here</a>.)</div></div></div>');
					} else {
						return $this->_error('<div class="global_form"><div><div>Please check the license key of ' . $PLUGIN_TITLE . ' in the Global Settings of Admin Panel for this plugin. Please go to the Global Settings and check the license key there. If you still have any problem then please contact the Support Team of SocialEngineAddOns from the Support section of your Account Area.</div></div></div>');
					}
				} else {
				}
			} else {
				return $this->_error('<div class="global_form"><div><div> You do not have the latest version ' . $SocialEngineAddOns_version . ' of the SocialEngineAddOns Core Plugin. Please download the latest version of this FREE plugin from your Client Area on <a href="http://www.socialengineaddons.com" target="_blank">SocialEngineAddOns</a> and upgrade this on your site.</div></div></div>');
			}
		}else {
			return $this->_error('<div class="global_form"><div><div>The SocialEngineAddOns Core Plugin is not enabled on your site. Please enable it or download the latest version of this FREE plugin from your Client Area on <a href="http://www.socialengineaddons.com" target="_blank">SocialEngineAddOns</a>.</div></div></div>');
		}
	}
	else {
		return $this->_error('<div class="global_form"><div><div>The SocialEngineAddOns Core Plugin is not installed on your site. Please download the latest version of this FREE plugin from your Client Area on <a href="http://www.socialengineaddons.com" target="_blank">SocialEngineAddOns</a>.</div></div></div>');
	}
?>