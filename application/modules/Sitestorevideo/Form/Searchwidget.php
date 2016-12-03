<?php

/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitestore
 * @copyright  Copyright 2012-2013 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: Search.php 2013-09-02 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
class Sitestorevideo_Form_Searchwidget extends Engine_Form {

  protected $_searchForm;
  protected $_item;
  
  //Changes in onchange event function for mobile mode.
  protected $_hasMobileMode = false;

  public function getHasMobileMode() {
    return $this->_hasMobileMode;
  }

  public function setHasMobileMode($flage) {
    $this->_hasMobileMode = $flage;
    return $this;
  }
  public function init() {
    // Add custom elements
    $this
        ->setAttribs(array(
                'id' => 'filter_form',
                'class' => 'global_form_box',
        ))
        ->setAction(Zend_Controller_Front::getInstance()->getRouter()->assemble(array()))
        ->setMethod('GET')
    ;
    $this->_searchForm = Engine_Api::_()->getDbTable('searchformsetting', 'seaocore');
    
    $this->getAdditionalOptionsElement();

    parent::init();

    $this->loadDefaultDecorators();
    $view = Zend_Registry::isRegistered('Zend_View') ? Zend_Registry::get('Zend_View') : null;
    $this->setAction($view->url(array(), 'sitestorevideo_browse', true))->getDecorator('HtmlTag')->setOption('class', '');
  }

 
  public function getItem() {
    return $this->_item;
  }

  public function setItem(Core_Model_Item_Abstract $item) {
    $this->_item = $item;
    return $this;
  }


  public function getAdditionalOptionsElement() {
    $subform = new Zend_Form_SubForm(array(
                'name' => 'extra',
                'order' => 19999999,
                'decorators' => array(
                        'FormElements',
                )
        ));
    Engine_Form::enableForm($subform);


    $search_column = array();
    $row = $this->_searchForm->getFieldsOptions('sitestore', 'category_id');
    $coreContent_table = Engine_Api::_()->getDbtable('content', 'core');
    $select_content = $coreContent_table->select()->where('name = ?', 'sitestorevideo.search-sitestorevideo');
    $params = $coreContent_table->fetchAll($select_content);
    foreach($params as $widget) { 
      if(isset($widget['params']['search_column'])) {
				$search_column = $widget['params']['search_column'];
      }
		}

    $showTabArray = Zend_Controller_Front::getInstance()->getRequest()->getParam("search_column", array("0" => "1", "1" => "2", "2" => "3", "3" => "4","4" => "5"));
    
    
    $enabledColumns = array_intersect($search_column, $showTabArray);
    if(empty($enabledColumns)) {
      $enabledColumns = $showTabArray;
    }

    $i = -5000;

    //$row = $this->_searchForm->getFieldsOptions('sitestore', 'search');

     if (in_array("4", $enabledColumns)) {
      $this->addElement('Text', 'search_video', array(
              'label' => 'Video Keywords',
              'order' => $row->order - 4,
      ));

    }

     if (in_array("3", $enabledColumns)) {
      $this->addElement('Text', 'title', array(
              'label' => 'Store Title',
              'order' => $row->order - 3,
              'autocomplete' => 'off',
      ));
     }

		  if (in_array("1", $enabledColumns)) {
		  $viewer_id = Engine_Api::_()->user()->getViewer()->getIdentity();
      $show_multiOptions = array();
      
			if(!empty($viewer_id)) {
				$show_multiOptions["my_video"] = 'My Videos';
				$show_multiOptions["my_like"] = 'Videos of Stores I Like';
			}
			
      $sitestorePackageEnable = Engine_Api::_()->getApi('settings', 'core')->getSetting('sitestore.package.enable', 1);
      if($sitestorePackageEnable) {
      $show_multiOptions["sponsored video"] = 'Sponsored Videos';
      }
      $show_multiOptions["featured"] = "Featured Videos";
      $enableNetwork = Engine_Api::_()->getApi('settings', 'core')->getSetting('sitestore.network', 0);
      if (empty($enableNetwork)) {
        $viewer_id = Engine_Api::_()->user()->getViewer()->getIdentity();
        $networkMembershipTable = Engine_Api::_()->getDbtable('membership', 'network');
        $viewerNetwork = $networkMembershipTable->fetchRow(array('user_id = ?' => $viewer_id));

        if (!empty($viewerNetwork) || Engine_Api::_()->getApi('subCore', 'sitestore')->storeBaseNetworkEnable()) {
          $show_multiOptions['Networks'] = 'Only My Networks';
          $browseDefaulNetwork = Engine_Api::_()->getApi('settings', 'core')->getSetting('sitestore.default.show', 0);

          if (!isset($_GET['show']) && !empty($browseDefaulNetwork)) {
            $value_deault = 3;
          } elseif (isset($_GET['show'])) {
            $value_deault = $_GET['show'];
          }
        }
      }
 
      
      $this->addElement('Select', 'show', array(
              'label' => 'Show',
              'multiOptions' => $show_multiOptions,
              'onchange' => $this->gethasMobileMode() ? '' : 'searchSitestorevideos();',
              'order' => $row->order - 2,
      ));
   
  }

   if (in_array("2", $enabledColumns)) {
		$this->addElement('Select', 'orderby', array(
					'label' => 'Browse By',
					'multiOptions' => array(
              '' => '',
							'creation_date' => 'Most Recent',
							'view_count' => 'Most Viewed',
							'rating' => 'Most Rated',
							'comment_count' => 'Most Commented',
							'like_count' => 'Most Liked',
					),
					'order' => $row->order - 1,
					'onchange' => $this->gethasMobileMode() ? '' : 'searchSitestorevideos();',
			));
    }
    $row = $this->_searchForm->getFieldsOptions('sitestore', 'category_id');
      if (in_array("5", $enabledColumns)) {
	    // prepare categories
	    $categories = Engine_Api::_()->getDbTable('categories', 'sitestore')->getCategories();
	    if (count($categories) != 0) {
	      $categories_prepared[0] = "";
	      foreach ($categories as $category) {
	        $categories_prepared[$category->category_id] = $category->category_name;
	      }
	     	    
				if (Engine_API::_()->seaocore()->checkSitemobileMode('fullsite-mode')) {
					$onChangeEvent = "subcategoryies(this.value, '', '');";
					$categoryFiles = 'application/modules/Sitestore/views/scripts/_Subcategory.tpl';
				}
				else {
					$onChangeEvent = "sm4.core.category.set(this.value, 'subcategory');";
					$categoryFiles = 'application/modules/Sitestore/views/sitemobile/scripts/_Subcategory.tpl';
				}

	      // category field
	      $this->addElement('Select', 'category_id', array(
	              'label' => 'Store Category',
	              'order' => $row->order,
	              'multiOptions' => $categories_prepared,
	              'onchange' => $onChangeEvent,
	      ));
	    }
	    
  		$this->addElement('Select', 'subcategory_id', array(
          'RegisterInArrayValidator' => false,
          'order' => $row->order + 1,
          'decorators' => array(array('ViewScript', array(
                                  'viewScript' => $categoryFiles,
                                  'class' => 'form element')))
 			 ));

  		$this->addElement('Select', 'subsubcategory_id', array(
          'RegisterInArrayValidator' => false,
          'order' => $row->order + 1,
          'decorators' => array(array('ViewScript', array(
                                  'viewScript' => $categoryFiles,
                                  'class' => 'form element')))
 			 ));

      
    } else {
		    $this->addElement('Hidden', 'category_id', array(
		            'order' => $i--,
		    ));
		
		    $this->addElement('Hidden', 'subcategory_id', array(
		            'order' => $i--,
		    ));
        
        $this->addElement('Hidden', 'subsubcategory_id', array(
		            'order' => $i--,
		    ));
    }
    
    $this->addElement('Hidden', 'store', array(
            'order' => $i--,
    ));

    $this->addElement('Hidden', 'category', array(
            'order' => $i--,
    ));

    $this->addElement('Hidden', 'subcategory', array(
            'order' => $i--,
    ));

    $this->addElement('Hidden', 'subsubcategory', array(
            'order' => $i--,
    ));

    $this->addElement('Hidden', 'categoryname', array(
            'order' => $i--,
    ));

    $this->addElement('Hidden', 'subcategoryname', array(
            'order' => $i--,
    ));

    $this->addElement('Hidden', 'subsubcategoryname', array(
            'order' => $i--,
    ));

    // init to
    $this->addElement('Hidden', 'resource_id', array());

    $subform->addElement('Button', 'done', array(
            'label' => 'Search',
            'type' => 'submit',
            'ignore' => true,
    ));

    $this->addSubForm($subform, $subform->getName());

    return $this;
  }

}
?>