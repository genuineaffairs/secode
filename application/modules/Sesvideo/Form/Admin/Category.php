<?php

/**
 * SocialEngineSolutions
 *
 * @category   Application_Sesvideo
 * @package    Sesvideo
 * @copyright  Copyright 2015-2016 SocialEngineSolutions
 * @license    http://www.socialenginesolutions.com/license/
 * @version    $Id: Category.php 2015-10-11 00:00:00 SocialEngineSolutions $
 * @author     SocialEngineSolutions
 */

class Sesvideo_Form_Admin_Category extends Engine_Form {

  protected $_field;

  public function init() {
    $this->setMethod('post');

    /*
      $type = new Zend_Form_Element_Hidden('type');
      $type->setValue('heading');
     */

    $label = new Zend_Form_Element_Text('label');
    $label->setLabel('Category Name')
            ->addValidator('NotEmpty')
            ->setRequired(true)
            ->setAttrib('class', 'text');


    $id = new Zend_Form_Element_Hidden('id');


    $this->addElements(array(
        //$type,
        $label,
        $id
    ));
    // Buttons
    $this->addElement('Button', 'submit', array(
        'label' => 'Add Category',
        'type' => 'submit',
        'ignore' => true,
        'decorators' => array('ViewHelper')
    ));

    $this->addElement('Cancel', 'cancel', array(
        'label' => 'cancel',
        'link' => true,
        'prependText' => ' or ',
        'href' => '',
        'onClick' => 'javascript:parent.Smoothbox.close();',
        'decorators' => array(
            'ViewHelper'
        )
    ));
    $this->addDisplayGroup(array('submit', 'cancel'), 'buttons');
    $button_group = $this->getDisplayGroup('buttons');

    // $this->addDisplayGroup(array('submit', 'cancel'), 'buttons');
  }

  public function setField($category) {
    $this->_field = $category;

    // Set up elements
    //$this->removeElement('type');
    $this->label->setValue($category->category_name);
    $this->id->setValue($category->category_id);
    $this->submit->setLabel('Edit Category');

    // @todo add the rest of the parameters
  }

}