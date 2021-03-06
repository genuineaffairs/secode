<?php
/**
* SocialEngine
*
* @category   Application_Extensions
* @package    List
* @copyright  Copyright 2009-2010 BigStep Technologies Pvt. Ltd.
* @license    http://www.socialengineaddons.com/license/
* @version    $Id: Controller.php 6590 2010-12-31 9:40:21Z SocialEngineAddOns $
* @author     SocialEngineAddOns
*/
class List_Widget_TagcloudListController extends Engine_Content_Widget_Abstract {

  public function indexAction() {

		//HOW MANY TAGS WE HAVE TO SHOW
		$total_tags = $this->_getParam('itemCount', 20);

    //CONSTRUCTING TAG CLOUD
    $tag_array = array();
		$listTable = Engine_Api::_()->getDbtable('listings', 'list');
		$this->view->count_only = $listTable->getTagCloud($total_tags, 1);
		if($this->view->count_only <= 0) {
			return $this->setNoRender();
		}
    $tag_cloud_array = $listTable->getTagCloud($total_tags, 0);

    foreach ($tag_cloud_array as $vales) {
      $tag_array[$vales['text']] = $vales['Frequency'];
      $tag_id_array[$vales['text']] = $vales['tag_id'];
    }

    if (!empty($tag_array)) {
      $max_font_size = 18;
      $min_font_size = 12;
      $max_frequency = max(array_values($tag_array));
      $min_frequency = min(array_values($tag_array));
      $spread = $max_frequency - $min_frequency;
      if ($spread == 0) {
        $spread = 1;
      }
      $step = ($max_font_size - $min_font_size) / ($spread);

      $tag_data = array('min_font_size' => $min_font_size, 'max_font_size' => $max_font_size, 'max_frequency' => $max_frequency, 'min_frequency' => $min_frequency, 'step' => $step);

      $this->view->tag_data = $tag_data;
      $this->view->tag_id_array = $tag_id_array;
    }
    $this->view->tag_array = $tag_array;
		
		if(empty($this->view->tag_array)) {
			return $this->setNoRender();
		}
  }

}