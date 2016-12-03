<?php

/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitepageoffer
 * @copyright  Copyright 2010-2011 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: Menus.php 2011-05-05 9:40:21Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>

<?php    

	$db = Engine_Db_Table::getDefaultAdapter();
	$select = new Zend_Db_Select($db);
	$page_id = $select
					->from("engine4_sitemobile_pages", array('page_id'))
					->where('name = ?', "sitestore_index_view")->query()->fetchColumn();

	if(empty($page_id)) 
		return false;  

  $engine4_sitestore_mobileadmincontent = $db->query('SHOW TABLES LIKE \'engine4_sitestore_mobileadmincontent\'')->fetch(); 
  if(empty($engine4_sitestore_mobileadmincontent))
    return false;

  $admincontentTable = 'engine4_sitestore_mobileadmincontent';  
	// Check if it's already been placed
	$select = new Zend_Db_Select($db);
	$select
					->from($admincontentTable)
					->where('store_id = ?', $page_id)
					->where('type = ?', 'widget')
					->where('name = ?', 'sitestoreoffer.sitemobile-profile-sitestoreoffers');

	$info = $select->query()->fetch();

	if (empty($info)) {
		// container_id (will always be there)
		$select = new Zend_Db_Select($db);
		$select
						->from($admincontentTable)
						->where('store_id = ?', $page_id)
						->where('type = ?', 'container')
						->where('name = ?', 'main')
						->limit(1);
		$container_id = $select->query()->fetchObject()->mobileadmincontent_id;

		// middle_id (will always be there)
		$select = new Zend_Db_Select($db);
		$select
						->from($admincontentTable)
						->where('parent_content_id = ?', $container_id)
						->where('type = ?', 'container')
						->where('name = ?', 'middle')
						->limit(1);
		$middle_id = $select->query()->fetchObject()->mobileadmincontent_id;

		// tab_id (tab container) may not always be there
		$select
						->reset('where')
						->where('type = ?', 'widget')
						->where('name = ?', 'sitemobile.container-tabs-columns')
						->where('store_id = ?', $page_id)
						->limit(1);
		$tab_id = $select->query()->fetchObject();
		if ($tab_id && @$tab_id->mobileadmincontent_id) {
			$tab_id = $tab_id->mobileadmincontent_id;
		} else {
			$tab_id = null;
		}

		// tab on profile
		$db->insert($admincontentTable, array(
				'store_id' => $page_id,
				'type' => 'widget',
				'name' => 'sitestoreoffer.sitemobile-profile-sitestoreoffers',
				'parent_content_id' => ($tab_id ? $tab_id : $middle_id),
				'order' => 1400,
				'params' => '{"title":"Offers","titleCount":true}',
		));

	}

?>