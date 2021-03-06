<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Store
 * @copyright  Copyright Hire-Experts LLC
 * @license    http://www.hire-experts.com
 * @version    $Id: Core.php 2011-08-19 17:22:12 mirlan $
 * @author     Mirlan
 */

/**
 * @category   Application_Extensions
 * @package    Store
 * @copyright  Copyright Hire-Experts LLC
 * @license    http://www.hire-experts.com
 */
class Store_Api_Core extends Core_Api_Abstract
{
  const IMAGE_WIDTH = 900;
  const IMAGE_HEIGHT = 900;

  const THUMB_WIDTH = 140;
  const THUMB_HEIGHT = 160;

  /**
   * @var Page_Model_Page
   */
  protected $_store;

  /**
   * @var Store_Model_Api
   */
  protected $_api;

  /**
   * @return Boolean
   **/
  public function isActiveTransaction()
  {
    $session = new Zend_Session_Namespace('Store_Transaction');

    if (!$session->order_id || !$session->cart_id) {
      return false;
    }

    if (null == $order = Engine_Api::_()->getItem('payment_order', $session->order_id)) {
      return false;
    }

    if ($order->source_type != 'store_cart' || !in_array($order->state, array('initial', 'pending')) || $session->cart_id != $order->source_id) {
      return false;
    }

    if (null == ($cart = Engine_Api::_()->getItem($order->source_type, $order->source_id))) {
      return false;
    }

    if (!in_array($cart->status, array('initial', 'pending'))) {
      return false;
    }

    return true;
  }

  public function createPhoto($params, $file)
  {
    if ($file instanceof Storage_Model_File) {
      $params['file_id'] = $file->getIdentity();

    } else {
      // Get image info and resize
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

      // Store photos
      $photo_params = array(
        'parent_id' => $params['owner_id'],
        'parent_type' => 'user',
      );

      try {
        $photoFile = Engine_Api::_()->storage()->create($mainName, $photo_params);
        $thumbFile = Engine_Api::_()->storage()->create($thumbName, $photo_params);
      } catch (Exception $e) {
        if ($e->getCode() == Storage_Api_Storage::SPACE_LIMIT_REACHED_CODE) {
          echo $e->getMessage();
          exit();
        }
      }

      $photoFile->bridge($thumbFile, 'thumb.normal');

      // Remove temp files
      @unlink($mainName);
      @unlink($thumbName);

      $params['file_id'] = $photoFile->file_id; // This might be wrong
      $params['photo_id'] = $photoFile->file_id;
      $params['user_id'] = Engine_Api::_()->user()->getViewer()->getIdentity();
    }

    $row = $this->getPhotoTable()->createRow();
    $row->setFromArray($params);
    $row->save();
    return $row;
  }

  public function getPhotoTable()
  {
    return Engine_Api::_()->getDbTable('photos', 'store');
  }

  public function isApiEnabled($params = array('title' => 'PayPal'))
  {
    if (!($gateway = $this->getApi($params))) {
      return false;
    }

    return $gateway->enabled;
  }

  /**
   * @param array $params
   * @return bool|null|Store_Model_Api
   */
  public function getApi($params = array('title' => 'PayPal'))
  {
    if ($this->_api instanceof Store_Model_Api) {
      return $this->_api;
    }

    $store = $this->getStore();

    //he@todo exception
    if (!($store instanceof Page_Model_Page)) {
      return false;
    }

    $table = Engine_Api::_()->getDbtable('gateways', 'payment');
    $select = $table->select()->where('title=?', $params['title']);

    /**
     * @var $gateway Payment_Model_Gateway
     */
    if (null == ($gateway = $table->fetchRow($select))) {
      return false;
    }

    /**
     * @var $apiTable Store_Model_DbTable_Apis
     */
    $apiTable = Engine_Api::_()->getDbTable('apis', 'store');

    $select = $apiTable->select()
      ->where('gateway_id=? ', $gateway->gateway_id)
      ->where('page_id=?', $store->getIdentity());

    if (null == ($api = $apiTable->fetchRow($select))) {
      $api = $apiTable->createRow(array(
        'gateway_id' => $gateway->gateway_id,
        'page_id' => $store->getIdentity()
      ));
      $api->save();
    }

    $this->_api = $api;

    return $api;
  }

  /**
   * @param null|Store_Model_Api $api
   * @return Store_Plugin_Gateway_PayPal
   */
  public function getPlugin(Store_Model_Api $api = null)
  {
    if ($api == null) {
      $api = $this->getApi();
    }

    if (!($api instanceof Store_Model_Api)) {
      return null;
    }

    return $api->getPlugin();
  }

  public function setStore(Page_Model_Page $store)
  {
    $this->_store = $store;
  }

  /**
   * @return Page_Model_Page
   */
  public function getStore()
  {
    return $this->_store;
  }

  public function createThumbnail($video)
  {
    // Now try to create thumbnail
    $thumbnail = $this->handleThumbnail($video->type, $video->code);
    $ext = ltrim(strrchr($thumbnail, '.'), '.');
    $thumbnail_parsed = @parse_url($thumbnail);

    if (@GetImageSize($thumbnail)) {
      $valid_thumb = true;
    } else {
      $valid_thumb = false;
    }

    if ($valid_thumb && $thumbnail && $ext && $thumbnail_parsed && in_array($ext, array('jpg', 'jpeg', 'gif', 'png'))) {
      $tmp_file = APPLICATION_PATH . '/temporary/link_' . md5($thumbnail) . '.' . $ext;
      $thumb_file = APPLICATION_PATH . '/temporary/link_thumb_' . md5($thumbnail) . '.' . $ext;
      $mini_file = APPLICATION_PATH . '/temporary/link_mini_' . md5($thumbnail) . '.' . $ext;
      $icon_file = APPLICATION_PATH . '/temporary/link_thumb_icon_' . md5($thumbnail) . '.' . $ext;

      $src_fh = fopen($thumbnail, 'r');
      $tmp_fh = fopen($tmp_file, 'w');
      stream_copy_to_stream($src_fh, $tmp_fh, 1024 * 1024 * 2);

      $image = Engine_Image::factory();
      $image->open($tmp_file)
        ->resize(240, 180)
        ->write($thumb_file)
        ->destroy();

      $image = Engine_Image::factory();
      $image->open($tmp_file)
        ->resize(34, 34)
        ->write($mini_file)
        ->destroy();

      $image = Engine_Image::factory();
      $image->open($tmp_file)
        ->resize(120, 120)
        ->write($icon_file)
        ->destroy();

      try {
        $thumbFileRow = Engine_Api::_()->storage()->create($thumb_file, array(
          'parent_type' => $video->getType(),
          'parent_id' => $video->getIdentity()
        ));

        $thumbMiniFileRow = Engine_Api::_()->storage()->create($mini_file, array(
          'parent_type' => $video->getType(),
          'parent_id' => $video->getIdentity()
        ));

        $thumbIconFileRow = Engine_Api::_()->storage()->create($icon_file, array(
          'parent_type' => $video->getType(),
          'parent_id' => $video->getIdentity()
        ));

        $thumbFileRow->bridge($thumbMiniFileRow, 'thumb.mini');
        $thumbFileRow->bridge($thumbIconFileRow, 'thumb.icon');

        // Remove temp file
        @unlink($thumb_file);
        @unlink($mini_file);
        @unlink($tmp_file);
        @unlink($icon_file);
      } catch (Exception $e) {
        throw $e;
      }
      $information = $this->handleInformation($video->type, $video->code);

      $video->duration = $information['duration'];
      if (!$video->description) $video->description = $information['description'];
      $video->photo_id = $thumbFileRow->file_id;
      $video->status = 1;
      $video->save();
    }
  }

  // handles thumbnails
  public function handleThumbnail($type, $code = null)
  {
    switch ($type) {
      //youtube
      case "1":
        // http://img.youtube.com/vi/E98IYokujSY/default.jpg
        return "http://img.youtube.com/vi/$code/0.jpg";
      // vimeo
      case "2":
        // thumbnail_medium
        $data = simplexml_load_file("http://vimeo.com/api/v2/video/" . $code . ".xml");
        $thumbnail = $data->video->thumbnail_large;
        return $thumbnail;
    }
  }

  // retrieves infromation and returns title + desc
  public function handleInformation($type, $code)
  {
    switch ($type) {
      //youtube
      case "1":
        $yt = new Zend_Gdata_YouTube();
        $youtube_video = $yt->getVideoEntry($code);
        if (!$data = @file_get_contents("http://www.youtube.com/watch?v=".$code)) return false;
        $information = array();
        $information['title'] = $youtube_video->getTitle();
        $information['description'] = $youtube_video->getVideoDescription();
        $information['duration'] = $youtube_video->getVideoDuration();

        return $information;
      //vimeo
      case "2":
        //thumbnail_medium
        $data = simplexml_load_file("http://vimeo.com/api/v2/video/" . $code . ".xml");
        $thumbnail = $data->video->thumbnail_medium;
        $information = array();
        $information['title'] = $data->video->title;
        $information['description'] = $data->video->description;
        $information['duration'] = $data->video->duration;

        return $information;
    }
  }

  public function deleteVideo($video)
  {

    if ($video->status == 1) {
      if ($video->photo_id) Engine_Api::_()->getItem('storage_file', $video->photo_id)->remove();
    }
    if ($video->status == 3) {
      if ($video->photo_id) Engine_Api::_()->getItem('storage_file', $video->file_id)->remove();
    }

    if (null != ($row = Engine_Api::_()->getDbTable('videos', 'store')->findRow($video->video_id))) {
      $row->delete();
    }
  }

  public function deleteAudio($audio)
  {
    if ($audio->file_id) {
      Engine_Api::_()->getItem('storage_file', $audio->file_id)->remove();
    }

    if (null != ($row = Engine_Api::_()->getDbTable('audios', 'store')->findRow($audio->audio_id))) {
      $row->delete();
    }

  }

  public function deleteFile($file_id)
  {
    if ($file_id && (null != ($file = Engine_Api::_()->getItem('storage_file', $file_id)))) {
      $file->remove();
    }

    return;
  }

  public function createVideo($params, $file, $video)
  {
    if ($file instanceof Storage_Model_File) {
      $params['file_id'] = $file->getIdentity();
    } else {

      // create video item
      $table = new Store_Model_DbTable_Videos();
      if (!$video) {
        $video = $table->createRow();
      }
      $file_ext = pathinfo($file['name']);
      $file_ext = $file_ext['extension'];
      $video->code = $file_ext;
      $video->save();

      // Store video in temporary storage object for ffmpeg to handle
      $storage = Engine_Api::_()->getItemTable('storage_file');
      $storageObject = $storage->createFile($file, array(
        'parent_id' => $video->getIdentity(),
        'parent_type' => $video->getType(),
        'user_id' => $video->owner_id,
      ));

      // Remove temporary file
      @unlink($file['tmp_name']);
      $video->url = '';
      $video->file_id = $storageObject->file_id;
      $video->save();

      // Add to jobs
      if (Engine_Api::_()->getApi('settings', 'core')->getSetting('video.html5', false)) {
        Engine_Api::_()->getDbtable('jobs', 'core')->addJob('storevideo_encode', array(
          'video_id' => $video->getIdentity(),
          'type' => 'mp4',
        ));
      } else {
        Engine_Api::_()->getDbtable('jobs', 'core')->addJob('storevideo_encode', array(
          'video_id' => $video->getIdentity(),
          'type' => 'flv',
        ));
      }

    }
    return $video;
  }


// handle audio upload
  public function createAudio($file, $params = array())
  {
    if (is_array($file)) {
      if (!is_uploaded_file($file['tmp_name'])) {
        throw new Storage_Model_Exception('Invalid upload or file too large');
      }
      $filename = $file['name'];
    } else if (is_string($file)) {
      $filename = $file;
    } else {
      throw new Storage_Model_Exception('Invalid upload or file too large');
    }

    // Check file extension
    if (!preg_match('/\.(mp3|m4a|aac|mp4)$/iu', $filename)) {
      throw new Storage_Model_Exception('Invalid file type');
    }

    $storage = Engine_Api::_()->getItemTable('storage_file');

    $row = $storage->createRow();
    $row->setFromArray(array(
      'parent_type' => 'store_audio',
      'parent_id' => 1, // Hack
      'user_id' => null,
    ));

    $row->store($file);
    return $row;
  }

  public function createFile($file)
  {
    if (is_array($file)) {
      if (!is_uploaded_file($file['tmp_name'])) {
        throw new Storage_Model_Exception('Invalid upload or file too large');
      }
      $filename = $file['name'];
    } else if (is_string($file)) {
      $filename = $file;
    } else {
      throw new Storage_Model_Exception('Invalid upload or file too large');
    }

    $htaccess = APPLICATION_PATH . '/public/store_product/.htaccess';

    if (!file_exists($htaccess)) {
      $fp = fopen($htaccess, "w");
      fwrite($fp, "deny from all");
      fclose($fp);
    }

    $storage = Engine_Api::_()->getItemTable('storage_file');

    $row = $storage->createRow();
    $row->setFromArray(array(
      'parent_type' => 'store_product',
      'parent_id' => 1, // Hack
      'user_id' => null,
    ));

    $row->store($file);
    return $row;
  }

  public function readfile_chunked($filename, $retbytes = true)
  {
    $chunksize = 1 * (1024 * 1024); // how many bytes per chunk
    $cnt = 0;
    $handle = fopen($filename, 'rb');
    if ($handle === false) {
      return false;
    }
    ob_end_clean(); //added to fix ZIP file corruption
    ob_start(); //added to fix ZIP file corruption

    while (!feof($handle)) {
      $buffer = fread($handle, $chunksize);
      echo $buffer;
      ob_flush();
      flush();
      if ($retbytes) {
        $cnt += strlen($buffer);
      }
    }
    $status = fclose($handle);
    if ($retbytes && $status) {
      return $cnt; // return num. bytes delivered like readfile() does.
    }
    return $status;
  }

  public function generate_random_letters($length)
  {
    $random = '';
    for ($i = 0; $i < $length; $i++) {
      $random .= chr(rand(ord('a'), ord('z')));
    }
    return $random;
  }

  function params_string($haystack, $delimiter1 = ': ', $delimiter2 = ', ')
  {
    if (!is_array($haystack)) return false;

    $array_str = '';
    $i = 0;
    foreach ($haystack as $arr) {
      if ($i > 0) $array_str .= $delimiter2;
      $array_str .= $arr['label'] . $delimiter1 . $arr['value'];
      $i++;
    }

    return $array_str;
  }

  public function getCommission($amt)
  {
    $amt = (double)$amt;
    $commission = 0.00;

    if ($amt <= 0.00 || $this->getPaymentMode() == 'client_store') {
      return $commission;
    }

    /**
     * @var $settings Core_Model_DbTable_Settings
     */
    $settings = Engine_Api::_()->getDbTable('settings', 'core');
    $commissionFixed = (double)$settings->getSetting('store.commission.fixed', 0);
    $commissionPercentage = (int)$settings->getSetting('store.commission.percentage', 0);
    $commission = round((double)($commissionFixed + ($amt * $commissionPercentage) / 100), 2);

    return $commission;
  }

  public function isStoreCreditEnabled()
  {
    if (!$this->isCreditEnabled()) {
      return false;
    }

    $isPageEnabled = Engine_Api::_()->getDbTable('modules', 'hecore')->isModuleEnabled('page');
    if (!$isPageEnabled) {
      return false;
    }

    $settings = Engine_Api::_()->getDbTable('settings', 'core');
    $isStoreEnabled = $settings->getSetting('store.credit.store', 0);
    if (!$isStoreEnabled) {
      return false;
    }

    return true;
  }

  public function isCreditEnabled()
  {
    $settings = Engine_Api::_()->getDbTable('settings', 'core');
    $switcher = $settings->getSetting('store.credit.enabled', 0);
    $isModuleEnabled = Engine_Api::_()->getDbTable('modules', 'hecore')->isModuleEnabled('credit');
    if (!$isModuleEnabled || !$switcher) {
      return false;
    }

    return true;
  }

  public function getCredits($price)
  {
    /**
     * @var $settings Core_Model_DbTable_Settings
     */

    $settings = Engine_Api::_()->getDbTable('settings', 'core');
    $defaultPrice = $settings->getSetting('credit.default.price', 100);

    return (int)ceil($price * $defaultPrice);
  }

  public function getPaymentMode()
  {
    $isPageEnabled = Engine_Api::_()->getDbTable('modules', 'hecore')->isModuleEnabled('page');
    if (!$isPageEnabled) {
      return 'client_site_store';
    }

    $settings = Engine_Api::_()->getDbTable('settings', 'core');
    $mode = $settings->getSetting('store.payment.mode', 'client_site_store');
    return $mode;
  }

  public function allowOrder($viewer = null)
  {
    /**
     * @var $viewer User_Model_User
     */
    if (!$viewer) {
      return 0;
    }

    $result = Engine_Api::_()->authorization()->getAdapter('levels')->getAllowed('store_product', $viewer, 'order');

    return $result;
  }

  public function getToken($isTransaction = false)
  {
    $viewer = Engine_Api::_()->user()->getViewer();

    if ($viewer->getIdentity()) {
      return null;
    }

    $session = new Zend_Session_Namespace('store_public_cart');
    $token = $session->__get('user_token', null);
    if (!$token && !$isTransaction) {
      $rand = mt_rand(-99999, 99999);
      $token = md5($rand);
      $session->__set('user_token', $token);
    }
    return $token;
  }

  public function getWishesCount($product_id = 0)
  {
    /**
     * @var $wishes Store_Model_DbTable_Wishes
     */
    $wishes = new Store_Model_DbTable_Wishes();
    return $wishes->getWishesCount($product_id);
  }

  public function sendPublicPurchaseEmail($url = null)
  {
    if (!$url) {
      return;
    }
    try {
      /**
       * @var $details Store_Model_DbTable_Details
       */
      $details = new Store_Model_DbTable_Details();
      $d = $details->getDetails(Engine_Api::_()->user()->getViewer());

      if ($d) {
        $fullname = trim($d['first_name'] . ' ' . $d['last_name'] . ' ' . $d['middle_name']);
        if (!$fullname) {
          $fullname = $d['email'];
        }

        $purchase_url = 'http://' . $_SERVER['HTTP_HOST'] .
          Zend_Controller_Front::getInstance()->getRouter()->assemble(array(
            'module' => 'store',
            'controller' => 'panel',
            'action' => 'purchase',
            'token' => $d['token']
          ), 'default', true);
        $host_url = 'http://' . $_SERVER['HTTP_HOST'] .
          Zend_Controller_Front::getInstance()->getRouter()->assemble(array(
            'module' => 'store'
          ), 'default', true);
        //[fullname],[email],[purchase_url],[header],[footer]
        Engine_Api::_()->getApi('mail', 'core')->sendSystem($d['email'], 'store_public_transaction', array(
          'fullname' => $fullname,
          'purchase_url' => $purchase_url,
          'host_url' => $host_url,
        ));
      }

    } catch (Exception $e) {
      print_log($e, 'mail');
    }
  }

  public function isWorldWideEnabled()
  {
    $settings = Engine_Api::_()->getDbTable('settings', 'core');
    return $settings->__get('store.ww.enabled', false);
  }

  public function getWorldWideShippingPrice()
  {
    $settings = Engine_Api::_()->getDbTable('settings', 'core');
    return $settings->__get('store.ww.price', 0);
  }

  public function getWorldWideShippingDays()
  {
    $settings = Engine_Api::_()->getDbTable('settings', 'core');
    return $settings->__get('store.ww.days', 0);
  }

  public function getWorldWideShippingTax()
  {
    $settings = Engine_Api::_()->getDbTable('settings', 'core');
    return $settings->__get('store.ww.tax', 0);
  }
  
  public function getToday() {
  	$viewer = Engine_Api::_()->user()->getViewer();
    $timezone = Engine_Api::_()->getApi('settings', 'core')
    ->getSetting('core_locale_timezone', 'GMT');
    if( $viewer && $viewer->getIdentity() && !empty($viewer->timezone) ) {
        $timezone = $viewer->timezone;
    }
    $date = new Zend_Date();
    $date->setTimezone($timezone);
    return $date;
  }

	public function getUserInfo($user) {
		$fieldStructure = Engine_Api::_()->fields()->getFieldsStructurePartial($user);
		$info = array();
		foreach( $fieldStructure as $map ) {
	      	// Get field meta object
	      	$field = $map->getChild();
	      	$value = $field->getValue($user);
			if ($field->label == 'Job Title') {
				$info['job_position'] = $this->getFieldValueString($field, $value, $user, $map, $fieldStructure);
			}
			if ($field->label == 'Business Name') {
				$info['company'] = $this->getFieldValueString($field, $value, $user, $map, $fieldStructure);
			}
			
			if ($field->label == 'Industry') {
				if (empty($info['company']))
					$info['company'] = $this->getFieldValueString($field, $value, $user, $map, $fieldStructure);
				else {
					$info['company'] .= ' / ' . $this->getFieldValueString($field, $value, $user, $map, $fieldStructure);
				}
			}
			
			if ($field->type == 'city') {
				$info['city'] = $this->getFieldValueString($field, $value, $user, $map, $fieldStructure);
			}
			
			if ($field->type == 'country') {
				if (empty($info['city']))
					$info['city'] = $this->getFieldValueString($field, $value, $user, $map, $fieldStructure);
				else {
					$info['city'] .= ', ' . $this->getFieldValueString($field, $value, $user, $map, $fieldStructure);
				}
			}
			
			if ($field->type == 'website') {
				$info['website'] = $this->getFieldValueString($field, $value, $user, $map, $fieldStructure);
				if ((strip_tags($info['website']) == 'http://') || (strip_tags($info['website']) == 'https://') )
				unset($info['website']);
			}
		}
		return $info;
	}
	
	public function getFieldValueString($field, $value, $subject, $map = null,
      $partialStructure = null) {
    	if( (!is_object($value) || !isset($value->value)) && !is_array($value) ) {
      		return null;
		}
    

    	$helperName = Engine_Api::_()->fields()->getFieldInfo($field->type, 'helper');
    	if( !$helperName ) {
      		return null;
    	}
		
		$view = Zend_Registry::get('Zend_View');
		$view -> addHelperPath(APPLICATION_PATH . '/application/modules/Fields/View/Helper', 'Fields_View_Helper_');
    	$helper = $view->getHelper($helperName);
    	if( !$helper ) {
      		return null;
    	}

	    $helper->structure = $partialStructure;
	    $helper->map = $map;
	    $helper->field = $field;
	    $helper->subject = $subject;
	    $tmp = $helper->$helperName($subject, $field, $value);
	    unset($helper->structure);
	    unset($helper->map);
	    unset($helper->field);
	    unset($helper->subject);
	    
	    return $tmp;
  }
}