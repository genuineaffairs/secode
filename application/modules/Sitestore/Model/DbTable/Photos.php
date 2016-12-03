<?php

/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitestore
 * @copyright  Copyright 2012-2013 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: Photos.php 2013-09-02 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
class Sitestore_Model_DbTable_Photos extends Engine_Db_Table {

  protected $_rowClass = 'Sitestore_Model_Photo';

  /**
   * @const SET IMAGE WIDTH
   */
  const IMAGE_WIDTH = 1000;
  /**
   * @const SET IMAGE HIGHT
   */
  const IMAGE_HEIGHT = 1000;
  /**
   * @const SET THUMB IMAGE WIDTH
   */
  const THUMB_WIDTH = 140;
  /**
   * @const SET THUMB IMAGE HIGHT
   */
  const THUMB_HEIGHT = 160;

  /**
   * Gets photos of the stores
   *
   * @param array params
   * @return photos for stores
   */
  public function getPhotos($params = array()) {

    if(!Engine_Api::_()->getApi('settings', 'core')->getSetting('sitestorealbum.hide.autogenerated', 1) && !isset($params['viewStore'])) {
			$albumTableName = Engine_Api::_()->getDbtable('albums', 'sitestore')->info('name');
			$photoTableName = $this->info('name');
			$select = $this->select()
											->setIntegrityCheck(false)
											->from($this->info('name'), array('album_id', 'store_id', 'user_id', 'order', 'title', 'description', 'photo_id', 'view_count', 'comment_count', 'like_count', 'modified_date', 'creation_date', 'photo_hide', 'file_id', 'collection_id'))
											->join($albumTableName, "$albumTableName.album_id = $photoTableName.album_id", array())
											->where("$photoTableName.collection_id <>?", 0);

			if (isset($params['store_id']) && !empty($params['store_id'])) {
				$select->where($this->info('name') . '.store_id' . '= ?', $params['store_id']);
			}
    } else {$select = $this->select();
			$select->from($this->info('name'), array('album_id', 'store_id', 'user_id', 'order', 'title', 'description', 'photo_id', 'view_count', 'comment_count', 'like_count', 'modified_date', 'creation_date', 'photo_hide', 'file_id', 'collection_id'));

			$select = $select->where('collection_id' . '<> ?', 0);
			
			if (isset($params['album_id']) && !empty($params['album_id'])) {
				$select = $select->where('album_id' . '= ?', $params['album_id']);
			}

			if (isset($params['store_id']) && !empty($params['store_id'])) {
				$select = $select->where('store_id' . '= ?', $params['store_id']);
			}
    }
    if (isset($params['user_id']) && !empty($params['user_id'])) {
			$user_ids = array();
			if (isset($params['store_id']) && !empty($params['store_id'])) {
				$results = Engine_Api::_()->getDbtable('manageadmins', 'sitestore')->getManageAdmin($params['store_id'], Engine_Api::_()->user()->getViewer()->getIdentity());
				foreach($results as $values) {
				$user_ids[] = $values['user_id'];
				}
			}

			if(!empty($user_ids)) {
				$implodeUserIds = implode(",", $user_ids);
				$implodeUserIds = $implodeUserIds . ','. $params['user_id'];
				$select = $select->where('user_id' . ' not in (?)', new Zend_Db_Expr(trim($implodeUserIds, ',')));
			} else {
        $select = $select->where('user_id' . ' <> (?)', $params['user_id']);
      }
    }

    if (isset($params['photo_hide'])) {
      $select = $select->where('photo_hide' . '= ?', $params['photo_hide']);
    }

    if (isset($params['file_id']) && !empty($params['file_id'])) {
      $select = $select->where('file_id' . '<>?', $params['file_id']);
    }

    if(!Engine_Api::_()->getApi('settings', 'core')->getSetting('sitestorealbum.hide.autogenerated', 1) && !isset($params['viewStore'])) {
			$select->where($albumTableName. '.default_value'.'= ?', 0);
			$select->where($albumTableName . ".type is Null");
    }
 
    if (isset($params['orderby']) && !empty($params['orderby'])) {
      $select = $select->order($params['orderby']);
    }

    $select = $select->order('order ASC');
   
    if ((isset($params['start']) && !empty($params['start'])) || (isset($params['end']) && !empty($params['end']))) {
      if (!isset($params['end'])) {
        $params['end'] = '';
      }
      $select = $select->limit($params['start'], $params['end']);
    }

		if (!(isset($params['albumviewStore'])) && !Engine_API::_()->seaocore()->checkSitemobileMode('fullsite-mode')) {
      return Zend_Paginator::factory($select);
    }
    return $this->fetchAll($select);
  }

  /**
   * Gets photo id by order
   *
   * @param int $album_id
   * @param int $store_id 
   * @return photo ids
   */
  public function getStorePhotosOrder($album_id, $store_id) {

    $currentOrder = $this->select()
                    ->from($this->info('name'), 'photo_id')
                    ->where('collection_id = ?', $album_id)
                    ->where('store_id = ?', $store_id)
                    ->order('order ASC')
                    ->query()
                    ->fetchAll(Zend_Db::FETCH_COLUMN);

    return $currentOrder;
  }

  /**
   * Gets notes data
   *
   * @param array $params
   * @return Zend_Db_Table_Select
   */
  public function widgetPhotos($params = array()) {
    $tableStore = Engine_Api::_()->getDbtable('stores', 'sitestore');
    $tableStoreName = $tableStore->info('name');
    $parentTable = Engine_Api::_()->getItemTable('sitestore_album');
    $parentTableName = $parentTable->info('name');
    $tablePhotoName = $this->info('name');
    $select = $this->select()
                    ->setIntegrityCheck(false)
                    ->from($this->info('name'))
                    ->joinLeft($tableStoreName, "$tableStoreName.store_id = $tablePhotoName.store_id", array('store_id', 'title AS store_title', 'closed', 'approved', 'declined', 'draft', 'expiration_date', 'owner_id', 'photo_id as store_photo_id'))
                    ->joinLeft($parentTableName, $parentTableName . '.album_id=' . $this->info('name') . '.album_id', array('title AS album_title'))
                    ->where('collection_id <>?', 0);
    if (isset($params['category_id']) && !empty($params['category_id'])) {
			$select = $select->where($tableStoreName . '.	category_id =?', $params['category_id']);
		}
    if (isset($params['zero_count']) && !empty($params['zero_count'])) {
      $select = $select->where($tablePhotoName . '.' . $params['zero_count'] . '!= ?', 0);
    }

    if (isset($params['orderby']) && !empty($params['orderby'])) {
      $select = $select->order($tablePhotoName . '.' . $params['orderby']);
    }
    if (isset($params['store_id']) && !empty($params['store_id'])) {
      $select = $select->where($tablePhotoName . '.store_id = ?', $params['store_id']);
    }

    $select = $select->order('photo_id DESC');

    if (isset($params['limit']) && !empty($params['limit'])) {
      $select = $select->limit($params['limit']);
    }

    $select = $select
                    ->where($tableStoreName . '.search = ?', '1')
                    ->where($tableStoreName . '.closed = ?', '0')
                    ->where($tableStoreName . '.approved = ?', '1')
                    ->where($tableStoreName . '.declined = ?', '0')
                    ->where($tableStoreName . '.draft = ?', '1');
    if (Engine_Api::_()->sitestore()->hasPackageEnable()) {
      $select->where($tableStoreName . '.expiration_date  > ?', date("Y-m-d H:i:s"));
    }

    //Start Network work
    if (!isset($params['store_id']) || empty($params['store_id'])) {
      $select = $tableStore->getNetworkBaseSql($select, array('not_groupBy' => 1, 'extension_group' => $tablePhotoName . ".photo_id"));
    }

    if(!Engine_Api::_()->getApi('settings', 'core')->getSetting('sitestorealbum.hide.autogenerated', 1) ) {
			$select->where($parentTableName. '.default_value'.'= ?', 0);
			$select->where($parentTableName . ".type is Null");
    }

    //End Network work
    return $this->fetchAll($select);
  }

  /**
   * Create Photo
   *
   * @param array $params
   * @param array $file
   */
  public function createPhoto($params, $file) {
    $getPackagePhoto = Engine_Api::_()->sitestore()->getPackageAuthInfo('sitestorealbum');
    if ($file instanceof Storage_Model_File) {
      $params['file_id'] = $file->getIdentity();
    } else {
      //Get image info and resize
      $name = basename($file['tmp_name']);
      $path = dirname($file['tmp_name']);
      $extension = ltrim(strrchr($file['name'], '.'), '.');

      $mainName = $path . '/m_' . $name . '.' . $extension;
      $thumbName = $path . '/t_' . $name . '.' . $extension;

      $image = Engine_Image::factory();
      $image->open($file['tmp_name'])
              ->resize(self::IMAGE_WIDTH, self::IMAGE_HEIGHT)
              ->write($mainName)
              ->destroy();

      $image = Engine_Image::factory();
      $image->open($file['tmp_name'])
              ->resize(self::THUMB_WIDTH, self::THUMB_HEIGHT)
              ->write($thumbName)
              ->destroy();

      //Store photos
      $photo_params = array(
          'parent_id' => $params['store_id'],
          'parent_type' => 'sitestore_store',
      );

      $photoFile = Engine_Api::_()->storage()->create($mainName, $photo_params);
      $thumbFile = Engine_Api::_()->storage()->create($thumbName, $photo_params);
      $photoFile->bridge($thumbFile, 'thumb.normal');

      $params['file_id'] = $photoFile->file_id; //This might be wrong
      $params['photo_id'] = $photoFile->file_id;

      //Remove temp files
      @unlink($mainName);
      @unlink($thumbName);
    }
  
      $row = Engine_Api::_()->getDbtable('photos', 'sitestore')->createRow();
      $row->setFromArray($params);
      $row->save();
      return $row;
    
  }
  /**
   * Gets total photo
   *
   * @param array $params
   * @return total photo
   */
  public function countTotalPhotos($params) {

    $tableStore = Engine_Api::_()->getDbtable('stores', 'sitestore');
    $tableStoreName = $tableStore->info('name');
    $tablePhotoName = $this->info('name');
    $select = $this->select()
                    ->setIntegrityCheck(false)
                    ->from($this->info('name'), array('count(*) as count'))
                    ->joinLeft($tableStoreName, "$tableStoreName.store_id = $tablePhotoName.store_id", array())
                    ->where('collection_id <>?', 0);
    if (isset($params['category_id']) && !empty($params['category_id'])) {
			$select = $select->where($tableStoreName . '.	category_id =?', $params['category_id']);
		}

    if (isset($params['zero_count']) && !empty($params['zero_count'])) {
      $select = $select->where($tablePhotoName . '.' . $params['zero_count'] . '!= ?', 0);
    }

    if (isset($params['orderby']) && !empty($params['orderby'])) {
      $select = $select->order($tablePhotoName . '.' . $params['orderby']);
    }
    if (isset($params['store_id']) && !empty($params['store_id'])) {
      $select = $select->where($tablePhotoName . '.store_id = ?', $params['store_id']);
    }

    $select = $select->order($tablePhotoName . '.photo_id DESC');

    if (isset($params['limit']) && !empty($params['limit'])) {
      $select = $select->limit(1);
    }

    $select = $select
                    ->where($tableStoreName . '.search = ?', '1')
                    ->where($tableStoreName . '.closed = ?', '0')
                    ->where($tableStoreName . '.approved = ?', '1')
                    ->where($tableStoreName . '.declined = ?', '0')
                    ->where($tableStoreName . '.draft = ?', '1');
    if (Engine_Api::_()->sitestore()->hasPackageEnable()) {
      $select->where($tableStoreName . '.expiration_date  > ?', date("Y-m-d H:i:s"));
    }

    //Start Network work
    if (!isset($params['store_id']) || empty($params['store_id'])) {
      $select = $tableStore->getNetworkBaseSql($select, array('not_groupBy' => 1, 'extension_group' => $tablePhotoName . ".photo_id"));
    }
    //End Network work                     
    
//     if(Engine_Api::_()->getApi('settings', 'core')->getSetting('sitestorealbum.hide.autogenerated', 1) ) {
// 			$select->where($parentTableName. '.default_value'.'= ?', 0);
// 			$select->where($parentTableName . ".type is Null");
//     }

    return $select->query()->fetchColumn();
  }  

  /**
   * Return photo of the day
   *
   * @return Zend_Db_Table_Select
   */
  public function photoOfDay() {

    //CURRENT DATE TIME
    $date = date('Y-m-d');
    
    $tableStore = Engine_Api::_()->getDbtable('stores', 'sitestore');
    $tableStoreName = $tableStore->info('name');

    //GET ITEM OF THE DAY TABLE NAME
    $photoOfTheDayTableName = Engine_Api::_()->getDbtable('itemofthedays', 'sitestore')->info('name');

    //GET PHOTO TABLE NAME
    $photoTableName = $this->info('name');

    //MAKE QUERY
    $select = $this->select()
                    ->setIntegrityCheck(false)
                    ->from($photoTableName)
                    ->joinLeft($tableStoreName, "$tableStoreName.store_id = $photoTableName.store_id", array('title AS store_title', 'photo_id as store_photo_id'))
                    ->join($photoOfTheDayTableName, $photoTableName . '.photo_id = ' . $photoOfTheDayTableName . '.resource_id')
                    ->where('resource_type = ?', 'sitestore_photo')
                    ->where('start_date <= ?', $date)
                    ->where('end_date >= ?', $date)
                    ->order('Rand()');

     $select = $select
              ->where($tableStoreName . '.closed = ?', '0')
              ->where($tableStoreName . '.approved = ?', '1')
              ->where($tableStoreName . '.declined = ?', '0')
              ->where($tableStoreName . '.draft = ?', '1');
    if (Engine_Api::_()->sitestore()->hasPackageEnable()) {
      $select->where($tableStoreName . '.expiration_date  > ?', date("Y-m-d H:i:s"));
    }

    //RETURN RESULTS
    return $this->fetchRow($select);
  }

  public function topcreatorData($limit = null,$category_id) {

    //ALBUM TABLE NAME
    $photoTableName = $this->info('name');

    //STORE TABLE
    $storeTable = Engine_Api::_()->getDbtable('stores', 'sitestore');
    $storeTableName = $storeTable->info('name');

    $select = $this->select()
                    ->setIntegrityCheck(false)
                    ->from($storeTableName, array('photo_id', 'title as sitestore_title','store_id'))
                    ->join($photoTableName, "$storeTableName.store_id = $photoTableName.store_id", array('COUNT(engine4_sitestore_stores.store_id) AS item_count'))
                    ->where($storeTableName.'.approved = ?', '1')
										->where($storeTableName.'.declined = ?', '0')
										->where($storeTableName.'.draft = ?', '1')
                    ->group($photoTableName . ".store_id")
                    ->order('item_count DESC')
                    ->limit($limit);
    if (!empty($category_id)) {
      $select->where($storeTableName . '.category_id = ?', $category_id);
    }
    return $select->query()->fetchAll();
  }
  
  /**
   * Gets count of the photos
   *
   * @param array params
   * @return photos count
   */
  public function getPhotosCount($params = array()) {

    $select = $this->select();
    
//     $select->from($this->info('name'), array( 'count(*) as count'));
//  
//     $select->where($this->info('name') . '.collection_id' . '<> ?', 0);
// 
//     if (isset($params['store_id']) && !empty($params['store_id'])) {
//       $select->where($this->info('name') . '.store_id' . '= ?', $params['store_id']);
//     }
// 
//     if (isset($params['album_id']) && !empty($params['album_id'])) {
//       $select->where($this->info('name') . '.album_id' . '= ?', $params['album_id']);
//     }

    $albumTableName = Engine_Api::_()->getDbtable('albums', 'sitestore')->info('name');
    $photoTableName = $this->info('name');
    $select = $this->select()
                    ->setIntegrityCheck(false)
                    ->from($this->info('name'), array( 'count(*) as count'))
                    ->join($albumTableName, "$albumTableName.album_id = $photoTableName.album_id", array())
                    ->where("$photoTableName.collection_id <>?", 0);
 
    if (isset($params['store_id']) && !empty($params['store_id'])) {
      $select->where($this->info('name') . '.store_id' . '= ?', $params['store_id']);
    }

//     if (isset($params['album_id']) && !empty($params['album_id'])) {
//       $select->where($this->info('name') . '.album_id' . '= ?', $params['album_id']);
//     }

    if (isset($params['user_id']) && !empty($params['user_id'])) {
			$user_ids = array();
			if (isset($params['store_id']) && !empty($params['store_id'])) {
				$results = Engine_Api::_()->getDbtable('manageadmins', 'sitestore')->getManageAdmin($params['store_id'], 1);
				foreach($results as $values) {
				$user_ids[] = $values['user_id'];
				}
			}

			if(!empty($user_ids)) {
				$implodeUserIds = implode(",", $user_ids);
				$select = $select->where('user_id' . ' not in (?)', new Zend_Db_Expr(trim($implodeUserIds, ',')));
			}
    }

    if (isset($params['photo_hide'])) {
      $select->where($this->info('name') . '.photo_hide' . '= ?', $params['photo_hide']);
    }

    if (isset($params['file_id']) && !empty($params['file_id'])) {
      $select->where($this->info('name') . '.file_id' . '<>?', $params['file_id']);
    }

    $select->group($this->info('name') . '.store_id');
    
    if ((isset($params['start']) && !empty($params['start'])) || (isset($params['end']) && !empty($params['end']))) {
      if (!isset($params['end'])) {
        $params['end'] = '';
      }
      $select->limit($params['start'], $params['end']);
    }
    
    if(!Engine_Api::_()->getApi('settings', 'core')->getSetting('sitestorealbum.hide.autogenerated', 1) && !isset($params['viewStore'])) {
			$select->where($albumTableName. '.default_value'.'= ?', 0);
			$select->where($albumTableName . ".type is Null");
    }

    return $select->query()->fetchColumn();
  }
  
}

?>